//
//  OTRMatrixManager.m
//  ChatSecure
//
//  Created by Jerzy K on 11/10/15.
//  Copyright © 2015 Chris Ballinger. All rights reserved.
//

#import "OTRMatrixManager.h"
#import "OTRConstants.h"
#import "OTRDatabaseManager.h"
#import "OTRNotificationController.h"
#import "OTRBuddy.h"
#import "OTRMatrixMessage.h"

@implementation OTRMatrixManager

- (id) initWithAccount:(OTRAccount *)newAccount {
    if(self = [self init])
    {
        NSAssert([newAccount isKindOfClass:[OTRMatrixAccount class]], @"Must have Matrix account");
//         self.isRegisteringNewAccount = NO;
        _account = (OTRMatrixAccount *)newAccount;
        self.connectionStatus = OTRProtocolConnectionStatusDisconnected;
        
        // Setup the XMPP stream
        [self setupClient];
        
//         self.buddyTimers = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)setupClient
{
    _mxRestClient = [[MXRestClient alloc] initWithHomeServer:_account.homeURL
                     andOnUnrecognizedCertificateBlock:^BOOL(NSData *certificate) {
                         return true;
                     }];
}

- (void) fetchBuddies
{
    MXSession *session = [[MXSession alloc] initWithMatrixRestClient:self.mxRestClient];
    [session start:^{
        [[[OTRDatabaseManager sharedInstance] newConnection] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *  transaction) {
            
            [self listenToMessages:session];
            
            for (MXRoom *room in session.rooms) {
                OTRBuddy* buddy;
                buddy = [OTRBuddy fetchBuddyWithUsername:room.state.roomId
                                     withAccountUniqueId:self.account.uniqueId
                                             transaction:transaction];
                if (!buddy) {
                    buddy = [[OTRBuddy alloc] init];
                    buddy.username = room.state.roomId;
                    buddy.displayName = room.state.displayname;
                    buddy.accountUniqueId = self.account.uniqueId;
                    [buddy saveWithTransaction:transaction];
                }
            }
        }];
        
    } failure:^(NSError *error) {
        // code
    }];
}

- (void) listenToMessages:(MXSession*)session
{
    for (MXRoom *room in session.rooms) {
        [room listenToEvents:^(MXEvent *event, MXEventDirection direction, MXRoomState *roomState) {

            [[[OTRDatabaseManager sharedInstance] newConnection] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * transaction) {
//                 [transaction removeAllObjectsInCollection:[[OTRMessage class] collection]];
                __block bool found = false;
                
                [OTRMessage enumerateMessagesWithMessageId:event.eventId
                                               transaction:transaction usingBlock:^(OTRMessage *message, BOOL *stop) {
                                                   found = true;
                                               }];
                
                if (!found && event.eventType == MXEventTypeRoomMessage && [event.content[@"msgtype"] isEqualToString:@"m.text"]) {
                    
                    
                    OTRMatrixMessage* message = [[OTRMatrixMessage alloc] init];
                    message.messageId = event.eventId;
                    message.text = [event.content[@"body"] stringByTrimmingCharactersInSet:
                                    [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    message.incoming = ![event.sender isEqual:session.myUser.userId];
                    message.date = [[NSDate alloc] initWithTimeIntervalSince1970:event.originServerTs/1000];
                    message.buddyUniqueId =
                        [[OTRBuddy fetchBuddyWithUsername:room.state.roomId
                                      withAccountUniqueId:self.account.uniqueId
                                              transaction:transaction] uniqueId];
                    message.matrixSender = event.sender;
                    message.delivered = true;
                    __block OTRMessage *toRemove;
                    [OTRMessage enumerateMessagesNotMatrixWithTransaction:transaction usingBlock:^(OTRMessage *message2, BOOL *stop) {
                        // find matching local echo which are stored as OTRMessage instead of
                        // OTRMatrixMessage
                        if ([[message2.text
                              stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceAndNewlineCharacterSet]]
                             isEqual:message.text] &&
                            [message2.buddyUniqueId isEqual:message.buddyUniqueId]) {
                            toRemove = message2;
                        }
                    }];
                    
                    if (toRemove) {
                        [toRemove removeWithTransaction:transaction];
                    }
                    
                    [message saveWithTransaction:transaction];
                }
            }];
        }];
        
        // Reset the pagination start point to now
        [room resetBackState];
        
        [room paginateBackMessages:10 complete:^{
            
            // At this point, the SDK has finished to enumerate the events to the attached listeners
            
        } failure:^(NSError *error) {
        }];
    }
}

- (void) connectWithPassword:(NSString *)password userInitiated:(BOOL)userInitiated
{
    // Don't issue a reconnect if we're already connected and authenticated
/*    if ([self.xmppStream isConnected] && [self.xmppStream isAuthenticated]) {
        return;
    } */
//    self.userInitiatedConnection = userInitiated;
    [_mxRestClient loginWithUser:self.account.username
                    andPassword:password
     success:^(MXCredentials *credentials) {
         _mxRestClient = [[MXRestClient alloc] initWithCredentials:credentials
                                 andOnUnrecognizedCertificateBlock:^BOOL(NSData *certificate) {
                                     return true;
                                 }];
         
         self.connectionStatus = OTRProtocolConnectionStatusConnected;
         self.loginStatus = OTRLoginStatusAuthenticated;
         [[NSNotificationCenter defaultCenter]
          postNotificationName:kOTRProtocolLoginSuccess object:self];
         
         [self fetchBuddies];
     } failure:^(NSError *error) {
         //
     }];
//    if (self.userInitiatedConnection) {
    if (userInitiated) {
        [[OTRNotificationController sharedInstance] showAccountConnectingNotificationWithAccountName:self.account.username];
    }
}

-(void)connectWithPassword:(NSString *)password
{
    [self connectWithPassword:password userInitiated:NO];
}

- (void) sendMessage:(OTRMessage*)message
{
    NSString *text = message.text;
    
    if (text) {
        [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
            OTRBuddy *buddy = [message buddyWithTransaction:transaction];
            [_mxRestClient sendTextMessageToRoom:buddy.username
                                            text:text
                                         success:^(NSString *eventId) {
                                             
                                       } failure:^(NSError *error) {
                                           
                                       }];
        }];
    }
}

@end

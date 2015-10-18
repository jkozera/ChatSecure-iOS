//
//  OTRMatrixMessage+JSQMessageData.m
//  ChatSecure
//
//  Created by Jerzy K on 11/10/15.
//  Copyright © 2015 Chris Ballinger. All rights reserved.
//

#import "OTRDatabaseManager.h"
#import "OTRAccount.h"
#import "OTRBuddy.h"
#import "OTRMatrixMessage+JSQMessageData.h"

@implementation OTRMatrixMessage (JSQMessageData)

- (NSString *)senderDisplayName {
    if (self.isIncoming) {
        return self.matrixSender;
    } else {
        __block NSString* sender;
        [[OTRDatabaseManager sharedInstance].readOnlyDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
                OTRBuddy *buddy = [self buddyWithTransaction:transaction];
                OTRAccount *account = [buddy accountWithTransaction:transaction];
                if ([account.displayName length]) {
                    sender = account.displayName;
                } else {
                    sender = account.username;
                }
        }];
        return sender;
    }
}

@end

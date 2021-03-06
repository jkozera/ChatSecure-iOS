//
//  OTRLoginHandler.h
//  ChatSecure
//
//  Created by David Chiles on 6/17/15.
//  Copyright (c) 2015 Chris Ballinger. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OTRAccount, XLFormDescriptor;

@protocol OTRBaseLoginViewControllerHandlerProtocol <NSObject>

@required
- (void)performActionWithValidForm:(XLFormDescriptor *)form account:(OTRAccount *)account completion:(void (^)(OTRAccount *account, NSError *error))completion;
- (void)moveAccountValues:(OTRAccount *)account intoForm:(XLFormDescriptor *)form;

@end

@interface OTRLoginHandler : NSObject

+ (id<OTRBaseLoginViewControllerHandlerProtocol>)loginHandlerForAccount:(OTRAccount *)account;

@end

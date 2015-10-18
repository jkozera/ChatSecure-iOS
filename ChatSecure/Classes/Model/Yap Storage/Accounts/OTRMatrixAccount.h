//
//  OTRMatrixAccount.h
//  ChatSecure
//
//  Created by Jerzy K on 11/10/15.
//  Copyright © 2015 Chris Ballinger. All rights reserved.
//

#import <ChatSecureCore/ChatSecureCore.h>

@interface OTRMatrixAccount : OTRAccount

@property (nonatomic, strong) NSString *homeURL;
@property (nonatomic, strong) NSString *identityURL;
@property (nonatomic, strong) NSString *pushURL;

@end

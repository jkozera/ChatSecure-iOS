//
//  OTRMatrixAccount.m
//  ChatSecure
//
//  Created by Jerzy K on 11/10/15.
//  Copyright © 2015 Chris Ballinger. All rights reserved.
//

#import "OTRMatrixAccount.h"

#import "OTRConstants.h"
#import "OTRStrings.h"
#import "OTRLanguageManager.h"
#import "OTRMatrixManager.h"

@implementation OTRMatrixAccount

- (id)init
{
    if (self = [super init]) {
        self.autologin = YES;
        self.rememberPassword = YES;
    }
    return self;
}

- (OTRProtocolType)protocolType
{
    return OTRProtocolTypeMatrix;
}

- (NSString *)protocolTypeString
{
    return kOTRProtocolTypeMatrix;
}

- (NSString *)accountDisplayName
{
    return MATRIX_STRING;
}

+ (NSString *)collection
{
    return NSStringFromClass([OTRAccount class]);
}

- (Class)protocolClass {
    return [OTRMatrixManager class];
}

@end

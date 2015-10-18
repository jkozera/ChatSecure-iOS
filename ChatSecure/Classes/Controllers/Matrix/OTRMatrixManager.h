//
//  OTRMatrixManager.h
//  ChatSecure
//
//  Created by Jerzy K on 11/10/15.
//  Copyright © 2015 Chris Ballinger. All rights reserved.
//

#import "MatrixSDK.h"

#import "OTRMatrixAccount.h"
#import "OTRProtocol.h"

@interface OTRMatrixManager : NSObject <OTRProtocol>

@property (nonatomic, readonly) MXRestClient *mxRestClient;
@property (nonatomic, readonly) MXCredentials *credentials;
@property (nonatomic, strong, readonly) OTRMatrixAccount *account;
@property (nonatomic) OTRProtocolConnectionStatus connectionStatus;
@property (nonatomic) OTRLoginStatus loginStatus;


@end

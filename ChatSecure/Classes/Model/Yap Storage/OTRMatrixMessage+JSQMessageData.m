//
//  OTRMatrixMessage+JSQMessageData.m
//  ChatSecure
//
//  Created by Jerzy K on 11/10/15.
//  Copyright © 2015 Chris Ballinger. All rights reserved.
//

#import "OTRMatrixMessage+JSQMessageData.h"

@implementation OTRMatrixMessage (JSQMessageData)

- (NSString *)senderDisplayName {
    return self.matrixSender;
}

@end

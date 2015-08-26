//
//  LDSDKQQServiceImpl.h
//  TestThirdPlatform
//
//  Created by ss on 15/8/17.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDSDKAuthService.h"
#import "LDSDKRegisterService.h"
#import "LDSDKShareService.h"

@class QQBaseReq;
@class QQBaseResp;

typedef void(^LDSDKQQCallbackBlock)(QQBaseResp *resp);

@interface LDSDKQQServiceImpl : NSObject <LDSDKAuthService, LDSDKRegisterService, LDSDKShareService>

@end

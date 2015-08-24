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

#define kQQ_OPENID_KEY   @"openId"
#define kQQ_TOKEN_KEY    @"access_token"
#define kQQ_NICKNAME_KEY @"nickname"
#define kQQ_EXPIRADATE_KEY @"expirationDate"
#define kQQ_AVATARURL_KEY  @"figureurl_qq_2"

@class QQBaseReq;
@class QQBaseResp;

typedef void(^LDSDKQQCallbackBlock)(QQBaseResp *resp);

@interface LDSDKQQServiceImpl : NSObject <LDSDKAuthService, LDSDKRegisterService, LDSDKShareService>

@end

//
//  LDQQAuthService.h
//  TestThirdPlatform
//
//  Created by ss on 15/8/13.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDSDKAuthService.h"

#define kQQ_OPENID_KEY   @"openId"
#define kQQ_TOKEN_KEY    @"access_token"
#define kQQ_NICKNAME_KEY @"nickname"
#define kQQ_EXPIRADATE_KEY @"expirationDate"
#define kQQ_AVATARURL_KEY  @"figureurl_qq_2"

@interface LDQQAuthService : NSObject<LDSDKAuthService>

/*
 注册QQ平台appId
 */
+ (BOOL)registerQQPlatformAppId:(NSString *)appId;

- (BOOL)handleOauthUrl:(NSURL *)url;

@end

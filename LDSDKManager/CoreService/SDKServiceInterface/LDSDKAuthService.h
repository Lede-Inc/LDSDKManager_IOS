//
//  LDSDKAuthService.h
//  LDThirdLib
//
//  Created by ss on 15/8/12.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LDSDKLoginCallback)(NSDictionary *oauthInfo, NSDictionary *userInfo, NSError *error);

#define kWX_OPENID_KEY      @"openid"
#define kWX_NICKNAME_KEY    @"nickname"
#define kWX_AVATARURL_KEY   @"headimgurl"
#define kWX_ACCESSTOKEN_KEY @"access_token"

#define kQQ_OPENID_KEY   @"openId"
#define kQQ_TOKEN_KEY    @"access_token"
#define kQQ_NICKNAME_KEY @"nickname"
#define kQQ_EXPIRADATE_KEY @"expirationDate"
#define kQQ_AVATARURL_KEY  @"figureurl_qq_2"

@protocol LDSDKAuthService <NSObject>

- (BOOL)isLoginEnabledOnPlatform;

/*
登录
 */
- (void)loginToPlatformWithCallback:(LDSDKLoginCallback)callback;

/*
 退出登录
 */
- (void)logoutFromPlatform;

@end

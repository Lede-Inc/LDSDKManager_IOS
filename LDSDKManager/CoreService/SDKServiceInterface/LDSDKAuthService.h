//
//  LDSDKAuthService.h
//  LDThirdLib
//
//  Created by ss on 15/8/12.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LDSDKLoginCallback)(NSDictionary *oauthInfo, NSDictionary *userInfo, NSError *error);

//微信登陆，用户信息的Key
#define kWX_OPENID_KEY @"openid"
#define kWX_NICKNAME_KEY @"nickname"
#define kWX_AVATARURL_KEY @"headimgurl"
#define kWX_ACCESSTOKEN_KEY @"access_token"

// QQ登陆，用户信息的Key
#define kQQ_OPENID_KEY @"openId"
#define kQQ_TOKEN_KEY @"access_token"
#define kQQ_NICKNAME_KEY @"nickname"
#define kQQ_EXPIRADATE_KEY @"expirationDate"
#define kQQ_AVATARURL_KEY @"figureurl_qq_2"

@protocol LDSDKAuthService <NSObject>

/*!
 *  @brief  判断该平台是否支持登陆
 *
 *  @return 已安装返回YES，否则返回NO
 */
- (BOOL)isLoginEnabledOnPlatform;

/*!
 *  @brief  第三方登陆
 *
 *  @param callback 登陆回调
 */
- (void)loginToPlatformWithCallback:(LDSDKLoginCallback)callback;

/*!
 *  @brief  退出登陆，主要是QQ平台
 */
- (void)logoutFromPlatform;

@end

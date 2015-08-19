//
//  LDWechatAuthService.h
//  TestThirdPlatform
//
//  Created by ss on 15/8/13.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDSDKAuthService.h"

#define kWX_OPENID_KEY      @"openid"
#define kWX_NICKNAME_KEY    @"nickname"
#define kWX_AVATARURL_KEY   @"headimgurl"
#define kWX_ACCESSTOKEN_KEY @"access_token"

//#import "LDWXPlatformDelegate.h"

@interface LDWechatAuthService : NSObject<LDSDKAuthService>
//
//@property (nonatomic, weak) id<LDWXPlatformDelegate> delegate;

//注册appid及secret，供请求token使用
+ (BOOL)registerWXAppId:(NSString *)addId appSecret:(NSString *)secret;

@end

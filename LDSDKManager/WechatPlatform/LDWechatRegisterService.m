//
//  LDWechatRegisterService.m
//  LDThirdLib
//
//  Created by ss on 15/8/12.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import "LDWechatRegisterService.h"
#import "WXApi.h"
#import "LDWechatAuthService.h"
#import "LDSDKWXService.h"

@implementation LDWechatRegisterService

+ (BOOL)platformInstalled
{
    return [WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi];
}

+ (void)registerWithAppId:(NSString *)appid withAppSecret:(NSString *)appsecret withDescription:(NSString *)description
{
    [WXApi registerApp:appid withDescription:description];
    [LDWechatAuthService registerWXAppId:appid appSecret:appsecret];
}

+ (BOOL)handleResultUrl:(NSURL *)url
{
    return [[LDSDKWXService defaultService] handleOpenURL:url];
}

@end

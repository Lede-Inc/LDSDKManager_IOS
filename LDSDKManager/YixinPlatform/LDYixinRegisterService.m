//
//  LDYixinRegisterService.m
//  TestThirdPlatform
//
//  Created by ss on 15/8/14.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import "LDYixinRegisterService.h"
#import "YXApi.h"
#import "LDSDKYXService.h"

@implementation LDYixinRegisterService

+ (BOOL)platformInstalled
{
    return [YXApi isYXAppInstalled] && [YXApi isYXAppSupportApi];
}

+ (void)registerWithAppId:(NSString *)appid withAppSecret:(NSString *)appsecret withDescription:(NSString *)description
{
    [YXApi registerApp:appid];
}

+ (BOOL)handleResultUrl:(NSURL *)url
{
    return [[LDSDKYXService defaultService] handleOpenURL:url];
}

@end

//
//  LDWechatRegisterService.m
//  LDThirdLib
//
//  Created by ss on 15/8/12.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import "LDWechatRegisterService.h"
#import "LDSDKManager.h"

#import "WXApi.h"
#import "LDWechatAuthService.h"
#import "LDSDKWXService.h"

@implementation LDWechatRegisterService

+ (BOOL)platformInstalled
{
    return [WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi];
}

+(void) registerWithPlatformConfig:(NSDictionary *)config{
    if(config == nil || config.allKeys.count == 0) return;

    NSString *wxAppId = config[LDSDKConfigAppIdKey];
    NSString *wxAppSecret = config[LDSDKConfigAppSecretKey];
    NSString *wxDescription = config[LDSDKConfigAppDescriptionKey];
    if (wxAppId && wxAppSecret && [wxAppId length] && [wxAppSecret length]) {
        [WXApi registerApp:wxAppId withDescription:wxDescription];
        [LDWechatAuthService registerWXAppId:wxAppId appSecret:wxAppSecret];
    }
}

+ (BOOL)handleResultUrl:(NSURL *)url
{
    return [[LDSDKWXService defaultService] handleOpenURL:url];
}

@end

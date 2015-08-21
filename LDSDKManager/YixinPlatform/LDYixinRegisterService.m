//
//  LDYixinRegisterService.m
//  TestThirdPlatform
//
//  Created by ss on 15/8/14.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import "LDYixinRegisterService.h"
#import "LDSDKManager.h"

#import "YXApi.h"
#import "LDSDKYXService.h"

@implementation LDYixinRegisterService

+ (BOOL)platformInstalled
{
    return [YXApi isYXAppInstalled] && [YXApi isYXAppSupportApi];
}

+(void) registerWithPlatformConfig:(NSDictionary *)config{
    if(config == nil || config.allKeys.count == 0) return;

    NSString *yxAppId = config[LDSDKConfigAppIdKey];
//    NSString *yxAppSecret = config[LDSDKRegisterAppSecretKey];
    if (yxAppId && [yxAppId length]) {
        [YXApi registerApp:yxAppId];
    }
}

+ (BOOL)handleResultUrl:(NSURL *)url
{
    return [[LDSDKYXService defaultService] handleOpenURL:url];
}

@end

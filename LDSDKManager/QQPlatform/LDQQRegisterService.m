//
//  LDQQRegisterService.m
//  LDThirdLib
//
//  Created by ss on 15/8/13.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import <TencentOpenAPI/QQApi.h>
#import "LDSDKManager.h"

#import "LDQQRegisterService.h"
#import "LDQQAuthService.h"
#import "LDSDKQQService.h"

@implementation LDQQRegisterService

+ (BOOL)platformInstalled
{
    return [QQApi isQQInstalled] && [QQApi isQQSupportApi];
}

+(void) registerWithPlatformConfig:(NSDictionary *)config{
    if(config == nil || config.allKeys.count == 0) return;

    NSString *qqAppId = config[LDSDKRegisterAppIdKey];
    if (qqAppId && [qqAppId length]) {
        [LDQQAuthService registerQQPlatformAppId:qqAppId];
    }
}

+ (BOOL)handleResultUrl:(NSURL *)url
{
    return [[LDQQAuthService sharedService] handleOauthUrl:url] || [[LDSDKQQService defaultService] handleOpenURL:url];
}

@end

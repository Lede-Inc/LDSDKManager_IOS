//
//  LDSDKRegisterService.h
//  LDThirdLib
//
//  Created by ss on 15/8/12.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LDSDKRegisterService <NSObject>

+ (BOOL)platformInstalled;

+ (void)registerWithAppId:(NSString *)appid withAppSecret:(NSString *)appsecret withDescription:(NSString *)description;

@optional

+ (BOOL)handleResultUrl:(NSURL *)url;

@end

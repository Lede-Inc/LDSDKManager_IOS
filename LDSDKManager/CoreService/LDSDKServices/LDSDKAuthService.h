//
//  LDSDKAuthService.h
//  LDThirdLib
//
//  Created by ss on 15/8/12.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LDSDKLoginCallback)(NSDictionary *oauthInfo, NSDictionary *userInfo, NSError *error);

@protocol LDSDKAuthService <NSObject>

+ (instancetype)sharedService;

+ (BOOL)platformLoginEnabled;

/*
登录
 */
- (void)platformLoginWithCallback:(LDSDKLoginCallback)callback;

/*
 退出登录
 */
- (void)platformLogout;

@end

//
//  LDSDKRegisterService.h
//  LDThirdLib
//
//  Created by ss on 15/8/12.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

//应用注册SDK服务，配置信息的Key
FOUNDATION_EXTERN NSString *const LDSDKConfigAppIdKey;
FOUNDATION_EXTERN NSString *const LDSDKConfigAppSecretKey;
FOUNDATION_EXTERN NSString *const LDSDKConfigAppSchemeKey;
FOUNDATION_EXTERN NSString *const LDSDKConfigAppPlatformTypeKey;
FOUNDATION_EXTERN NSString *const LDSDKConfigAppDescriptionKey;

/*!
 *  @brief  第三方SDK注册、应用安装检测接口
 */
@protocol LDSDKRegisterService <NSObject>

@required

/*!
 *  @brief  每个注册SDK自行管理其服务单例
 *
 *  @return 返回SDK服务实现的单例
 */
+ (instancetype)sharedService;

/*!
 *  @brief  检测第三方SDK应用是否安装
 *
 *  @return 已安装返回YES，否则返回NO
 */
- (BOOL)isPlatformAppInstalled;

/*!
 *  @brief  注册获取第三方SDK使用权限
 */
- (void)registerWithPlatformConfig:(NSDictionary *)config;

/*!
 *  @brief  判断是否已经获取注册权限
 */
- (BOOL)isRegistered;

/*!
 *  @brief  统一处理第三方SDK应用的处理回调
 *
 *  @param url fixMe
 *
 *  @return 处理成功返回YES，否则返回NO
 */
- (BOOL)handleResultUrl:(NSURL *)url;

@end

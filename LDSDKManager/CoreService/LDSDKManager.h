//
//  LDSDKManager.h
//  TestThirdPlatform
//
//  Created by ss on 15/8/14.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import <Foundation/Foundation.h>
FOUNDATION_EXTERN NSString *const LDSDKConfigAppIdKey;
FOUNDATION_EXTERN NSString *const LDSDKConfigAppSecretKey;
FOUNDATION_EXTERN NSString *const LDSDKConfigAppSchemeKey;
FOUNDATION_EXTERN NSString *const LDSDKConfigAppPlatformTypeKey;
FOUNDATION_EXTERN NSString *const LDSDKConfigAppDescriptionKey;

FOUNDATION_EXTERN NSString *const LDShareDictTitleKey;
FOUNDATION_EXTERN NSString *const LDShareDictDescriptionKey;
FOUNDATION_EXTERN NSString *const LDShareDictImageUrlKey;
FOUNDATION_EXTERN NSString *const LDShareDictWapUrlKey;
FOUNDATION_EXTERN NSString *const LDShareDictTextKey;

/*!
 *  @brief  第三方SDK支付回调
 *
 *  @param signString 签名字符串
 *  @param error
 */
typedef void(^LDSDKPayCallback)(NSString *signString, NSError *error);

/*!
 *  @brief  第三方SDK分享回调
 *
 *  @param success 是否分享成功
 *  @param error
 */
typedef void(^LDSDKShareCallback)(BOOL success, NSError *error);

/*!
 *  @brief  第三方SDK登录回调
 *
 *  @param oauthInfo 登录口令信息
 *  @param userInfo  第三方用户基本信息
 *  @param error
 */
typedef void(^LDSDKLoginCallback)(NSDictionary *oauthInfo, NSDictionary *userInfo, NSError *error);


typedef NS_ENUM(NSUInteger, LDSDKPlatformType)
{
    LDSDKPlatformQQ = 1,             //QQ
    LDSDKPlatformWeChat,         //微信
    LDSDKPlatformYiXin,          //易信
    LDSDKPlatformAliPay,         //支付宝
};


typedef NS_ENUM(NSUInteger, LDSDKShareType)
{
    LDSDKShareToQQ,             //QQ
    LDSDKShareToQzone,          //QQ空间
    LDSDKShareToWeChat,         //微信
    LDSDKShareToWeChatTimeLine, //微信朋友圈
    LDSDKShareToYiXin,          //易信
    LDSDKShareToYiXinTimeline,  //易信朋友圈
    LDSDKShareToAliPay,         //支付宝
};


/*!
 *  @brief  LDSDKManager 第三方SDK集成管理（目前已经集成QQ、微信、易信、支付宝）
 */
@interface LDSDKManager : NSObject

+ (instancetype)sharedManager;

/**
 *  查询是否安装某个第三方SDK应用
 *
 *  @param type  第三方平台类型
 *
 *  @return 已安装返回YES，
 */
+ (BOOL)isAppInstalled:(LDSDKPlatformType)type;


/**
 *  配置所有客户端appkey、appsecret等信息
 */
+ (void)registerWithPlatformConfigList:(NSArray *)configList;


/**
 *  获取某应用是否已被注册
 *
 *  @param type  注册类型，整数值
 *
 *  @return YES则已注册
 */
+ (BOOL)isRegistered:(LDSDKPlatformType)type;



/**
 *  处理url返回
 *
 *  @param url       第三方应用的url回调
 *
 *  @return YES则处理成功
 */
+ (BOOL)handleOpenURL:(NSURL *)url;

/**
 *  支付
 *
 *  @param payType     支付类型，支付宝或微信
 *  @param orderString 签名后的订单信息字符串
 *  @param callback    回调
 */
- (void)payOrderWithType:(LDSDKPlatformType)payType orderString:(NSString *)orderString callback:(LDSDKPayCallback)callback;

/**
 *  获得支持的分享类型
 *
 *  @return 返回支持的结果，掩码
 */
- (NSArray *)availableShareTypeList;

/**
 *  第三方分享
 *
 *  @param type     分享类型
 *  @param dict     分享内容的字典，参照key
 *  @param complete 成功后的回调
 */
- (void)shareWithType:(LDSDKShareType)type withDict:(NSDictionary *)dict onComplete:(LDSDKShareCallback)complete;

/**
 *  判断是否支持这个分享
 *
 *  @param type 分享类型,整数值
 *
 *  @return 支持分享，返回YES，否则返回NO
 */
- (BOOL)isAvailableShareType:(LDSDKShareType)type;

/**
 *  判断是否支持这个登陆
 *
 *  @param type 登陆类型,整数值
 *
 *  @return 支持登陆，返回YES，否则返回NO
 */
- (BOOL)isPlatformLoginEnabled:(LDSDKPlatformType)type;

/**
 *  第三方登陆
 *
 *  @param type     登陆类型
 *  @param callback 登陆之后的回调，返回包括auth信息，用户信息以及错误信息
 */
- (void)loginFromPlatformType:(LDSDKPlatformType)type withCallback:(LDSDKLoginCallback)callback;

/**
 *  第三方登出
 *
 *  @param type     分享类型，目前只有QQ支持登出
 */
- (void)logoutFromPlatformType:(LDSDKPlatformType)type;

@end

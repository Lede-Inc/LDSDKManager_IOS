//
//  LDSDKManager.m
//  TestThirdPlatform
//
//  Created by ss on 15/8/14.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import "LDSDKManager.h"
#import "LDSDKRegisterService.h"
#import "LDSDKPayService.h"
#import "LDSDKAuthService.h"
#import "LDSDKShareService.h"
#import "LDSDKCommon.h"

NSString *const LDRegisterDictWXAppId         = @"weixinAppId";
NSString *const LDRegisterDictWXAppSecret     = @"weixinAppSecret";
NSString *const LDRegisterDictWXDescription   = @"weixinDescription";
NSString *const LDRegisterDictYXAppId         = @"yixinAppId";
NSString *const LDRegisterDictYXAppSecret     = @"yixinAppSecret";
NSString *const LDRegisterDictQQAppId         = @"qqAppId";
NSString *const LDRegisterDictQQAppKey        = @"qqAppKey";
NSString *const LDRegisterDictAliPayAppScheme = @"alipayAppScheme";

NSString *const LDShareDictTitleKey       = @"title";
NSString *const LDShareDictDescriptionKey = @"description";
NSString *const LDShareDictImageUrlKey    = @"imageurl";
NSString *const LDShareDictWapUrlKey      = @"webpageurl";
NSString *const LDShareDictTextKey      = @"text";


@implementation LDSDKManager

+ (instancetype)sharedService
{
    static LDSDKManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

/**
 *  是否安装客户端
 *
 *  @param type  安装类型，整数值
 *
 *  @return YES则已安装
 */
+ (BOOL)isAppInstalled:(LDSDKPlatformType)type
{
    if (type == LDSDKPlatformTypeWeChat || type == LDSDKPlatformTypeWeChatTimeLine) {
        Class wxClass = NSClassFromString(@"LDWechatRegisterService");
        if (wxClass) {
            return [wxClass platformInstalled];
        } else {
            return NO;
        }
    } else if (type == LDSDKPlatformTypeQQ || type == LDSDKPlatformTypeQzone) {
        Class qqClass = NSClassFromString(@"LDQQRegisterService");
        if (qqClass) {
            return [qqClass platformInstalled];
        } else {
            return NO;
        }
    } else if (type == LDSDKPlatformTypeYiXin || type == LDSDKPlatformTypeYiXinTimeline) {
        Class yxClass = NSClassFromString(@"LDYixinRegisterService");
        if (yxClass) {
            return [yxClass platformInstalled];
        } else {
            return NO;
        }
    }
    return YES;
}

/**
 *  获取某应用是否已被注册
 *
 *  @param type  注册类型，整数值
 *
 *  @return YES则已注册
 */
+ (BOOL)isRegistered:(LDSDKPlatformType)type
{
    switch (type) {
        case LDSDKPlatformTypeAliPay:
            return [[LDSDKCommon sharedInstance].aliPayScheme length];
        case LDSDKPlatformTypeQQ:
            return [[LDSDKCommon sharedInstance].qqAppId length]
            && [[LDSDKCommon sharedInstance].qqAppKey length];
        case LDSDKPlatformTypeWeChat:
            return [[LDSDKCommon sharedInstance].wxAppId length]
            && [[LDSDKCommon sharedInstance].wxAppSecret length];
        case LDSDKPlatformTypeYiXin:
            return [[LDSDKCommon sharedInstance].yxAppId length]
            && [[LDSDKCommon sharedInstance].yxAppSecret length];
        default:
            break;
    }
    return NO;
}

/**
 *  配置所有客户端appkey、appsecret等信息
 *
 *  @param dict       配置，包含wxappkey、wxappsecret
 *  @param description 配置描述，项目名称
 *
 *  @return YES则配置成功
 */
+ (BOOL)registerWithDictionary:(NSDictionary *)dict
{
    NSString *wxAppId = [dict objectForKey:LDRegisterDictWXAppId];
    NSString *wxAppSecret = [dict objectForKey:LDRegisterDictWXAppSecret];
    NSString *wxDescription = [dict objectForKey:LDRegisterDictWXDescription];
    NSString *yxAppId = [dict objectForKey:LDRegisterDictYXAppId];
    NSString *yxAppSecret = [dict objectForKey:LDRegisterDictYXAppSecret];
    NSString *qqAppId = [dict objectForKey:LDRegisterDictQQAppId];
    NSString *qqAppKey = [dict objectForKey:LDRegisterDictQQAppKey];
    NSString *aliPayScheme = [dict objectForKey:LDRegisterDictAliPayAppScheme];
    if (wxAppId && wxAppSecret && [wxAppId length] && [wxAppSecret length]) {
        Class wxClass = NSClassFromString(@"LDWechatRegisterService");
        if (wxClass) {
            [LDSDKCommon sharedInstance].wxAppId = wxAppId;
            [LDSDKCommon sharedInstance].wxAppSecret = wxAppSecret;
            [wxClass registerWithAppId:wxAppId withAppSecret:wxAppSecret withDescription:wxDescription];
        }
    }
    if (qqAppId && [qqAppId length]) {
        Class qqClass = NSClassFromString(@"LDQQRegisterService");
        if (qqClass) {
            [LDSDKCommon sharedInstance].qqAppId = qqAppId;
            [LDSDKCommon sharedInstance].qqAppKey = qqAppKey;
            [qqClass registerWithAppId:qqAppId withAppSecret:qqAppKey withDescription:@""];
        }
    }
    if (yxAppId && yxAppSecret && [yxAppId length] && [yxAppSecret length]) {
        Class yxClass = NSClassFromString(@"LDYixinRegisterService");
        if (yxClass) {
            [LDSDKCommon sharedInstance].yxAppId = yxAppId;
            [LDSDKCommon sharedInstance].yxAppSecret = yxAppSecret;
            [yxClass registerWithAppId:yxAppId withAppSecret:yxAppSecret withDescription:@""];
        }
    }
    if (aliPayScheme && [aliPayScheme length]) {
        Class aliClass = NSClassFromString(@"LDAliPayRegisterService");
        if (aliClass) {
            [LDSDKCommon sharedInstance].aliPayScheme = aliPayScheme;
            [aliClass registerWithAppId:aliPayScheme withAppSecret:aliPayScheme withDescription:@""];
        }
    }
    return YES;
}

/**
 *  处理url返回
 *
 *  @param url       第三方应用的url回调
 *
 *  @return YES则处理成功
 */
+ (BOOL)handleOpenURL:(NSURL *)url
{
    if ([[LDSDKManager sharedService] handlePayType:LDSDKPlatformTypeWeChat resultURL:url callback:NULL]) {
        return YES;
    }
    
    if([LDSDKManager handleOpenURL:url withType:LDSDKPlatformTypeQQ] ||
       [LDSDKManager handleOpenURL:url withType:LDSDKPlatformTypeWeChat] ||
       [LDSDKManager handleOpenURL:url withType:LDSDKPlatformTypeYiXin]) {
        return YES;
    }
    NSString *scheme = [[url scheme] lowercaseString];
    if ([scheme hasPrefix:[LDSDKCommon sharedInstance].aliPayScheme]) {
        [[LDSDKManager sharedService] handlePayType:LDSDKPlatformTypeAliPay resultURL:url callback:NULL];
        return YES;
    }
    
    return YES;
}

+ (BOOL)handleOpenURL:(NSURL *)url withType:(LDSDKPlatformType)type
{
    if (type == LDSDKPlatformTypeQQ) {
        Class qqClass = NSClassFromString(@"LDQQRegisterService");
        if (qqClass) {
            return [qqClass handleResultUrl:url];
        }
    } else if (type == LDSDKPlatformTypeWeChat) {
        Class wxClass = NSClassFromString(@"LDWechatRegisterService");
        if (wxClass) {
            return [wxClass handleResultUrl:url];
        }
    } else if (type == LDSDKPlatformTypeYiXin) {
        Class yxClass = NSClassFromString(@"LDYixinRegisterService");
        if (yxClass) {
            return [yxClass handleResultUrl:url];
        }
    }
    return NO;
}

/**
 *  支付
 *
 *  @param payType     支付类型，支付宝或微信
 *  @param orderString 签名后的订单信息字符串
 *  @param callback    回调
 */
- (void)payOrderWithType:(LDSDKPlatformType)payType orderString:(NSString *)orderString callback:(LDSDKPayCallback)callback
{
    if (payType == LDSDKPlatformTypeAliPay) {
        Class aliClass = NSClassFromString(@"LDAliPayService");
        if (aliClass) {
            [[aliClass sharedService] payOrderString:orderString callback:callback];
        }
    } else if (payType == LDSDKPlatformTypeWeChat) {
        Class wxClass = NSClassFromString(@"LDWechatPayService");
        if (wxClass) {
            [[wxClass sharedService] payOrderString:orderString callback:callback];
        }
    }
}

/**
 *  支付完成后结果的处理
 *
 *  @param result   支付结果
 *  @param callback 支付宝负责的回调
 */
- (BOOL)handlePayType:(LDSDKPlatformType)payType resultURL:(NSURL *)result callback:(void (^)(NSDictionary *))callback
{
    if (payType == LDSDKPlatformTypeAliPay) {
        Class aliClass = NSClassFromString(@"LDAliPayService");
        if (aliClass) {
            return [[aliClass sharedService] payProcessOrderWithPaymentResult:result standbyCallback:callback];
        }
    } else if (payType == LDSDKPlatformTypeWeChat) {
        Class wxClass = NSClassFromString(@"LDWechatPayService");
        if (wxClass) {
            return [[wxClass sharedService] payProcessOrderWithPaymentResult:result standbyCallback:callback];
        }
    }
    return NO;
}

/**
 *  获得支持的分享类型
 *
 *  @return 返回支持的结果，掩码
 */
- (NSArray *)availableShareTypeList
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if ([LDSDKManager isRegistered:LDSDKPlatformTypeQQ]) {
        [result addObject:[NSNumber numberWithUnsignedInteger:LDSDKPlatformTypeQQ]];
        [result addObject:[NSNumber numberWithUnsignedInteger:LDSDKPlatformTypeQzone]];
    }
    
    if ([LDSDKManager isRegistered:LDSDKPlatformTypeWeChat]) {
        [result addObject:[NSNumber numberWithUnsignedInteger:LDSDKPlatformTypeWeChat]];
        [result addObject:[NSNumber numberWithUnsignedInteger:LDSDKPlatformTypeWeChatTimeLine]];
    }
    
    if ([LDSDKManager isRegistered:LDSDKPlatformTypeYiXin]) {
        [result addObject:[NSNumber numberWithUnsignedInteger:LDSDKPlatformTypeYiXin]];
        [result addObject:[NSNumber numberWithUnsignedInteger:LDSDKPlatformTypeYiXinTimeline]];
    }
    
    return [NSArray arrayWithArray:result];
}

/**
 *  第三方分享
 *
 *  @param type     分享类型
 *  @param dict     分享内容的字典，参照key
 *  @param complete 成功后的回调
 */
- (void)shareWithType:(LDSDKPlatformType)type withDict:(NSDictionary *)dict onComplete:(LDSDKShareCallback)complete
{
    if (type == LDSDKPlatformTypeQQ) {
        Class qqClass = NSClassFromString(@"LDQQShareService");
        if (qqClass) {
            [[qqClass sharedService] shareWithDict:dict onComplete:complete];
        }
    } else if (type == LDSDKPlatformTypeQzone) {
        Class qqClass = NSClassFromString(@"LDQzoneShareService");
        if (qqClass) {
            [[qqClass sharedService] shareWithDict:dict onComplete:complete];
        }
    } else if (type == LDSDKPlatformTypeWeChat) {
        Class qqClass = NSClassFromString(@"LDWechatShareService");
        if (qqClass) {
            [[qqClass sharedService] shareWithDict:dict onComplete:complete];
        }
    } else if (type == LDSDKPlatformTypeWeChatTimeLine) {
        Class qqClass = NSClassFromString(@"LDWXTimelineShareService");
        if (qqClass) {
            [[qqClass sharedService] shareWithDict:dict onComplete:complete];
        }
    } else if (type == LDSDKPlatformTypeYiXin) {
        Class qqClass = NSClassFromString(@"LDYixinShareService");
        if (qqClass) {
            [[qqClass sharedService] shareWithDict:dict onComplete:complete];
        }
    } else if (type == LDSDKPlatformTypeYiXinTimeline) {
        Class qqClass = NSClassFromString(@"LDYXTimelineShareService");
        if (qqClass) {
            [[qqClass sharedService] shareWithDict:dict onComplete:complete];
        }
    }
}

/**
 *  判断是否支持这个分享
 *
 *  @param type 分享类型,整数值
 *
 *  @return 支持分享，返回YES，否则返回NO
 */
- (BOOL)isAvailableShareType:(LDSDKPlatformType)type
{
    if (type == LDSDKPlatformTypeQQ || type == LDSDKPlatformTypeQzone) {
        return [LDSDKManager isRegistered:LDSDKPlatformTypeQQ];
    } else if (type == LDSDKPlatformTypeWeChatTimeLine || type == LDSDKPlatformTypeWeChat) {
        return [LDSDKManager isRegistered:LDSDKPlatformTypeWeChat];
    } else if (type == LDSDKPlatformTypeYiXin || type == LDSDKPlatformTypeYiXinTimeline) {
        return [LDSDKManager isRegistered:LDSDKPlatformTypeYiXin];
    }
    return NO;
}

- (BOOL)isPlatformLoginEnabled:(LDSDKPlatformType)type
{
    if (type == LDSDKPlatformTypeQQ) {
        Class qqClass = NSClassFromString(@"LDQQAuthService");
        if (qqClass) {
            return [qqClass platformLoginEnabled];
        } else {
            return NO;
        }
    } else if (type == LDSDKPlatformTypeWeChat) {
        Class wxClass = NSClassFromString(@"LDWechatAuthService");
        if (wxClass) {
            return [wxClass platformLoginEnabled];
        } else {
            return NO;
        }
    }
    return NO;
}

- (void)loginFromPlatformType:(LDSDKPlatformType)type withCallback:(LDSDKLoginCallback)callback
{
    if (type == LDSDKPlatformTypeQQ) {
        Class qqClass = NSClassFromString(@"LDQQAuthService");
        if (qqClass) {
            [[qqClass sharedService] platformLoginWithCallback:callback];
        }
    } else if (type == LDSDKPlatformTypeWeChat) {
        Class wxClass = NSClassFromString(@"LDWechatAuthService");
        if (wxClass) {
            [[wxClass sharedService] platformLoginWithCallback:callback];
        }
    }
}

- (void)logoutFromPlatformType:(LDSDKPlatformType)type
{
    if (type == LDSDKPlatformTypeQQ) {
        Class qqClass = NSClassFromString(@"LDQQAuthService");
        if (qqClass) {
            [[qqClass sharedService] platformLogout];
        }
        
    } else if (type == LDSDKPlatformTypeQQ) {
        Class wxClass = NSClassFromString(@"LDWechatAuthService");
        if (wxClass) {
            [[wxClass sharedService] platformLogout];
        }
    }
}

@end

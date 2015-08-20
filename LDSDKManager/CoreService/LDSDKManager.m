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

NSString *const LDRegisterDictAppId         = @"appid";
NSString *const LDRegisterDictAppSecret     = @"appsecret";
NSString *const LDRegisterDictAppDescription   = @"description";
NSString *const LDRegisterDictAppKey        = @"appkey";
NSString *const LDRegisterDictAppScheme = @"appscheme";

NSString *const LDRegisterDictTypeWechat = @"wechat";
NSString *const LDRegisterDictTypeQQ = @"qq";
NSString *const LDRegisterDictTypeYixin = @"yixin";
NSString *const LDRegisterDictTypeAlipay = @"alipay";

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
    if (type == LDSDKPlatformWeChat) {
        Class wxClass = NSClassFromString(@"LDWechatRegisterService");
        if (wxClass) {
            return [wxClass platformInstalled];
        } else {
            return NO;
        }
    } else if (type == LDSDKPlatformQQ) {
        Class qqClass = NSClassFromString(@"LDQQRegisterService");
        if (qqClass) {
            return [qqClass platformInstalled];
        } else {
            return NO;
        }
    } else if (type == LDSDKPlatformYiXin) {
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
        case LDSDKPlatformAliPay:
            return [[LDSDKCommon sharedInstance].aliPayScheme length];
        case LDSDKPlatformQQ:
            return [[LDSDKCommon sharedInstance].qqAppId length]
            && [[LDSDKCommon sharedInstance].qqAppKey length];
        case LDSDKPlatformWeChat:
            return [[LDSDKCommon sharedInstance].wxAppId length]
            && [[LDSDKCommon sharedInstance].wxAppSecret length];
        case LDSDKPlatformYiXin:
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
    NSString *wxAppId = nil;
    NSString *wxAppSecret = nil;
    NSString *wxDescription = nil;
    if ([dict objectForKey:LDRegisterDictTypeWechat]) {
        wxAppId = [[dict objectForKey:LDRegisterDictTypeWechat] objectForKey:LDRegisterDictAppId];
        wxAppSecret = [[dict objectForKey:LDRegisterDictTypeWechat] objectForKey:LDRegisterDictAppSecret];
        wxDescription = [[dict objectForKey:LDRegisterDictTypeWechat] objectForKey:LDRegisterDictAppDescription];
        if (wxAppId && wxAppSecret && [wxAppId length] && [wxAppSecret length]) {
            Class wxClass = NSClassFromString(@"LDWechatRegisterService");
            if (wxClass) {
                [LDSDKCommon sharedInstance].wxAppId = wxAppId;
                [LDSDKCommon sharedInstance].wxAppSecret = wxAppSecret;
                [wxClass registerWithAppId:wxAppId withAppSecret:wxAppSecret withDescription:wxDescription];
            }
        }
    }
    
    NSString *yxAppId = nil;
    NSString *yxAppSecret = nil;
    if ([dict objectForKey:LDRegisterDictTypeYixin]) {
        yxAppId = [[dict objectForKey:LDRegisterDictTypeYixin] objectForKey:LDRegisterDictAppId];
        yxAppSecret = [[dict objectForKey:LDRegisterDictTypeYixin] objectForKey:LDRegisterDictAppSecret];
        if (yxAppId && yxAppSecret && [yxAppId length] && [yxAppSecret length]) {
            Class yxClass = NSClassFromString(@"LDYixinRegisterService");
            if (yxClass) {
                [LDSDKCommon sharedInstance].yxAppId = yxAppId;
                [LDSDKCommon sharedInstance].yxAppSecret = yxAppSecret;
                [yxClass registerWithAppId:yxAppId withAppSecret:yxAppSecret withDescription:@""];
            }
        }

    }
    
    NSString *qqAppId = nil;
    NSString *qqAppKey = nil;
    if ([dict objectForKey:LDRegisterDictTypeQQ]) {
        qqAppId = [[dict objectForKey:LDRegisterDictTypeQQ] objectForKey:LDRegisterDictAppId];
        qqAppKey = [[dict objectForKey:LDRegisterDictTypeQQ] objectForKey:LDRegisterDictAppKey];
        if (qqAppId && [qqAppId length]) {
            Class qqClass = NSClassFromString(@"LDQQRegisterService");
            if (qqClass) {
                [LDSDKCommon sharedInstance].qqAppId = qqAppId;
                [LDSDKCommon sharedInstance].qqAppKey = qqAppKey;
                [qqClass registerWithAppId:qqAppId withAppSecret:qqAppKey withDescription:@""];
            }
        }
    }
    
    NSString *aliPayScheme = nil;
    if ([dict objectForKey:LDRegisterDictTypeAlipay]) {
        aliPayScheme = [[dict objectForKey:LDRegisterDictTypeAlipay] objectForKey:LDRegisterDictAppScheme];
        if (aliPayScheme && [aliPayScheme length]) {
            Class aliClass = NSClassFromString(@"LDAliPayRegisterService");
            if (aliClass) {
                [LDSDKCommon sharedInstance].aliPayScheme = aliPayScheme;
                [aliClass registerWithAppId:aliPayScheme withAppSecret:aliPayScheme withDescription:@""];
            }
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
    if ([[LDSDKManager sharedService] handlePayType:LDSDKPlatformWeChat resultURL:url callback:NULL]) {
        return YES;
    }
    
    if([LDSDKManager handleOpenURL:url withType:LDSDKPlatformQQ] ||
       [LDSDKManager handleOpenURL:url withType:LDSDKPlatformWeChat] ||
       [LDSDKManager handleOpenURL:url withType:LDSDKPlatformYiXin]) {
        return YES;
    }
    NSString *scheme = [[url scheme] lowercaseString];
    if ([scheme hasPrefix:[LDSDKCommon sharedInstance].aliPayScheme]) {
        [[LDSDKManager sharedService] handlePayType:LDSDKPlatformAliPay resultURL:url callback:NULL];
        return YES;
    }
    
    return YES;
}

+ (BOOL)handleOpenURL:(NSURL *)url withType:(LDSDKPlatformType)type
{
    if (type == LDSDKPlatformQQ) {
        Class qqClass = NSClassFromString(@"LDQQRegisterService");
        if (qqClass) {
            return [qqClass handleResultUrl:url];
        }
    } else if (type == LDSDKPlatformWeChat) {
        Class wxClass = NSClassFromString(@"LDWechatRegisterService");
        if (wxClass) {
            return [wxClass handleResultUrl:url];
        }
    } else if (type == LDSDKPlatformYiXin) {
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
    if (payType == LDSDKPlatformAliPay) {
        Class aliClass = NSClassFromString(@"LDAliPayService");
        if (aliClass) {
            [[aliClass sharedService] payOrderString:orderString callback:callback];
        } else {
            if (callback) {
                NSError *errorTmp = [NSError errorWithDomain:@"WXpay" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"请先导入微信模块", @"NSLocalizedDescription", nil]];
                callback(nil, errorTmp);
                return;
            }
        }
    } else if (payType == LDSDKPlatformWeChat) {
        Class wxClass = NSClassFromString(@"LDWechatPayService");
        if (wxClass) {
            [[wxClass sharedService] payOrderString:orderString callback:callback];
        } else {
            if (callback) {
                NSError *errorTmp = [NSError errorWithDomain:@"Alipay" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"请先导入支付宝模块", @"NSLocalizedDescription", nil]];
                callback(nil, errorTmp);
                return;
            }
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
    if (payType == LDSDKPlatformAliPay) {
        Class aliClass = NSClassFromString(@"LDAliPayService");
        if (aliClass) {
            return [[aliClass sharedService] payProcessOrderWithPaymentResult:result standbyCallback:callback];
        }
    } else if (payType == LDSDKPlatformWeChat) {
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
    if ([LDSDKManager isRegistered:LDSDKPlatformQQ]) {
        [result addObject:[NSNumber numberWithUnsignedInteger:LDSDKShareToQQ]];
        [result addObject:[NSNumber numberWithUnsignedInteger:LDSDKShareToQzone]];
    }
    
    if ([LDSDKManager isRegistered:LDSDKPlatformWeChat]) {
        [result addObject:[NSNumber numberWithUnsignedInteger:LDSDKShareToWeChat]];
        [result addObject:[NSNumber numberWithUnsignedInteger:LDSDKShareToWeChatTimeLine]];
    }
    
    if ([LDSDKManager isRegistered:LDSDKPlatformYiXin]) {
        [result addObject:[NSNumber numberWithUnsignedInteger:LDSDKShareToYiXin]];
        [result addObject:[NSNumber numberWithUnsignedInteger:LDSDKShareToYiXinTimeline]];
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
- (void)shareWithType:(LDSDKShareType)type withDict:(NSDictionary *)dict onComplete:(LDSDKShareCallback)complete
{
    if (type == LDSDKShareToQQ) {
        Class qqClass = NSClassFromString(@"LDQQShareService");
        if (qqClass) {
            [[qqClass sharedService] shareWithDict:dict onComplete:complete];
        } else {
            if (complete) {
                NSError *errorTmp = [NSError errorWithDomain:@"qqshare" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"请先导入QQ模块", @"NSLocalizedDescription", nil]];
                complete(NO, errorTmp);
                return;
            }
        }
    } else if (type == LDSDKShareToQzone) {
        Class qzoneClass = NSClassFromString(@"LDQzoneShareService");
        if (qzoneClass) {
            [[qzoneClass sharedService] shareWithDict:dict onComplete:complete];
        } else {
            if (complete) {
                NSError *errorTmp = [NSError errorWithDomain:@"qzoneshare" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"请先导入QQ模块", @"NSLocalizedDescription", nil]];
                complete(NO, errorTmp);
                return;
            }
        }
    } else if (type == LDSDKShareToWeChat) {
        Class wxClass = NSClassFromString(@"LDWechatShareService");
        if (wxClass) {
            [[wxClass sharedService] shareWithDict:dict onComplete:complete];
        } else {
            if (complete) {
                NSError *errorTmp = [NSError errorWithDomain:@"wxshare" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"请先导入微信模块", @"NSLocalizedDescription", nil]];
                complete(NO, errorTmp);
                return;
            }
        }
    } else if (type == LDSDKShareToWeChatTimeLine) {
        Class wxtClass = NSClassFromString(@"LDWXTimelineShareService");
        if (wxtClass) {
            [[wxtClass sharedService] shareWithDict:dict onComplete:complete];
        } else {
            if (complete) {
                NSError *errorTmp = [NSError errorWithDomain:@"wxtshare" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"请先导入微信模块", @"NSLocalizedDescription", nil]];
                complete(NO, errorTmp);
                return;
            }
        }
    } else if (type == LDSDKShareToYiXin) {
        Class yxClass = NSClassFromString(@"LDYixinShareService");
        if (yxClass) {
            [[yxClass sharedService] shareWithDict:dict onComplete:complete];
        } else {
            if (complete) {
                NSError *errorTmp = [NSError errorWithDomain:@"yxshare" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"请先导入易信模块", @"NSLocalizedDescription", nil]];
                complete(NO, errorTmp);
                return;
            }
        }
    } else if (type == LDSDKShareToYiXinTimeline) {
        Class yxtClass = NSClassFromString(@"LDYXTimelineShareService");
        if (yxtClass) {
            [[yxtClass sharedService] shareWithDict:dict onComplete:complete];
        } else {
            if (complete) {
                NSError *errorTmp = [NSError errorWithDomain:@"yxtshare" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"请先导入易信模块", @"NSLocalizedDescription", nil]];
                complete(NO, errorTmp);
                return;
            }
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
- (BOOL)isAvailableShareType:(LDSDKShareType)type
{
    if (type == LDSDKShareToQQ || type == LDSDKShareToQzone) {
        return [LDSDKManager isRegistered:LDSDKPlatformQQ];
    } else if (type == LDSDKShareToWeChatTimeLine || type == LDSDKShareToWeChat) {
        return [LDSDKManager isRegistered:LDSDKPlatformWeChat];
    } else if (type == LDSDKShareToYiXin || type == LDSDKShareToYiXinTimeline) {
        return [LDSDKManager isRegistered:LDSDKPlatformYiXin];
    }
    return NO;
}

- (BOOL)isPlatformLoginEnabled:(LDSDKPlatformType)type
{
    if (type == LDSDKPlatformQQ) {
        Class qqClass = NSClassFromString(@"LDQQAuthService");
        if (qqClass) {
            return [LDSDKManager isAppInstalled:LDSDKPlatformQQ] &&
                                  [qqClass platformLoginEnabled] &&
                        [LDSDKManager isRegistered:LDSDKPlatformQQ];
        } else {
            return NO;
        }
    } else if (type == LDSDKPlatformWeChat) {
        Class wxClass = NSClassFromString(@"LDWechatAuthService");
        if (wxClass) {
            return [LDSDKManager isAppInstalled:LDSDKPlatformWeChat] &&
                                      [wxClass platformLoginEnabled] &&
                        [LDSDKManager isRegistered:LDSDKPlatformWeChat];
        } else {
            return NO;
        }
    }
    return NO;
}

- (void)loginFromPlatformType:(LDSDKPlatformType)type withCallback:(LDSDKLoginCallback)callback
{
    if (type == LDSDKPlatformQQ) {
        Class qqClass = NSClassFromString(@"LDQQAuthService");
        if (qqClass) {
            [[qqClass sharedService] platformLoginWithCallback:callback];
        }
    } else if (type == LDSDKPlatformWeChat) {
        Class wxClass = NSClassFromString(@"LDWechatAuthService");
        if (wxClass) {
            [[wxClass sharedService] platformLoginWithCallback:callback];
        }
    }
}

- (void)logoutFromPlatformType:(LDSDKPlatformType)type
{
    if (type == LDSDKPlatformQQ) {
        Class qqClass = NSClassFromString(@"LDQQAuthService");
        if (qqClass) {
            [[qqClass sharedService] platformLogout];
        }
        
    } else if (type == LDSDKPlatformWeChat) {
        Class wxClass = NSClassFromString(@"LDWechatAuthService");
        if (wxClass) {
            [[wxClass sharedService] platformLogout];
        }
    }
}

@end

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

NSString *const LDSDKConfigAppIdKey = @"kAppID";
NSString *const LDSDKConfigAppSecretKey = @"kAppSecret";
NSString *const LDSDKConfigAppSchemeKey = @"kAppScheme";
NSString *const LDSDKConfigAppPlatformTypeKey = @"kAppPlatformType";
NSString *const LDSDKConfigAppDescriptionKey   = @"kAppDescription";

NSString *const LDShareDictTitleKey       = @"title";
NSString *const LDShareDictDescriptionKey = @"description";
NSString *const LDShareDictImageUrlKey    = @"imageurl";
NSString *const LDShareDictWapUrlKey      = @"webpageurl";
NSString *const LDShareDictTextKey      = @"text";


//SDKManager管理的功能服务类型
typedef NS_ENUM(NSUInteger, LDSDKServiceType)
{
    LDSDKServiceRegister = 1,  //sdk应用注册服务
    LDSDKServicePay,           //sdk支付服务
    LDSDKServiceShare,         //sdk分享服务
    LDSDKServiceOAuth          //sdk第三方登录服务
};


static NSArray *sdkServiceConfigList = nil;

@implementation LDSDKManager

+ (instancetype)sharedManager
{
    static LDSDKManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


#pragma mark -
#pragma mark - SDK Register Interface

+ (BOOL)isAppInstalled:(LDSDKPlatformType)type
{
    Class registerServiceImplCls = [self getServiceProviderWithPlatformType:type serviceType:LDSDKServiceRegister];
    if(registerServiceImplCls != nil){
        return [registerServiceImplCls platformInstalled];
    } else {
        if (type == LDSDKPlatformAliPay) {
            return YES;
        } else {
            return NO;
        }
    }
}

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
 *  根据配置列表依次注册第三方SDK
 *
 *  @return YES则配置成功
 */
+ (void)registerWithPlatformConfigList:(NSArray *)configList;
{
    if(configList == nil || configList.count == 0) return;
    
    for(NSDictionary *onePlatformConfig in configList){
        LDSDKPlatformType platformType = [onePlatformConfig[LDSDKConfigAppPlatformTypeKey] intValue];
        Class registerServiceImplCls = [self getServiceProviderWithPlatformType:platformType serviceType:LDSDKServiceRegister];
        if(registerServiceImplCls != nil){
            [registerServiceImplCls registerWithPlatformConfig:onePlatformConfig];
        }
    }
}


#pragma mark -
#pragma mark - SDK Pay Interface

/**
 *  支付
 *
 *  @param payType     支付类型，支付宝或微信
 *  @param orderString 签名后的订单信息字符串
 *  @param callback    回调
 */
- (void)payOrderWithType:(LDSDKPlatformType)payType orderString:(NSString *)orderString callback:(LDSDKPayCallback)callback
{
    Class payServiceImplCls = [LDSDKManager getServiceProviderWithPlatformType:payType serviceType:LDSDKServicePay];
    if(payServiceImplCls != nil){
        [[payServiceImplCls sharedService] payOrderString:orderString callback:callback];
    } else {
        if (callback) {
            NSError *errorTmp = [NSError errorWithDomain:@"pay" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"该模块可能未导入或不支持支付功能", @"NSLocalizedDescription", nil]];
            callback(nil, errorTmp);
            return;
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
    Class payServiceImplCls = [LDSDKManager getServiceProviderWithPlatformType:payType serviceType:LDSDKServicePay];
    if(payServiceImplCls != nil){
        return [[payServiceImplCls sharedService] payProcessOrderWithPaymentResult:result standbyCallback:callback];
    }
    return NO;
}


#pragma mark -
#pragma mark - SDK Share Interface

- (NSArray *)availableSharePlatformList
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if ([LDSDKManager isRegistered:LDSDKPlatformQQ]) {
        [result addObject:[NSNumber numberWithUnsignedInteger:LDSDKPlatformQQ]];
    }
    
    if ([LDSDKManager isRegistered:LDSDKPlatformWeChat]) {
        [result addObject:[NSNumber numberWithUnsignedInteger:LDSDKPlatformWeChat]];
    }
    
    if ([LDSDKManager isRegistered:LDSDKPlatformYiXin]) {
        [result addObject:[NSNumber numberWithUnsignedInteger:LDSDKPlatformYiXin]];
    }
    
    return [NSArray arrayWithArray:result];
}

- (BOOL)isAvailableShareToPlatform:(LDSDKPlatformType)platformType;
{
    return [LDSDKManager isRegistered:platformType];
}


- (void)shareToPlatform:(LDSDKPlatformType)platformType
            shareModule:(LDSDKShareToModule)shareModule
               withDict:(NSDictionary *)dict
             onComplete:(LDSDKShareCallback)complete{
    Class shareServiceImplCls = [[self class] getServiceProviderWithPlatformType:platformType serviceType:LDSDKServiceShare];
    if(shareServiceImplCls != nil){
        [[shareServiceImplCls sharedService] shareWithDict:dict onComplete:complete];
    } else {
        if(complete){
            NSError *errorTmp = [NSError errorWithDomain:@"SDK分享组件" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"请先导入分享平台的SDK", @"NSLocalizedDescription", nil]];
            complete(NO, errorTmp);
        }
    }
}

#pragma mark -
#pragma mark - SDK Login Interface

- (BOOL)isPlatformLoginEnabled:(LDSDKPlatformType)type
{
    Class loginServiceImplCls = [LDSDKManager getServiceProviderWithPlatformType:type serviceType:LDSDKServiceOAuth];
    if(loginServiceImplCls != nil){
        return [LDSDKManager isAppInstalled:type] &&
               [loginServiceImplCls platformLoginEnabled] &&
               [LDSDKManager isRegistered:type];
    }
    return NO;
}

- (void)loginFromPlatformType:(LDSDKPlatformType)type withCallback:(LDSDKLoginCallback)callback
{
    Class loginServiceImplCls = [LDSDKManager getServiceProviderWithPlatformType:type serviceType:LDSDKServiceOAuth];
    if(loginServiceImplCls != nil){
        [[loginServiceImplCls sharedService] platformLoginWithCallback:callback];
    }
}

- (void)logoutFromPlatformType:(LDSDKPlatformType)type
{
    Class loginServiceImplCls = [LDSDKManager getServiceProviderWithPlatformType:type serviceType:LDSDKServiceOAuth];
    if(loginServiceImplCls != nil){
        [[loginServiceImplCls sharedService] platformLogout];
    }
}

#pragma mark -
#pragma mark - SDK Callback Interface

/**
 *  处理url返回
 *
 *  @param url       第三方应用的url回调
 *
 *  @return YES则处理成功
 */
+ (BOOL)handleOpenURL:(NSURL *)url
{
    if ([[LDSDKManager sharedManager] handlePayType:LDSDKPlatformWeChat resultURL:url callback:NULL]) {
        return YES;
    }

    if([LDSDKManager handleOpenURL:url withType:LDSDKPlatformQQ] ||
       [LDSDKManager handleOpenURL:url withType:LDSDKPlatformWeChat] ||
       [LDSDKManager handleOpenURL:url withType:LDSDKPlatformYiXin]) {
        return YES;
    }
    NSString *scheme = [[url scheme] lowercaseString];
    if ([scheme hasPrefix:[LDSDKCommon sharedInstance].aliPayScheme]) {
        [[LDSDKManager sharedManager] handlePayType:LDSDKPlatformAliPay resultURL:url callback:NULL];
        return YES;
    }

    return YES;
}

+ (BOOL)handleOpenURL:(NSURL *)url withType:(LDSDKPlatformType)type
{
    Class registerServiceImplCls = [self getServiceProviderWithPlatformType:type serviceType:LDSDKServiceRegister];
    if(registerServiceImplCls != nil){
        return [registerServiceImplCls handleResultUrl:url];
    }
    return NO;
}


#pragma mark - 
#pragma mark - Common Method

/**
 * 根据平台类型和服务类型获取服务提供者
 */
+(Class)getServiceProviderWithPlatformType:(LDSDKPlatformType)platformType serviceType:(LDSDKServiceType)serviceType{
    if(sdkServiceConfigList == nil){
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"SDKServiceConfig" ofType:@"plist"];
        sdkServiceConfigList = [[NSArray alloc] initWithContentsOfFile:plistPath];
    }

    Class serviceProvider = nil;
    for(NSDictionary *oneSDKServiceConfig in sdkServiceConfigList){
        //find the specified platform
        if([oneSDKServiceConfig[@"platformType"] intValue] == platformType){
            NSArray *configServiceList = oneSDKServiceConfig[@"configServiceList"];
            if(configServiceList != nil && configServiceList.count > 0){
                for(NSDictionary *configService in configServiceList){
                    //find the specified service
                    if([configService[@"serviceType"] intValue] == serviceType){
                        serviceProvider = NSClassFromString(configService[@"serviceProvider"]);
                        break;
                    }
                }//for
            }
            break;
        }//if
    }//for

    return serviceProvider;
}



@end

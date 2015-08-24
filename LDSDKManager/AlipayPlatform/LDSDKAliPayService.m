//
//  LDSDKAliPayService.m
//  LDSDKManager
//
//  Created by ss on 15/8/21.
//  Copyright (c) 2015年 张海洋. All rights reserved.
//

#import "LDSDKAliPayService.h"
#import <AlipaySDK/AlipaySDK.h>
#import "LDSDKCommon.h"

@implementation LDSDKAliPayService

+ (instancetype)sharedService
{
    static LDSDKAliPayService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


#pragma mark -
#pragma mark - 配置部分

- (BOOL)platformInstalled{
    return YES;
}


- (void)registerWithPlatformConfig:(NSDictionary *)config{
}


#pragma mark -
#pragma mark -  支付部分

-(void)payOrderString:(NSString *)orderString callback:(LDSDKPayCallback)callback
{
    NSLog(@"AliPay");
    [self aliPayOrderString:orderString callback:callback];
}

-(BOOL)payProcessOrderWithPaymentResult:(NSURL *)url standbyCallback:(void (^)(NSDictionary *))callback
{
    NSLog(@"alipayProcessOrder");
    [self aliPayProcessOrderWithPaymentResult:url standbyCallback:callback];
    return YES;
}


#pragma mark - alipay
- (void)aliPayOrderString:(NSString *)orderString callback:(LDSDKPayCallback)callback
{
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:[LDSDKCommon sharedInstance].aliPayScheme callback:^(NSDictionary *resultDic) {
        NSString *signString = [resultDic objectForKey:@"result"];
        NSString *memo = [resultDic objectForKey:@"memo"];
        NSInteger resultStatus = [[resultDic objectForKey:@"resultStatus"] integerValue];
        if (callback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (resultStatus==9000) {
                    callback(signString, nil);
                } else {
                    NSError *error = [NSError errorWithDomain:@"AliPay" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:memo, @"NSLocalizedDescription", nil]];
                    callback(signString, error);
                }
                
            });
        }
    }];
}

- (void)aliPayProcessOrderWithPaymentResult:(NSURL *)url standbyCallback:(void (^)(NSDictionary *resultDic))callback
{
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                              standbyCallback:callback];
}

@end

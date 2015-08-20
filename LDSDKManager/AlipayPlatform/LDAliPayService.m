//
//  LDAliPayService.m
//  LDThirdLib
//
//  Created by ss on 15/8/12.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import "LDAliPayService.h"
#import <AlipaySDK/AlipaySDK.h>
#import "LDSDKCommon.h"

@implementation LDAliPayService

+ (instancetype)sharedService
{
    static LDAliPayService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

-(void)payOrderString:(NSString *)orderString callback:(LDSDKPayCallback)callback
{
    NSLog(@"AliPay");
    [[LDAliPayService sharedService] aliPayOrderString:orderString callback:callback];
}

-(BOOL)payProcessOrderWithPaymentResult:(NSURL *)url standbyCallback:(void (^)(NSDictionary *))callback
{
    NSLog(@"alipayProcessOrder");
    [[LDAliPayService sharedService] aliPayProcessOrderWithPaymentResult:url standbyCallback:callback];
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

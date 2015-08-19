//
//  LDAliPayService.m
//  LDThirdLib
//
//  Created by ss on 15/8/12.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import "LDAliPayService.h"
#import <AlipaySDK/AlipaySDK.h>
#import "JSONKit.h"
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
    NSLog(@"orderString = %@", orderString);
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:[LDSDKCommon sharedInstance].aliPayScheme callback:^(NSDictionary *resultDic) {
        NSError *parseError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDic options:NSJSONWritingPrettyPrinted error:&parseError];
        NSString *resultString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *signString = [resultString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode][@"result"];
        if (callback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(signString, nil);
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

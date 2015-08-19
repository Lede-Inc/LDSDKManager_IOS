//
//  LDWechatPayService.m
//  LDThirdLib
//
//  Created by ss on 15/8/12.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import "LDWechatPayService.h"
#import "WXApi.h"
#import "NSString+LDSDKAdditions.h"
#import "NSDictionary+LDSDKAdditions.h"

@interface LDWechatPayService () <WXApiDelegate>
{
    BOOL _shouldHandleWXPay;
    LDSDKPayCallback _wxCallback;
}
@end

@implementation LDWechatPayService

+ (instancetype)sharedService
{
    static LDWechatPayService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

-(void)payOrderString:(NSString *)orderString callback:(LDSDKPayCallback)callback
{
    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]) {
        if (callback) {
            NSError *error = [NSError errorWithDomain:@"wxPay" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"请先安装微信客户端", @"NSLocalizedDescription", nil]];
            callback(nil, error);
        }
        return;
    }
    [[LDWechatPayService sharedService] wxPayOrderString:orderString callback:callback];
}

-(BOOL)payProcessOrderWithPaymentResult:(NSURL *)url standbyCallback:(void (^)(NSDictionary *))callback
{
    if (_shouldHandleWXPay) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    return NO;
}

- (void)wxPayOrderString:(NSString *)orderString callback:(LDSDKPayCallback)callback
{
    NSDictionary *orderDict = [orderString urlParamsDecodeDictionary];
    
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = [[[orderDict stringForKey:@"partnerId"] URLDecodedString] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    request.prepayId = [[[orderDict stringForKey:@"prepayId"] URLDecodedString] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    request.package = [[[orderDict stringForKey:@"packageValue"] URLDecodedString] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    request.nonceStr = [[[orderDict stringForKey:@"nonceStr"] URLDecodedString] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSString *time = [[[orderDict stringForKey:@"timeStamp"] URLDecodedString] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    request.timeStamp = (UInt32)[time longLongValue];
    request.sign = [[[orderDict stringForKey:@"weixinSign"] URLDecodedString] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    _shouldHandleWXPay = YES;
    BOOL result = [WXApi sendReq:request];
    
    if (!result) {
        _shouldHandleWXPay = NO;
        if (callback) {
            NSError *error = [NSError errorWithDomain:@"wxPay" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"无法支付", @"NSLocalizedDescription", nil]];
            callback(nil, error);
        }
    }
    
    _wxCallback = callback;
}

#pragma mark WXPayDelegate
- (void)onReq:(BaseReq*)req
{
    // do nothing
    _shouldHandleWXPay = NO;
}

- (void)onResp:(BaseResp*)resp
{
    if (_wxCallback) {
        if ([resp isKindOfClass:[PayResp class]]) {
            PayResp *pResp = (PayResp *)resp;
            _wxCallback(pResp.returnKey, nil);
        } else {
            NSError *error = [NSError errorWithDomain:@"wxPay" code:resp.errCode userInfo:[NSDictionary dictionaryWithObjectsAndKeys:resp.errStr, @"NSLocalizedDescription", nil]];
            _wxCallback(nil, error);
        }
        _wxCallback = NULL;
    }
    
    _shouldHandleWXPay = NO;
}

@end

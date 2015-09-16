//
//  LDSDKPayService.h
//  LDThirdLib
//
//  Created by ss on 15/8/12.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LDSDKPayCallback)(NSString *signString, NSError *error);

@protocol LDSDKPayService <NSObject>

/**
 *  请求支付
 *
 *  @param orderString 支付的订单串
 *  @param callback    回调方法
 */
- (void)payOrder:(NSString *)orderString callback:(LDSDKPayCallback)callback;

/**
 *  回调处理
 *
 *  @param url      回调的url
 *  @param callback 处理的回调方法
 */
- (BOOL)payProcessOrderWithPaymentResult:(NSURL *)url
                         standbyCallback:(void (^)(NSDictionary *resultDic))callback;

@end

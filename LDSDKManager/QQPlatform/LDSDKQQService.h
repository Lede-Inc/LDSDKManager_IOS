//
//  LDSDKQQService.h
//  TestThirdPlatform
//
//  Created by ss on 15/8/17.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/QQApiInterface.h>

typedef void(^LDSDKQQCallbackBlock)(QQBaseResp *resp);

@interface LDSDKQQService : NSObject

+ (instancetype)defaultService;

- (QQApiSendResultCode)sendReq:(QQBaseReq *)req shareModule:(NSUInteger)shareModule callback:(LDSDKQQCallbackBlock)callbackBlock;

- (BOOL)handleOpenURL:(NSURL *)url;

@end

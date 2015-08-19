//
//  LDSDKWXService.h
//  Pods
//
//  Created by yangning on 15-1-29.
//
//

#import <Foundation/Foundation.h>

@class BaseReq;
@class BaseResp;

typedef void(^LDSDKWXCallbackBlock)(BaseResp *resp);

@interface LDSDKWXService : NSObject

+ (instancetype)defaultService;

- (BOOL)sendReq:(BaseReq *)req callback:(LDSDKWXCallbackBlock)callbackBlock;

- (BOOL)handleOpenURL:(NSURL *)url;

@end

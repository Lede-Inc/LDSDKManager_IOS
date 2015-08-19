//
//  LDSDKYXService.h
//  Pods
//
//  Created by yangning on 15-1-30.
//
//

#import <Foundation/Foundation.h>

@class YXBaseReq;
@class YXBaseResp;

typedef void(^LDSDKYXCallbackBlock)(YXBaseResp *resp);

@interface LDSDKYXService : NSObject

+ (instancetype)defaultService;

- (BOOL)sendReq:(YXBaseReq *)req callback:(LDSDKYXCallbackBlock)callbackBlock;

- (BOOL)handleOpenURL:(NSURL *)url;

@end

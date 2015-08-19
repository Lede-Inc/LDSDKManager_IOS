//
//  LDSDKYXService.m
//  Pods
//
//  Created by yangning on 15-1-30.
//
//

#import "LDSDKYXService.h"
#import "YXApi.h"

@interface LDSDKYXService ()<YXApiDelegate>

@property (nonatomic, copy) LDSDKYXCallbackBlock callbackBlock;

@end

@implementation LDSDKYXService

+ (instancetype)defaultService
{
    static LDSDKYXService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    return _sharedInstance;
}

- (BOOL)sendReq:(YXBaseReq *)req callback:(LDSDKYXCallbackBlock)callbackBlock
{
    self.callbackBlock = callbackBlock;
    return [YXApi sendReq:req];
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    return [YXApi handleOpenURL:url delegate:self];
}

#pragma mark YXApiDelegate

- (void)onReceiveRequest:(YXBaseReq *)req
{
#ifdef DEBUG
    NSLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
#endif
}

- (void)onReceiveResponse:(YXBaseResp *)resp
{
#ifdef DEBUG
    NSLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
#endif
    
    if (self.callbackBlock) {
        self.callbackBlock(resp);
    }
}

@end

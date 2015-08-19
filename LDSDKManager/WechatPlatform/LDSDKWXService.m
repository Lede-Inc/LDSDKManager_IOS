//
//  LDSDKWXService.m
//  Pods
//
//  Created by yangning on 15-1-29.
//
//

#import "LDSDKWXService.h"
#import "WXApi.h"

@interface LDSDKWXService ()<WXApiDelegate>

@property (nonatomic, copy) LDSDKWXCallbackBlock callbackBlock;

@end

@implementation LDSDKWXService

+ (instancetype)defaultService
{
    static LDSDKWXService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    return _sharedInstance;
}

- (BOOL)sendReq:(BaseReq *)req callback:(LDSDKWXCallbackBlock)callbackBlock
{
    self.callbackBlock = callbackBlock;
    return [WXApi sendReq:req];
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

#pragma mark - WXApiDelegate

- (void)onReq:(BaseReq *)req
{
#ifdef DEBUG
    NSLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
#endif
}

- (void)onResp:(BaseResp *)resp
{
#ifdef DEBUG
    NSLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
#endif
    
    if (self.callbackBlock) {
        self.callbackBlock(resp);
    }
}

@end

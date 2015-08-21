//
//  LDSDKQQService.m
//  TestThirdPlatform
//
//  Created by ss on 15/8/17.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import "LDSDKQQService.h"

@interface LDSDKQQService ()<QQApiInterfaceDelegate>

@property (nonatomic, copy) LDSDKQQCallbackBlock callbackBlock;

@end

@implementation LDSDKQQService

+ (instancetype)defaultService
{
    static LDSDKQQService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    return _sharedInstance;
}

- (QQApiSendResultCode)sendReq:(QQBaseReq *)req shareModule:(NSUInteger)shareModule callback:(LDSDKQQCallbackBlock)callbackBlock
{
    self.callbackBlock = callbackBlock;
    if (shareModule == 1) {
        return [QQApiInterface sendReq:req];
    } else if (shareModule == 2) {
        return [QQApiInterface SendReqToQZone:req];
    } else {
        return EQQAPIMESSAGETYPEINVALID;
    }
    
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    return [QQApiInterface handleOpenURL:url delegate:self];
}

#pragma mark - WXApiDelegate

- (void)onReq:(QQBaseReq *)req
{
#ifdef DEBUG
    NSLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
#endif
}

- (void)onResp:(QQBaseResp *)resp
{
#ifdef DEBUG
    NSLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
#endif
    
    if (self.callbackBlock) {
        self.callbackBlock(resp);
    }
}

-(void)isOnlineResponse:(NSDictionary *)response
{
#ifdef DEBUG
    NSLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
#endif
}

@end

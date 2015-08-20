//
//  LDQQAuthService.m
//  TestThirdPlatform
//
//  Created by ss on 15/8/13.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "LDQQAuthService.h"


#define kQQPlatformLogin @"login_qq"

static NSArray *_permissions = nil;

@interface LDQQAuthService () <TencentSessionDelegate>

@property (nonatomic, assign) BOOL isLogining;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) TencentOAuth *tencentOAuth;
@property (nonatomic, strong) NSString *appId;
@property (copy) void(^MyBlock)(NSDictionary *oauthInfo, NSDictionary *userInfo, NSError *error);

@end

@implementation LDQQAuthService

+ (instancetype)sharedService
{
    static LDQQAuthService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _isLogining = NO;
        _permissions = [NSArray arrayWithObjects:
                        kOPEN_PERMISSION_GET_USER_INFO,
                        kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                        nil];
    }
    return self;
}

+ (BOOL)registerQQPlatformAppId:(NSString *)appId
{
    NSLog(@"register appid = %@", appId);
    LDQQAuthService *instance = [self sharedService];
    if (instance) {
        instance.tencentOAuth = [[TencentOAuth alloc] initWithAppId:appId
                                                        andDelegate:instance];
        instance.appId = appId;
        return YES;
    }
    return NO;
}

- (BOOL)handleOauthUrl:(NSURL *)url
{
    return [TencentOAuth HandleOpenURL:url];
}

+(BOOL)platformLoginEnabled
{
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:kQQPlatformLogin];
    if (string.length == 0) {
        return YES;
    } else {
        return [string boolValue];
    }
}

-(void)platformLoginWithCallback:(LDSDKLoginCallback)callback
{
    if (![QQApi isQQInstalled] || ![QQApi isQQSupportApi]) {
        NSError *errorTmp = [NSError errorWithDomain:@"QQLogin" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"请先安装QQ客户端", @"NSLocalizedDescription", nil]];
        if (callback) {
            callback(nil, nil, errorTmp);
        }
        return;
    }
    if ([QQApi isQQInstalled]) {//手机QQ登录流程
        NSLog(@"login by QQ oauth = %@", self.tencentOAuth);
        if (callback) {
            self.MyBlock = callback;
        }
        self.error = nil;
        self.isLogining = YES;
        if (!self.tencentOAuth) {
            NSLog(@"tencentOauth && permissions = %@", _permissions);
            self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:self.appId
                                                        andDelegate:self];
        }
        //此处可set Token、oppenId、有效期 等参数
        [self.tencentOAuth authorize:_permissions];
    }}

-(void)platformLogout
{
    
    [self.tencentOAuth logout:self];
    self.MyBlock = nil;
    self.tencentOAuth = nil;
}

#pragma mark - TencentLoginDelegate
//登录成功后的回调
- (void)tencentDidLogin
{
    NSLog(@"did login");
    self.isLogining = NO;
    if (self.tencentOAuth.accessToken && 0 != [self.tencentOAuth.accessToken length])
    {
        //NSLog(@"QQ授权信息：\n%@\n%@\n%@",self.tencentOAuth.accessToken,self.tencentOAuth.expirationDate,self.tencentOAuth.openId);
        NSMutableDictionary *oauthInfo = [NSMutableDictionary dictionary];
        [oauthInfo setObject:self.tencentOAuth.accessToken forKey:kQQ_TOKEN_KEY];
        if (self.tencentOAuth.expirationDate) {
            [oauthInfo setObject:self.tencentOAuth.expirationDate forKey:kQQ_EXPIRADATE_KEY];
        }
        if (self.tencentOAuth.openId) {
            [oauthInfo setObject:self.tencentOAuth.openId forKey:kQQ_OPENID_KEY];
        }
//        if ([self.delegate respondsToSelector:@selector(qqSuccessGetOAuthInfo:)]) {
//            [self.delegate qqSuccessGetOAuthInfo:oauthInfo];
//        }
        if (self.MyBlock) {
            self.MyBlock(oauthInfo, nil, nil);
        }
        [self.tencentOAuth getUserInfo];
        
    } else {//登录失败，没有获取授权accesstoken
        self.error = [NSError errorWithDomain:@"QQLogin" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"登录失败", @"NSLocalizedDescription", nil]];
//        if ([self.delegate respondsToSelector:@selector(qqFailGetInfoWithError:)]) {
//            [self.delegate qqFailGetInfoWithError:self.error];
//        }
        if (self.MyBlock) {
            self.MyBlock(nil, nil, self.error);
        }
    }
}

//登录失败后的回调
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    NSLog(@"did not login");
    self.isLogining = NO;
    self.error = [NSError errorWithDomain:@"QQLogin" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"登录失败", @"NSLocalizedDescription", nil]];
//    if ([self.delegate respondsToSelector:@selector(qqFailGetInfoWithError:)]) {
//        [self.delegate qqFailGetInfoWithError:self.error];
//    }
    if (self.MyBlock) {
        self.MyBlock(nil, nil, self.error);
    }
    if (cancelled) {//NSLog(@"用户取消登录");
    } else {//NSLog(@"登录失败");
    }
}

//登录时网络有问题的回调
- (void)tencentDidNotNetWork
{
    NSLog(@"did not network");
    self.isLogining = NO;
    self.error = [NSError errorWithDomain:@"QQLogin" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"请检查网络", @"NSLocalizedDescription", nil]];
//    if ([self.delegate respondsToSelector:@selector(qqFailGetInfoWithError:)]) {
//        [self.delegate qqFailGetInfoWithError:self.error];
//    }
    if (self.MyBlock) {
        self.MyBlock(nil, nil, self.error);
    }
}

#pragma mark - TencentSessionDelegate
//退出登录的回调
- (void)tencentDidLogout
{
    NSLog(@"退出登录");
}
//API授权不够，需增量授权
- (BOOL)tencentNeedPerformIncrAuth:(TencentOAuth *)tencentOAuth
                   withPermissions:(NSArray *)permissions
{
    NSLog(@"wufashouquan");
    return YES;
}

//获取用户个人信息回调
- (void)getUserInfoResponse:(APIResponse*) response
{
    NSLog(@"getUserInfo %d  %@ \n %@", response.retCode, response.message, response.errorMsg);
    if (response.retCode == URLREQUEST_FAILED) {//失败
//        if ([self.delegate respondsToSelector:@selector(qqFailGetInfoWithError:)]) {
//            self.error = [NSError errorWithDomain:@"QQLogin" code:response.detailRetCode userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"登录失败", @"NSLocalizedDescription", nil]];
//            [self.delegate qqFailGetInfoWithError:self.error];
//        }
        if (self.MyBlock) {
            self.MyBlock(nil, nil, self.error);
        }
    } else if (response.retCode == URLREQUEST_SUCCEED){//成功用户资料
        if (response.detailRetCode == kOpenSDKErrorSuccess) {
            if (self.MyBlock) {//([self.delegate respondsToSelector:@selector(qqSuccessGetOAuthInfo:userInfo:)]) {
                NSMutableDictionary *oauthInfo = [NSMutableDictionary dictionary];
                [oauthInfo setObject:self.tencentOAuth.accessToken forKey:kQQ_TOKEN_KEY];
                if (self.tencentOAuth.expirationDate) {
                    [oauthInfo setObject:self.tencentOAuth.expirationDate forKey:kQQ_EXPIRADATE_KEY];
                }
                if (self.tencentOAuth.openId) {
                    [oauthInfo setObject:self.tencentOAuth.openId forKey:kQQ_OPENID_KEY];
                }
                
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                NSString *nickName = [response.jsonResponse objectForKey:kQQ_NICKNAME_KEY];
                NSString *avatarUrl = [response.jsonResponse objectForKey:kQQ_AVATARURL_KEY];
                if (nickName && [nickName length]) {
                    [userInfo setObject:nickName forKey:kQQ_NICKNAME_KEY];
                }
                if (avatarUrl) {
                    [userInfo setObject:avatarUrl forKey:kQQ_AVATARURL_KEY];
                }
                
//                [self.delegate qqSuccessGetOAuthInfo:oauthInfo userInfo:userInfo];
                self.MyBlock(oauthInfo, userInfo, nil);
            }
        } else {//获取失败
            self.error = [NSError errorWithDomain:@"QQLogin" code:response.detailRetCode userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"登录失败", @"NSLocalizedDescription", nil]];
//            if ([self.delegate respondsToSelector:@selector(qqFailGetInfoWithError:)]) {
//                [self.delegate qqFailGetInfoWithError:self.error];
//            }
            if (self.MyBlock) {
                self.MyBlock(nil, nil, self.error);
            }
        }
    }
}

@end

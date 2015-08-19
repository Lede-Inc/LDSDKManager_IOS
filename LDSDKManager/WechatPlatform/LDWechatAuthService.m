//
//  LDWechatAuthService.m
//  TestThirdPlatform
//
//  Created by ss on 15/8/13.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import "LDWechatAuthService.h"
#import "WXApi.h"
#import "LDSDKWXService.h"
#import "LDSDKAFHTTPRequestOperation.h"
#import "LDSDKHttpClient.h"

#define kWXPlatformLogin  @"login_wx"
#define kWX_APPID_KEY     @"appid"
#define kWX_APPSECRET_KEY @"secret"
#define kWX_APPCODE_KEY   @"code"

#define kWX_GET_TOKEN_URL @"https://api.weixin.qq.com/sns/oauth2/access_token"
#define kWX_GET_USERINFO_URL @"https://api.weixin.qq.com/sns/userinfo"

@interface LDWechatAuthService ()

@property (nonatomic, weak) NSError *error;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appSecret;
@property (nonatomic, strong) NSDictionary *oauthDict;
@property (copy) void(^MyBlock)(NSDictionary *oauthInfo, NSDictionary *userInfo, NSError *error);

@end

@implementation LDWechatAuthService


+ (instancetype)sharedService
{
    static LDWechatAuthService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.error = nil;
        self.oauthDict = nil;
    }
    return self;
}

+ (BOOL)isMobileWXInstalled
{
    return [WXApi isWXAppInstalled];
}

+(BOOL)platformLoginEnabled
{
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:kWXPlatformLogin];
    if (string.length == 0) {
        return YES;
    } else {
        return [string boolValue];
    }
}

+ (BOOL)registerWXAppId:(NSString *)addId appSecret:(NSString *)secret
{
    if (!addId || !secret || ![addId length] || ![secret length]) {
        return NO;
    }
    
    [[self sharedService] setAppId:addId];
    [[self sharedService] setAppSecret:secret];
    return YES;
}

-(void)platformLoginWithCallback:(LDSDKLoginCallback)callback
{
    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]) {
        NSError *error = [NSError errorWithDomain:@"WXLogin" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"请先安装微信客户端", @"NSLocalizedDescription", nil]];
        if (callback) {
            callback(nil, nil, error);
        }
        return;
    }
    SendAuthReq* req =[[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"10000";
    [[LDSDKWXService defaultService] sendReq:req callback:^(BaseResp *resp) {
        if (callback) {
            self.MyBlock = callback;
        }
        if ([resp isKindOfClass:[SendAuthResp class]]) {
            SendAuthResp *oauth = (SendAuthResp *)resp;
            [[LDWechatAuthService sharedService] handleWeChatAuthResp:oauth];
        }
    }];
}

- (BOOL)handleWeChatAuthResp:(SendAuthResp *)resp;
{
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (resp.errCode == 0) { //用户同意
            if (resp.code) {
                [[LDWechatAuthService sharedService] wxTokenWithCode:resp.code];
            }
        } else {   //authResp.errCode == -4 //用户拒绝授权 authResp.errCode == -2 //用户取消
            self.error = [NSError errorWithDomain:@"WXLogin" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"登录失败", @"NSLocalizedDescription", nil]];
            if (self.MyBlock) {
                self.MyBlock(nil, nil, self.error);
            }
        }
        return YES;
    } else {
        return NO;
    }
}

- (void)wxTokenWithCode:(NSString *)code
{
    self.error = nil;
    self.oauthDict = nil;
    
    if (!code || ![code length]) {
        self.error = [NSError errorWithDomain:@"WXLogin" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"登录失败", @"NSLocalizedDescription", nil]];
        if (self.MyBlock) {
            self.MyBlock(nil, nil, self.error);
        }
        return;
    }
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.appId forKey:kWX_APPID_KEY]; //@"wxfe3c0a50a4cd3f92"
    [paramDict setObject:self.appSecret forKey:kWX_APPSECRET_KEY]; //@"695852ffc8626d9c4c65a394cc4a7eb7"
    [paramDict setObject:@"authorization_code" forKey:@"grant_type"];
    [paramDict setObject:code forKey:kWX_APPCODE_KEY];
    LDThirdAFHTTPRequestOperation *loadOperation = [[LDSDKHttpClient sharedClient]
                                                 HTTPRequestWithMethod:@"POST"
                                                 path:kWX_GET_TOKEN_URL
                                                 parameters:paramDict];
    __weak typeof(self) weakSelf = self;
    [loadOperation setCompletionBlockWithSuccess:^(LDThirdAFHTTPRequestOperation *operation, id responseObject) {
        __strong __typeof(&*weakSelf) strongSelf = weakSelf;
        if (responseObject) {
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            //NSLog(@"%@",resultDic);
            //请求用户资料数据
            strongSelf.oauthDict = resultDic;
            if (strongSelf.MyBlock) {
                strongSelf.MyBlock(resultDic, nil, nil);
            }
            [self getWXUserInfoWithToken:resultDic[kWX_ACCESSTOKEN_KEY] openId:resultDic[kWX_OPENID_KEY]];
        } else {
            strongSelf.error = [NSError errorWithDomain:@"WXLogin" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"登录失败", @"NSLocalizedDescription", nil]];
            if (strongSelf.MyBlock) {
                strongSelf.MyBlock(nil, nil, strongSelf.error);
            }
        }
        
    } failure:^(LDThirdAFHTTPRequestOperation *operation, NSError *error) {
        __strong __typeof(&*weakSelf) strongSelf = weakSelf;
        strongSelf.error = [NSError errorWithDomain:@"WXLogin" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"登录失败", @"NSLocalizedDescription", nil]];
        if (strongSelf.MyBlock) {
            strongSelf.MyBlock(nil, nil, strongSelf.error);
        }
    }];
    
    [loadOperation start];
}

- (void)getWXUserInfoWithToken:(NSString *)accessToken openId:(NSString *)openId
{
    if (!accessToken || ![accessToken length] || !openId || ![openId length]) {
        self.error = [NSError errorWithDomain:@"WXLogin" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"登录失败", @"NSLocalizedDescription", nil]];
        if (self.MyBlock) {
            self.MyBlock(nil, nil, self.error);
        }
        return;
    }
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:accessToken forKey:kWX_ACCESSTOKEN_KEY];
    [paramDict setObject:openId forKey:kWX_OPENID_KEY];
    
    __weak typeof(self) weakSelf = self;
    LDThirdAFHTTPRequestOperation *loadOperation = [[LDSDKHttpClient sharedClient]
                                                 HTTPRequestWithMethod:@"POST"
                                                 path:kWX_GET_USERINFO_URL
                                                 parameters:paramDict];
    
    [loadOperation setCompletionBlockWithSuccess:^(LDThirdAFHTTPRequestOperation *operation, id responseObject) {
        __strong __typeof(&*weakSelf) strongSelf = weakSelf;
        if (responseObject) {
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            //NSLog(@"%@",resultDic);
            if (strongSelf.MyBlock) {
                strongSelf.MyBlock(strongSelf.oauthDict, resultDic, nil);
            }
        } else {
            strongSelf.error = [NSError errorWithDomain:@"WXLogin" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"登录失败", @"NSLocalizedDescription", nil]];
            if (strongSelf.MyBlock) {
                strongSelf.MyBlock(nil, nil, strongSelf.error);
            }
        }
        
    } failure:^(LDThirdAFHTTPRequestOperation *operation, NSError *error) {
        __strong __typeof(&*weakSelf) strongSelf = weakSelf;
        strongSelf.error = [NSError errorWithDomain:@"WXLogin" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"登录失败", @"NSLocalizedDescription", nil]];
        if (strongSelf.MyBlock) {
            strongSelf.MyBlock(nil, nil, strongSelf.error);
        }
    }];
    [loadOperation start];
}

-(void)platformLogout
{
    
}

@end

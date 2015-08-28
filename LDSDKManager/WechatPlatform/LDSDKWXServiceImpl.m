//
//  LDSDKWXServiceImpl.m
//  Pods
//
//  Created by yangning on 15-1-29.
//
//

#import "LDSDKWXServiceImpl.h"
#import "WXApi.h"
#import "NSString+LDSDKAdditions.h"
#import "NSDictionary+LDSDKAdditions.h"
#import "UIImage+LDSDKShare.h"

#define kWXPlatformLogin @"login_wx"
#define kWX_APPID_KEY @"appid"
#define kWX_APPSECRET_KEY @"secret"
#define kWX_APPCODE_KEY @"code"

#define kWX_GET_TOKEN_URL @"https://api.weixin.qq.com/sns/oauth2/access_token"
#define kWX_GET_USERINFO_URL @"https://api.weixin.qq.com/sns/userinfo"

@interface LDSDKWXServiceImpl () <WXApiDelegate, NSURLConnectionDataDelegate> {
    NSDictionary *oauthDict;
    void (^MyBlock)(NSDictionary *oauthInfo, NSDictionary *userInfo, NSError *wxerror);

    LDSDKWXCallbackBlock wxcallbackBlock;

    BOOL _shouldHandleWXPay;
    LDSDKPayCallback _wxCallback;
}

@property (nonatomic, copy) NSString *authAppId;
@property (nonatomic, copy) NSString *authAppSecret;

@end

@implementation LDSDKWXServiceImpl


+ (instancetype)sharedService
{
    static LDSDKWXServiceImpl *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


#pragma mark -
#pragma mark - 配置部分

- (BOOL)isPlatformAppInstalled
{
    return [WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi];
}

- (void)registerWithPlatformConfig:(NSDictionary *)config
{
    if (config == nil || config.allKeys.count == 0) return;

    NSString *wxAppId = config[LDSDKConfigAppIdKey];
    NSString *wxAppSecret = config[LDSDKConfigAppSecretKey];
    NSString *wxDescription = config[LDSDKConfigAppDescriptionKey];
    if (wxAppId && wxAppSecret && [wxAppId length] && [wxAppSecret length]) {
        [WXApi registerApp:wxAppId withDescription:wxDescription];
        [self registerWXAppId:wxAppId appSecret:wxAppSecret];
    }
}

- (BOOL)registerWXAppId:(NSString *)addId appSecret:(NSString *)secret
{
    if (!addId || !secret || ![addId length] || ![secret length]) {
        return NO;
    }

    self.authAppId = addId;
    self.authAppSecret = secret;
    return YES;
}

- (BOOL)isRegistered
{
    return (self.authAppId && [self.authAppId length] && self.authAppSecret &&
            [self.authAppSecret length]);
}


#pragma mark -
#pragma mark - 处理URL回调

- (BOOL)handleResultUrl:(NSURL *)url
{
    if ([self payProcessOrderWithPaymentResult:url standbyCallback:NULL]) {
        return YES;
    }
    return [WXApi handleOpenURL:url delegate:self];
}


#pragma mark -
#pragma mark - 登陆部分

- (BOOL)isLoginEnabledOnPlatform
{
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:kWXPlatformLogin];
    if (string.length == 0) {
        return [self isPlatformAppInstalled] && [self isRegistered];
    } else {
        return [string boolValue] && [self isPlatformAppInstalled] && [self isRegistered];
    }
}

- (void)loginToPlatformWithCallback:(LDSDKLoginCallback)callback
{
    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]) {
        NSError *error = [NSError
            errorWithDomain:@"WXLogin"
                       code:0
                   userInfo:[NSDictionary
                                dictionaryWithObjectsAndKeys:@"请先安装微信客户端",
                                                             @"NSLocalizedDescription", nil]];
        if (callback) {
            callback(nil, nil, error);
        }
        return;
    }
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"10000";
    [self sendReq:req
         callback:^(BaseResp *resp) {
             if (callback) {
                 MyBlock = callback;
             }
             if ([resp isKindOfClass:[SendAuthResp class]]) {
                 SendAuthResp *oauth = (SendAuthResp *)resp;
                 [self handleWeChatAuthResp:oauth];
             }
         }];
}

- (BOOL)handleWeChatAuthResp:(SendAuthResp *)resp;
{
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (resp.errCode == 0) {  //用户同意
            if (resp.code) {
                [self wxTokenWithCode:resp.code];
            }
        } else {  // authResp.errCode == -4 //用户拒绝授权 authResp.errCode == -2 //用户取消
            NSError *error = [NSError
                errorWithDomain:@"WXLogin"
                           code:0
                       userInfo:[NSDictionary
                                    dictionaryWithObjectsAndKeys:@"登录失败",
                                                                 @"NSLocalizedDescription", nil]];
            if (MyBlock) {
                MyBlock(nil, nil, error);
            }
        }
        return YES;
    } else {
        return NO;
    }
}

- (void)wxTokenWithCode:(NSString *)code
{
    NSError *error = nil;
    oauthDict = nil;

    if (!code || ![code length]) {
        error = [NSError
            errorWithDomain:@"WXLogin"
                       code:0
                   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"登录失败",
                                                                       @"NSLocalizedDescription",
                                                                       nil]];
        if (MyBlock) {
            MyBlock(nil, nil, error);
        }
        return;
    }

    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.authAppId forKey:kWX_APPID_KEY];  //@"wxfe3c0a50a4cd3f92"
    [paramDict setObject:self.authAppSecret
                  forKey:kWX_APPSECRET_KEY];  //@"695852ffc8626d9c4c65a394cc4a7eb7"
    [paramDict setObject:@"authorization_code" forKey:@"grant_type"];
    [paramDict setObject:code forKey:kWX_APPCODE_KEY];

    NSMutableURLRequest *request =
        [self requestWithMethod:@"POST" path:kWX_GET_TOKEN_URL parameters:paramDict];

    // 设置

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection == nil) {
        error = [NSError
            errorWithDomain:@"WXLogin"
                       code:0
                   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"登录失败",
                                                                       @"NSLocalizedDescription",
                                                                       nil]];
        if (MyBlock) {
            MyBlock(nil, nil, error);
        }
    }
}

- (void)getWXUserInfoWithToken:(NSString *)accessToken openId:(NSString *)openId
{
    if (!accessToken || ![accessToken length] || !openId || ![openId length]) {
        NSError *error = [NSError
            errorWithDomain:@"WXLogin"
                       code:0
                   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"登录失败",
                                                                       @"NSLocalizedDescription",
                                                                       nil]];
        if (MyBlock) {
            MyBlock(nil, nil, error);
        }
        return;
    }

    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:accessToken forKey:kWX_ACCESSTOKEN_KEY];
    [paramDict setObject:openId forKey:kWX_OPENID_KEY];

    NSMutableURLRequest *request =
        [self requestWithMethod:@"POST" path:kWX_GET_USERINFO_URL parameters:paramDict];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection == nil) {
        NSError *error = [NSError
            errorWithDomain:@"WXLogin"
                       code:0
                   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"登录失败",
                                                                       @"NSLocalizedDescription",
                                                                       nil]];
        if (MyBlock) {
            MyBlock(nil, nil, error);
        }
    }
}

- (void)logoutFromPlatform
{
}


#pragma mark -
#pragma mark - 支付部分

- (void)payOrder:(NSString *)orderString callback:(LDSDKPayCallback)callback
{
    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]) {
        if (callback) {
            NSError *error = [NSError
                errorWithDomain:@"wxPay"
                           code:0
                       userInfo:[NSDictionary
                                    dictionaryWithObjectsAndKeys:@"请先安装微信客户端",
                                                                 @"NSLocalizedDescription", nil]];
            callback(nil, error);
        }
        return;
    }
    [self wxpayOrder:orderString callback:callback];
}

- (BOOL)payProcessOrderWithPaymentResult:(NSURL *)url
                         standbyCallback:(void (^)(NSDictionary *))callback
{
    if (_shouldHandleWXPay) {
        return [WXApi handleOpenURL:url delegate:self];
    }

    return NO;
}

- (void)wxpayOrder:(NSString *)orderString callback:(LDSDKPayCallback)callback
{
    NSDictionary *orderDict = [orderString urlParamsDecodeDictionary];

    PayReq *request = [[PayReq alloc] init];
    request.partnerId = [[[orderDict stringForKey:@"partnerId"] URLDecodedString]
        stringByReplacingOccurrencesOfString:@"\""
                                  withString:@""];
    request.prepayId = [[[orderDict stringForKey:@"prepayId"] URLDecodedString]
        stringByReplacingOccurrencesOfString:@"\""
                                  withString:@""];
    request.package = [[[orderDict stringForKey:@"packageValue"] URLDecodedString]
        stringByReplacingOccurrencesOfString:@"\""
                                  withString:@""];
    request.nonceStr = [[[orderDict stringForKey:@"nonceStr"] URLDecodedString]
        stringByReplacingOccurrencesOfString:@"\""
                                  withString:@""];
    NSString *time = [[[orderDict stringForKey:@"timeStamp"] URLDecodedString]
        stringByReplacingOccurrencesOfString:@"\""
                                  withString:@""];
    request.timeStamp = (UInt32)[time longLongValue];
    request.sign = [[[orderDict stringForKey:@"weixinSign"] URLDecodedString]
        stringByReplacingOccurrencesOfString:@"\""
                                  withString:@""];

    _shouldHandleWXPay = YES;
    BOOL result = [WXApi sendReq:request];

    if (!result) {
        _shouldHandleWXPay = NO;
        if (callback) {
            NSError *error = [NSError
                errorWithDomain:@"wxPay"
                           code:0
                       userInfo:[NSDictionary
                                    dictionaryWithObjectsAndKeys:@"无法支付",
                                                                 @"NSLocalizedDescription", nil]];
            callback(nil, error);
        }
    }

    _wxCallback = callback;
}


#pragma mark -
#pragma mark - 分享部分

- (void)shareWithContent:(NSDictionary *)content
             shareModule:(NSUInteger)shareModule
              onComplete:(LDSDKShareCallback)complete
{
    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]) {
        NSError *error = [NSError
            errorWithDomain:@"WXShare"
                       code:0
                   userInfo:[NSDictionary
                                dictionaryWithObjectsAndKeys:@"请先安装微信客户端",
                                                             @"NSLocalizedDescription", nil]];
        if (complete) {
            complete(NO, error);
        }
        return;
    }

    WXMediaMessage *message = [WXMediaMessage message];
    NSString *title = content[@"title"];
    NSString *description = content[@"description"];
    NSString *urlString = content[@"webpageurl"];
    UIImage *oldImage = content[@"image"];

    if (urlString) {
        message.title = title;
        message.description = description;
        if (oldImage) {
            [message setThumbImage:oldImage];
        }

        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = urlString;
        message.mediaObject = ext;
    } else if (oldImage) {  //分享图片
        UIImage *image = oldImage;
        CGSize thumbSize = image.size;
        UIImage *thumbImage = image;
        if (image.scale > 1.0) {
            thumbImage = [image LDSDKShare_resizedImage:image.size
                                   interpolationQuality:kCGInterpolationDefault];
        }

        NSData *thumbData = UIImageJPEGRepresentation(thumbImage, 0.0);
        while (thumbData.length > 32 * 1024) {  //不能超过32K
            thumbSize = CGSizeMake(thumbSize.width / 2.0, thumbSize.height / 2.0);
            thumbImage = [thumbImage LDSDKShare_resizedImage:thumbSize
                                        interpolationQuality:kCGInterpolationDefault];
            thumbData = UIImageJPEGRepresentation(thumbImage, 0.0);
        }
        [message setThumbData:thumbData];

        WXImageObject *ext = [WXImageObject object];
        ext.imageData = UIImageJPEGRepresentation(image, 1.0);
        message.title = title;
        message.description = description;
        message.mediaObject = ext;
    } else {
        // NSAssert(0, @"WechatTimelien contentItem Error");
    }

    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    if (shareModule == 1) {
        req.scene = WXSceneSession;
    } else if (shareModule == 2) {
        req.scene = WXSceneTimeline;
    } else {
        req.scene = WXSceneSession;
    }

    [self sendReq:req
         callback:^(BaseResp *resp) {
             if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
                 [self handleShareResultInActivity:resp onComplete:complete];
             }
         }];
}


- (void)handleShareResultInActivity:(id)result onComplete:(void (^)(BOOL, NSError *))complete
{
    SendMessageToWXResp *response = (SendMessageToWXResp *)result;

    switch (response.errCode) {
        case WXSuccess:
            if (complete) {
                complete(YES, nil);
            }

            break;
        case WXErrCodeUserCancel: {
            NSError *error = [NSError
                errorWithDomain:@"WXShare"
                           code:-2
                       userInfo:[NSDictionary
                                    dictionaryWithObjectsAndKeys:@"用户取消分享",
                                                                 @"NSLocalizedDescription", nil]];
            if (complete) {
                complete(NO, error);
            }
        } break;
        default: {
            NSError *error = [NSError
                errorWithDomain:@"WXShare"
                           code:-1
                       userInfo:[NSDictionary
                                    dictionaryWithObjectsAndKeys:@"分享失败",
                                                                 @"NSLocalizedDescription", nil]];
            if (complete) {
                complete(NO, error);
            }
        }

        break;
    }
}


#pragma mark -
#pragma mark - 发送请求

- (BOOL)sendReq:(BaseReq *)req callback:(LDSDKWXCallbackBlock)callbackBlock
{
    wxcallbackBlock = callbackBlock;
    return [WXApi sendReq:req];
}


#pragma mark -
#pragma mark - 构建HTTP请求

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
{
    NSParameterAssert(method);

    if (!path) {
        path = @"";
    }

    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *request =
        [[NSMutableURLRequest alloc] initWithURL:url
                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                 timeoutInterval:10];
    [request setHTTPMethod:method];

    if (parameters) {
        NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(
            CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        [request setValue:[NSString
                              stringWithFormat:@"application/x-www-form-urlencoded; charset=%@",
                                               charset]
            forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[[self LDSDKQueryStringFromParametersWithEncoding:parameters
                                                                      encoding:NSUTF8StringEncoding]
                                 dataUsingEncoding:NSUTF8StringEncoding]];
    }

    return request;
}

- (NSString *)LDSDKQueryStringFromParametersWithEncoding:(NSDictionary *)parameters
                                                encoding:(NSStringEncoding)stringEncoding
{
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (NSString *key in [parameters allKeys]) {
        NSString *value = [parameters objectForKey:key];
        if (!value || [value isEqual:[NSNull null]]) {
            [mutablePairs addObject:LDSDKAFPercentEscapedQueryStringKeyFromStringWithEncoding(
                                        [key description], stringEncoding)];
        } else {
            [mutablePairs
                addObject:[NSString stringWithFormat:
                                        @"%@=%@",
                                        LDSDKAFPercentEscapedQueryStringKeyFromStringWithEncoding(
                                            [key description], stringEncoding),
                                        LDSDKAFPercentEscapedQueryStringValueFromStringWithEncoding(
                                            [value description], stringEncoding)]];
        }
    }
    return [mutablePairs componentsJoinedByString:@"&"];
}

static NSString *const kLDSDKAFCharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";

static NSString *
LDSDKAFPercentEscapedQueryStringKeyFromStringWithEncoding(NSString *string,
                                                          NSStringEncoding encoding)
{
    static NSString *const kLDSDKAFCharactersToLeaveUnescapedInQueryStringPairKey = @"[].";

    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
        kCFAllocatorDefault, (__bridge CFStringRef)string,
        (__bridge CFStringRef)kLDSDKAFCharactersToLeaveUnescapedInQueryStringPairKey,
        (__bridge CFStringRef)kLDSDKAFCharactersToBeEscapedInQueryString,
        CFStringConvertNSStringEncodingToEncoding(encoding));
}

static NSString *
LDSDKAFPercentEscapedQueryStringValueFromStringWithEncoding(NSString *string,
                                                            NSStringEncoding encoding)
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
        kCFAllocatorDefault, (__bridge CFStringRef)string, NULL,
        (__bridge CFStringRef)kLDSDKAFCharactersToBeEscapedInQueryString,
        CFStringConvertNSStringEncodingToEncoding(encoding));
}

#pragma mark - WXApiDelegate

- (void)onReq:(BaseReq *)req
{
    _shouldHandleWXPay = NO;
#ifdef DEBUG
    NSLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
#endif
}

- (void)onResp:(BaseResp *)resp
{
#ifdef DEBUG
    NSLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
#endif
    if (_wxCallback) {
        if ([resp isKindOfClass:[PayResp class]]) {
            PayResp *pResp = (PayResp *)resp;
            _wxCallback(pResp.returnKey, nil);
        } else {
            NSError *error = [NSError
                errorWithDomain:@"wxPay"
                           code:resp.errCode
                       userInfo:[NSDictionary
                                    dictionaryWithObjectsAndKeys:resp.errStr,
                                                                 @"NSLocalizedDescription", nil]];
            _wxCallback(nil, error);
        }
        _wxCallback = NULL;
    } else if (wxcallbackBlock) {
        wxcallbackBlock(resp);
        wxcallbackBlock = NULL;
    }

    _shouldHandleWXPay = NO;
}


#pragma mark -
#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}

// 接收数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    if ([urlStr isEqualToString:kWX_GET_TOKEN_URL]) {
        if (data) {
            NSDictionary *resultDic =
                [NSJSONSerialization JSONObjectWithData:data
                                                options:NSJSONReadingAllowFragments
                                                  error:nil];
            oauthDict = resultDic;
            if (MyBlock) {
                MyBlock(resultDic, nil, nil);
            }
            [self getWXUserInfoWithToken:resultDic[kWX_ACCESSTOKEN_KEY]
                                  openId:resultDic[kWX_OPENID_KEY]];
        } else {
            NSError *error = [NSError
                errorWithDomain:@"WXLogin"
                           code:0
                       userInfo:[NSDictionary
                                    dictionaryWithObjectsAndKeys:@"登录失败",
                                                                 @"NSLocalizedDescription", nil]];
            if (MyBlock) {
                MyBlock(nil, nil, error);
            }
        }
    } else if ([urlStr isEqualToString:kWX_GET_USERINFO_URL]) {
        if (data) {
            NSDictionary *resultDic =
                [NSJSONSerialization JSONObjectWithData:data
                                                options:NSJSONReadingAllowFragments
                                                  error:nil];
            if (MyBlock) {
                MyBlock(oauthDict, resultDic, nil);
            }
        } else {
            NSError *error = [NSError
                errorWithDomain:@"WXLogin"
                           code:0
                       userInfo:[NSDictionary
                                    dictionaryWithObjectsAndKeys:@"登录失败",
                                                                 @"NSLocalizedDescription", nil]];
            if (MyBlock) {
                MyBlock(nil, nil, error);
            }
        }
    }
}

// 数据接收完毕
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading");
}

// 返回错误
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (MyBlock) {
        MyBlock(nil, nil, error);
    }
}

@end

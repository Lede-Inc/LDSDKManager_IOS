//
//  LDSDKYXServiceImpl.m
//  Pods
//
//  Created by yangning on 15-1-30.
//
//

#import "LDSDKYXServiceImpl.h"
#import "YXApi.h"
#import "UIImage+LDSDKShare.h"

@interface LDSDKYXServiceImpl () <YXApiDelegate>

@property (nonatomic, copy) NSString *yxAppid;
@property (nonatomic, copy) NSString *yxAppSecret;
@property (nonatomic, copy) LDSDKYXCallbackBlock callbackBlock;

@end

@implementation LDSDKYXServiceImpl


+ (instancetype)sharedService
{
    static LDSDKYXServiceImpl *sharedInstance = nil;
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
    return [YXApi isYXAppInstalled] && [YXApi isYXAppSupportApi];
}

- (void)registerWithPlatformConfig:(NSDictionary *)config
{
    if (config == nil || config.allKeys.count == 0) return;

    NSString *yxAppId = config[LDSDKConfigAppIdKey];
    //    NSString *yxAppSecret = config[LDSDKRegisterAppSecretKey];
    if (yxAppId && [yxAppId length]) {
        [YXApi registerApp:yxAppId];
        self.yxAppid = yxAppId;
    }
}

- (BOOL)isRegistered
{
    return (self.yxAppid && [self.yxAppid length]);
}


#pragma mark -
#pragma mark - 处理URL回调

- (BOOL)handleResultUrl:(NSURL *)url
{
    return [self handleOpenURL:url];
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    return [YXApi handleOpenURL:url delegate:self];
}


#pragma mark -
#pragma mark - 分享部分

- (void)shareWithContent:(NSDictionary *)content
             shareModule:(NSUInteger)shareModule
              onComplete:(void (^)(BOOL, NSError *))complete
{
    if (![YXApi isYXAppInstalled] || ![YXApi isYXAppSupportApi]) {

        NSError *error = [NSError
            errorWithDomain:@"YXShare"
                       code:0
                   userInfo:[NSDictionary
                                dictionaryWithObjectsAndKeys:@"请先安装易信客户端",
                                                             @"NSLocalizedDescription", nil]];
        if (complete) {
            complete(NO, error);
        }
        return;
    }

    NSString *title = content[@"title"];
    NSString *description = content[@"description"];
    NSString *urlString = content[@"webpageurl"];
    UIImage *oldImage = content[@"image"];

    YXMediaMessage *message = [YXMediaMessage message];
    message.title = title;
    message.description = description;

    if (urlString) {  //分享链接
        if (oldImage) {
            //控件大小，否则无法跳转
            UIImage *image = oldImage;
            CGSize thumbSize = image.size;
            UIImage *thumbImage = image;
            if (image.scale > 1.0) {
                thumbImage = [image LDSDKShare_resizedImage:image.size
                                       interpolationQuality:kCGInterpolationDefault];
            }

            NSData *thumbData = UIImageJPEGRepresentation(thumbImage, 0.0);
            while (thumbData.length > 64 * 1024) {  //不能超过64K
                thumbSize = CGSizeMake(thumbSize.width / 2.0, thumbSize.height / 2.0);
                thumbImage = [thumbImage LDSDKShare_resizedImage:thumbSize
                                            interpolationQuality:kCGInterpolationDefault];
                thumbData = UIImageJPEGRepresentation(thumbImage, 0.0);
            }
            [message setThumbData:thumbData];
        }


        YXWebpageObject *ext = [YXWebpageObject object];
        ext.webpageUrl = urlString;
        message.mediaObject = ext;
    } else if (oldImage) {  //分享图片
        UIImage *image = oldImage;
        YXImageObject *ext = [YXImageObject object];
        ext.imageData = UIImageJPEGRepresentation(image, 1.0);
        message.mediaObject = ext;

        CGSize thumbSize = image.size;
        UIImage *thumbImage = image;
        if (image.scale > 1.0) {
            thumbImage = [image LDSDKShare_resizedImage:image.size
                                   interpolationQuality:kCGInterpolationDefault];
        }

        NSData *thumbData = UIImageJPEGRepresentation(thumbImage, 0.0);
        while (thumbData.length > 64 * 1024) {  //不能超过64K
            thumbSize = CGSizeMake(thumbSize.width / 2.0, thumbSize.height / 2.0);
            thumbImage = [thumbImage LDSDKShare_resizedImage:thumbSize
                                        interpolationQuality:kCGInterpolationDefault];
            thumbData = UIImageJPEGRepresentation(thumbImage, 0.0);
        }
        [message setThumbData:thumbData];
    } else {
        NSAssert(0, @"YiXin ContentItem Error");
    }

    SendMessageToYXReq *req = [[SendMessageToYXReq alloc] init];
    req.bText = NO;
    req.message = message;
    if (shareModule == 1) {
        req.scene = kYXSceneSession;
    } else if (shareModule == 2) {
        req.scene = kYXSceneTimeline;
    } else {
        req.scene = kYXSceneSession;
    }

    [self sendReq:req
         callback:^(YXBaseResp *resp) {
             [self handleShareResultInActivity:resp onComplete:complete];
         }];
}

- (void)handleShareResultInActivity:(id)result onComplete:(void (^)(BOOL, NSError *))complete
{
    SendMessageToYXResp *response = (SendMessageToYXResp *)result;

    switch (response.code) {
        case kYXRespSuccess:
            if (complete) {
                complete(YES, nil);
            }

            break;
        case kYXRespErrUserCancel: {
            NSError *error = [NSError
                errorWithDomain:@"YXShare"
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
                errorWithDomain:@"YXShare"
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

- (BOOL)sendReq:(YXBaseReq *)req callback:(LDSDKYXCallbackBlock)callbackBlock
{
    self.callbackBlock = callbackBlock;
    return [YXApi sendReq:req];
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

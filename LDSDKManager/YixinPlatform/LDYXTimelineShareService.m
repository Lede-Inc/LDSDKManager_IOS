//
//  LDYXTimelineShareService.m
//  TestThirdPlatform
//
//  Created by ss on 15/8/17.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import "LDYXTimelineShareService.h"
#import "YXApi.h"
#import "UIImage+LDSDKShare.h"
#import "LDSDKYXService.h"

@implementation LDYXTimelineShareService

+ (instancetype)sharedService
{
    static LDYXTimelineShareService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

-(void)shareWithDict:(NSDictionary *)dict onComplete:(void (^)(BOOL, NSError *))complete
{
    if (![YXApi isYXAppInstalled] || ![YXApi isYXAppSupportApi]) {
        NSError *error = [NSError errorWithDomain:@"YXTimelineShare" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"请先安装易信客户端", @"NSLocalizedDescription", nil]];
        if (complete) {
            complete(NO, error);
        }
        return;
    }
    
    NSString *title = dict[@"title"];
    NSString *description = dict[@"description"];
    NSString *urlString = dict[@"webpageurl"];
    UIImage *oldImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:dict[@"imageurl"]]]];
    
    YXMediaMessage *message = [YXMediaMessage message];
    message.title = title;
    message.description = description;
    
    if(urlString){ //分享链接
        if (oldImage) {
            //控制大小，否则无法跳转
            UIImage *image = oldImage;
            CGSize thumbSize = image.size;
            UIImage *thumbImage = image;
            if (image.scale > 1.0) {
                thumbImage = [image LDSDKShare_resizedImage:image.size interpolationQuality:kCGInterpolationDefault];
            }
            
            NSData *thumbData = UIImageJPEGRepresentation(thumbImage, 0.0);
            while (thumbData.length > 64*1024) { //不能超过64K
                thumbSize =CGSizeMake(thumbSize.width/2.0, thumbSize.height/2.0);
                thumbImage = [thumbImage LDSDKShare_resizedImage:thumbSize interpolationQuality:kCGInterpolationDefault];
                thumbData = UIImageJPEGRepresentation(thumbImage, 0.0);
            }
            [message setThumbData:thumbData];
        }
        YXWebpageObject *ext = [YXWebpageObject object];
        NSString *link = urlString;
        ext.webpageUrl = [link stringByAppendingFormat:[link rangeOfString:@"?"].location == NSNotFound ? @"?shareMode=%lu" : @"&shareMode=%lu",(unsigned long)4];
        message.mediaObject = ext;
    } else if (oldImage) { //分享图片
        UIImage *image = oldImage;
        YXImageObject *ext = [YXImageObject object];
        ext.imageData = UIImageJPEGRepresentation(image, 1.0);
        message.mediaObject = ext;
        
        CGSize thumbSize = image.size;
        UIImage *thumbImage = image;
        if (image.scale > 1.0) {
            thumbImage = [image LDSDKShare_resizedImage:image.size interpolationQuality:kCGInterpolationDefault];
        }
        
        NSData *thumbData = UIImageJPEGRepresentation(thumbImage, 0.0);
        while (thumbData.length > 64*1024) { //不能超过64K
            thumbSize =CGSizeMake(thumbSize.width/2.0, thumbSize.height/2.0);
            thumbImage = [thumbImage LDSDKShare_resizedImage:thumbSize interpolationQuality:kCGInterpolationDefault];
            thumbData = UIImageJPEGRepresentation(thumbImage, 0.0);
        }
        [message setThumbData:thumbData];
    } else {
        NSAssert(0, @"YiXinTimeline ContentItem Error");
    }
    
    SendMessageToYXReq* req = [[SendMessageToYXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = kYXSceneTimeline;
    [[LDSDKYXService defaultService] sendReq:req callback:^(YXBaseResp *resp) {
        [LDYXTimelineShareService handleShareResultInActivity:resp onComplete:complete];
    }];
}

+(void)handleShareResultInActivity:(id)result onComplete:(void (^)(BOOL, NSError *))complete
{
    SendMessageToYXResp *response = (SendMessageToYXResp *)result;
    
    switch (response.code) {
        case kYXRespSuccess:
            if (complete) {
                complete(YES, nil);
            }
            
            break;
        case kYXRespErrUserCancel:{
            NSError *error = [NSError errorWithDomain:@"YXTimelineShare" code:-2 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"用户取消分享", @"NSLocalizedDescription", nil]];
            if (complete) {
                complete(NO, error);
            }
        }
            break;
        default:{
            NSError *error = [NSError errorWithDomain:@"YXTimelineShare" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"分享失败", @"NSLocalizedDescription", nil]];
            if (complete) {
                complete(NO, error);
            }
        }
            
            break;
    }
    
}


@end

//
//  LDQQShareService.m
//  TestThirdPlatform
//
//  Created by ss on 15/8/14.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import <TencentOpenAPI/QQApiInterface.h>
#import "LDQQShareService.h"
#import "UIImage+LDSDKShare.h"
#import "LDSDKQQService.h"

@implementation LDQQShareService

+ (instancetype)sharedService
{
    static LDQQShareService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

-(void)shareWithDict:(NSDictionary *)dict onComplete:(LDSDKShareCallback)complete
{
    if (![QQApi isQQInstalled] || ![QQApi isQQSupportApi]) {
        NSError *error = [NSError errorWithDomain:@"QQShare" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"请先安装QQ客户端", @"NSLocalizedDescription", nil]];
        if (complete) {
            complete(NO, error);
        }
        return;
    }
    
    
    NSLog(@"dict = %@", dict);
    //构造QQ、空间分享内容
    NSString *title = dict[@"title"];
    NSString *description = dict[@"description"];
    NSString *urlString = dict[@"webpageurl"];
    
    QQApiObject *messageObj = nil;
    UIImage *oldImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:dict[@"imageurl"]]]];
    if (urlString){ //链接分享
        //原图图片信息
        UIImage *image = oldImage;
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        NSData *thumbData = [NSData dataWithData:imageData];
        if (oldImage) {
            //缩略图片
            CGSize thumbSize = image.size;
            UIImage *thumbImage = image;
            NSData *thumbData = imageData;
            while (thumbData.length > 1000*1024) { //缩略图不能超过1M
                thumbSize =CGSizeMake(thumbSize.width/1.5, thumbSize.height/1.5);
                thumbImage = [thumbImage LDSDKShare_resizedImage:thumbSize interpolationQuality:kCGInterpolationDefault];
                thumbData = UIImageJPEGRepresentation(thumbImage, 0.5);
            }
            
        }
        messageObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:urlString]
                                              title:title
                                        description:description
                                   previewImageData:thumbData];
        
    } else if (oldImage) { //图片分享
        //原图图片信息
        UIImage *image = oldImage;
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        //内容图片(大图)
        CGSize contentSize = image.size;
        UIImage *contentImage = image;
        NSData  *contentData = [NSData dataWithData:imageData];
        if (contentData.length > 5000*1024) { //图片不能超过5M
            contentSize =CGSizeMake(contentSize.width/1.5, contentSize.height/1.5);
            contentImage = [contentImage LDSDKShare_resizedImage:contentSize interpolationQuality:kCGInterpolationDefault];
            contentData = UIImageJPEGRepresentation(contentImage, 0.5);
        }
        
        //缩略图片
        CGSize thumbSize = image.size;
        UIImage *thumbImage = image;
        NSData *thumbData = [NSData dataWithData:imageData];
        while (thumbData.length > 1000*1024) { //缩略图不能超过1M
            thumbSize =CGSizeMake(thumbSize.width/1.5, thumbSize.height/1.5);
            thumbImage = [thumbImage LDSDKShare_resizedImage:thumbSize interpolationQuality:kCGInterpolationDefault];
            thumbData = UIImageJPEGRepresentation(thumbImage, 0.5);
        }
        
        messageObj = [QQApiImageObject objectWithData:contentData
                                     previewImageData:thumbData
                                                title:title
                                          description:description];
    } else {
        NSLog(@"未知分享");
    }
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:messageObj];
    [[LDSDKQQService defaultService] sendReq:req callback:^(QQBaseResp *resp) {
        if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
            [LDQQShareService handleShareResultInActivity:resp onComplete:complete];
        }
    }];
    
}

+ (void)handleShareResultInActivity:(id)result onComplete:(LDSDKShareCallback)complete
{
    SendMessageToQQResp *response = (SendMessageToQQResp *)result;
    
    NSString *resultStr = response.result;
    
    if ([resultStr isEqualToString:@"0"]) {//成功
        if (complete) {
            complete(YES, nil);
        }
    } else if ([resultStr isEqualToString:@"-4"]) {
        NSError *error = [NSError errorWithDomain:@"QQShare" code:-2 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"用户取消分享", @"NSLocalizedDescription", nil]];
        if (complete) {
            complete(NO, error);
        }
    } else {
        NSError *error = [NSError errorWithDomain:@"QQShare" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"分享失败", @"NSLocalizedDescription", nil]];
        if (complete) {
            complete(NO, error);
        }
    }
}

@end

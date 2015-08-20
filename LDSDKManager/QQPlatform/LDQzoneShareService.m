//
//  LDQzoneShareService.m
//  TestThirdPlatform
//
//  Created by ss on 15/8/14.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import "LDQzoneShareService.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "LDSDKQQService.h"
#import "UIImage+LDSDKShare.h"

@implementation LDQzoneShareService

+ (instancetype)sharedService
{
    static LDQzoneShareService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

-(void)shareWithDict:(NSDictionary *)dict onComplete:(LDSDKShareCallback)complete
{
    if (![QQApi isQQInstalled] || ![QQApi isQQSupportApi]) {
        NSError *error = [NSError errorWithDomain:@"QzoneShare" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"请先安装QQ客户端", @"NSLocalizedDescription", nil]];
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
    
    UIImage *oldImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:dict[@"imageurl"]]]];
    //原图图片信息
    UIImage *image = oldImage;
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSData *thumbData = [NSData dataWithData:imageData];
    if (urlString){ //链接分享
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
    }
    
    QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:urlString]
                                                        title:title
                                                  description:description
                                             previewImageData:thumbData];
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    [[LDSDKQQService defaultService] sendReq:req callback:^(QQBaseResp *resp) {
        [LDQzoneShareService handleShareResultInActivity:resp onComplete:complete];
    }];
}


+ (void)handleShareResultInActivity:(id)result onComplete:(void (^)(BOOL, NSError *))complete
{
    SendMessageToQQResp *response = (SendMessageToQQResp *)result;
    
    NSString *resultStr = response.result;
    
    if ([resultStr isEqualToString:@"0"]) {//成功
        if (complete) {
            complete(YES, nil);
        }
    } else if ([resultStr isEqualToString:@"-4"]) {
        NSError *error = [NSError errorWithDomain:@"QzoneShare" code:-2 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"用户取消分享", @"NSLocalizedDescription", nil]];
        if (complete) {
            complete(NO, error);
        }
    } else {
        NSError *error = [NSError errorWithDomain:@"QzoneShare" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"分享失败", @"NSLocalizedDescription", nil]];
        if (complete) {
            complete(NO, error);
        }
    }
}

@end

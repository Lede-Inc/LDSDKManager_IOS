//
//  LDSDKShareService.h
//  LDThirdLib
//
//  Created by ss on 15/8/12.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LDSDKShareCallback)(BOOL success, NSError *error);

//使用SDK分享，分享内容信息的Key
FOUNDATION_EXTERN NSString *const LDSDKShareContentTitleKey;
FOUNDATION_EXTERN NSString *const LDSDKShareContentDescriptionKey;
FOUNDATION_EXTERN NSString *const LDSDKShareContentImageKey;
FOUNDATION_EXTERN NSString *const LDSDKShareContentWapUrlKey;
FOUNDATION_EXTERN NSString *const LDSDKShareContentTextKey;         //新浪微博分享专用
FOUNDATION_EXTERN NSString *const LDSDKShareContentRedirectURIKey;  //新浪微博分享专用

typedef NS_ENUM(NSUInteger, LDSDKShareToModule) {
    LDSDKShareToContact = 1,  //分享至第三方应用的联系人或组
    LDSDKShareToTimeLine,     //分享至第三方应用的timeLine
    LDSDKShareToOther         //分享至第三方应用的其他模块
};

@protocol LDSDKShareService <NSObject>

/*!
 *  @brief  分享到指定平台
 *
 *  @param content  分享内容
 *  @param shareModule 分享子平台，目前主要包括好友和朋友圈（空间）两部分
 *  @param complete  分享之后的回调
 */
- (void)shareWithContent:(NSDictionary *)content
             shareModule:(NSUInteger)shareModule
              onComplete:(LDSDKShareCallback)complete;

@end

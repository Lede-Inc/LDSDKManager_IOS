//
//  LDSDKShareService.h
//  LDThirdLib
//
//  Created by ss on 15/8/12.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LDSDKShareCallback)(BOOL success, NSError *error);

FOUNDATION_EXTERN NSString *const LDSDKShareContentTitleKey;
FOUNDATION_EXTERN NSString *const LDSDKShareContentDescriptionKey;
FOUNDATION_EXTERN NSString *const LDSDKShareContentImageKey;
FOUNDATION_EXTERN NSString *const LDSDKShareContentWapUrlKey;
FOUNDATION_EXTERN NSString *const LDSDKShareContentTextKey;

typedef NS_ENUM(NSUInteger, LDSDKShareToModule){
    LDSDKShareToContact = 1,  //分享至第三方应用的联系人或组
    LDSDKShareToTimeLine,     //分享至第三方应用的timeLine
    LDSDKShareToOther         //分享至第三方应用的其他模块
};

@protocol LDSDKShareService <NSObject>

- (void)shareWithContent:(NSDictionary *)content shareModule:(NSUInteger)shareModule onComplete:(LDSDKShareCallback)complete;

@end

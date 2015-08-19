//
//  LDSDKCommon.h
//  TestThirdPlatform
//
//  Created by ss on 15/8/14.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDSDKCommon : NSObject

+ (instancetype)sharedInstance;

@property (copy, nonatomic) NSString *wxAppId;
@property (copy, nonatomic) NSString *wxAppSecret;
@property (copy, nonatomic) NSString *yxAppId;
@property (copy, nonatomic) NSString *yxAppSecret;
@property (copy, nonatomic) NSString *qqAppId;
@property (copy, nonatomic) NSString *qqAppKey;
@property (copy, nonatomic) NSString *aliPayScheme;

@end

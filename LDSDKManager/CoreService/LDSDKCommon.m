//
//  LDSDKCommon.m
//  TestThirdPlatform
//
//  Created by ss on 15/8/14.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import "LDSDKCommon.h"

@implementation LDSDKCommon

@synthesize wxAppId, wxAppSecret, yxAppId, yxAppSecret, qqAppId, qqAppKey, aliPayScheme;

+ (instancetype)sharedInstance
{
    static LDSDKCommon *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}


-(instancetype)init
{
    if (self = [super init]) {
        wxAppId = @"";
        wxAppSecret = @"";
        yxAppId = @"";
        yxAppSecret = @"";
        qqAppId = @"";
        qqAppKey = @"";
        aliPayScheme = @"";
    }
    return self;
}

@end

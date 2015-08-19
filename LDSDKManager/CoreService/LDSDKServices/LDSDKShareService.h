//
//  LDSDKShareService.h
//  LDThirdLib
//
//  Created by ss on 15/8/12.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LDSDKShareCallback)(BOOL success, NSError *error);

@protocol LDSDKShareService <NSObject>

+ (instancetype)sharedService;

- (void)shareWithDict:(NSDictionary *)dict onComplete:(LDSDKShareCallback)complete;

@end

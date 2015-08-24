//
//  LDSDKYXServiceImpl.h
//  Pods
//
//  Created by yangning on 15-1-30.
//
//

#import <Foundation/Foundation.h>
#import "LDSDKRegisterService.h"
#import "LDSDKShareService.h"

@class YXBaseReq;
@class YXBaseResp;

typedef void(^LDSDKYXCallbackBlock)(YXBaseResp *resp);

@interface LDSDKYXServiceImpl : NSObject <LDSDKRegisterService, LDSDKShareService>

@end

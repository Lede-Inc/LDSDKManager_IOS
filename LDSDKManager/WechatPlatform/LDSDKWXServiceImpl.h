//
//  LDSDKWXServiceImpl.h
//  Pods
//
//  Created by yangning on 15-1-29.
//
//

#import <Foundation/Foundation.h>
#import "LDSDKAuthService.h"
#import "LDSDKRegisterService.h"
#import "LDSDKPayService.h"
#import "LDSDKShareService.h"

@class BaseReq;
@class BaseResp;

typedef void (^LDSDKWXCallbackBlock)(BaseResp *resp);

@interface LDSDKWXServiceImpl
    : NSObject <LDSDKAuthService, LDSDKRegisterService, LDSDKShareService, LDSDKPayService>

@end

//
//  LDSDKWXService.h
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

#define kWX_OPENID_KEY      @"openid"
#define kWX_NICKNAME_KEY    @"nickname"
#define kWX_AVATARURL_KEY   @"headimgurl"
#define kWX_ACCESSTOKEN_KEY @"access_token"

@class BaseReq;
@class BaseResp;

typedef void(^LDSDKWXCallbackBlock)(BaseResp *resp);

@interface LDSDKWXService : NSObject <LDSDKAuthService, LDSDKRegisterService, LDSDKShareService, LDSDKPayService>

@end

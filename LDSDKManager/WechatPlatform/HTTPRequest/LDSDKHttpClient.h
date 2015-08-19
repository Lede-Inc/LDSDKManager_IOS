//
//  LDThirdHttpClient.h
//  TestThirdPlatform
//
//  Created by ss on 15/8/17.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDSDKAFHTTPClient.h"
#import "LDSDKAFHTTPRequestOperation.h"

@interface LDSDKHttpClient : LDThirdAFHTTPClient

@property (nonatomic,copy) NSString *interfaceHeaderString; //所有URL附带的统一查询参数


+ (LDSDKHttpClient *)sharedClient;

- (LDThirdAFHTTPRequestOperation *)HTTPRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters;

@end

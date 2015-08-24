//
//  LDSDKHttpClient.m
//  TestThirdPlatform
//
//  Created by ss on 15/8/17.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import "LDSDKHttpClient.h"

@implementation LDSDKHttpClient

+ (LDSDKHttpClient *)sharedClient
{
    static LDSDKHttpClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[LDSDKHttpClient alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    });
    return _sharedClient;
}

- (LDSDKAFHTTPRequestOperation *)HTTPRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters
{
    path = [self interfaceHeaderPath:path];
    NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:parameters];
    LDSDKAFHTTPRequestOperation *httpRequest = [[LDSDKAFHTTPRequestOperation alloc] initWithRequest:request];
    
#ifdef  TEST_VERSION_
    NSLog(@"%@",request.URL.absoluteString);
#endif
    
    return httpRequest;
}

#pragma mark - append interface header

-(NSString*)interfaceHeaderPath:(NSString*)originPath
{
    NSString *newPath = originPath;
    if (self.interfaceHeaderString) {
        if ([originPath rangeOfString:@"?"].length > 0) {
            newPath = [originPath stringByAppendingFormat:@"&%@", self.interfaceHeaderString];
        } else {
            newPath = [originPath stringByAppendingFormat:@"?%@", self.interfaceHeaderString];
        }
    }
    return newPath;
}

@end

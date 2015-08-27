//
//  LDAppDelegate.m
//  LDSDKManager
//
//  Created by 张海洋 on 08/19/2015.
//  Copyright (c) 2015 张海洋. All rights reserved.
//

#import "LDAppDelegate.h"
//#import "LDSDKManager.h"
#import "LDSDKManager.h"
#import "LDSDKRegisterService.h"
#import "LDViewController.h"

@implementation LDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];


    /*!
     *  @brief  批量注册第三方SDK
     */
    NSArray *regPlatformConfigList = @[
        @{
            LDSDKConfigAppIdKey:@"wxc133b9f78c1141b0",
            LDSDKConfigAppSecretKey:@"67b24b8f6951b1086675c33b144e0709",
            LDSDKConfigAppDescriptionKey:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
            LDSDKConfigAppPlatformTypeKey:@(LDSDKPlatformWeChat)
        },
        @{
            LDSDKConfigAppIdKey:@"1104472826",
            LDSDKConfigAppSecretKey:@"nLCqXsceOMtojCtD",
            LDSDKConfigAppPlatformTypeKey:@(LDSDKPlatformQQ)
        },
        @{
            LDSDKConfigAppIdKey:@"yx778ae2bc7a2a489bb627d51f03a92682",
            LDSDKConfigAppSecretKey:@"6042fc1511260d6594",
            LDSDKConfigAppPlatformTypeKey:@(LDSDKPlatformYiXin)
        },
        @{
            LDSDKConfigAppSchemeKey:@"alisdkldchexian",
            LDSDKConfigAppPlatformTypeKey:@(LDSDKPlatformAliPay)
        },
    ];
//    [LDSDKManager registerWithPlatformConfigList:regPlatformConfigList];
    [LDSDKManager registerWithPlatformConfigList:regPlatformConfigList];

    LDViewController *view = [[LDViewController alloc] init];
    self.window.rootViewController = view;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
//    return [LDSDKManager handleOpenURL:url];
    return [LDSDKManager handleOpenURL:url];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
//    return [LDSDKManager handleOpenURL:url];
    return [LDSDKManager handleOpenURL:url];
}

@end

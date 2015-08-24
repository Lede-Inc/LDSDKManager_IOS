# LDSDKManager
===============

>对应用中集成的第三方SDK（目前包括QQ,微信,易信,支付宝）进行集中管理，按照功能（目前包括第三方登录,分享,支付）开放给各个产品使用。通过接口的方式进行产品集成，方便对第三方SDK进行升级维护。


## 如何集成LDSDKManager
-------------------

### Pod集成

>
强烈推荐采用Pod集成。具体方法如下：

1.  Clone线上repo仓库到本地 (第一次创建私有类库引用)

pod repo add podspec https://git.ms.netease.com/commonlibraryios/podspec.git 
pod repo update podspec

2. 在项目工程的Podfile文件中加载LDSDKManager库：

pod 'LDSDKManager'


### 代码拷贝集成

>
如果没有私有库Pod访问权限（可以联系技术支持），也可以拷贝工程中[LDSDKManager文件夹](LDSDKManager) 到你所在项目的工程文件夹中 进行代码集成；


## 如何使用LDSDKManager
---------------------------------

> 通过pod或者代码拷贝manager代码到工程之后，即可通过如下方式调用SDKManager管理的功能：

1. 在应用的appdelegate的didFinishLaunchingWithOptions函数中配置SDK的初始化参数，格式示例：

    	NSArray *regPlatformConfigList = @[
    	@{
    	    LDSDKConfigAppIdKey:@"微信appid",
    	    LDSDKConfigAppSecretKey:@"微信appsecret",
    	    LDSDKConfigAppDescriptionKey:@"应用描述",
    	    LDSDKConfigAppPlatformTypeKey:@(LDSDKPlatformWeChat)
    	},
    	@{
    	    LDSDKConfigAppIdKey:@"QQ appid",
    	    LDSDKConfigAppSecretKey:@"qq appkey",
    	    LDSDKConfigAppPlatformTypeKey:@(LDSDKPlatformQQ)
    	},
    	@{
    	    LDSDKConfigAppIdKey:@"易信appid",
    	    LDSDKConfigAppSecretKey:@"易信appsecret",
    	    LDSDKConfigAppPlatformTypeKey:@(LDSDKPlatformYiXin)
    	},
    	@{
    	    LDSDKConfigAppSchemeKey:@"支付宝 appScheme",
            LDSDKConfigAppPlatformTypeKey:@(LDSDKPlatformAliPay)
    	},
    	];
    	[LDSDKManager registerWithPlatformConfigList:regPlatformConfigList];

2. 配置应用回调时，首先配置info.plist中的URL types，然后在appdelegate中添加代码：

    	-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
    	{
    	    return [LDSDKManager handleOpenURL:url];
    	}
    	
    	-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
    	{
    	    return [LDSDKManager handleOpenURL:url];
    	}

3. 需要登陆时，提供对应函数：

        + (BOOL)isAppInstalled:(LDSDKPlatformType)type；
        + (void)loginFromPlatformType:(LDSDKPlatformType)type withCallback:(LDSDKLoginCallback)callback;

4. 需要分享时，提供对应函数：

        + (NSArray *)availableSharePlatformList;
        + (void)shareToPlatform:(LDSDKPlatformType)platformType
                    shareModule:(LDSDKShareToModule)shareModule
                       withDict:(NSDictionary *)dict
                     onComplete:(LDSDKShareCallback)complete;

5. 需要支付时，提供对应函数：

        + (void)payOrderWithType:(LDSDKPlatformType)payType 
                     orderString:(NSString *)orderString 
                        callback:(LDSDKPayCallback)callback;



## Author

张海洋, zhanghaiyang@corp.netease.com

## License

LDSDKManager is available under the MIT license. See the LICENSE file for more info.

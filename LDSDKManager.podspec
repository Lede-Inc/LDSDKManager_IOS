Pod::Spec.new do |s|
    s.name             = "LDSDKManager"
    s.version          = "0.1.0"
    s.summary          = "LD SDKs"
    s.description      = "对应用中应用到的第三方SDK（目前包括QQ,微信,易信,支付宝）进行集中管理，按照功能（目前包括第三方登录,分享,支付）开放给各个产品使用。通过接口的方式进行产品集成，方便对第三方SDK进行升级维护。"
    s.license          = 'MIT'
    s.author           = { "张海洋" => "zhanghaiyang@corp.netease.com" }
    s.homepage         = "https://git.ms.netease.com/commonlibraryios/LDSDKManager"
    s.source           = { :git => "https://git.ms.netease.com/commonlibraryios/LDSDKManager.git", :tag => s.version.to_s }

    s.platform     = :ios, '6.0'
    s.requires_arc = true

    #组件对外提供服务接口
    s.subspec 'CoreService' do |ss|
        ss.public_header_files = 'LDSDKManager/CoreService/LDSDKManager.h',
                                     'LDSDKManager/CoreService/LDSDKCommon.h'
        ss.source_files = 'LDSDKManager/CoreService/**/*.{h,m,mm}'
    end

    #QQ平台SDK集成
    s.subspec 'QQPlatform' do |ss|
        ss.source_files = 'LDSDKManager/QQPlatform/**/*.{h,m,mm}'
        ss.vendored_frameworks = 'LDSDKManager/QQPlatform/LDQQSDK/TencentOpenAPI.framework'
        ss.resources = ['LDSDKManager/QQPlatform/**/*.{bundle}']
        ss.dependency 'LDSDKManager/CoreService'
    end

    #微信平台SDK集成
    s.subspec 'WechatPlatform' do |ss|
        ss.source_files = 'LDSDKManager/WechatPlatform/**/*.{h,m,mm}'
        ss.vendored_library = 'LDSDKManager/WechatPlatform/WeChatSDK/libWeChatSDK.a'
        ss.frameworks = 'MobileCoreServices', 'SystemConfiguration'
        ss.libraries = 'z', 'sqlite3.0', 'c++'
        ss.dependency 'LDSDKManager/CoreService'
    end

    #易信平台SDK集成
    s.subspec 'YixinPlatform' do |ss|
        ss.source_files = 'LDSDKManager/YixinPlatform/**/*.{h,m,mm}'
        ss.vendored_library = 'LDSDKManager/YixinPlatform/YiXinSDK/libYixinSDK.a'
        ss.dependency 'LDSDKManager/CoreService'
    end

    #支付宝平台SDK集成
    s.subspec 'AlipayPlatform' do |ss|
        ss.source_files = 'LDSDKManager/AlipayPlatform/**/*{h,m,mm}'
        ss.vendored_frameworks = 'LDSDKManager/AlipayPlatform/AliSDK/AlipaySDK.framework'
        ss.resources = ['LDSDKManager/AlipayPlatform/**/*.{bundle}']
        ss.dependency 'JSONKit-NoWarning', '~> 1.2'
        ss.dependency 'LDSDKManager/CoreService'
    end

    s.frameworks = 'UIKit', 'CoreGraphics', 'Foundation'
end

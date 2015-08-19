Pod::Spec.new do |s|
  s.name             = "LDSDKManager"
  s.version          = "0.1.0"
  s.summary          = "A short description of LDSDKManager."

  s.description      = <<-DESC
                       DESC

  s.homepage         = "https://git.ms.netease.com/commonlibraryios/LDSDKManager"
  s.license          = 'MIT'
  s.author           = { "张海洋" => "zhanghaiyang@corp.netease.com" }
  s.source           = { :git => "https://git.ms.netease.com/commonlibraryios/LDSDKManager.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.subspec 'CoreService' do |ss|
    ss.ios.deployment_target = '7.0'
    ss.ios.public_header_files = 'LDSDKManager/CoreService/LDSDKManager.h',
                                 'LDSDKManager/CoreService/LDSDKCommon.h'
    ss.ios.source_files = 'LDSDKManager/CoreService', 'LDSDKManager/CoreService/LDSDKServices'
  end

  s.subspec 'QQPlatform' do |ss|
    ss.ios.dependency 'LDSDKManager/CoreService'
    ss.ios.vendored_frameworks = 'LDSDKManager/QQPlatform/LDQQSDK/TencentOpenAPI.framework'
    ss.ios.resources = ['LDSDKManager/QQPlatform/LDQQSDK/TencentOpenApi_IOS_Bundle.bundle']
    ss.ios.source_files = 'LDSDKManager/QQPlatform'
  end

  s.subspec 'WechatPlatform' do |ss|
    ss.ios.dependency 'LDSDKManager/CoreService'
    ss.ios.source_files = 'LDSDKManager/WechatPlatform',
                          'LDSDKManager/WechatPlatform/HTTPRequest',
                          'LDSDKManager/WechatPlatform/WechatCommon',
                          'LDSDKManager/WechatPlatform/WeChatSDK/*.h'
    ss.ios.vendored_library = 'LDSDKManager/WechatPlatform/WeChatSDK/libWeChatSDK.a'
    ss.frameworks = 'SystemConfiguration'
    ss.libraries = 'z', 'sqlite3.0', 'c++'
  end

  s.subspec 'YixinPlatform' do |ss|
    ss.ios.dependency 'LDSDKManager/CoreService'
    ss.ios.source_files = 'LDSDKManager/YixinPlatform',
                          'LDSDKManager/YixinPlatform/YiXinSDK/*.h'
    ss.ios.vendored_library = 'LDSDKManager/YixinPlatform/YiXinSDK/libYixinSDK.a'
  end

  s.subspec 'AlipayPlatform' do |ss|
    ss.ios.dependency 'JSONKit-NoWarning', '~> 1.2'
    ss.ios.dependency 'LDSDKManager/CoreService'
    ss.ios.vendored_frameworks = 'LDSDKManager/AlipayPlatform/AliSDK/AlipaySDK.framework'
    ss.ios.resources = ['LDSDKManager/AlipayPlatform/AliSDK/AlipaySDK.bundle']
    ss.ios.source_files = 'LDSDKManager/AlipayPlatform'
  end

  # s.source_files = 'Pod/Classes/**/*'
  # s.resource_bundles = {
  #   'LDSDKManager' => ['Pod/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'CoreGraphics', 'Foundation'
  # s.dependency 'AFNetworking', '~> 2.3'
end

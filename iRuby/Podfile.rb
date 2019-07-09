# --------------
# Uncomment this line to define a global platform for your project
# Podfile其实是定义CocoaPods库执行某些方法的参数
# pod  其实都是CocoaPods的function
# --------------
platform :ios, '8.0'
use_frameworks!

# File.expand_path('../easyrtc_pod.rb', __FILE__) : 根据第二个参数返回第一个参数的abs_path
# __FILE__: 当前文件路径
require File.expand_path('../easyrtc_pod.rb', __FILE__)
extend EasyrtcPod

abstract_target 'CommonPods' do
    pod 'pop', '~> 1.0'
    pod 'SDWebImage', '~>4.0.0'
    pod 'MJRefresh', '~>2.4'
    pod 'Masonry', '~> 1.1'
    pod 'Branch'
    pod 'DTCoreText', '~> 1.6'
    pod 'GRMustache', '~> 7.3'
    
    pod 'UITextView+Placeholder', '~> 1.2'
    pod 'Reveal-iOS-SDK', :configurations => ['Debug', 'Debug-without-easyrtc', 'Adhoc']
    pod 'MGSwipeTableCell'
    pod 'TTTAttributedLabel'
    
    pod 'PushClient', :path => "../NewAFS_Server/server/push/protocol/"
    
    pod 'SnapKit', '~> 3.2'
    
    pod 'SachsenKit', :git => "https://github.com/StringsTech/SachsenKit.git"
    pod 'ChatKit', :git => "https://github.com/StringsTech/ChatKit.git"

    pod 'YYImage', :git => "https://github.com/iCrany/YYImage.git"
    
    pod 'FDFullscreenPopGesture', '1.1'
    pod 'Shimmer', '~> 1.0'
    
    pod 'MBProgressHUD', '~> 1.0.0'

    # 这个是我们自定义的pod方法, 类比下pod方法理解
    easyrtc_pod '283.0.0', :configurations => ['Debug', 'Adhoc', 'Release']
    
    pod 'easyrtc_objc_dummy', :git => "https://github.com/StringsTech/EasyrtcObjcDummy.git", :configuration => 'Debug-without-easyrtc'
    
    pod 'libPhoneNumber-iOS', '~> 0.9'
    pod 'UMengAnalytics-NO-IDFA', '~> 4.2.5'
    pod 'AMap3DMap-NO-IDFA', '~> 5.0'
    pod 'AMapLocation-NO-IDFA', '~> 2.3'
    pod 'AMapSearch-NO-IDFA', '~> 5.0'
    pod 'AMapFoundation-NO-IDFA', '~> 1.3'
    pod 'Bugtags', '~> 3.0.0’
    
    pod 'WeiboSDK', :git => 'https://github.com/sinaweibosdk/weibo_ios_sdk.git'
    pod 'TencentOpenAPIV2_3', '~> 3.1'
    pod 'libWeChatSDK', '~> 1.7'
    pod 'JPFPSStatus', '~> 0.1'
    
    ##Can't use :configuration in below target
    target 'AtFirstSight' do
        
        target 'AtFirstSightTests' do
            inherit! :search_paths
        end
        
    end
end

def mute_pushclient_logging(installer)
    done = false
    installer.pods_project.targets.each do |target|
        if target.name == 'PushClient'
            target.build_configurations.each do |config|
                #  注意 || 和 && 计算顺序
                #  config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] || ['$(inherited)']
                #  '$(inherited)': '' 里面的内容一般就是值,没有什么特殊的涵义. 再说ruby里面没有见过 $()
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << "_LOG_LEVEL=_LOG_LEVEL_WARN"
            end
            done = true
        end
    end
    if !done
        logerror 'Warning: could not found target "PushClient", unable to mute logging for it.'
    end
end

post_install do |installer|
    mute_pushclient_logging installer
    
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
          # 忽略pod target 警告
          config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
        end
    end

end

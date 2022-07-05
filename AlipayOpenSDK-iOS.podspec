Pod::Spec.new do |spec|
    spec.name                   = 'AlipayOpenSDK-iOS'
    spec.version                = '15.8.10' # 版本号和支付宝的保持一致
    spec.homepage               = 'https://github.com/liujunliuhong/AlipayOpenSDK'
    spec.source                 = { :git => 'https://github.com/liujunliuhong/AlipayOpenSDK.git', :tag => spec.version }
    spec.summary                = 'Alipay open SDK'
    spec.license                = { :type => 'MIT', :file => 'LICENSE' }
    spec.author                 = { 'liujunliuhong' => '1035841713@qq.com' }
    spec.platform               = :ios, '9.0'
    spec.ios.deployment_target  = '9.0'
    spec.requires_arc           = true
    spec.vendored_frameworks 	= 'Alipay_SDK/iOS_SDK/AlipaySDK.framework'
    spec.resource               = 'Alipay_SDK/iOS_SDK/AlipaySDK.bundle'
    spec.frameworks             = 'UIKit', 'Foundation', 'CFNetwork', 'SystemConfiguration', 'QuartzCore', 'CoreGraphics', 'CoreMotion', 'CoreTelephony', 'CoreText', 'WebKit'
    spec.libraries              = 'z', 'c++'
    spec.pod_target_xcconfig    = {
        'OTHER_LDFLAGS' => '-all_load',
        'VALID_ARCHS' => 'x86_64 armv7 arm64'
    }
end

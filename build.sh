#!/bin/bash

echo "===============================Begin Build======================================"

LOCAL_Alipay_ZIP="Alipay_SDK.zip"                          # Alipay互联SDK压缩包名字
LOCAL_Alipay_UNZIP_DIRECTORY="Alipay_SDK"                  # Alipay互联SDK解压缩之后，文件夹名字
LOCAL_Alipay_PODSPEC_FILE_NAME="AlipayOpenSDK-iOS.podspec" # Alipay互联SDK podspec文件名
LOCAL_Alipay_PODSPEC_NAME="AlipayOpenSDK-iOS"              # Alipay互联SDK podspec name

LAST_LOCAL_Alipay_PODSPEC_VERSION=""                       # 本地podspec文件上次的版本号

function getLocalPodVersion() {
    if [ -f "${LOCAL_Alipay_PODSPEC_FILE_NAME}" ]; then
        pattern=".*\.version.*\'.*\'.*"
        version=$(cat ${LOCAL_Alipay_PODSPEC_FILE_NAME} | grep "${pattern}")
        version="${version#*\'}" # 从左向右截取第一个'后的字符串
        version="${version%\'*}" # 从右向左截取第一个'后的字符串
        echo "获取${LOCAL_Alipay_PODSPEC_FILE_NAME}的pod版本成功，版本：${version}"
        LAST_LOCAL_Alipay_PODSPEC_VERSION=${version}
        # echo -e "\n"
    else
        echo "${LOCAL_Alipay_PODSPEC_FILE_NAME}不存在，需要新建"
        # echo -e "\n"
    fi
}


# 获取本地podspec文件的version，以便于和官方version做比较
getLocalPodVersion
echo "本地podspec版本: ${LAST_LOCAL_Alipay_PODSPEC_VERSION}"


# Alipay_SDK_VERSION="15.8.07"
Alipay_SDK_VERSION="15.8.10"
Alipay_SDK_DOWNLOAD_URL="https://gw.alipayobjects.com/os/bmw-prod/41dbf55a-3110-4c0b-9463-b6f4dbe9d406.zip"

echo "支付宝iOS SDK最新版本: ${Alipay_SDK_VERSION}"
echo "当前支付宝iOS SDK下载地址: ${Alipay_SDK_DOWNLOAD_URL}"



rm -rf ${LOCAL_Alipay_ZIP}
rm -rf ${LOCAL_Alipay_UNZIP_DIRECTORY}
curl -s "${Alipay_SDK_DOWNLOAD_URL}" >${LOCAL_Alipay_ZIP}
unzip ${LOCAL_Alipay_ZIP} -d ${LOCAL_Alipay_UNZIP_DIRECTORY}

function makePodSpec() {
    echo "创建podspec文件"
    rm -rf ${LOCAL_Alipay_PODSPEC_FILE_NAME}

    rm -rf ${LOCAL_Alipay_UNZIP_DIRECTORY}/iOS_SDK/AlipaySDK.framework/Modules
    mkdir ${LOCAL_Alipay_UNZIP_DIRECTORY}/iOS_SDK/AlipaySDK.framework/Modules
    cat <<-EOF >${LOCAL_Alipay_UNZIP_DIRECTORY}/iOS_SDK/AlipaySDK.framework/Modules/module.modulemap
framework module AlipaySDK {
    umbrella header "AlipaySDK.h"
    export *
    module * { export * }
}
EOF

    cat <<-EOF >${LOCAL_Alipay_PODSPEC_FILE_NAME}
Pod::Spec.new do |spec|
    spec.name                   = '${LOCAL_Alipay_PODSPEC_NAME}'
    spec.version                = '${Alipay_SDK_VERSION}' # 版本号和支付宝的保持一致
    spec.homepage               = 'https://github.com/liujunliuhong/AlipayOpenSDK'
    spec.source                 = { :git => 'https://github.com/liujunliuhong/AlipayOpenSDK.git', :tag => spec.version }
    spec.summary                = 'Alipay open SDK'
    spec.license                = { :type => 'MIT', :file => 'LICENSE' }
    spec.author                 = { 'liujunliuhong' => '1035841713@qq.com' }
    spec.platform               = :ios, '9.0'
    spec.ios.deployment_target  = '9.0'
    spec.requires_arc           = true
    spec.vendored_frameworks 	= '${LOCAL_Alipay_UNZIP_DIRECTORY}/iOS_SDK/AlipaySDK.framework'
    spec.resource               = '${LOCAL_Alipay_UNZIP_DIRECTORY}/iOS_SDK/AlipaySDK.bundle'
    spec.frameworks             = 'UIKit', 'Foundation', 'CFNetwork', 'SystemConfiguration', 'QuartzCore', 'CoreGraphics', 'CoreMotion', 'CoreTelephony', 'CoreText', 'WebKit'
    spec.libraries              = 'z', 'c++'
    spec.pod_target_xcconfig    = {
        'OTHER_LDFLAGS' => '-all_load',
        'VALID_ARCHS' => 'x86_64 armv7 arm64'
    }
end
EOF
}

# 创建podspec文件
makePodSpec

# 输出podspec文件内容
cat ${LOCAL_Alipay_PODSPEC_FILE_NAME}

echo "开始验证pod..."
pod lib lint --allow-warnings
echo "pod验证完毕"

echo "请手动执行pod trunk push --allow-warnings"

echo "===============================End Build======================================"

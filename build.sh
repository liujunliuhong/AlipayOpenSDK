#!/bin/bash

echo "===============================Begin Build======================================"

ALIPAY_MAIN_PAGE_URL="https://opendocs.alipay.com/open/"
ALIPAY_MAIN_HTML_FILE="AlipayMain.html"
MAIN_REPO_CODE=""

Alipay_SDK_DOWNLOAD_URL=""                                 # Alipay互联SDK下载地址
Alipay_SDK_VERSION=""                                      # Alipay互联SDK版本号
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
        echo "${LOCAL_Alipay_PODSPEC_FILE_NAME}不存在"
        # echo -e "\n"
    fi
}

function getMainRepoCode() {
    if [ -f "${ALIPAY_MAIN_HTML_FILE}" ]; then
        pattern="mainRepoCode\":\"[a-zA-Z0-9]*\""
        MAIN_REPO_CODE=$(grep -o "${pattern}" ${ALIPAY_MAIN_HTML_FILE} | sed 's/mainRepoCode\":\"//g' | sed 's/\"//g')
        echo "MainRepoCode: ${MAIN_REPO_CODE}"
        # echo -e "\n"
    else
        echo "${ALIPAY_MAIN_HTML_FILE}不存在"
        # echo -e "\n"
    fi
}

# 获取本地podspec文件的version，以便于和官方version做比较
getLocalPodVersion
echo "本地podspec版本: ${LAST_LOCAL_Alipay_PODSPEC_VERSION}"

rm -rf ${ALIPAY_MAIN_HTML_FILE}
curl ${ALIPAY_MAIN_PAGE_URL} >${ALIPAY_MAIN_HTML_FILE}

getMainRepoCode

ALIPAY_NAVIGATOR_URL="https://opendocs.alipay.com/api/navigator/${MAIN_REPO_CODE}?_output_charset=utf-8&_input_charset=utf-8"
ALIPAY_NAVIGATOR_JSON_FILE="AlipayNavigator.json"
echo "Navigator URL: ${ALIPAY_NAVIGATOR_URL}"

# shell json解析
# brew install jq

rm -rf ${ALIPAY_NAVIGATOR_JSON_FILE}
curl -s "${ALIPAY_NAVIGATOR_URL}" | jq . >${ALIPAY_NAVIGATOR_JSON_FILE}

CATALOG_CODE=$(cat ${ALIPAY_NAVIGATOR_JSON_FILE} | jq '.[0].childrenCatalog[3].catalogCode' | sed 's/\"//g')
echo "CatalogCode: ${CATALOG_CODE}"

CATALOG_CODE_URL="https://opendocs.alipay.com/api/catalogChildren/${MAIN_REPO_CODE}/${CATALOG_CODE}?_output_charset=utf-8&_input_charset=utf-8"
CATALOG_CODE_JSON_FILE="CatalogCode.json"
echo "CatalogCode URL: ${CATALOG_CODE_URL}"

rm -rf ${CATALOG_CODE_JSON_FILE}
curl -s "${CATALOG_CODE_URL}" | jq . >${CATALOG_CODE_JSON_FILE}

DEMO_CATALOG_CODE=$(cat ${CATALOG_CODE_JSON_FILE} | jq '.[0].childrenCatalog[3].childrenCatalog[3].catalogCode' | sed 's/\"//g')
echo "Demo CatalogCode: ${DEMO_CATALOG_CODE}"

DEMO_CATALOG_CODE_URL="https://opendocs.alipay.com/api/content/${DEMO_CATALOG_CODE}?_output_charset=utf-8&_input_charset=utf-8"
DEMO_CATALOG_CODE_JSON_FILE="DemoCatalogCode.json"
echo "Deno CatalogCode URL: ${DEMO_CATALOG_CODE_URL}"

rm -rf ${DEMO_CATALOG_CODE_JSON_FILE}
curl -s "${DEMO_CATALOG_CODE_URL}" | jq . >${DEMO_CATALOG_CODE_JSON_FILE}

DEMO_CATALOG_CODE_TEXT_FILE="DemoCatalogCodeText.txt"
rm -rf ${DEMO_CATALOG_CODE_TEXT_FILE}
cat ${DEMO_CATALOG_CODE_JSON_FILE} | jq '.result.text' | sed 's/ [^(href)][a-zA-Z-]*=[^<=]*\"//g' >${DEMO_CATALOG_CODE_TEXT_FILE}

version_pattern="<span>[0-9.]+</span>.+iOS 支付 SDK 和示例项目"
Alipay_SDK_VERSION=$(cat ${DEMO_CATALOG_CODE_TEXT_FILE} | grep -o -E "${version_pattern}" | grep -o -E ">[0-9.]+<")
Alipay_SDK_VERSION="${Alipay_SDK_VERSION#*>}"
Alipay_SDK_VERSION="${Alipay_SDK_VERSION%<*}"
echo "当前支付宝iOS SDK版本: ${Alipay_SDK_VERSION}"

download_url_pattern="<p><a href=.+\.zip.+iOS 支付 SDK 和示例项目"
Alipay_SDK_DOWNLOAD_URL=$(cat ${DEMO_CATALOG_CODE_TEXT_FILE} | grep -o -E "${download_url_pattern}" | grep -o -E "http.+\.zip")
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

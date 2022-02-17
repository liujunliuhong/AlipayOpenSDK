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

# function getLocalPodVersion() {
#     if [ -f "${LOCAL_QQ_PODSPEC_FILE_NAME}" ]; then
#         pattern=".*\.version.*\'.*\'.*"
#         version=$(cat ${LOCAL_QQ_PODSPEC_FILE_NAME} | grep "${pattern}")
#         version="${version#*\'}" # 从左向右截取第一个'后的字符串
#         version="${version%\'*}" # 从右向左截取第一个'后的字符串
#         echo "获取${LOCAL_QQ_PODSPEC_FILE_NAME}的pod版本成功，版本：${version}"
#         LAST_LOCAL_QQ_PODSPEC_VERSION=${version}
#         # echo -e "\n"
#     else
#         echo "${LOCAL_QQ_PODSPEC_FILE_NAME}不存在"
#         # echo -e "\n"
#     fi
# }

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

# function getAlipayProperties() {
#     if [ -f "${LOCAL_QQ_DOWNLOAD_HTML_FILE}" ]; then
#         pattern="<td><a href=\"[^<]*\">iOS_SDK_V[^<]*</a></td>"

#         url1=$(cat ${LOCAL_QQ_DOWNLOAD_HTML_FILE} | grep -o -E "${pattern}")
#         url1="${url1#*\"}" # 从左向右截取第一个["]后的字符串
#         url1="${url1%\"*}" # 从右向左截取第一个["]前的字符串
#         echo "QQ互联官方下载url：${url1}"
#         QQ_SDK_DOWNLOAD_URL=${url1}

#         version1=$(cat ${LOCAL_QQ_DOWNLOAD_HTML_FILE} | grep -o -E "${pattern}")
#         version1="${version1#*\iOS_SDK_V}" # 从左向右截取第一个[iOS_SDK_V]后的字符串
#         version1="${version1%\</a></td>*}" # 从右向左截取第一个[</a></td>]前的字符串
#         echo "QQ互联官方的版本号：${version1}"
#         QQ_SDK_VERSION=${version1}
#         # echo -e "\n"
#     else
#         echo "${LOCAL_QQ_DOWNLOAD_HTML_FILE}不存在"
#         # echo -e "\n"
#     fi
# }

# 获取本地podspec文件的version，以便于和官方version做比较
# getLocalPodVersion

# # 移除压缩文件夹
# rm -rf ${LOCAL_Alipay_ZIP}

# # 移除解压缩文件夹
# rm -rf ${LOCAL_Alipay_UNZIP_DIRECTORY}


rm -rf ${ALIPAY_MAIN_HTML_FILE}
curl ${ALIPAY_MAIN_PAGE_URL} >${ALIPAY_MAIN_HTML_FILE}

getMainRepoCode

ALIPAY_NAVIGATOR_URL="https://opendocs.alipay.com/api/navigator/${MAIN_REPO_CODE}?_output_charset=utf-8&_input_charset=utf-8"
ALIPAY_NAVIGATOR_JSON_FILE="AlipayNavigator.json"

echo "Navigator URL: ${ALIPAY_NAVIGATOR_URL}"

# brew install jq

rm -rf ${ALIPAY_NAVIGATOR_JSON_FILE}
curl -s "${ALIPAY_NAVIGATOR_URL}" | jq . > ${ALIPAY_NAVIGATOR_JSON_FILE}

CATALOG_CODE=$(cat ${ALIPAY_NAVIGATOR_JSON_FILE} | jq '.[0].childrenCatalog[3].catalogCode'  | sed 's/\"//g')
echo "CatalogCode: ${CATALOG_CODE}"

CATALOG_CODE_URL="https://opendocs.alipay.com/api/catalogChildren/${MAIN_REPO_CODE}/${CATALOG_CODE}?_output_charset=utf-8&_input_charset=utf-8"
CATALOG_CODE_JSON_FILE="CatalogCode.json"
echo "CatalogCode URL: ${CATALOG_CODE_URL}"

rm -rf ${CATALOG_CODE_JSON_FILE}
curl -s "${CATALOG_CODE_URL}" | jq . > ${CATALOG_CODE_JSON_FILE}

DEMO_CATALOG_CODE=$(cat ${CATALOG_CODE_JSON_FILE} | jq '.[0].childrenCatalog[3].childrenCatalog[3].catalogCode'  | sed 's/\"//g')
echo "Demo CatalogCode: ${DEMO_CATALOG_CODE}"


DEMO_CATALOG_CODE_URL="https://opendocs.alipay.com/api/content/${DEMO_CATALOG_CODE}?_output_charset=utf-8&_input_charset=utf-8"
DEMO_CATALOG_CODE_JSON_FILE="DemoCatalogCode.json"
echo "dEMO CatalogCode URL: ${DEMO_CATALOG_CODE_URL}"

rm -rf ${DEMO_CATALOG_CODE_JSON_FILE}
curl -s "${DEMO_CATALOG_CODE_URL}" | jq . > ${DEMO_CATALOG_CODE_JSON_FILE}





# 获取QQ互联官方SDK官方属性（sdk下载url，sdk版本）
# getQQProperties

# # 下载zip
# curl "${QQ_SDK_DOWNLOAD_URL}" -o ${LOCAL_QQ_ZIP}

# # 解压缩zip
# unzip ${LOCAL_QQ_ZIP} -d ${LOCAL_QQ_UNZIP_DIRECTORY}

# function makePodSpec() {
#     if [ "${LAST_LOCAL_QQ_PODSPEC_VERSION}" != "${QQ_SDK_VERSION}" ]; then
#         echo "开始制作包podspec文件，版本号不相等，重新创建podspec文件"
#         rm -rf ${LOCAL_QQ_PODSPEC_FILE_NAME}

#         rm -rf ${LOCAL_QQ_UNZIP_DIRECTORY}/TencentOpenAPI.framework/Headers/TencentOpenApiUmbrellaHeader.h
#         rm -rf ${LOCAL_QQ_UNZIP_DIRECTORY}/TencentOpenAPI.framework/Headers/TencentOpenAPI.h
#         touch ${LOCAL_QQ_UNZIP_DIRECTORY}/TencentOpenAPI.framework/Headers/TencentOpenAPI.h
#         cat <<-EOF >${LOCAL_QQ_UNZIP_DIRECTORY}/TencentOpenAPI.framework/Headers/TencentOpenAPI.h
# // 这个文件是我自己创建的，QQ原来的'TencentOpenApiUmbrellaHeader.h'里，把'#import "SDKDef.h"'拼写错了
# #import "QQApiInterface.h"
# #import "QQApiInterfaceObject.h"
# #import "sdkdef.h"
# #import "TencentOAuth.h"
# EOF

#         rm -rf ${LOCAL_QQ_UNZIP_DIRECTORY}/TencentOpenAPI.framework/Headers/*.modulemap
#         rm -rf ${LOCAL_QQ_UNZIP_DIRECTORY}/TencentOpenAPI.framework/Modules
#         mkdir ${LOCAL_QQ_UNZIP_DIRECTORY}/TencentOpenAPI.framework/Modules
#         cat <<-EOF >${LOCAL_QQ_UNZIP_DIRECTORY}/TencentOpenAPI.framework/Modules/module.modulemap
# framework module TencentOpenAPI {
#     umbrella header "TencentOpenAPI.h"
#     export *
#     module * { export * }
# }
# EOF

#         cat <<-EOF >${LOCAL_QQ_PODSPEC_FILE_NAME}
# Pod::Spec.new do |spec|
#     spec.name                   = '${LOCAL_QQ_PODSPEC_NAME}'
#     spec.version                = '${QQ_SDK_VERSION}' # 版本号和QQ的保持一致
#     spec.homepage               = 'https://github.com/liujunliuhong/TencentOpenSDK'
#     spec.source                 = { :git => 'https://github.com/liujunliuhong/TencentOpenSDK.git', :tag => spec.version }
#     spec.summary                = 'Tencent open SDK'
#     spec.license                = { :type => 'MIT', :file => 'LICENSE' }
#     spec.author                 = { 'liujunliuhong' => '1035841713@qq.com' }
#     spec.platform               = :ios, '9.0'
#     spec.ios.deployment_target  = '9.0'
#     spec.requires_arc           = true
#     spec.vendored_frameworks 	= '${LOCAL_QQ_UNZIP_DIRECTORY}/*.framework'
#     spec.resource               = '${LOCAL_QQ_UNZIP_DIRECTORY}/*.bundle'
#     spec.frameworks             = 'Security', 'SystemConfiguration', 'CoreTelephony', 'CoreGraphics', 'WebKit'
#     spec.libraries              = 'iconv', 'z', 'stdc++', 'sqlite3', 'c++'
#     spec.pod_target_xcconfig    = {
#         'OTHER_LDFLAGS' => '-all_load',
#         'VALID_ARCHS' => 'x86_64 armv7 arm64'
#     }
# end
# EOF
#     else
#         echo "开始制作包含支付功能的podspec文件，版本号相等，不再重新创建podspec文件"
#     fi
# }

# # 创建podspec文件
# makePodSpec

# # 输出podspec文件内容
# cat ${LOCAL_QQ_PODSPEC_FILE_NAME}

# echo "开始验证pod..."
# pod lib lint ${LOCAL_QQ_PODSPEC_FILE_NAME} --allow-warnings
# echo "pod验证完毕"

# echo "请手动执行pod trunk push --allow-warnings"

echo "===============================End Build======================================"

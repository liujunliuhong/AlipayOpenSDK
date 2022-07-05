# AlipayOpenSDK

<div>
<a href="https://opendocs.alipay.com/open">支付宝官方文档</a>
</div>
<br>

&emsp;&emsp;支付宝官方支付`SDK`支持`pod`导入，但不支持`Swift module`。为了解决这个问题，我制作了该`pod`。<br>
&emsp;&emsp;支持`Swift`。<br>
&emsp;&emsp;我只是一个搬运工😄。<br>

## 当前pod库支持的支付宝支付SDK版本

```
15.8.10
```

## 版本要求
`iOS`版本必须是`9.0`及以上

## 安装

推荐使用`CocoaPods`

```
pod 'AlipayOpenSDK-iOS'
```

或者指定git源

```
pod 'AlipayOpenSDK-iOS', :git => "https://github.com/liujunliuhong/AlipayOpenSDK.git"
```

## 使用
Swift
```
import AlipaySDK
```

OC
```
@import AlipaySDK;
```

或者

```
#import <AlipaySDK/AlipaySDK.h>
```

## 说明
- `pod`版本和支付宝官方版本保持一致，比如`pod`版本是`15.8.07`，表示当前使用的官方`SDK`版本也是`15.8.07`
- 我只是一个搬运工，`pod`库的更新依赖于官方，即官方更新了`SDK`，我的`pod`库才会更新
//
//  APWebViewController.h
//  AliSDKDemo
//
//  Created by antfin on 17-10-24.
//  Copyright (c) 2017年 AntFin. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface APWebViewController : UIViewController<WKNavigationDelegate>

@property (strong, nonatomic) IBOutlet WKWebView *webView;

@end

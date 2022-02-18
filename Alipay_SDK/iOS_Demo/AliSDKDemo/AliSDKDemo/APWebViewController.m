//
//  APWebViewController.m
//  AliSDKDemo
//
//  Created by antfin on 17-10-24.
//  Copyright (c) 2017年 AntFin. All rights reserved.
//

#import "APWebViewController.h"
#import <AlipaySDK/AlipaySDK.h>

@interface APWebViewController ()

@property (nonatomic, strong)UIView* maskView;
@property (nonatomic, strong)UIView* urlInputView;
@property (nonatomic, strong)UITextField* urlInput;

@end


@implementation APWebViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.webView.navigationDelegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView = [[WKWebView alloc]initWithFrame:self.view.frame configuration:[[WKWebViewConfiguration alloc]init]];
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    // 加载已经配置的url
    NSString* webUrl = [[NSUserDefaults standardUserDefaults]objectForKey:@"alipayweburl"];
    if (webUrl.length > 0) {
        [self loadWithUrlStr:webUrl];
    }
}


#pragma mark -
#pragma mark   ============== webview相关 回调及加载 WKWebView ==============
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    __weak APWebViewController* wself = self;
    NSString * urlStr = navigationAction.request.URL.absoluteString;
    BOOL isIntercepted = [[AlipaySDK defaultService] payInterceptorWithUrl:urlStr fromScheme:@"alisdkdemo" callback:^(NSDictionary *result) {
        // 处理支付结果
        NSLog(@"%@", result);
        // isProcessUrlPay 代表 支付宝已经处理该URL
        if ([result[@"isProcessUrlPay"] boolValue]) {
            // returnUrl 代表 第三方App需要跳转的成功页URL
            NSString* urlStr = result[@"returnUrl"];
            [wself loadWithUrlStr:urlStr];
        }
    }];
    
    if (isIntercepted) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark   ==============  UIWebView ==============
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    //新版本的H5拦截支付对老版本的获取订单串和订单支付接口进行合并，推荐使用该接口
//    __weak APWebViewController* wself = self;
//    BOOL isIntercepted = [[AlipaySDK defaultService] payInterceptorWithUrl:[request.URL absoluteString] fromScheme:@"alisdkdemo" callback:^(NSDictionary *result) {
//        // 处理支付结果
//        NSLog(@"%@", result);
//        // isProcessUrlPay 代表 支付宝已经处理该URL
//        if ([result[@"isProcessUrlPay"] boolValue]) {
//            // returnUrl 代表 第三方App需要跳转的成功页URL
//            NSString* urlStr = result[@"returnUrl"];
//            [wself loadWithUrlStr:urlStr];
//        }
//    }];
//
//    if (isIntercepted) {
//        return NO;
//    }
//
//    return YES;
//}

- (void)loadWithUrlStr:(NSString*)urlStr
{
    if (urlStr.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURLRequest *webRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]
                                                        cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                    timeoutInterval:30];
            [self.webView loadRequest:webRequest];
        });
    }
}


#pragma mark -
#pragma mark   ============== url 输入界面及响应==============

- (IBAction)onOpenUrlInput:(id)sender
{
    if (self.maskView == nil) {
        self.maskView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        self.maskView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
    }
    
    if (self.urlInputView == nil) {
        self.urlInputView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 105)];
        self.urlInputView.backgroundColor = [UIColor lightGrayColor];
        self.urlInputView.layer.cornerRadius = 8.0f;
        self.urlInputView.layer.masksToBounds = YES;
        
        self.urlInput = [[UITextField alloc]initWithFrame:CGRectMake(10, 15, 280, 30)];
        self.urlInput.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.urlInput.autocorrectionType = UITextAutocorrectionTypeNo;
        self.urlInput.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.urlInput.backgroundColor = [UIColor whiteColor];
        self.urlInput.layer.cornerRadius = 4.0f;
        self.urlInput.layer.masksToBounds = YES;
        [self.urlInputView addSubview:self.urlInput];
        
        UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(230, 60, 60, 30)];
        btn.backgroundColor = [UIColor colorWithRed:81.0f/255.0f green:141.0f/255.0f blue:229.0f/255.0f alpha:1.0f];
        btn.layer.cornerRadius = 4.0f;
        btn.layer.masksToBounds = YES;
        
        [btn setTitle:@"Go" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onOpenInputedUrl:) forControlEvents:UIControlEventTouchUpInside];
        [self.urlInputView addSubview:btn];
    }
    
    NSString* webUrl = [[NSUserDefaults standardUserDefaults]objectForKey:@"alipayweburl"];
    self.urlInput.text = webUrl;
    
    UIWindow* keyWnd = [UIApplication sharedApplication].keyWindow;
    if (keyWnd) {
        if (self.maskView.superview) {
            [self.maskView removeFromSuperview];
        }
        [keyWnd addSubview:self.maskView];
        
        if (self.urlInputView.superview) {
            [self.urlInputView removeFromSuperview];
        }
        [keyWnd addSubview:self.urlInputView];
        self.urlInputView.center = keyWnd.center;
        CGRect frame = self.urlInputView.frame;
        frame.origin.y = 84;
        self.urlInputView.frame = frame;
    }
}

- (IBAction)onOpenInputedUrl:(id)sender
{
    if (self.urlInputView.superview) {
        [self.urlInputView removeFromSuperview];
    }
    
    if (self.maskView.superview) {
        [self.maskView removeFromSuperview];
    }
    
    NSString* urlStr = self.urlInput.text;
    if (urlStr.length > 0) {
        if (![urlStr hasPrefix:@"http"]) {
            urlStr = [NSString stringWithFormat:@"https://%@", urlStr];
        }
        [[NSUserDefaults standardUserDefaults] setObject:urlStr forKey:@"alipayweburl"];
        [self loadWithUrlStr:urlStr];
    }
}

@end

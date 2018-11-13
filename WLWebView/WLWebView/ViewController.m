//
//  ViewController.m
//  WLWebView
//
//  Created by MAC on 2018/11/13.
//  Copyright © 2018年 MAC. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController ()<WKNavigationDelegate,WKScriptMessageHandler>
@property (nonatomic ,strong) WKWebView * webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     [self.view addSubview:self.webView];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * path = [paths objectAtIndex:0];
    path = [path stringByAppendingString:[NSString stringWithFormat:@"/app/html/ios.html"]];
    NSString * pathString = [[NSBundle mainBundle] pathForResource:@"ios" ofType:@"html" inDirectory:@"app/html"];
    
    //实现代理方法
    NSString * urlString2 = [[NSString stringWithFormat:@"?sid=%@",@"cookie"]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    //        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString2 relativeToURL:[NSURL fileURLWithPath:path]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.f]];
    //加载沙盒不带参数
    //
    //        NSString * urlString1 = [[NSString stringWithFormat:@"%@",path] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    
    //加载本地的html  ,这样有的会出现图片样式不显示的情况， 解决办法 ： Added folders  选择 Create folder references ；或者将文件压缩，拖到项目中，然后解压到沙盒目录下
    //不带参数
    //        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:pathString]]];
    //带参数
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString2 relativeToURL:[NSURL fileURLWithPath:pathString]]]];
    
    //加载服务器链接 带参数
    //        NSString * urlS = [NSString stringWithFormat:@"https://www.baidu.com?q=w"];
    //        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlS]]];
    
    //        //加载服务器链接 不带参数
    //        NSString * urlS = [NSString stringWithFormat:@"https://www.baidu.com"];
    //        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlS]]];
}

- (WKWebView *)webView {
    if (!_webView) {
        // 进行配置控制器
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        // 实例化对象
        configuration.userContentController = [WKUserContentController new];
        // 调用原生的方法
        [configuration.userContentController addScriptMessageHandler:self name:@"uploadPersonImage"];
        //        window.webkit.messageHandlers.uploadPersonImage.postMessage({body: 'goodsId=1212'}); js调用
        // 进行偏好设置
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptEnabled = YES;
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        preferences.minimumFontSize = 40.0;
        configuration.preferences = preferences;
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64) configuration:configuration];
        _webView.navigationDelegate = self;
        _webView.opaque = NO;
        _webView.backgroundColor = [UIColor whiteColor];
        if (@available(ios 11.0,*)){ _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;}
    }
    return _webView;
}

- (void)dealloc {
    [self.webView stopLoading];
    self.webView.navigationDelegate = nil;
    self.webView = nil;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    NSLog(@"%@内存释放",self);
}


// 页面开始加载时调用
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"页面开始加载时调用");
    
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"当内容开始返回时调用");
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{//这里修改导航栏的标题，动态改变
    NSLog(@"页面加载完成之后调用");
    NSString * jsString =[NSString stringWithFormat:@"sendKey('%@')",@"参数"];
    [self.webView evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
       //此处可以打印error.
    }];
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"页面加载失败时调用");
}
// 接收到服务器跳转请求之后再执行
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"接收到服务器跳转请求之后再执行");
}
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSLog(@"在收到响应后，决定是否跳转");
    NSLog(@"%@",navigationResponse);
    WKNavigationResponsePolicy actionPolicy = WKNavigationResponsePolicyAllow;
    //这句是必须加上的，不然会异常
    decisionHandler(actionPolicy);
}
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSLog(@"在发送请求之前，决定是否跳转");

    //这句是必须加上的，不然会异常
    decisionHandler(WKNavigationActionPolicyAllow);
    NSURL *requestURL = navigationAction.request.URL;
    NSLog(@"-----%@",requestURL.absoluteString);
   
    if ( [[requestURL scheme] isEqualToString:@"nwvn"]) {
    
        return;
    }
    if ( [[requestURL scheme] isEqualToString:@"nwvr"]) {
        return;
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"uploadPersonImage"]) {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

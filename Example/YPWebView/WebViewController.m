//
//  WebViewController.m
//  YPWebView
//
//  Created by apple on 16/5/29.
//  Copyright © 2016年 Gaotang.Zhang. All rights reserved.
//

#import "WebViewController.h"

#import "NJKWebViewProgressView.h"

#define HEIGHT_NAVIGATION_BAR 44.0f

@interface WebViewController ()<YPWebViewDelegate>

@property(nonatomic,strong) NJKWebViewProgressView *progressView;

@end

@implementation WebViewController

-(instancetype)init{
   self = [super init];
    
    //config WebView
    [self configWebView];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.webview.frame = self.view.bounds;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self loadWebView];
    
    [self showProgressView];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self hideProgressView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Methods

/**
 *  加载网页
 */
-(void)loadWebView{
    
    if (self.url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_url]];
        
        [self.webview loadRequest:request];
    }else if (self.filePath){
        
        [self.webview loadFilePath:self.filePath baseFilePath:self.basePath];
    }
    
}

/**
 *  初始化布局webview
 */
-(void)configWebView{
    if (!self.webview) {
        
        if ([WKWebView class]) {
            
            WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
            
            self.webview = [[YPWebView alloc] initWithFrame:self.view.bounds withConfiguration:configuration];
            
            self.webview.wkUIDelegateViewController = self;
            //self.webView.wkWebView.UIDelegate = self;
            
        }else{
            self.webview = [[YPWebView alloc] initWithFrame:self.view.bounds];
        }
        
        self.webview.delegate = self;
        
        self.webview.customBackAction = YES;    //自定义的后退操作
        
        self.webview.localFileDirectory = @"www";   //存放本地HTML资源的文件夹
        
        [self.view addSubview:self.webview];
        
    }
}



#pragma mark - Progress View Methods
/*
 * 显示进度条
 */
-(void)showProgressView{
    
    CGFloat progressBarHeight = 2.f;
    
    if (!_progressView) {
        _progressView = [[NJKWebViewProgressView alloc] init];
    }
    
    if (self.navigationController && !self.navigationController.navigationBarHidden) {
        //导航条上显示进度条
        CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
        CGRect progressFrame = CGRectMake(0, 44-progressBarHeight , navigationBarBounds.size.width, progressBarHeight);
        _progressView.frame = progressFrame;
        
        [self.navigationController.navigationBar addSubview:_progressView];
    }
    
    [_progressView setProgress:0.0];
}

/*
 * 隐藏进度条
 */
-(void)hideProgressView{
    [_progressView removeFromSuperview];
}


#pragma mark - URL Heloper Methods

/*
 * 打开外部URL,调用电话、mail,sms
 */
-(BOOL)canHandleOpenURL:(NSURL *)url{
    
    BOOL _canHandle = NO;    //是否处理外部URL
    
    BOOL _canOpen = [[UIApplication sharedApplication] canOpenURL:url];
    
    if (_canOpen && ![self isHTTPRequest:url] && ![url.scheme isEqualToString:@"file"]) {
        
        [[UIApplication sharedApplication] openURL:url];
        _canHandle = YES;
        
    }
    
    return _canHandle;
}


/*
 * 判断是否为http url请求
 */
-(BOOL)isHTTPRequest:(NSURL *)url{
    BOOL flag = YES;
    
    NSString *scheme = url.scheme;
    
    if (scheme == nil || [scheme isEqual:@""] || !([scheme isEqual:@"http"] || [scheme isEqual:@"https"])) {
        flag = NO;
    }
    
    return flag;
}


#pragma mark - YPWebViewDeleage method
-(BOOL)YPwebview:(YPWebView *)webview shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)type{
    
    BOOL allow = YES;
    
    NSLog(@"------current request url:%@",request.URL);
    
    allow = ![self canHandleOpenURL:request.URL];   //外部URL处理
    
    return allow;
}

-(void)YPwebviewDidStartLoad:(YPWebView *)webview{
    NSLog(@"%s",__func__);
}

-(void)YPwebviewDidCommitLoad:(YPWebView *)webview{
    NSLog(@"%s",__func__);
}

-(void)YPwebviewDidFinishLoad:(YPWebView *)webview{
    NSLog(@"%s",__func__);
    
    /**
     *  js 调用原生程序
     */
    [webview evaluteJavaScriptString:@"window.webkit.messageHandlers.YP_hdk.postMessage({test:'test1'})" completionHandler:nil];
}

-(void)YPwebview:(YPWebView *)webview didLoadFailedWithError:(NSError *)error{
    NSLog(@"%s",__func__);
    
    if (error.code == NSURLErrorCancelled || error.code == 102) {
        return;
    }
    
    NSLog(@"load request error:%@",error);
}

-(void)YPwebview:(YPWebView *)webview loadProgress:(double)progress{
    
    NSLog(@"**** progress: %f",progress);
    
    [self.progressView setProgress:progress animated:YES];
}

/**
 *  接收js发送的消息
 *
 */
-(void)YPwebview:(YPWebView *)webview receiveScriptMessage:(NSDictionary *)message{
    NSLog(@"receive script message:%@",message);
}

@end

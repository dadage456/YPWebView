//
//  WebViewController.m
//  YPWebView
//
//  Created by apple on 16/5/29.
//  Copyright © 2016年 Gaotang.Zhang. All rights reserved.
//

#import "WebViewController.h"

#import "NJKWebViewProgressView.h"

@interface WebViewController ()
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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



#pragma mark - Private Methods
/*
 * 显示进度条
 */
-(void)showProgressView{
    
    CGFloat progressBarHeight = 2.f;
    
    if (!self.navigationController.navigationBarHidden) {
        CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
        CGRect progressFrame = CGRectMake(0, 0, navigationBarBounds.size.width, progressBarHeight);
        _progressView.frame = progressFrame;
        
        [self.navigationController.navigationBar addSubview:_progressView];
    }else{
        
        CGRect progressFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), progressBarHeight);
        
        _progressView.frame = progressFrame;
        
        [self.view addSubview:_progressView];
    }
    
    [_progressView setProgress:0.0];
}

/*
 * 隐藏进度条
 */
-(void)hideProgressView{
    [_progressView removeFromSuperview];
}

/*
 * 打开外部URL,调用电话、mail,sms
 */
-(BOOL)canHandleOpenURL:(NSURL *)url{
    
    BOOL _canHandle = NO;    //是否处理外部URL
    
    BOOL _canOpen = [[UIApplication sharedApplication] canOpenURL:url];
    
    if (_canOpen && ![self isHTTPRequest:url]) {
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



@end

//
//  YPWebView.m
//  YPWebViewDemo
//
//  Created by 融贯 on 16/2/17.
//  Copyright © 2016年 haier. All rights reserved.
//

#import "YPWebView.h"
#import "NJKWebViewProgress.h"

#define SCRIPT_MESSAGE_HANDLER_NAME @"YP_hdk"

static void *KINWebBrowserContext = &KINWebBrowserContext;

@interface YPWebView ()<NJKWebViewProgressDelegate,WKScriptMessageHandler>{
    NSMutableArray *_backList;
}

@property(nonatomic,strong) WKWebViewConfiguration *configuration;
@property(nonatomic,strong) NJKWebViewProgress *progressProxy;

@property(nonatomic,strong) JSContext *jscontext;

@end

@implementation YPWebView

#pragma mark - Initializer

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.localFileDirectory = @"www";   //默认的html资源存放文件夹
        
        if ([WKWebView class]) {
            _VERSION_ABOVE_IOS_8 = YES;
        }else{
            _VERSION_ABOVE_IOS_8 = NO;
        }
        
        if (_VERSION_ABOVE_IOS_8) {
            
            if (!self.configuration) {
                self.configuration = [[WKWebViewConfiguration alloc] init];
            }
            
            if (!self.configuration.userContentController) {
                self.configuration.userContentController = [[WKUserContentController alloc] init];
            }
            
            //add js script Handler
            [self.configuration.userContentController addScriptMessageHandler:self name:SCRIPT_MESSAGE_HANDLER_NAME];
            
            self.wkWebView = [[WKWebView alloc] initWithFrame:self.bounds configuration:self.configuration];
            
            
            self.wkWebView.backgroundColor = [UIColor clearColor];
            self.wkWebView.navigationDelegate = self;
            self.wkWebView.UIDelegate = self;
            
            [self addSubview:self.wkWebView];
            
            
            //add KVO
            [self.wkWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:NSKeyValueObservingOptionNew context:nil];
        }else{
            self.uiWebView = [[UIWebView alloc] initWithFrame:self.bounds];
            self.uiWebView.backgroundColor = [UIColor clearColor];
            
            self.progressProxy = [[NJKWebViewProgress alloc] init];
            self.uiWebView.delegate = self.progressProxy;
            self.progressProxy.webViewProxyDelegate = self;
            self.progressProxy.progressDelegate = self;
            
            [self addSubview:self.uiWebView];
        }
        
        
        //config
        self.customBackAction = NO;
        _backList = [NSMutableArray array];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame withConfiguration:(WKWebViewConfiguration *)configuration{
    
    self.configuration = configuration;
    
    self  = [self initWithFrame:frame];
    
    return self;
}

-(void)dealloc{
    
    if (_VERSION_ABOVE_IOS_8){
        //remove KVO
        [self.wkWebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    }
    
}


-(void)layoutSubviews{
    [super layoutSubviews];

    if (_VERSION_ABOVE_IOS_8) {
        self.wkWebView.frame = self.bounds;
    }else{
        self.uiWebView.frame = self.bounds;
    }
}


#pragma mark - load Html Method

-(void)loadRequest:(NSURLRequest *)request{
    if (_VERSION_ABOVE_IOS_8) {
        [self.wkWebView loadRequest:request];
    }else{
        [self.uiWebView loadRequest:request];
    }
}


-(void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL{
    if (_VERSION_ABOVE_IOS_8) {
        [self.wkWebView loadHTMLString:string baseURL:baseURL];
    }else{
        [self.uiWebView loadHTMLString:string baseURL:baseURL];
    }
}

/**
 *  加载本地的HTML文件
 *
 *  @param filePath 本地文件路径
 *  @param basePath 本地文件目录
 */
-(void)loadFilePath:(NSString *)filePath baseFilePath:(NSString *)basePath{
    
    NSURL *filePathURL = [NSURL fileURLWithPath:filePath];
    NSURL *basePathURL = [NSURL fileURLWithPath:basePath];
    
    
    if (_VERSION_ABOVE_IOS_8) {

        if ([self.wkWebView respondsToSelector:@selector(loadFileURL:allowingReadAccessToURL:)]) {
            [self.wkWebView loadFileURL:filePathURL allowingReadAccessToURL:basePathURL];
        }else{
            //将html资源文件夹拷贝到tmp文件夹中
            [self copyBundleResouceToTempDirectory:_localFileDirectory];
            
            NSString *bundleDirPath = [[NSBundle mainBundle] bundlePath];
            NSString *tempDirPath = NSTemporaryDirectory();
            
            NSString *newFilePath  = [filePath stringByReplacingOccurrencesOfString:bundleDirPath withString:tempDirPath];
            NSString *baseURLPath = [basePath stringByReplacingOccurrencesOfString:bundleDirPath withString:tempDirPath];
            
            NSString *htmlStr = [NSString stringWithContentsOfFile:newFilePath encoding:NSUTF8StringEncoding error:nil];
            [self.wkWebView loadHTMLString:htmlStr baseURL:[NSURL fileURLWithPath:baseURLPath]];
        }
    }else{
        NSString *htmlStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        
        [self.uiWebView loadHTMLString:htmlStr baseURL:basePathURL];
        
        /**
         *  加载本地网页，无需进度提示
         */
        self.progress = 1;
        if ([self.delegate respondsToSelector:@selector(YPwebview:loadProgress:)]) {
            [self.delegate YPwebview:self loadProgress:self.progress];
        }
    }
}

#pragma mark - WebView Option

-(NSURL *)URL{
    
    NSURL *url = nil;
    
    if (_VERSION_ABOVE_IOS_8) {
        url = self.wkWebView.URL;
    }else{
        url = self.uiWebView.request.URL;
    }
    
    return url;
}

-(void)reload{
    if (_VERSION_ABOVE_IOS_8) {
        [self.wkWebView reload];
    }else{
        [self.uiWebView reload];
    }
}

-(BOOL)canGoBack{
    BOOL flag = NO;
    
    if (_customBackAction) {
        flag = [self customCanGoBack];
    }else{
        if (_VERSION_ABOVE_IOS_8) {
            flag = [self.wkWebView canGoBack];
        }else{
            flag = [self.uiWebView canGoBack];
        }
    }
    
    return flag;
}

-(BOOL)canGoForward{
    BOOL flag = NO;
    
    if (_VERSION_ABOVE_IOS_8) {
        flag = [self.wkWebView canGoForward];
    }else{
        flag = [self.uiWebView canGoForward];
    }
    
    return flag;
}

-(void)goBack{
    
    if (_customBackAction) {
        
        [self customGoBack];
        
    }else{
        
        if (_VERSION_ABOVE_IOS_8) {
            [self.wkWebView goBack];
        }else{
            [self.uiWebView goBack];
        }
    }
}

-(void)goForward{
    if (_VERSION_ABOVE_IOS_8) {
        [self.wkWebView goForward];
    }else{
        [self.uiWebView goForward];
    }
}

-(UIScrollView *)scrollView{
    
    UIScrollView *scrollView;
    
    if (_VERSION_ABOVE_IOS_8) {
        scrollView = self.wkWebView.scrollView;
    }else{
        scrollView = self.uiWebView.scrollView;
    }
    
    return scrollView;
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqual:@"estimatedProgress"]) {
        if ([self.delegate respondsToSelector:@selector(YPwebview:loadProgress:)]) {
            [self.delegate YPwebview:self loadProgress:self.wkWebView.estimatedProgress];
        }
    }
}

#pragma mark - Object-C call Javascript
-(void)evaluteJavaScriptString:(NSString *)scriptString completionHandler:(void (^)(id, NSError *))completionHandler{
    if (_VERSION_ABOVE_IOS_8) {
        [self.wkWebView evaluateJavaScript:scriptString completionHandler:completionHandler];
    }else{
        
        JSContext *context = [self.uiWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        
        JSValue *jsResult = [[context evaluateScript:scriptString] toObject];
    
        
        id result = jsResult;
        
        if (completionHandler) {
            completionHandler(result,nil);
        }
    }
}

#pragma mark - UIWebView Delegate Methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    BOOL allow = YES;
    
    
    
    if ([self.delegate respondsToSelector:@selector(YPwebview:shouldStartLoadWithRequest:navigationType:)]) {
        allow = [self.delegate YPwebview:self shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    if (allow) {
        //添加后退记录
        [self addBackHistoryList:request andNavigationType:navigationType];
    }
    
    return allow;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    if ([self.delegate respondsToSelector:@selector(YPwebviewDidStartLoad:)]) {
        [self.delegate YPwebviewDidStartLoad:self];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    /**
     *  绑定jsContext ，消息转发
     */
    [self bindingContextForMessageHandler];
    
    //可执行javascript脚本
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if ((interactive || complete) && [self.delegate respondsToSelector:@selector(YPwebviewDidCommitLoad:)]) {
        [self.delegate YPwebviewDidCommitLoad:self];
    }
    
    //加载完成
    if ([self.delegate respondsToSelector:@selector(YPwebviewDidFinishLoad:)]) {
        [self.delegate YPwebviewDidFinishLoad:self];
    }
    
    //本地文件，加载进度优化
    if ([webView.request.URL.scheme isEqual:@"file"] && [self.delegate respondsToSelector:@selector(YPwebview:loadProgress:)]) {
        [self.delegate YPwebview:self loadProgress:1.0];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    
    if (error && error.code != NSURLErrorCancelled && error.code != 102 && [self.delegate respondsToSelector:@selector(YPwebview:didLoadFailedWithError:)]) {
        [self.delegate YPwebview:self didLoadFailedWithError:error];
    }
}

#pragma mark - WKNavigationDelegate Methods
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    BOOL allow = YES;
    
    UIWebViewNavigationType navigationType = [self ConvertFromWKNavigationType:navigationAction.navigationType];
    
    if ([self.delegate respondsToSelector:@selector(YPwebview:shouldStartLoadWithRequest:navigationType:)]) {
        
        allow = [self.delegate YPwebview:self shouldStartLoadWithRequest:navigationAction.request navigationType:navigationType];
    }
    
    if (allow) {
        //添加后退纪录
        [self addBackHistoryList:navigationAction.request andNavigationType:navigationType];
        
        decisionHandler(WKNavigationActionPolicyAllow);
    }else{
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    if ([self.delegate respondsToSelector:@selector(YPwebviewDidCommitLoad:)]) {
        [self.delegate YPwebviewDidCommitLoad:self];
    }
}

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    if ([self.delegate respondsToSelector:@selector(YPwebviewDidStartLoad:)]) {
        [self.delegate YPwebviewDidStartLoad:self];
    }
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    if ([self.delegate respondsToSelector:@selector(YPwebviewDidFinishLoad:)]) {
        [self.delegate YPwebviewDidFinishLoad:self];
    }
    
}

-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    
    if (error  && error.code != NSURLErrorCancelled && [self.delegate respondsToSelector:@selector(YPwebview:didLoadFailedWithError:)]) {
        [self.delegate YPwebview:self didLoadFailedWithError:error];
    }
    
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    if (error  && error.code != NSURLErrorCancelled && [self.delegate respondsToSelector:@selector(YPwebview:didLoadFailedWithError:)]) {
        
        [self.delegate YPwebview:self didLoadFailedWithError:error];
        
    }
}


#pragma mark - NJKWebViewProgressDelegate Methods

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress{
    self.progress = progress;
    
    if ([self.delegate respondsToSelector:@selector(YPwebview:loadProgress:)]) {
        [self.delegate YPwebview:self loadProgress:self.progress];
    }
}


#pragma mark - WKUIDelegate Method
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    if (self.wkUIDelegateViewController) {
        [self.wkUIDelegateViewController presentViewController:alertController animated:YES completion:nil];
    }
    
}

-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    
    if (self.wkUIDelegateViewController) {
        [self.wkUIDelegateViewController presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:prompt preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *textField = [alertController.textFields objectAtIndex:0];
        
        NSString *text = textField.text;
        
        completionHandler(text);
        
    }]];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        if (defaultText != nil && ![defaultText isEqual:@""]) {
            textField.text = defaultText;
        }
    }];
    
    if (self.wkUIDelegateViewController) {
        [self.wkUIDelegateViewController presentViewController:alertController animated:YES completion:nil];
    }
}

- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    
    [webView loadRequest:navigationAction.request];
    
    return nil;
    
}


#pragma mark - WKScriptMessageHandler delegate

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    if ([self.delegate  respondsToSelector:@selector(YPwebview:receiveScriptMessage:)]) {

        [self.delegate YPwebview:self receiveScriptMessage:message.body];

    }
    
}

#pragma mark - Binding JsContext MessageHandler

/**
 * 绑定jsContext,消息转发
 * js端通过 window.webkit.messageHandlers.hdk.postMessage(param); 发送消息
 */
-(void)bindingContextForMessageHandler{
    
    if (!_jscontext) {
        _jscontext = [self.uiWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        
        [_jscontext setExceptionHandler:^(JSContext *context, JSValue *value) {
            context.exception = value;
            NSLog(@"JSContext Exception:%@",value);
        }];
    }

    
    if (![_jscontext[@"webkit"] toObject]) {
        
        __weak typeof(self) _weakSelf = self;
        
        NSString *defineHandleJS = [NSString stringWithFormat:@"webkit = {messageHandlers:{%@:{}}}",SCRIPT_MESSAGE_HANDLER_NAME];
        
        [_jscontext evaluateScript:defineHandleJS];
        
        _jscontext[@"webkit"][@"messageHandlers"][SCRIPT_MESSAGE_HANDLER_NAME][@"postMessage"] = ^(NSDictionary *params){
            if ([_weakSelf.delegate respondsToSelector:@selector(YPwebview:receiveScriptMessage:)]) {
                [_weakSelf.delegate YPwebview:_weakSelf receiveScriptMessage:params];
            }
        };
    }
    
}

#pragma mark - Private URL Request Helper Method
/*
 * 判断是否为页面内的跳转链接
 */
-(BOOL)isFrgmentJump:(NSURL *)requestURL andCurrentURL:(NSURL *)currentURL{
    BOOL isFragmentJump = NO;
    
    if (requestURL.fragment) {
        NSString *nonFragmentURL = [requestURL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:requestURL.fragment] withString:@""];
        
        NSString *currentURLStr;
        
        if (currentURL.fragment) {
            currentURLStr = [currentURL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:currentURL.fragment] withString:@""];
        }else{
            currentURLStr = currentURL.absoluteString;
        }
        
        
        isFragmentJump = [nonFragmentURL isEqualToString:currentURLStr];
    }
    
    return isFragmentJump;
}

/*
 * 判断是否为主请求链接
 */
-(BOOL)isTopLevelNavigation:(NSURLRequest *)request{
    BOOL isTopLevel = [request.mainDocumentURL isEqual:request.URL];
    
    return isTopLevel;
}

/*
 * 判断该请求是http、https、file协议
 */
-(BOOL)IS_HTTP_OR_LOCALFILE:(NSURLRequest *)request{
    BOOL flag = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"] || [request.URL.scheme isEqualToString:@"file"];
    
    return flag;
}

/*
 * 判断请求的页面与当前页面是否为同一页
 */
-(BOOL)isSameHTMLPageByCurrentURL:(NSURL *)currentURL andRequestURL:(NSURL *)requestURL{
    BOOL isSame = NO;
    
    NSString *currentURLStr = [[currentURL absoluteString] lowercaseString];
    NSString *requestURLStr = [[requestURL absoluteString] lowercaseString];
    
    BOOL isFragment = [self isFrgmentJump:requestURL andCurrentURL:currentURL];
    
    if (isFragment) {
        //fragment
        isSame = YES;
        
    }else{
        isSame = [currentURLStr isEqualToString:requestURLStr];
    }
    
    return isSame;
}


/*
 * 转换NavigationType
 *      将WKWebView的navigationType转换为UIWebView的navigationType
 */
-(UIWebViewNavigationType)ConvertFromWKNavigationType:(WKNavigationType)navigationType{
    UIWebViewNavigationType convertedType = UIWebViewNavigationTypeOther;
    
    switch (navigationType) {
        case WKNavigationTypeLinkActivated:
        convertedType=UIWebViewNavigationTypeLinkClicked;
        break;
        
        case WKNavigationTypeReload:
        convertedType = UIWebViewNavigationTypeReload;
        break;
        
        case WKNavigationTypeBackForward:
        convertedType = UIWebViewNavigationTypeBackForward;
        break;
        
        case WKNavigationTypeFormSubmitted:
        convertedType = UIWebViewNavigationTypeFormSubmitted;
        break;
        
        case WKNavigationTypeFormResubmitted:
        convertedType = UIWebViewNavigationTypeFormResubmitted;
        break;
        
        case WKNavigationTypeOther:
        convertedType = UIWebViewNavigationTypeOther;
        break;
        
        default:
        convertedType = UIWebViewNavigationTypeOther;
        break;
    }
    
    return convertedType;
}

#pragma mark - Back History List Operation

/*
 * 添加后退历史纪录
 */
-(void)addBackHistoryList:(NSURLRequest *)request andNavigationType:(UIWebViewNavigationType)type{
    
    NSURL *currentURL;
    
    if (_VERSION_ABOVE_IOS_8) {
        currentURL = self.wkWebView.URL;
    }else{
        currentURL = self.uiWebView.request.URL;
    }
    
    //判断条件:
    //1：webview当前的url不为空（已经显示了一个网页）
    //2:是主请求URL
    //3:与当前页面不是一个页面(不是页面内跳转)
    //4:除了点击链接打开方式，不纪录历史记录
    // 注意：在wkwebview初次打开请求，wkwebview.request.URL = 请求的打开的URL ,navigationType = WKNavigationTypeOther
    //      而uiwebview初次打开请求, uiwebview.URL = nil  ,navigationType = UIWebViewNavigationTypeOther
    //
    if (currentURL!=nil &&
        [self isTopLevelNavigation:request] &&
        ![self isSameHTMLPageByCurrentURL:currentURL andRequestURL:request.URL] &&
        type==UIWebViewNavigationTypeLinkClicked) {
        
        [_backList addObject:currentURL];
        
        NSLog(@"***************add Back List : %@",_backList);
    }
}


/*
 * 是否可后退
 */
-(BOOL)customCanGoBack{
    BOOL canBack = NO;
    
    if ([_backList count]>0) {
        canBack = YES;
    }
    
    return canBack;
}

/*
 * 自定义后退操作
 */
-(void)customGoBack{
    
    NSInteger count = [_backList count];
    
    if (count>0) {
        NSURL *backRequestURL = [_backList lastObject];
        NSURLRequest *backRequest = [NSURLRequest requestWithURL:backRequestURL];
        
        if (_VERSION_ABOVE_IOS_8) {
            [self.wkWebView loadRequest:backRequest];
        }else {
            [self.uiWebView loadRequest:backRequest];
        }
        
        [_backList removeLastObject];
    }
    
    NSLog(@"***********back History Operation,List:%@",_backList);
}


#pragma mark - Local File Resource Directory Operation

/**
 *  拷贝本地文件和资源到temp文件夹
 *
 *  @param directoryName
 */
-(void)copyBundleResouceToTempDirectory:(NSString *)directoryName{
    
    NSString *tempDirectoryPath = NSTemporaryDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *resourceDirectory = [tempDirectoryPath stringByAppendingPathComponent:directoryName];
    
    
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *bundleDirectory = [bundlePath stringByAppendingPathComponent:directoryName];
    
    //判断是否已经存在该文件夹
    BOOL isDir = NO;
    BOOL isExist = [fileManager fileExistsAtPath:resourceDirectory isDirectory:&isDir];
    if (!(isExist && isDir)) {
        //创建文件夹
        BOOL createDir = [fileManager createDirectoryAtPath:resourceDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        
        if (createDir) {
            //开始复制文件
            
            NSArray *fileNameArray = [fileManager contentsOfDirectoryAtPath:bundleDirectory error:nil];
            
            for (NSString *fileName in fileNameArray) {
                
                NSString *filePath = [bundleDirectory stringByAppendingPathComponent:fileName];
                NSString *newFilePath = [resourceDirectory stringByAppendingPathComponent:fileName];
                
                [fileManager copyItemAtPath:filePath toPath:newFilePath error:nil];
            }
        }
        
    }
    
}


#pragma mark - 清除浏览器缓存
+(void)clearWebViewCache{
    if ([WKWebView class]) {
        NSSet *websiteDataTypes
        = [NSSet setWithArray:@[
                                WKWebsiteDataTypeDiskCache,
                                WKWebsiteDataTypeMemoryCache
                                ]];
        //// Date from
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        //// Execute
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            // Done
        }];
    }else{
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
    }
}

@end

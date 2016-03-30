//
//  YPWebView.h
//  YPWebViewDemo
//
//  Created by 融贯 on 16/2/17.
//  Copyright © 2016年 haier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol YPWebViewDelegate;

@interface YPWebView : UIView<WKNavigationDelegate,UIWebViewDelegate,WKUIDelegate>

@property(nonatomic,assign) BOOL VERSION_ABOVE_IOS_8;

@property(nonatomic,strong) WKWebView *wkWebView;
@property(nonatomic,strong) UIWebView *uiWebView;

/*
 * WKUIDelegate 委托的Controller
 */
@property(nonatomic,weak) UIViewController *wkUIDelegateViewController;

#pragma mark - delegate

@property(nonatomic,weak) id<YPWebViewDelegate> delegate;

#pragma mark - WKWebView Delegate Methods
//@property(nonatomic,weak) id<WKNavigationDelegate> wkNavigationDelegate;
//@property(nonatomic,weak) id<WKUIDelegate> wkUIDelegate;

#pragma mark - UIWebView Delegate Methods
@property(nonatomic,weak) id<UIWebViewDelegate> uiWebViewDelegate;

@property(nonatomic,assign) float progress;

@property(nonatomic,readonly) UIScrollView *scrollView;

//custom back action flag.Default customeBackAction=NO
@property(nonatomic,assign) BOOL customBackAction;

-(instancetype)initWithFrame:(CGRect)frame withConfiguration:(WKWebViewConfiguration *)configuration NS_AVAILABLE_IOS(8_0);


#pragma mark - public load method

-(void)loadRequest:(NSURLRequest *)request;

-(void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;


-(void)evaluteJavaScriptString:(NSString *)scriptString completionHandler:(void (^)(id result, NSError *error))completionHandler;

-(void)reload;
-(BOOL)canGoBack;
-(BOOL)canGoForward;
-(void)goBack;
-(void)goForward;


-(NSURL *)URL;

@end


@protocol YPWebViewDelegate <NSObject>

@optional

/*
 * 是否允许请求
 */
-(BOOL)YPwebview:(YPWebView *)webview shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)type;

/*
 * 请求加载开始
 */
-(void)YPwebviewDidStartLoad:(YPWebView *)webview;

/*
 * mainFrame加载内容，可以执行js
 */
-(void)YPwebviewDidCommitLoad:(YPWebView *)webview;

/*
 * 请求加载结束
 */
-(void)YPwebviewDidFinishLoad:(YPWebView *)webview;

/*
 * 请求错误
 */
-(void)YPwebview:(YPWebView *)webview didLoadFailedWithError:(NSError *)error;

/*
 * 加载进度
 */
-(void)YPwebview:(YPWebView *)webview loadProgress:(double)progress;


#pragma mark - 清除浏览器缓存
+(void)clearWebViewCache;

@end
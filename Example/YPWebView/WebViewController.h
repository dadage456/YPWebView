//
//  WebViewController.h
//  YPWebView
//
//  Created by apple on 16/5/29.
//  Copyright © 2016年 Gaotang.Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YPWebView.h"
#import <WebKit/WebKit.h>

@interface WebViewController : UIViewController

@property(nonatomic,strong) YPWebView *webview;

@property(nonatomic,strong) NSString *url;

@property(nonatomic,strong) NSString *filePath;

@property(nonatomic,strong) NSString *basePath;

-(void)loadWebView;

@end

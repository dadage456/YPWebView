# YPWebView 简介
混合UIWebView和WKWebView,根据系统自动选择控件。

#### 1、用到的Framework
* WebKit.framework
* JavaScriptCore.framework

#### 2、安装方式:使用Cocoaspod安装

```
	pod 'YPWebView'
```


---

## YPWebView特性

  * 在IOS7下使用UIWebView控件，在IOS8以上版本使用WKWebView控件。
  
  * 优化的历史后退操作，针对APP访问网页的后退优化操作。设置customBackAction = YES
  
  * 整合了UIWebView 与 WKWebView 的委托事件。
  
  * 默认实现了WKWebView UIDelegate委托事件，实现弹出提示框、确认框、输入框。
  
---


## YPWebView 使用

### 一、初始化
  
  ```
  @interface WebViewController ()<YPWebViewDelegate,WKScriptMessageHandler>
  @property(nonatomic,strong) YPWebView *webView;
  @end
  
  @implementation WebViewController
  
  -(void)webViewInit{
  	if ([WKWebView class]) {
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        
        self.webView = [[YPWebView alloc] initWithFrame:self.view.bounds withConfiguration:configuration];
        
        self.webView.wkUIDelegateViewController = self;
        //self.webView.wkWebView.UIDelegate = self;
    
    }else{
        self.webView = [[YPWebView alloc] initWithFrame:self.view.bounds];
    }
    
    self.webView.delegate = self;
    
    self.webView.customBackAction = YES;    //自定义的后退操作
  }
  
  @end
  ```
	

### 二、请求网页
* 1、加载远程URLRequest: `-loadRequest: `
  
* 2、加载本地、远程的HTMLString: `-loadHTMLString:baseURL: `

* 3、加载本地的HTML文件： `-loadFilePath:baseFilePath: `  
		**解决了在IOS8以上，UIWebView与WKWebView加载本地HTML文件不显示本地资源(css、图片、js文件).**
		
  

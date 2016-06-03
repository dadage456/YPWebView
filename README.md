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

  * YPWebView支持 IOS 7 以上的系统。
  
  * 在IOS7下使用UIWebView控件与JavascriptCore，在IOS8以上版本使用WKWebView控件。
  
  * 优化的历史后退操作，针对APP访问网页的后退优化操作。(忽略页内跳转、post请求...)
  
  	`customBackAction = YES`
  
  * 整合了UIWebView 与 WKWebView 的委托事件。
  
  * 默认实现了WKWebView UIDelegate委托事件，实现弹出提示框、确认框、输入框。
  
  * 解决了WKWebView网页内执行JS window.open无响应。([解决方案](http://stackoverflow.com/questions/33190234/wkwebview-and-window-open))
  
  * 统一了UIWebView 与 WKWebview 调用原生程序的方式。  
    `window.webkit.messageHandlers.YP_hdk.postMessage({name:'value'})`
  
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
	
---

### 二、请求网页
* 1、加载远程URLRequest: `-loadRequest: `
  
* 2、加载本地、远程的HTMLString: `-loadHTMLString:baseURL: `

* 3、加载本地的HTML文件： `-loadFilePath:baseFilePath: `  
		**解决了在IOS8以上，UIWebView与WKWebView加载本地HTML文件不显示本地资源(css、图片、js文件).**
		
		
---

### 三、JS调用原生程序

>YPWebView 统一了UIWebView 与 WKWebview 的 js 调用原生程序的方式。

1. js通过执行`window.webkit.messageHandlers.YP_hdk.postMessage({name:'value'})`发送消息给原生程序。。

2. 原生程序实现YPWebviewDelegate的`-YPwebview:receiveScriptMessage`方法，获取js发送过来的数据，进行处理。
  

# YPWebView
混合UIWebView和WKWebView,根据系统自动选择控件。。。

# YPWebView特性
  * 在IOS7下使用UIWebView控件，在IOS8以上版本使用WKWebView控件。
  * 委托事件YPWebViewDelegate，实现了UIWebView的UIWebViewDelegate、WKWebView的WKNavigationDelegate委托事件。
  * 加载进度获取：UIWebView使用第三方类库'NJKWebViewProgress'读取进度，WKWebView使用控件自身的'estimatedProgress'读取进度。
      进度委托事件-(void)YPwebview:(YPWebView *)webview loadProgress:(double)progress;
  * YPWebViewDelegate 整合了UIWebView的UIWebViewDelegate、WKWebView的WKNavigationDelegate委托事件。实现同一处理。
  
# YPWebView 优化点
  * 可使用已优化的历史后退操作，针对APP访问网页的后退优化操作。
      customBackAction:默认为NO,不优化。
  

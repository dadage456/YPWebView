//
//  ScriptMessageHandlerHelper.m
//  Pods
//
//  Created by apple on 16/6/8.
//
//

#import "YPScriptMessageHandlerHelper.h"

@implementation YPScriptMessageHandlerHelper

-(instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate{
    self = [super init];
    
    if (self) {
        self.delegate = delegate;
    }
    
    return self;
}


#pragma mark - ScriptMessageHandler Delegate

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    if (self.delegate) {
        [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
    }
    
}

@end

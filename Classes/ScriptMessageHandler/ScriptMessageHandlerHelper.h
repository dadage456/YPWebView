//
//  ScriptMessageHandlerHelper.h
//  Pods
//
//  Created by apple on 16/6/8.
//
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface ScriptMessageHandlerHelper : NSObject<WKScriptMessageHandler>

@property(nonatomic,weak) id<WKScriptMessageHandler> delegate;

-(instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate;

@end

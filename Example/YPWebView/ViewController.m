//
//  ViewController.m
//  YPWebView
//
//  Created by apple on 16/5/29.
//  Copyright © 2016年 Gaotang.Zhang. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)buttonAction:(id)sender{
    UIButton *button = (UIButton *)sender;
    
    int tag = button.tag;
    
    if (tag == 0) {
        //打开远程URL
        
    }else if(tag == 1){
        //打开本地URL
        
    }
}

@end

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
        WebViewController  *controller = [[WebViewController alloc] init];
        
        controller.url = @"http://d.eqxiu.com/s/oNPt4BQD";
        
        [self.navigationController pushViewController:controller animated:YES];
        
    }else if(tag == 1){
        //打开本地URL
        WebViewController *controller = [[WebViewController alloc] init];
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html" inDirectory:@"www"];
        NSString *basePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"www"];
        
        controller.filePath = filePath;
        controller.basePath = basePath;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end

//
//  ViewController.m
//  ZHW
//
//  Created by 闫世超 on 16/10/29.
//  Copyright © 2016年 闫世超. All rights reserved.
//

#import "ViewController.h"
#import "XYView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blueColor];
    
    XYView *view = [[XYView alloc]init];
    view.frame = CGRectMake(0, (self.view.frame.size.height) - 170, self.view.frame.size.width, 170);
    view.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:view];

    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

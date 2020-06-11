//
//  ViewController.m
//  ClockView
//
//  Created by KingZ on 2020/6/11.
//  Copyright © 2020 KingZ. All rights reserved.
//

#import "ViewController.h"
#import "KZClockView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    KZClockView* clockView = [[KZClockView alloc]initWithFrame:CGRectMake(5, 100, self.view.bounds.size.width-10, 200)];
    [self.view addSubview:clockView];
    
}


@end

//
//  ViewController.m
//  Scan
//
//  Created by WenQing on 2017/6/12.
//  Copyright © 2017年 com.rainbow. All rights reserved.
//

#import "ViewController.h"
#import "THScanViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    _label.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, [UIScreen mainScreen].bounds.size.height/2.0);
    _label.text = @" 触摸屏幕开启扫码功能";
    [self.view addSubview:_label];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    THScanViewController *scanVC = [THScanViewController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:scanVC];
    [self presentViewController:nav animated:YES completion:nil];
}

@end

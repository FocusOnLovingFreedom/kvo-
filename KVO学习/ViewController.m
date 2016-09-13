//
//  ViewController.m
//  KVO学习
//
//  Created by 小度－李山 on 16/9/12.
//  Copyright © 2016年 Baidu_video. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+ls_kvo.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *topView;

@property (weak, nonatomic) IBOutlet UIButton *changeColorBtn;

@property (weak, nonatomic) IBOutlet UILabel *colorLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.topView ls_addObserver:self key:@"backgroundColor" callBack:^(id observer, NSString *key, id oldValue, id newValue) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.colorLabel.text = [NSString stringWithFormat:@"当前view的背景颜色是:%@",newValue];
        });
    }];
}
- (IBAction)changeColorClick:(id)sender {
    CGFloat red = arc4random()%256;
    CGFloat green = arc4random()%256;
    CGFloat blue = arc4random()%256;
    CGFloat alpha = arc4random()%256;
    self.topView.backgroundColor = [UIColor colorWithRed:red/256 green:green/256 blue:blue/256 alpha:alpha/256];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

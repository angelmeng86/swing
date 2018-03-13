//
//  JPNoticeViewController.m
//  Swing
//
//  Created by Mapple on 2018/3/10.
//  Copyright © 2018年 zzteam. All rights reserved.
//

#import "JPNoticeViewController.h"
#import "CommonDef.h"

@interface JPNoticeViewController ()

@end

@implementation JPNoticeViewController

- (void)viewDidLoad {
    self.notLoadBackgroudImage = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"JPNotice" ofType:@"txt"];
    self.textLabel.text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    self.view.backgroundColor = RGBA(0xfc, 0xfc, 0xfc, 1.0f);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)agreeAction:(id)sender {
    [GlobalCache shareInstance].local.showJPNoticTip = NO;
    [[GlobalCache shareInstance] saveInfo];
    [self dismissViewControllerAnimated:YES completion:^{
        if ([_delegate respondsToSelector:@selector(noticeViewControllerBack)]) {
            [_delegate noticeViewControllerBack];
        }
    }];
}
@end

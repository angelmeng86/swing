//
//  UVIViewController.m
//  Swing
//
//  Created by Mapple on 16/7/30.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "UVIndexViewController.h"

@interface UVIndexViewController ()

@end

@implementation UVIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _uvi = [[WeartherModel alloc] init];
    _uvi.uvi = (rand() % 10) + 1;
    
    [self.uvLabel setTitleColor:[_uvi color] forState:UIControlStateNormal];
    
    self.uvLabel.layer.cornerRadius = 50.f;
    self.uvLabel.layer.borderColor = [self.uvLabel titleColorForState:UIControlStateNormal].CGColor;
    self.uvLabel.layer.borderWidth = 5.f;
    self.uvLabel.layer.masksToBounds = YES;
    
    self.infoLabel.textColor = [_uvi color];
    self.titleLabel.textColor = [_uvi color];
    
    [self.uvLabel setTitle:[NSString stringWithFormat:@"%d", _uvi.uvi] forState:UIControlStateNormal];
    self.infoLabel.text = [_uvi recommend];
    
    UIView *bgView = [UIView new];
    [self.view addSubview:bgView];
    [bgView autoPinEdgesToSuperviewEdges];
    bgView.backgroundColor = [[_uvi color] colorWithAlphaComponent:0.3f];
    [self.view sendSubviewToBack:bgView];
    
    self.infoLabel.adjustsFontSizeToFitWidth = YES;
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

@end

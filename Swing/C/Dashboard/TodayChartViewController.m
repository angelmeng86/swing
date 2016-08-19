//
//  TodayChartViewController.m
//  Swing
//
//  Created by Mapple on 16/8/9.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "TodayChartViewController.h"
#import "RectProgress.h"
#import "CommonDef.h"
#import "LMArrowView.h"

@interface TodayChartViewController ()

@property (nonatomic, strong) NSLayoutConstraint *lineWidth;

@property (nonatomic, strong) ActivityResultModel* indoor;
@property (nonatomic, strong) ActivityResultModel* outdoor;

@end

@implementation TodayChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGBA(0xdc, 0xcc, 0xfe, 1.0f);
    
    LMArrowView *leftView = [LMArrowView new];
    LMArrowView *rightView = [LMArrowView new];
    rightView.isRight = YES;
    
    leftView.color = _titleLabel.textColor;
    rightView.color = _titleLabel.textColor;
    
    [self.view addSubview:leftView];
    [self.view addSubview:rightView];
    [leftView autoSetDimensionsToSize:CGSizeMake(6, 10)];
    [leftView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_titleLabel];
    [leftView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:_titleLabel];
    [rightView autoSetDimensionsToSize:CGSizeMake(6, 10)];
    [rightView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_titleLabel];
    [rightView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_titleLabel];
    
    self.stepProgress.progressTotal = 150;
    self.stepProgress.progressCounter = 0;
    
    self.distanceProgress.progressTotal = 150;
    self.distanceProgress.progressCounter = 0;
    
    self.flightsProgress.progressTotal = 150;
    self.flightsProgress.progressCounter = 0;
    
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor redColor];
    [self.view addSubview:line];
    [line autoSetDimensionsToSize:CGSizeMake(3, 200)];
    self.lineWidth = [line autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:_distanceProgress withOffset:-50];
    [line autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_distanceProgress];
    
    UIImage *image = [ControlFactory imageFromColor:RGBA(0x67, 0x5c, 0xa7, 1.0f) size:CGSizeMake(100, 30)];
//    UIImage *image = [ControlFactory imageFromColor:[UIColor redColor] size:CGSizeMake(100, 30)];
    
    self.indoorBtn.layer.borderWidth = 2;
    self.indoorBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.indoorBtn.layer.masksToBounds = YES;
    self.indoorBtn.adjustsImageWhenHighlighted = NO;
    self.indoorBtn.showsTouchWhenHighlighted = NO;
    [self.indoorBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.indoorBtn setBackgroundImage:image forState:UIControlStateSelected];
    [self.indoorBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.indoorBtn.selected = YES;
    
    self.outdoorBtn.layer.borderWidth = 2;
    self.outdoorBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.outdoorBtn.layer.masksToBounds = YES;
    self.outdoorBtn.adjustsImageWhenHighlighted = NO;
    self.outdoorBtn.showsTouchWhenHighlighted = NO;
    [self.outdoorBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.outdoorBtn setBackgroundImage:image forState:UIControlStateSelected];
    [self.outdoorBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnAction:(id)sender {
    if (self.indoorBtn == sender) {
        self.indoorBtn.selected = YES;
        self.outdoorBtn.selected = NO;
        [self reloadData];
    }
    else {
        self.indoorBtn.selected = NO;
        self.outdoorBtn.selected = YES;
        [self reloadData];
    }
    [self.stepProgress setNeedsLayout];
    if ([_delegate respondsToSelector:@selector(showChanged:)]) {
        [_delegate showChanged:self.outdoorBtn.selected];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData {
    if (self.indoorBtn.selected) {
        self.stepProgress.progressTotal = self.indoor.steps * 2;
        self.stepProgress.progressCounter = self.indoor.steps;
        self.stepProgress.text = [NSString stringWithFormat:@"Step %ld", self.indoor.steps];
    }
    else {
        self.stepProgress.progressTotal = self.outdoor.steps * 2;
        self.stepProgress.progressCounter = self.outdoor.steps;
        self.stepProgress.text = [NSString stringWithFormat:@"Step %ld", self.outdoor.steps];
    }
//    [self.stepProgress setNeedsLayout];
    [self.stepProgress setNeedsDisplay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    if (self.indoorBtn.selected) {
//        self.stepProgress.progressTotal = [GlobalCache shareInstance].indoorSteps * 2 + 60;
//        self.stepProgress.progressCounter = [GlobalCache shareInstance].indoorSteps;
//    }
//    else {
//        self.stepProgress.progressTotal = [GlobalCache shareInstance].outdoorSteps * 2 + 60;
//        self.stepProgress.progressCounter = [GlobalCache shareInstance].outdoorSteps;
//    }
//    [self.stepProgress setNeedsLayout];
    
    NSString *macId = [Fun dataToHex:[GlobalCache shareInstance].deviceMAC];
    if (macId.length == 0) {
        return;
    }
    [[SwingClient sharedClient] deviceGetActivity:macId type:GetActivityTypeDay completion:^(id dailyActs, NSError *error) {
        if (!error) {
            LOG_D(@"dailyActs:%@", dailyActs);
            for (ActivityResultModel *m in dailyActs) {
                if ([m.type isEqualToString:@"INDOOR"]) {
                    self.indoor = m;
                }
                else if([m.type isEqualToString:@"OUTDOOR"]) {
                    self.outdoor = m;
                }
            }
            [self reloadData];
        }
        else {
            LOG_D(@"deviceGetActivity fail: %@", error);
        }
    }];
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

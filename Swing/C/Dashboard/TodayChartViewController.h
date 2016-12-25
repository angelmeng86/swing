//
//  TodayChartViewController.h
//  Swing
//
//  Created by Mapple on 16/8/9.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"
@class RectProgress;

@protocol TodayChartViewDelegate <NSObject>

- (void)showChanged:(BOOL)isOutdoor;

@end

@interface TodayChartViewController : LMBaseViewController

@property (nonatomic) NSUInteger pageIndex;
@property (nonatomic, assign) id delegate;

@property (weak, nonatomic) IBOutlet RectProgress *stepProgress;
@property (weak, nonatomic) IBOutlet RectProgress *distanceProgress;
@property (weak, nonatomic) IBOutlet RectProgress *flightsProgress;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;

@property (weak, nonatomic) IBOutlet UIButton *indoorBtn;
@property (weak, nonatomic) IBOutlet UIButton *outdoorBtn;

@end

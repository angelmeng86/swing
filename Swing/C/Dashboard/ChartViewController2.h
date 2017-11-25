//
//  ChartViewController.h
//  Swing
//
//  Created by Mapple on 16/7/31.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "JBBaseChartViewController.h"

typedef enum : NSUInteger {
    ChartTypeYear,
    ChartTypeMonth,
    ChartTypeWeek,
} ChartType;

@interface ChartViewController2 : JBBaseChartViewController

@property (nonatomic) ChartType type;
@property (nonatomic) NSUInteger pageIndex;

//@property (nonatomic) BOOL isOutdoor;

- (void)reloadChartView;

@end

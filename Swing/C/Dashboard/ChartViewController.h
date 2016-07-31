//
//  ChartViewController.h
//  Swing
//
//  Created by Mapple on 16/7/31.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "JBBaseChartViewController.h"

typedef enum : NSUInteger {
    ChartTypeWeek,
    ChartTypeMonth,
    ChartTypeYear,
} ChartType;

@interface ChartViewController : JBBaseChartViewController

@property (nonatomic) ChartType type;
@property (nonatomic) NSUInteger pageIndex;

@end

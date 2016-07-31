//
//  JBBaseChartViewController.h
//  JBChartViewDemo
//
//  Created by Terry Worona on 3/13/14.
//  Copyright (c) 2014 Jawbone. All rights reserved.
//

#import "LMBaseViewController.h"

// Views
#import "JBChartTooltipView.h"
#import "JBChartView.h"

@interface JBBaseChartViewController : LMBaseViewController

@property (nonatomic, strong, readonly) JBChartTooltipView *tooltipView;

// Settres
- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated atTouchPoint:(CGPoint)touchPoint atChartView:(JBChartView*)chartView;
- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated atChartView:(JBChartView*)chartView;

@end

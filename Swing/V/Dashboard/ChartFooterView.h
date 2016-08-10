//
//  ChartFooterView.h
//  Swing
//
//  Created by Mapple on 16/7/30.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChartFooterView;
@protocol ChartFooterViewDelegate <NSObject>

- (NSUInteger)numberOfBarsInChartFooterView:(ChartFooterView *)footerView;
- (NSString*)chartFooterView:(ChartFooterView *)footerView textAtIndex:(NSUInteger)index;

@end

@interface ChartFooterView : UIView

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UILabel *titleLabel;

- (void)reload;

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;

@property (nonatomic, strong) NSArray *labels;

@property (nonatomic, assign) id<ChartFooterViewDelegate> delegate;

@end

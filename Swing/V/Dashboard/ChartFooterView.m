//
//  ChartFooterView.m
//  Swing
//
//  Created by Mapple on 16/7/30.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "ChartFooterView.h"
#import "CommonDef.h"

@implementation ChartFooterView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.lineColor = [UIColor blackColor];
        /*
        self.titleLabel = [UILabel new];
        [self addSubview:self.titleLabel];
        
        [self.titleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [self.titleLabel autoSetDimension:ALDimensionHeight toSize:20];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.backgroundColor = _lineColor;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        self.titleLabel.font = [UIFont boldAvenirFontOfSize:14];
        */
        self.leftLabel = [UILabel new];
        [self addSubview:self.leftLabel];
        
        [self.leftLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
        [self.leftLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        [self.leftLabel autoSetDimension:ALDimensionHeight toSize:20];
        self.leftLabel.textColor = _lineColor;
        self.leftLabel.textAlignment = NSTextAlignmentLeft;
        
        self.leftLabel.font = [UIFont avenirFontOfSize:15];
        
        self.rightLabel = [UILabel new];
        [self addSubview:self.rightLabel];
        
        [self.rightLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
        [self.rightLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        [self.rightLabel autoSetDimension:ALDimensionHeight toSize:20];
        self.rightLabel.textColor = _lineColor;
        self.rightLabel.textAlignment = NSTextAlignmentRight;
        
        self.rightLabel.font = [UIFont avenirFontOfSize:15];
        
        [self.leftLabel autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:self.rightLabel];
        [self.leftLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.rightLabel];
        
        self.backgroundColor = [UIColor clearColor];
        
        self.lineView = [UIView new];
        _lineView.backgroundColor = _lineColor;
        [self addSubview:_lineView];
        [self.lineView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, -10, 0, -10) excludingEdge:ALEdgeBottom];
        [self.lineView autoSetDimension:ALDimensionHeight toSize:3];
    }
    return self;
}

- (void)reload {
    if ([_delegate respondsToSelector:@selector(numberOfBarsInChartFooterView:)]) {
        NSUInteger count = [_delegate numberOfBarsInChartFooterView:self];
        for (UILabel *label in _labels) {
            [label removeFromSuperview];
        }
        NSMutableArray *array = [NSMutableArray new];
        for (int i = 0; i < count; i++) {
            UILabel *label = [UILabel new];
            [self addSubview:label];
            [array addObject:label];
            [label autoPinEdgeToSuperviewEdge:ALEdgeTop];
            [label autoSetDimension:ALDimensionHeight toSize:20];
            label.textColor = _lineColor;
            label.font = [UIFont avenirFontOfSize:13];
            label.adjustsFontSizeToFitWidth = YES;
            if (i == 0) {
                label.textAlignment = NSTextAlignmentLeft;
            }
            else if(i == count - 1) {
                label.textAlignment = NSTextAlignmentRight;
            }
            else {
                label.textAlignment = NSTextAlignmentCenter;
            }
            if ([_delegate respondsToSelector:@selector(numberOfBarsInChartFooterView:)]) {
                label.text = [_delegate chartFooterView:self textAtIndex:i];
            }
        }
//        [array autoAlignViewsToEdge:ALEdgeTop];
//        [array autoSetViewsDimension:ALDimensionHeight toSize:20];
        if(array.count > 0) {
            [array autoDistributeViewsAlongAxis:ALAxisHorizontal alignedTo:ALAttributeHorizontal withFixedSpacing:0];
        }
        self.labels = array;
    }
}

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    self.leftLabel.textColor = lineColor;
    self.rightLabel.textColor = lineColor;
    self.lineView.backgroundColor = lineColor;
}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    // Drawing code
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, _lineColor.CGColor);
//    CGContextFillRect(context, CGRectMake(0, 0, CGRectGetWidth(self.frame), 3));
//}


@end

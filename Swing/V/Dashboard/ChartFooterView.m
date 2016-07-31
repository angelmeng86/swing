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
        self.titleLabel = [UILabel new];
        [self addSubview:self.titleLabel];
        
        [self.titleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [self.titleLabel autoSetDimension:ALDimensionHeight toSize:20];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.backgroundColor = _lineColor;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        self.titleLabel.font = [UIFont boldAvenirFontOfSize:14];
        
        self.leftLabel = [UILabel new];
        [self addSubview:self.leftLabel];
        
        [self.leftLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.leftLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        [self.leftLabel autoSetDimension:ALDimensionHeight toSize:20];
        self.leftLabel.textColor = [UIColor whiteColor];
        self.leftLabel.textAlignment = NSTextAlignmentLeft;
        
        self.leftLabel.font = [UIFont avenirFontOfSize:13];
        
        self.rightLabel = [UILabel new];
        [self addSubview:self.rightLabel];
        
        [self.rightLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.rightLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        [self.rightLabel autoSetDimension:ALDimensionHeight toSize:20];
        self.rightLabel.textColor = [UIColor whiteColor];
        self.rightLabel.textAlignment = NSTextAlignmentRight;
        
        self.rightLabel.font = [UIFont avenirFontOfSize:13];
        
        [self.leftLabel autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:self.rightLabel];
        [self.leftLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.rightLabel];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    self.titleLabel.backgroundColor = lineColor;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, _lineColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, CGRectGetWidth(self.frame), 3));
}


@end

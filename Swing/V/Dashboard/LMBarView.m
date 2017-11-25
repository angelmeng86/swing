//
//  LMBarView.m
//  Swing
//
//  Created by Mapple on 16/8/10.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBarView.h"
#import "CommonDef.h"

@implementation LMBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (void)commonInit
{
    self.label = [UILabel new];
    [self addSubview:_label];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont avenirFontOfSize:15];
    _label.adjustsFontSizeToFitWidth = YES;
    [_label autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [_label autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [_label autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0 relation:NSLayoutRelationLessThanOrEqual];
    NSLayoutConstraint *bottom = [_label autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0 relation:NSLayoutRelationGreaterThanOrEqual];
    bottom.priority = UILayoutPriorityDefaultHigh;
    
    [_label autoSetDimension:ALDimensionHeight toSize:20];
    
    self.dateLabel = [UILabel new];
    [self addSubview:_dateLabel];
    _dateLabel.textAlignment = NSTextAlignmentCenter;
    _dateLabel.textColor = [UIColor whiteColor];
    _dateLabel.font = [UIFont avenirFontOfSize:15];
    _dateLabel.adjustsFontSizeToFitWidth = YES;
    [_dateLabel autoAlignAxisToSuperviewMarginAxis:ALAxisVertical];
    [_dateLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self withOffset:5];
    [_dateLabel autoSetDimension:ALDimensionHeight toSize:20];
    [_dateLabel autoConstrainAttribute:ALAttributeWidth toAttribute:ALAttributeWidth ofView:self withMultiplier:1.5];
}

@end

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
    [_label autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [_label autoSetDimension:ALDimensionHeight toSize:20];
}

@end

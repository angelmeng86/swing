//
//  LMArrowLabel.m
//  Swing
//
//  Created by Mapple on 2017/11/26.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "LMArrowLabel.h"
#import "LMArrowView.h"
#import "CommonDef.h"

@interface LMArrowLabel ()
{
    LMArrowView *leftView;
}

@end

@implementation LMArrowLabel

- (id)init {
    if (self = [super init]) {
        [self initView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
}

- (void)initView {
    leftView = [LMArrowView new];
    [self addSubview:leftView];
    [leftView autoSetDimension:ALDimensionWidth toSize:8];
    [leftView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, -8, 0, 0) excludingEdge:ALEdgeRight];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    leftView.color = backgroundColor;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

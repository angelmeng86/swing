//
//  TimeLineView.m
//  Swing
//
//  Created by Mapple on 16/7/31.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "TimeLineView.h"
#import "CommonDef.h"

@implementation TimeLineView

- (id)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel = [UILabel new];
        [self addSubview:_textLabel];
        
        [_textLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        [_textLabel autoSetDimensionsToSize:CGSizeMake(40, 20)];
        [_textLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = RGBA(129, 147, 155, 1.0f);
        _textLabel.font = [UIFont boldAvenirFontOfSize:10];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, RGBA(181, 219, 230, 1.0f).CGColor);
    CGContextFillRect(context, CGRectMake(40, CGRectGetMidY(self.bounds) - 1, CGRectGetWidth(self.frame), 2));
}


@end

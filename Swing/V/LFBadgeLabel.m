//
//  BadgeLabel.m
//  HelpMe
//
//  Created by Mapple on 2017/1/8.
//  Copyright © 2017年 Maple. All rights reserved.
//

#import "LFBadgeLabel.h"

@implementation LFBadgeLabel

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
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor redColor];
    self.textAlignment = NSTextAlignmentCenter;
    self.adjustsFontSizeToFitWidth = YES;
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect rect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, TEXTFIELD_EDGE, 0, TEXTFIELD_EDGE);
    return UIEdgeInsetsInsetRect(rect, insets);
}

@end

//
//  EventLabel.m
//  Swing
//
//  Created by Mapple on 16/8/1.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "EventLabel.h"

#define EDGE_VALUE  20

@implementation EventLabel

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = UIEdgeInsetsMake(0, EDGE_VALUE, 0, EDGE_VALUE);
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end

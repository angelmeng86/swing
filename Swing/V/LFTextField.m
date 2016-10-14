//
//  LFTextField.m
//  MyShow
//
//  Created by 刘武忠 on 15-8-25.
//  Copyright (c) 2015年 zzteam. All rights reserved.
//

#import "LFTextField.h"

@implementation LFTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect rect = [super textRectForBounds:bounds];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, TEXTFIELD_EDGE, 0, TEXTFIELD_EDGE);
    return UIEdgeInsetsInsetRect(rect, insets);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    CGRect rect = [super textRectForBounds:bounds];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, TEXTFIELD_EDGE, 0, TEXTFIELD_EDGE);
    return UIEdgeInsetsInsetRect(rect, insets);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect rect = [super textRectForBounds:bounds];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, TEXTFIELD_EDGE, 0, TEXTFIELD_EDGE);
    return UIEdgeInsetsInsetRect(rect, insets);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

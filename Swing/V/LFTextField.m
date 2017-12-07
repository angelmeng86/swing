//
//  LFTextField.m
//  MyShow
//
//  Created by 刘武忠 on 15-8-25.
//  Copyright (c) 2015年 zzteam. All rights reserved.
//

#import "LFTextField.h"
#import "CommonDef.h"

@implementation LFTextField

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
    [self setValue:TEXTFIELD_PLACEHOLDER_COLOR forKeyPath:@"_placeholderLabel.textColor"];
    self.textColor = TEXTFIELD_PLACEHOLDER_COLOR;
}

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

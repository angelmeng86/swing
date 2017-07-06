//
//  RectProgress.m
//  Swing
//
//  Created by Mapple on 16/8/9.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "RectProgress.h"
#import "CommonDef.h"

#define EDGE_VALUE  5

@implementation RectProgress

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
    
}

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = UIEdgeInsetsMake(0, EDGE_VALUE, 0, EDGE_VALUE);
//    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
    
    if(self.progressCounter <= self.progressTotal)
    {
        CGRect actualRect = CGRectMake(0, 0, CGRectGetWidth(self.frame) / self.progressTotal * self.progressCounter, CGRectGetHeight(self.frame));
        [super drawTextInRect:UIEdgeInsetsInsetRect(actualRect, insets)];
    }
    else {
        CGRect actualRect = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        [super drawTextInRect:UIEdgeInsetsInsetRect(actualRect, insets)];
    }
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.color == nil ? RGBA(0x62, 0x5c, 0xb5, 1.0f).CGColor : self.color.CGColor);
    if(self.progressCounter <= self.progressTotal)
    {
        CGContextFillRect(context, CGRectMake(0, 0, CGRectGetWidth(self.frame) / self.progressTotal * self.progressCounter, CGRectGetHeight(self.frame)));
    }
    else {
        CGContextFillRect(context, CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)));
    }
    // Drawing code
    [super drawRect:rect];
}

//- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
//{
//    return CGRectMake(50, 0, CGRectGetWidth(self.frame) / self.progressTotal * self.progressCounter, CGRectGetHeight(self.frame));
//}

@end

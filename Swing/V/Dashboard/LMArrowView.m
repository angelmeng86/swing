//
//  LMArrowView.m
//  Swing
//
//  Created by Mapple on 16/8/10.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMArrowView.h"

CGFloat const kLMArrowViewDefaultWidth = 5.0f;
CGFloat const kLMArrowViewDefaultHeight = 8.0f;
#define kJBColorTooltipColor [UIColor colorWithWhite:1.0 alpha:0.9]

@implementation LMArrowView

#pragma mark - Alloc/Init

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, kLMArrowViewDefaultWidth, kLMArrowViewDefaultHeight)];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor clearColor] set];
    CGContextFillRect(context, rect);
    
    CGContextSaveGState(context);
    {
        CGContextBeginPath(context);
        switch (_arrow) {
            case LMArrowRight:
            {
                CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
                CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMidY(rect));
                CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
            }
            break;
            case LMArrowUp:
            {
                CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
                CGContextAddLineToPoint(context, CGRectGetMidX(rect), CGRectGetMinY(rect));
                CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
            }
            break;
            case LMArrowDown:
            {
                CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
                CGContextAddLineToPoint(context, CGRectGetMidX(rect), CGRectGetMaxY(rect));
                CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
            }
            break;
            default:
            {
                CGContextMoveToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
                CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect));
                CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
            }
            break;
        }
        
        if (_isNotFill) {
            CGContextSetLineWidth(context, 1.5);
            CGContextSetStrokeColorWithColor(context, _color == nil ? kJBColorTooltipColor.CGColor : _color.CGColor);
            CGContextStrokePath(context);
        }
        else {
            CGContextClosePath(context);
            CGContextSetFillColorWithColor(context, _color == nil ? kJBColorTooltipColor.CGColor : _color.CGColor);
            CGContextFillPath(context);
        }
    }
    CGContextRestoreGState(context);
}

@end

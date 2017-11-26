//
//  LFLineView.h
//  Swing
//
//  Created by Mapple on 2017/11/23.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LFLineView : UIView
{
    NSInteger _lineLength;
    NSInteger _lineSpacing;
    UIColor *_lineColor;
    CGFloat _height;
}

@property (nonatomic) BOOL  horizontalLine;

- (instancetype)initWithLineLength:(NSInteger)lineLength withLineSpacing:(NSInteger)lineSpacing withLineColor:(UIColor *)lineColor;

@end

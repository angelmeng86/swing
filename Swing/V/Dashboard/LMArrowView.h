//
//  LMArrowView.h
//  Swing
//
//  Created by Mapple on 16/8/10.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    LMArrowLeft,
    LMArrowRight,
    LMArrowUp,
    LMArrowDown,
} LMArrow;

@interface LMArrowView : UIControl

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) LMArrow arrow;

@property (nonatomic, assign) BOOL isNotFill;

@end

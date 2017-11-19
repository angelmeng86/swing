//
//  LFBaseSheet.m
//  Swing
//
//  Created by Mapple on 2017/11/19.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "LFBaseSheet.h"
#import "CommonDef.h"

#define SCREEN_BOUNDS         [UIScreen mainScreen].bounds
#define SCREEN_WIDTH          [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT         [UIScreen mainScreen].bounds.size.height
#define SCREEN_ADJUST(Value)  SCREEN_WIDTH * (Value) / 375.0

#define kActionItemHeight  SCREEN_ADJUST(50)
#define kLineHeight        0.5
#define kDividerHeight     7.5

#define kTitleFontSize       SCREEN_ADJUST(15)
#define kActionItemFontSize  SCREEN_ADJUST(17)

#define kActionSheetColor            [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f]
#define kDividerColor                [UIColor colorWithRed:0xF6/255.0f green:0xF6/255.0f blue:0xF6/255.0f alpha:1.0f]

#define kButtonColor                [UIColor colorWithRed:0xC7/255.0f green:0xC7/255.0f blue:0xC7/255.0f alpha:1.0f]

@implementation LFBaseSheet

- (instancetype)init {
    
    if (self = [super initWithFrame:SCREEN_BOUNDS]) {
        [self setupCover];
        [self setupActionSheet];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self setupCover];
        [self setupActionSheet];
    }
    return self;
}

+ (instancetype)actionSheetView
{
    return [[self alloc] init];
}

- (void)setupCover {
    
    [self addSubview:({
        UIView *cover = [[UIView alloc] init];
        cover.frame = self.bounds;
        cover.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.33];
//        cover.backgroundColor = 
        cover.alpha = 0;
        [cover addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAction)]];
        _cover = cover;
    })];
}

- (void)dismissAction {
    if (!self.disableTouchDismiss) {
        [self dismiss];
    }
}

- (void)setupActionSheet {
    
}

#pragma mark - Animations

- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.9
          initialSpringVelocity:0.7
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.cover.alpha = 1.0;
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)dismiss {
    
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.9
          initialSpringVelocity:0.7
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.cover.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

@end

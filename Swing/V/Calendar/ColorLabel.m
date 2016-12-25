//
//  ColorLabel.m
//  Swing
//
//  Created by Mapple on 16/8/2.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "ColorLabel.h"
#import "CommonDef.h"
#import "LFTextField.h"

@interface ColorLabel ()
{
    UIButton *selectedBtn;
    NSLayoutConstraint *colorsViewHeight;
}


@end

@implementation ColorLabel

- (id)init {
    if (self = [super init]) {
        [self initView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initView];
    }
    return self;
}

+ (NSArray*)colors {
    static NSArray* colors = nil;
    if (colors == nil) {
        colors = @[RGBA(247, 202, 49, 1.0f), RGBA(99, 90, 185, 1.0f), RGBA(58, 187, 166, 1.0f), RGBA(237, 47, 107, 1.0f), RGBA(240, 93, 37, 1.0f), RGBA(137, 135, 137, 1.0f)];
    }
    return colors;
}

- (void)initView {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5.f;
    self.layer.masksToBounds = YES;
    
    UILabel *label = [UILabel new];
    label.text = LOC_STR(@"Color Label");
    label.font = [UIFont avenirFontOfSize:15];
    [self addSubview:label];
    [label autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:TEXTFIELD_EDGE + 10];
    [label autoSetDimension:ALDimensionHeight toSize:35];
    
    _selectedColor = RGBA(240, 93, 37, 1.0f);
    selectedBtn = [self createDotBtn:_selectedColor superView:self];
    
    [label autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:selectedBtn withOffset:10];
    [selectedBtn autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:10];
    [selectedBtn autoAlignAxis:ALAxisHorizontal toSameAxisOfView:label];
    
    UIView *colorsView = [UIView new];
    colorsView.backgroundColor = [UIColor clearColor];
    [self addSubview:colorsView];
    
    [label autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:colorsView];
    [colorsView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    colorsViewHeight = [colorsView autoSetDimension:ALDimensionHeight toSize:30];
    
    NSMutableArray *array = [NSMutableArray array];
    NSArray *colors = [ColorLabel colors];
    for (int i = 0; i < colors.count; i++) {
        UIButton *btn = [self createDotBtn:colors[i] superView:colorsView];
        [array addObject:btn];
    }
    
    UIView *firstView = [array firstObject];
    [firstView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
    [firstView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:20];
    
    UIView *previousView = nil;
    for (UIView *v in array) {
        if (previousView) {
            [previousView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:v withOffset:-20];
            [v autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:previousView];
        }
        previousView = v;
    }
    
//    [array autoDistributeViewsAlongAxis:ALAxisHorizontal alignedTo:ALAttributeHorizontal withFixedSpacing:10.0 insetSpacing:YES matchedSizes:NO];
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
    selectedBtn.backgroundColor = _selectedColor;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, RGBA(236, 236, 236, 1.0f).CGColor);
    CGContextFillRect(context, CGRectMake(10, 30, CGRectGetWidth(self.frame) - 20, 1));
}

- (UIButton*)createDotBtn:(UIColor*)color superView:(UIView*)view {
    UIButton *btn = [UIButton new];
    btn.backgroundColor = color;
    btn.layer.cornerRadius = 10.f;
    btn.layer.masksToBounds = YES;
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:btn];
    [btn autoSetDimensionsToSize:CGSizeMake(20, 20)];
    
    return btn;
}

- (void)btnAction:(UIButton*)sender {
    if (sender == selectedBtn) {
//        if (colorsViewHeight.constant > 0) {
//            colorsViewHeight.constant = 0.0f;
//        }
//        else {
//            colorsViewHeight.constant = 30.0f;
//        }
//        [UIView animateWithDuration:0.3f animations:^{
//            [self.superview layoutIfNeeded];
//        }];
    }
    else {
        self.selectedColor = sender.backgroundColor;
//        colorsViewHeight.constant = 0.0f;
//        [UIView animateWithDuration:0.3f animations:^{
//            [self.superview layoutIfNeeded];
//        }];
    }
}

@end

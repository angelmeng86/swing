//
//  DoItemLabel.m
//  Swing
//
//  Created by Mapple on 16/8/2.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "DoItemLabel.h"
#import "CommonDef.h"

@implementation DoItemLabel

- (id)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel = [UITextField new];
        [self addSubview:_textLabel];
        _textLabel.returnKeyType = UIReturnKeyDone;
        _textLabel.delegate = self;
        
        UIButton *dotView = [UIButton new];
//        dotView.backgroundColor = [UIColor clearColor];
//        dotView.layer.cornerRadius = 7.f;
//        dotView.layer.borderColor = RGBA(150, 150, 150, 1.0f).CGColor;
//        dotView.layer.borderWidth = 2.f;
//        dotView.layer.masksToBounds = YES;
        [self addSubview:dotView];
        
        
        dotView.titleLabel.font = [UIFont systemFontOfSize:15];
        [dotView setTitle:@"x" forState:UIControlStateNormal];
        dotView.titleEdgeInsets = UIEdgeInsetsMake(-1, 0, 1, 0);
        
        [dotView setTitleColor:COMMON_TITLE_COLOR forState:UIControlStateNormal];
        dotView.layer.borderColor = COMMON_TITLE_COLOR.CGColor;
        dotView.layer.borderWidth = 2.0f;
        dotView.layer.cornerRadius = 10.f;
        dotView.layer.masksToBounds = YES;
        
        [dotView addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        
        [dotView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [dotView autoPinEdgeToSuperviewMargin:ALEdgeLeading];
//        [dotView autoSetDimensionsToSize:CGSizeMake(14, 14)];
        [dotView autoSetDimensionsToSize:CGSizeMake(20, 20)];
        [dotView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:_textLabel withOffset:-8];
        [_textLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeLeading];
        
        _textLabel.textColor = RGBA(150, 150, 150, 1.0f);
        _textLabel.font = [UIFont avenirFontOfSize:14];
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)deleteAction {
    if ([_delegate respondsToSelector:@selector(doItemLabelDidDelete:)]) {
        [_delegate doItemLabelDidDelete:self];
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, RGBA(236, 236, 236, 1.0f).CGColor);
    CGContextFillRect(context, CGRectMake(25, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame) - 35, 1));
}

@end

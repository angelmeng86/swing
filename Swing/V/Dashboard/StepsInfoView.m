//
//  StepsInfoView.m
//  Swing
//
//  Created by Mapple on 2017/11/15.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "StepsInfoView.h"
#import "CommonDef.h"

@implementation StepsInfoView

- (void)setThemeColor:(UIColor*)color {
    self.leftLabel1.textColor = color;
    self.leftLabel2.textColor = color;
    self.rightLabel.textColor = color;
    self.valueLabel.textColor = color;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self xibSetup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self xibSetup];
    }
    return self;
}

- (void)xibSetup {
    UIView *v = [[[NSBundle mainBundle] loadNibNamed:@"StepsInfoView" owner:self options:nil] firstObject];
    [self addSubview:v];
    v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    v.frame = self.bounds;
    
    self.valueLabel.text = @"2,222";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 10.f;
    self.layer.masksToBounds = YES;
    
    self.leftLabel1.text = LOC_STR(@"Indoor");
    self.leftLabel2.text = LOC_STR(@"Steps");
    self.rightLabel.text = LOC_STR(@"Steps");
}

@end

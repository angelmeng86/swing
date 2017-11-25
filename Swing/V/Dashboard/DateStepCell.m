//
//  DateStepCell.m
//  Swing
//
//  Created by Mapple on 2017/11/24.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "DateStepCell.h"
#import "CommonDef.h"

@implementation DateStepCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.stepsLabel.text = LOC_STR(@"Steps");
    
    self.backView.layer.cornerRadius = 10.f;
    self.backView.layer.masksToBounds = YES;
    self.backView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

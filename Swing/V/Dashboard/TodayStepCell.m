//
//  TodayStepCell.m
//  Swing
//
//  Created by Mapple on 2017/11/24.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "TodayStepCell.h"
#import "CommonDef.h"

@implementation TodayStepCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.startLabel.text = LOC_STR(@"Start");
    self.endLabel.text = LOC_STR(@"End");
    self.stepsLabel.text = LOC_STR(@"Steps");
    
    self.backView.layer.cornerRadius = 10.f;
    self.backView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

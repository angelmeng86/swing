//
//  EventSelectTableViewCell.m
//  Swing
//
//  Created by Mapple on 16/8/1.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "EventSelectTableViewCell.h"

@implementation EventSelectTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.checkBtn.layer.cornerRadius = 10.f;
    self.checkBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.checkBtn.layer.borderWidth = 2.f;
    self.checkBtn.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

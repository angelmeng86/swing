//
//  KidInfoTableViewCell.m
//  Swing
//
//  Created by Mapple on 2017/11/18.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "KidInfoTableViewCell.h"

@implementation KidInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.iconView.layer.cornerRadius = 12.f;
    self.iconView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

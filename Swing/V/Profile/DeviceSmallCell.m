//
//  DeviceSmallCell.m
//  Swing
//
//  Created by Mapple on 2017/11/12.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "DeviceSmallCell.h"
#import "CommonDef.h"

@implementation DeviceSmallCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.headerView.layer.borderColor = COMMON_HEADER_BORDER_COLOR.CGColor;
    self.headerView.layer.borderWidth = 1.0f;
    self.headerView.layer.cornerRadius = 15.f;
    self.headerView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setChecked:(BOOL)checked
{
    _checked = checked;
    if (checked) {
        self.headerView.layer.borderColor = COMMON_TITLE_COLOR.CGColor;
    }
    else {
        self.headerView.layer.borderColor = COMMON_HEADER_BORDER_COLOR.CGColor;
    }
}

@end

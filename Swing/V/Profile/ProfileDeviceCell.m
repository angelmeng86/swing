//
//  ProfileDeviceCell.m
//  Swing
//
//  Created by Mapple on 16/7/30.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "ProfileDeviceCell.h"
#import "CommonDef.h"

@implementation ProfileDeviceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageBtn.layer.borderColor = COMMON_HEADER_BORDER_COLOR.CGColor;
    [self.imageBtn setTitleColor:COMMON_HEADER_BORDER_COLOR forState:UIControlStateNormal];
    self.imageBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    self.imageBtn.layer.borderWidth = 1.0f;
    self.imageBtn.layer.cornerRadius = 25.f;
    self.imageBtn.layer.masksToBounds = YES;
}

- (void)setChecked:(BOOL)checked
{
    _checked = checked;
    if (checked) {
        self.imageBtn.layer.borderColor = COMMON_TITLE_COLOR.CGColor;
        self.imageBtn.layer.borderWidth = 2.0f;
    }
    else {
        self.imageBtn.layer.borderColor = COMMON_HEADER_BORDER_COLOR.CGColor;
        self.imageBtn.layer.borderWidth = 1.0f;
    }
}


@end

//
//  ProfileDeviceCell.m
//  Swing
//
//  Created by Mapple on 16/7/30.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "ProfileDeviceCell.h"

@implementation ProfileDeviceCell

- (void)awakeFromNib {
    self.imageBtn.layer.cornerRadius = 30.f;
    self.imageBtn.layer.masksToBounds = YES;
}

@end

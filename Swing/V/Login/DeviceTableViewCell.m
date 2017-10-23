//
//  DeviceTableViewCell.m
//  Swing
//
//  Created by Mapple on 16/7/21.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "DeviceTableViewCell.h"

@implementation DeviceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.iconView.layer.cornerRadius = 12.f;
//    self.contentView.backgroundColor = [UIColor clearColor];
    
//    self.backgroundColor = [UIColor clearColor];
    
//    UIView *backView = [UIView new];
//    backView.backgroundColor = [UIColor clearColor];
//    self.backgroundView = backView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(deviceTableViewCellDidClicked:)]) {
        [_delegate deviceTableViewCellDidClicked:self];
    }
}

@end

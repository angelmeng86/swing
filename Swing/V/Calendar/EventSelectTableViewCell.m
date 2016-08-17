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
    
    [self.checkBtn setTitle:@"" forState:UIControlStateNormal];
    [self.checkBtn setTitle:@"●" forState:UIControlStateSelected];
    
    [self.checkBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.checkBtn.selected = selected;
    if (selected) {
        self.checkBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        self.contentLabel.textColor = [UIColor whiteColor];
    }
    else {
        self.checkBtn.layer.borderColor = [UIColor grayColor].CGColor;
        self.contentLabel.textColor = [UIColor grayColor];
    }
    // Configure the view for the selected state
}

@end

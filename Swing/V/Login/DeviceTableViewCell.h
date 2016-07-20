//
//  DeviceTableViewCell.h
//  Swing
//
//  Created by 刘武忠 on 16/7/21.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *btn;
- (IBAction)btnAction:(id)sender;

@end

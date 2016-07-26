//
//  DeviceTableViewCell.h
//  Swing
//
//  Created by Mapple on 16/7/21.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DeviceTableViewCell;
@protocol DeviceTableViewCellDelegate <NSObject>

- (void)deviceTableViewCellDidClicked:(DeviceTableViewCell*)cell;

@end

@interface DeviceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *btn;
- (IBAction)btnAction:(id)sender;

@property (weak, nonatomic) id delegate;

@end

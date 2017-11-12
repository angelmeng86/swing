//
//  DeviceSmallCell.h
//  Swing
//
//  Created by Mapple on 2017/11/12.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceSmallCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (nonatomic) BOOL checked;

@end

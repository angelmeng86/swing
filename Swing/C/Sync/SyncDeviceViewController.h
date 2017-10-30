//
//  SyncDeviceViewController.h
//  Swing
//
//  Created by Mapple on 16/7/27.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"

@interface SyncDeviceViewController : LMBaseViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
- (IBAction)syncAnotherAction:(id)sender;

- (IBAction)goDashboardAction:(id)sender;

- (IBAction)syncCurrentAction:(id)sender;
@end

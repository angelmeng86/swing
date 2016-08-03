//
//  SearchDeviceViewController.h
//  Swing
//
//  Created by Mapple on 16/7/27.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"
#import "CommonDef.h"

@interface SearchDeviceViewController : LMBaseViewController

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet MDRadialProgressView *progressView;
- (IBAction)btnAction:(id)sender;

@end

//
//  BatteryViewController.h
//  Swing
//
//  Created by Mapple on 16/7/17.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"
#import "CommonDef.h"

@interface BatteryViewController : LMBaseViewController

@property (weak, nonatomic) IBOutlet MDRadialProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

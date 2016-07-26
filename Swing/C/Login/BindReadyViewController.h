//
//  BindReadyViewController.h
//  Swing
//
//  Created by Mapple on 16/7/26.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"

@interface BindReadyViewController : LMBaseViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
- (IBAction)goAction:(id)sender;
- (IBAction)addAnotherAction:(id)sender;

@end

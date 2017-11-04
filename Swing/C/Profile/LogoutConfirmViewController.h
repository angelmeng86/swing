//
//  LogoutConfirmViewController.h
//  Swing
//
//  Created by Mapple on 2017/11/4.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"

@interface LogoutConfirmViewController : LMBaseViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *yesBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
- (IBAction)yesAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end

//
//  ChangePwdViewController.h
//  Swing
//
//  Created by Mapple on 2017/10/29.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"

@interface ChangePwdViewController : LMBaseViewController
@property (weak, nonatomic) IBOutlet UITextField *pwdTF;
@property (weak, nonatomic) IBOutlet UITextField *pwdTF2;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
- (IBAction)saveAction:(id)sender;

@end

//
//  KidBindViewController.h
//  Swing
//
//  Created by Mapple on 16/7/26.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"

@interface KidBindViewController : LMBaseViewController

@property (weak, nonatomic) IBOutlet UIButton *imageBtn;
@property (weak, nonatomic) IBOutlet UITextField *kidNameTF;
@property (weak, nonatomic) IBOutlet UITextField *zipCodeTF;
- (IBAction)imageAction:(id)sender;

@end

//
//  KidBindViewController.h
//  Swing
//
//  Created by Mapple on 16/7/26.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"
@class KidInfo;
@interface EditKidViewController : LMBaseViewController

@property (nonatomic, strong) KidInfo* kid;

@property (weak, nonatomic) IBOutlet UIButton *imageBtn;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTF;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

- (IBAction)imageAction:(id)sender;
- (IBAction)saveAction:(id)sender;

@end

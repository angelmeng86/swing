//
//  KidBindViewController.h
//  Swing
//
//  Created by Mapple on 16/7/26.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"
@class Kid;
@interface EditKidViewController : LMBaseViewController

@property (nonatomic, strong) Kid* kid;

@property (weak, nonatomic) IBOutlet UIButton *imageBtn;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTF;

- (IBAction)imageAction:(id)sender;

@end

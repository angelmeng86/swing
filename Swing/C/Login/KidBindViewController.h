//
//  KidBindViewController.h
//  Swing
//
//  Created by Mapple on 16/7/26.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"

@interface KidBindViewController : LMBaseViewController

@property (nonatomic, strong) NSData *macAddress;
@property (nonatomic, strong) NSString *version;

@property (weak, nonatomic) IBOutlet UIButton *imageBtn;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTF;
- (IBAction)imageAction:(id)sender;
- (IBAction)doneAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;

@end

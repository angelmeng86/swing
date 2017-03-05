//
//  RegisterViewController.h
//  Swing
//
//  Created by Mapple on 16/7/19.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"

@interface RegisterViewController : LMBaseViewController

@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* pwd;

@property (weak, nonatomic) IBOutlet UIButton *imageBtn;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTF;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *zipCodeTF;
- (IBAction)imageAction:(id)sender;
- (IBAction)doneAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@end

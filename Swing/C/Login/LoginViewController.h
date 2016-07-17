//
//  LoginViewController.h
//  Swing
//
//  Created by 刘武忠 on 16/7/17.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"

@interface LoginViewController : LMBaseViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwd2TextField;
@end

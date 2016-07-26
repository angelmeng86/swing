//
//  KidBindViewController.m
//  Swing
//
//  Created by Mapple on 16/7/26.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "KidBindViewController.h"

@interface KidBindViewController ()<UITextFieldDelegate>

@end

@implementation KidBindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.title;
    
    [self.kidNameTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.zipCodeTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.kidNameTF.delegate = self;
    self.zipCodeTF.delegate = self;
    
    self.imageBtn.layer.cornerRadius = 60.f;
    self.imageBtn.layer.borderColor = [self.imageBtn titleColorForState:UIControlStateNormal].CGColor;
    self.imageBtn.layer.borderWidth = 2.f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.kidNameTF) {
        [self.zipCodeTF becomeFirstResponder];
    }
    else if (textField == self.zipCodeTF) {
        //Go
        UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
        UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"BindReady"];
        [self.navigationController pushViewController:ctl animated:YES];
    }
    return YES;
}

@end

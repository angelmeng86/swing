//
//  SearchEmailViewController.h
//  Swing
//
//  Created by Mapple on 2017/11/13.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"

@interface SearchEmailViewController : LMBaseViewController

@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UIButton *btn1;

- (IBAction)btn1Action:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *deviceView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *deviceLabel;
@property (weak, nonatomic) IBOutlet UIButton *deviceBtn;
- (IBAction)deviceAction:(id)sender;

@end

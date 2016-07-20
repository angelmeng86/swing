//
//  AskStepViewController.h
//  Swing
//
//  Created by 刘武忠 on 16/7/20.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"

@interface AskStepViewController : LMBaseViewController

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;

- (IBAction)btn1Action:(id)sender;
- (IBAction)btn2Action:(id)sender;

@end

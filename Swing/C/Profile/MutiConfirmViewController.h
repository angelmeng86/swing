//
//  MutiConfirmViewController.h
//  Swing
//
//  Created by Mapple on 2017/11/5.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"

typedef enum : NSUInteger {
    MutiConfirmTypeSwitch,
    MutiConfirmTypeSwitchDone,
    MutiConfirmTypeRemove,
    MutiConfirmTypeRemoveDone,
} MutiConfirmType;
@class KidModel;
@interface MutiConfirmViewController : LMBaseViewController

@property (nonatomic) MutiConfirmType type;
@property (nonatomic, strong) KidModel* kid;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
- (IBAction)btn1Action:(id)sender;
- (IBAction)btn2Action:(id)sender;
- (IBAction)btn3Action:(id)sender;

@end

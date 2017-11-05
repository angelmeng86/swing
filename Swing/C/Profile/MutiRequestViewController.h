//
//  MutiRequestViewController.h
//  Swing
//
//  Created by Mapple on 2017/11/5.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"

typedef enum : NSUInteger {
    MutiRequestTypePending,
    MutiRequestTypePendingCancel,
    MutiRequestTypeFrom,
    MutiRequestTypeFromDeny,
} MutiRequestType;
@class SubHostModel;
@interface MutiRequestViewController : LMBaseViewController

@property (nonatomic) MutiRequestType type;

@property (strong, nonatomic) SubHostModel* subHost;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
- (IBAction)btn1Action:(id)sender;
- (IBAction)btn2Action:(id)sender;
- (IBAction)btn3Action:(id)sender;

@end

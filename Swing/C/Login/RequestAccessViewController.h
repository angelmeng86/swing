//
//  RequestAccessViewController.h
//  Swing
//
//  Created by Mapple on 2017/10/22.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"
#import "CommonDef.h"

typedef enum : NSUInteger {
    RequestTypeAccess,
    RequestTypePending,
} RequestType;

@interface RequestAccessViewController : LMBaseViewController

@property (nonatomic) RequestType type;
@property (nonatomic, strong) KidModel *kid;
@property (nonatomic, strong) UserModel *user;

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;

- (IBAction)btn1Action:(id)sender;
- (IBAction)btn2Action:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *deviceView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *deviceLabel;
@property (weak, nonatomic) IBOutlet UIButton *deviceBtn;
- (IBAction)deviceAction:(id)sender;

@end

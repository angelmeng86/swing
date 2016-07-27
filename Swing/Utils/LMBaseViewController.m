//
//  BaseViewController.m
//  
//
//  Created by Mapple on 15-4-24.
//  Copyright (c) 2015年 TriggerOnce. All rights reserved.
//

#import "LMBaseViewController.h"
#import "CommonDef.h"

@interface LMBaseViewController ()

@end

@implementation LMBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
//    {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.extendedLayoutIncludesOpaqueBars = YES;
//    }
//    
//    
//    if (self.navigationController.viewControllers.count > 1) {
//        self.navigationItem.leftBarButtonItem = [ControlFactory backBarButtonItemWithTarget:self action:@selector(backAction)];
//    }
    
    self.view.backgroundColor = COMMON_BACKGROUND_COLOR;
}

- (void)awakeFromNib {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:LOAD_IMAGE(@"login_bg")];
    
    [self.view addSubview:imageView];
    
    [imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [imageView autoSetDimension:ALDimensionHeight toSize:kDeviceWidth];
    
    
    [self.view sendSubviewToBack:imageView];
    [self updateViewConstraints];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  JPNoticeViewController.h
//  Swing
//
//  Created by Mapple on 2018/3/10.
//  Copyright © 2018年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"
@protocol JPNoticeViewControllerDelegate <NSObject>

- (void)noticeViewControllerBack;

@end
@interface JPNoticeViewController : LMBaseViewController
@property (weak, nonatomic) id delegate;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;
- (IBAction)agreeAction:(id)sender;
@end

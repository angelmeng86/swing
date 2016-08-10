//
//  AlertSelectViewController.h
//  Swing
//
//  Created by Mapple on 16/8/11.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBaseTableViewController.h"

@class AlertModel;
@protocol AlertSelectViewDelegate <NSObject>

- (void)alertSelectViewControllerDidSelected:(AlertModel*)alert;

@end

@interface AlertSelectViewController : LMBaseTableViewController

@property (nonatomic, assign) id delegate;

@end

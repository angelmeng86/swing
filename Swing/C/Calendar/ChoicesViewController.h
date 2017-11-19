//
//  ChoicesViewController.h
//  Swing
//
//  Created by Mapple on 16/8/15.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBaseTableViewController.h"

@class ChoicesViewController;
@protocol ChoicesViewDelegate <NSObject>

- (void)choicesViewController:(ChoicesViewController*)ctl didSelected:(id)data;
- (void)choicesViewController:(ChoicesViewController*)ctl didSelectedIndex:(int)index;

- (void)choicesViewController:(ChoicesViewController*)ctl didMutiSelected:(NSArray*)indexs;

@end

@interface ChoicesViewController : LMBaseTableViewController

@property (nonatomic, strong) NSArray *array;
@property (nonatomic, assign) id delegate;

@property (nonatomic, strong) NSMutableSet *selectArray;
@property (nonatomic) BOOL mutiSelected;

@end

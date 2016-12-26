//
//  ChoicesViewController.h
//  Swing
//
//  Created by Mapple on 16/8/15.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBaseTableViewController.h"

@protocol ChoicesViewDelegate <NSObject>

- (void)choicesViewControllerDidSelected:(NSString*)text;
- (void)choicesViewControllerDidSelectedIndex:(int)index;

@end

@interface ChoicesViewController : LMBaseTableViewController

@property (nonatomic, strong) NSArray *textArray;
@property (nonatomic, assign) id delegate;

@end

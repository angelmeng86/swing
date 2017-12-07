//
//  ToDoListView.h
//  Swing
//
//  Created by Mapple on 16/8/2.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LFTextField.h"

@interface ToDoListView : UIView

@property (nonatomic, strong) UITextField *textField;

- (NSArray*)itemList;

- (void)setItemList:(NSArray*)todolist;

@end

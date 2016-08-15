//
//  ToDoListView.h
//  Swing
//
//  Created by Mapple on 16/8/2.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToDoListView : UIView

@property (nonatomic, strong) UITextField *textField;

- (NSArray*)itemList;

@end

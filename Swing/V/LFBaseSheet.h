//
//  LFBaseSheet.h
//  Swing
//
//  Created by Mapple on 2017/11/19.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LFBaseSheet : UIView

@property (nonatomic, weak) UIView *cover;

@property (nonatomic) BOOL disableTouchDismiss;

+ (instancetype)actionSheetView;

- (void)show;
- (void)dismiss;

- (void)setupActionSheet;

@end

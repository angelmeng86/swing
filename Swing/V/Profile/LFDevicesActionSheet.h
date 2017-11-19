//
//  LFDevicesActionSheet.h
//  Swing
//
//  Created by Mapple on 2017/11/12.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LFBaseSheet.h"

@class LFDevicesActionSheet;
@class KidInfo;

typedef void (^LFDevicesActionSheetDidSelectBlock)(LFDevicesActionSheet *actionSheet, KidInfo* kid);

@interface LFDevicesActionSheet : LFBaseSheet

+ (instancetype)actionSheetViewWithBlock:(LFDevicesActionSheetDidSelectBlock)actionBlock;

- (void)show;

@end

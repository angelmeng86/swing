//
//  LFCommentSheet.h
//  TaTaYue
//
//  Created by Mapple on 2017/6/15.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LFSyncSheet;

typedef void (^LFSyncSheetDidActionBlock)(LFSyncSheet *actionSheet, BOOL check);

@interface LFSyncSheet : UIView

+ (instancetype)actionSheetViewWithBlock:(LFSyncSheetDidActionBlock)actionBlock;

- (void)show;
- (void)showArrow:(CGRect)target;

@end

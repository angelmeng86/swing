//
//  DoItemLabel.h
//  Swing
//
//  Created by Mapple on 16/8/2.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DoItemLabel;
@protocol DoItemLabelDelegate <NSObject>

- (void)doItemLabelDidDelete:(DoItemLabel*)label;

@end

@interface DoItemLabel : UIView<UITextFieldDelegate>

@property (nonatomic, assign) id delegate;
@property (nonatomic, strong) UITextField *textLabel;
@property (weak, nonatomic) NSLayoutConstraint *positionLayoutConstaint;

@end

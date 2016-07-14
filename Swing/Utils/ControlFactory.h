//
//  ControlFactory.h
//  
//
//  Created by Mapple on 14-5-29.
//  Copyright (c) 2014年 Triggeronce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ControlFactory : NSObject

+ (UIBarButtonItem*)backBarButtonItemWithTarget:(id)target action:(SEL)action;

+ (UIBarButtonItem*)imageBarButtonItemWithImage:(UIImage*)image target:(id)target action:(SEL)action;

+ (void)setNavigationBarStyle:(UINavigationController*)navCtl;

+ (UILabel*)createNavigationTitleLabel;

+ (void)setClickAction:(UIView*)view target:(id)target action:(SEL)action;

+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size;

@end

//
//  ControlFactory.m
//  
//
//  Created by Mapple on 14-5-29.
//  Copyright (c) 2014年 Triggeronce. All rights reserved.
//

#import "ControlFactory.h"
#import "CommonDef.h"

@implementation ControlFactory

+ (UIBarButtonItem*)backBarButtonItemWithTarget:(id)target action:(SEL)action
{
    UIImage *infoImage = [UIImage imageNamed:@"back_arrow_icon"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, 40);
    [btn setImage:infoImage forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    return item;
}

+ (UIBarButtonItem*)imageBarButtonItemWithImage:(UIImage*)image target:(id)target action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, 40);
    [btn setImage:image forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    return item;
}

+ (void)setNavigationBarStyle:(UINavigationController*)navCtl
{
    UINavigationBar *navBar = navCtl.navigationBar;
//    if ([navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
//        [navBar setBackgroundImage:LOAD_IMAGE(@"main_nav_bg.png") forBarMetrics:UIBarMetricsDefault];
//    }
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = RGBA(0x50, 0x8f, 0xce, 1.0f);
    }
    if ([navBar respondsToSelector:@selector(setTintColor:)]) {
        navBar.tintColor = RGBA(0x50, 0x8f, 0xce, 1.0f);
    }
    
    navBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
}

+ (UILabel*)createNavigationTitleLabel
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = RGBA(0x4F, 0x59, 0x5D, 1.0f);
    titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:20.0f];
    return titleLabel;
}

+ (void)setClickAction:(UIView*)view target:(id)target action:(SEL)action
{
    if (view.gestureRecognizers.count > 0) {
        return;
    }
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [view addGestureRecognizer:gesture];
}

+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end

//
//  AvenirFont.h
//  DaProject
//
//  Created by Mapple on 15-9-3.
//  Copyright (c) 2015年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
 Family:Avenir
Font Name:Avenir-Bold
Font Name:Avenir-Regular
 */

@interface UIFont (AvenirFont)

+ (UIFont *)avenirFontOfSize:(CGFloat)fontSize;
+ (UIFont *)boldAvenirFontOfSize:(CGFloat)fontSize;

@end

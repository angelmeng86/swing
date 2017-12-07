//
//  AvenirFont.m
//  DaProject
//
//  Created by Mapple on 15-9-3.
//  Copyright (c) 2015年 zzteam. All rights reserved.
//

#import "UIFont+AvenirFont.h"

@implementation UIFont (AvenirFont)

+ (UIFont *)avenirFontOfSize:(CGFloat)fontSize
{
//    return [UIFont fontWithName:@"Avenir-Book" size:fontSize];
    return [UIFont fontWithName:@"ArialRoundedMTBold" size:fontSize];
}

+ (UIFont *)boldAvenirFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"ArialRoundedMTBold" size:fontSize];
}

@end

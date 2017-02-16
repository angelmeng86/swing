//
//  UIImage+wiRoundedRectImage.h
//  Swing
//
//  Created by Mapple on 2017/2/16.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (wiRoundedRectImage)

+ (id)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(NSInteger)r;

+ (id)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(NSInteger)r scale:(CGFloat)scale color:(UIColor*)borderColor;

+ (id)createRoundedRectBlank:(UIColor*)backColor size:(CGSize)size radius:(NSInteger)r scale:(CGFloat)scale color:(UIColor*)borderColor;

@end

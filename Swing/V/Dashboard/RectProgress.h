//
//  RectProgress.h
//  Swing
//
//  Created by Mapple on 16/8/9.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RectProgress : UILabel

@property (assign, nonatomic) NSUInteger progressTotal;
@property (assign, nonatomic) NSUInteger progressCounter;

@property (nonatomic, strong) UIColor *color;

@end

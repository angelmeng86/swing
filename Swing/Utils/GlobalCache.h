//
//  GlobalCache.h
//  GmatProject
//
//  Created by Mapple on 15-6-10.
//  Copyright (c) 2015年 Yan Cui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonDef.h"

@interface GlobalCache : NSObject

+ (GlobalCache*)shareInstance;

- (void)initConfig;

@property (strong, nonatomic) LoginedModel* info;

@end

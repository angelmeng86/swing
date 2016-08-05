//
//  GlobalCache.h
//  GmatProject
//
//  Created by Mapple on 15-6-10.
//  Copyright (c) 2015年 Yan Cui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonDef.h"

#define KIDS_LIST_LOAD_NOTI @"KIDS_LIST_LOAD_NOTI"

@interface GlobalCache : NSObject

+ (GlobalCache*)shareInstance;

- (void)initConfig;

- (void)saveInfo;

- (void)queryKids;

- (void)logout;

@property (strong, nonatomic) LoginedModel* info;
@property (strong, nonatomic) UserModel* user;

@property (strong, nonatomic) NSArray* kidsList;
@property (strong, nonatomic) NSURLSessionDataTask *kidsTask;

@end

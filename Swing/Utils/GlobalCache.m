//
//  GlobalCache.m
//  GmatProject
//
//  Created by 刘武忠 on 15-6-10.
//  Copyright (c) 2015年 Yan Cui. All rights reserved.
//

#import "GlobalCache.h"

@implementation GlobalCache

+ (GlobalCache*)shareInstance
{
    static GlobalCache* globalCache = nil;
    if (globalCache == nil) {
        globalCache = [[GlobalCache alloc] init];
    }
    return globalCache;
}

- (NSDate*)examDate
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"examDate"];
}

- (void)setExamDate:(NSDate *)examDate
{
    [[NSUserDefaults standardUserDefaults] setObject:examDate forKey:@"examDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setIsInited:(BOOL)isInited
{
    [[NSUserDefaults standardUserDefaults] setBool:isInited forKey:@"isInited"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isInited
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"isInited"];
}

- (id)init
{
    if (self = [super init]) {

    }
    return self;
}

@end

//
//  GlobalCache.m
//  GmatProject
//
//  Created by Mapple on 15-6-10.
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

- (void)initConfig {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    NSString *json = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    _info = [[LoginedModel alloc] initWithString:json error:nil];
}

- (void)setInfo:(LoginedModel *)info {
    _info = info;
    [[NSUserDefaults standardUserDefaults] setObject:[info toJSONString] forKey:@"token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)init
{
    if (self = [super init]) {

    }
    return self;
}

@end

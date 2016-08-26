//
//  UserLocalData.m
//  Swing
//
//  Created by Mapple on 16/8/26.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMLocalData.h"
#import "GlobalCache.h"

@implementation LMLocalData

- (void)checkDate {
    NSString *key = [GlobalCache dateToDayString:[NSDate date]];
    if ([key isEqualToString:_date]) {
        return;
    }
    _date = key;
    _indoorSteps = 0;
    _outdoorSteps = 0;
}

@end

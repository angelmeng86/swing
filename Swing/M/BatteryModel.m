//
//  BatteryModel.m
//  BabyBluetoothAppDemo
//
//  Created by Mapple on 16/8/20.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "BatteryModel.h"

@implementation BatteryModel

- (id)init {
    if (self = [super init]) {
        _batteryValue = -1;
    }
    return self;
}

- (BOOL)ready {
    return (_macAddress && _peripheral /*&& _batteryValue >= 0*/);
}

- (NSString*)description {
    return [NSString stringWithFormat:@"BatteryModel peripheral:%@ batteryValue:%d mac:%@", _peripheral, _batteryValue, _macAddress];
}

@end

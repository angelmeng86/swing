//
//  BLEDelegate.m
//  Swing
//
//  Created by Mapple on 2016/11/29.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "BLEDelegate.h"
#import "CommonDef.h"

@implementation BLEDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOn:
            LOG_D(@"蓝牙已打开,请扫描外设");
            break;
        case CBManagerStatePoweredOff:
            LOG_D(@"蓝牙没有打开,请先打开蓝牙");
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict {
    LOG_D(@"willRestoreState:%@", dict);
}

@end

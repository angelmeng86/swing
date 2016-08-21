//
//  BatteryModel.h
//  BabyBluetoothAppDemo
//
//  Created by Mapple on 16/8/20.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BatteryModel : NSObject

@property (nonatomic, strong) CBPeripheral* peripheral;
@property (nonatomic) int batteryValue;
@property (nonatomic, strong) NSData* macAddress;

- (BOOL)ready;

@end

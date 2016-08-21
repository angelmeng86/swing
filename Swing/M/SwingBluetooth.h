//
//  SwingBluetooth.h
//  BabyBluetoothAppDemo
//
//  Created by Mapple on 16/8/19.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define SWING_WATCH_BATTERY_NOTIFY  @"SWING_WATCH_BATTERY_NOTIFY"

typedef void (^SwingBluetoothInitDeviceBlock)(NSData *macAddress, NSError *error);
typedef void (^SwingBluetoothScanDeviceBlock)(CBPeripheral *peripheral, NSDictionary *advertisementData, NSError *error);
typedef void (^SwingBluetoothQueryBatteryBlock)(NSArray *batteryDevices, NSError *error);

typedef void (^SwingBluetoothSearchDeviceBlock)(CBPeripheral *peripheral, NSError *error);
typedef void (^SwingBluetoothSyncDeviceBlock)(NSMutableArray *activities, NSError *error);

@interface SwingBluetooth : NSObject

- (void)scanDeviceWithCompletion:(SwingBluetoothScanDeviceBlock)completion;

- (void)stopScan;

- (void)initDevice:(CBPeripheral*)peripheral completion:(SwingBluetoothInitDeviceBlock)completion;

- (void)queryBattery:(NSArray*)macAddressList completion:(SwingBluetoothQueryBatteryBlock)completion;

- (void)searchDevice:(NSData*)macAddress completion:(SwingBluetoothSearchDeviceBlock)completion;

- (void)syncDevice:(CBPeripheral*)peripheral event:(NSArray*)events completion:(SwingBluetoothSyncDeviceBlock)completion;


- (void)cannelAll;

@end

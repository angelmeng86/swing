//
//  BLEDelegate.h
//  Swing
//
//  Created by Mapple on 2016/11/29.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void (^SwingBluetoothInitDeviceBlock)(NSData *macAddress, NSError *error);
typedef void (^SwingBluetoothScanDeviceBlock)(CBPeripheral *peripheral, NSDictionary *advertisementData, NSError *error);

typedef void (^SwingBluetoothScanDeviceMacAddressBlock)(CBPeripheral *peripheral, NSData *macAddress, NSString *version, NSError *error);

typedef void (^SwingBluetoothSearchDeviceBlock)(CBPeripheral *peripheral, NSError *error);
typedef void (^SwingBluetoothSyncDeviceBlock)(NSMutableArray *activities, NSError *error, int battery, NSString *realMac);

typedef void (^SwingBluetoothUpdateDeviceBlock)(float percent, NSString *remainTime);

@interface BLEDelegate : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@end

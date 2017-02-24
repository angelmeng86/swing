//
//  BLEInitDevice.h
//  BLETester
//
//  Created by Mapple on 2016/11/14.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEWaitDevice.h"

@protocol BLEInitDeviceDelegate <NSObject>

- (void)reportInitDeviceResult:(NSData*)data error:(NSError*)error;

@end

@interface BLEInitDevice : BLEWaitDevice

@property (nonatomic, copy) SwingBluetoothUpdateDeviceBlock blockOnUpdateDevice;

- (void)initDevice:(CBPeripheral*)peripheral  centralManager:(CBCentralManager *)central;

@end

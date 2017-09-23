//
//  BLEClient.h
//  BLETester
//
//  Created by Mapple on 2016/11/13.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEDelegate.h"



@interface BLEClient : BLEDelegate

- (void)scanDeviceWithCompletion:(SwingBluetoothScanDeviceBlock)completion;

- (void)stopScan;

- (void)scanDeviceMacAddressWithCompletion:(SwingBluetoothScanDeviceMacAddressBlock)completion;

- (void)stopScanMacAddress;

- (void)initDevice:(CBPeripheral*)peripheral completion:(SwingBluetoothInitDeviceBlock)completion;

- (void)searchDevice:(NSData*)macAddress completion:(SwingBluetoothSearchDeviceBlock)completion;

//- (void)syncDevice:(CBPeripheral*)peripheral event:(NSArray*)events completion:(SwingBluetoothSyncDeviceBlock)completion;

//- (void)initDevice:(CBPeripheral*)peripheral completion:(SwingBluetoothInitDeviceBlock)completion update:(SwingBluetoothUpdateDeviceBlock)updateBlock;

- (void)syncDevice:(CBPeripheral*)peripheral macAddress:(NSString*)macAddress event:(NSArray*)events completion:(SwingBluetoothSyncDeviceBlock)completion update:(SwingBluetoothUpdateDeviceBlock)updateBlock check:(BOOL)checkVerOnly;

- (void)cannelAll;

@end

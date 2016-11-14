//
//  BLESyncDevice.h
//  BLETester
//
//  Created by Mapple on 2016/11/14.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BLESyncDeviceDelegate <NSObject>

- (void)reportSyncDeviceResult:(NSMutableArray*)activities error:(NSError*)error;

@end

@interface BLESyncDevice : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, weak) id delegate;

- (void)syncDevice:(CBPeripheral*)peripheral centralManager:(CBCentralManager *)central event:(NSArray*)events;

- (void)cannel;

@end

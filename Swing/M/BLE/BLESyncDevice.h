//
//  BLESyncDevice.h
//  BLETester
//
//  Created by Mapple on 2016/11/14.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEWaitDevice.h"

@protocol BLESyncDeviceDelegate <NSObject>

- (void)reportSyncDeviceResult:(NSMutableArray*)activities battery:(int)battery error:(NSError*)error;

@end

@interface BLESyncDevice : BLEWaitDevice


@property (nonatomic, strong) NSString* macId;
@property (nonatomic, copy) SwingBluetoothUpdateDeviceBlock blockOnUpdateDevice;

- (void)syncDevice:(CBPeripheral*)peripheral centralManager:(CBCentralManager *)central event:(NSArray*)events;

@end

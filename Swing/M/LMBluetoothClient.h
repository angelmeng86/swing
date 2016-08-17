//
//  LMBluetoothClient.h
//  Swing
//
//  Created by Mapple on 16/8/16.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ActivityModel.h"

@protocol LMBluetoothClientDelegate <NSObject>

- (void)bluetoothClientScanDevice:(NSArray*)peripherals;
- (void)bluetoothClientBattery:(int)value;
- (void)bluetoothClientSyncFinished;

- (void)bluetoothClientActivity:(ActivityModel *)data;

@end

@interface LMBluetoothClient : NSObject

@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) NSMutableArray* alertEvents;
@property (nonatomic, strong) NSData *macAddress;

- (void)beginScan;

- (void)stopScan;

- (void)syncDevice;

- (void)beginBattery;

@end

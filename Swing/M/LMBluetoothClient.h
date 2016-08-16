//
//  LMBluetoothClient.h
//  Swing
//
//  Created by Mapple on 16/8/16.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol LMBluetoothClientDelegate <NSObject>

- (void)bluetoothClientScanDevice:(NSArray*)peripherals;
- (void)bluetoothClientBattery:(int)value;
- (void)bluetoothClientSyncFinished;

@end

@interface LMBluetoothClient : NSObject

@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) NSMutableArray* alertEvents;

- (void)beginScan;

- (void)stopScan;

- (void)syncDevice;

- (void)readBattery;

@end

//
//  BLEUpdater.h
//  Swing
//
//  Created by Mapple on 2017/2/24.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define OAD_SERVICE_UUID @"0xF000FFC0-0451-4000-B000-000000000000"
#define OAD_IMAGE_NOTIFY_UUID @"0xF000FFC1-0451-4000-B000-000000000000"
#define OAD_IMAGE_BLOCK_REQUEST_UUID @"0xF000FFC2-0451-4000-B000-000000000000"

@protocol BLEUpdaterDelegate <NSObject>

- (void)deviceUpdateProgress:(float)percent remainTime:(NSString*)text;
- (void)deviceUpdateResult:(BOOL)success;

@end

@interface BLEUpdater : NSObject

@property (nonatomic, weak) id delegate;
@property (nonatomic, retain) CBPeripheral* peripheral;

@property (nonatomic, retain) NSData* imageData;
@property (nonatomic, retain) NSString* imageVersion;//Swing Version

@property (nonatomic, strong) NSString *deviceVersion;

- (BOOL)needUpdate;
- (BOOL)supportUpdate;
- (BOOL)readyUpdate;
- (void)startUpdate;
- (void)cancelUpdate;

- (void)didDiscoverServices:(CBService *)service;
- (void)didDiscoverCharacteristicsForService:(CBService *)service;

- (void)didUpdateValueForProfile:(CBCharacteristic *)characteristic;
- (void)deviceDisconnected:(CBPeripheral *)peripheral;

@end

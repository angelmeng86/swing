//
//  BLEInitDevice.m
//  BLETester
//
//  Created by Mapple on 2016/11/14.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import "BLEInitDevice.h"
#import "BLEUpdater.h"
#import "CBService+LMMethod.h"
#import "CommonDef.h"

@interface BLEInitDevice ()
{
    NSTimer *outTimer;
}

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) BLEUpdater *updater;

@property (nonatomic, strong) NSData *tmpData;

@end

@implementation BLEInitDevice

- (void)cannel {
    [super cannel];
    if (_peripheral) {
        [self.manager cancelPeripheralConnection:_peripheral];
    }
    if (outTimer) {
        [outTimer invalidate];
        outTimer = nil;
    }
    self.peripheral = nil;
    self.tmpData = nil;
    [self.updater cancelUpdate];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    LOG_D(@"didConnectPeripheral:%@", peripheral);
    [peripheral setDelegate:self];
    NSArray *services = @[[CBUUID UUIDWithString:@"FFA0"], [CBUUID UUIDWithString:@"180F"], [CBUUID UUIDWithString:OAD_SERVICE_UUID]];
    [peripheral discoverServices:services];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    LOG_D(@"didFailToConnectPeripheral:%@ error:%@", peripheral, error);
    [self reportInitDeviceResult:nil error:error];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    LOG_D(@"didDisconnectPeripheral:%@ error:%@", peripheral, error);
    if (self.isCancel) {
        return;
    }
    [self.updater deviceDisconnected:peripheral];
    if (self.tmpData) {
        //如果是在等待固件版本时断开连接，则正常进行业务
        [self deviceUpdateResult:NO];
    }
    else {
        [self reportInitDeviceResult:nil error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    LOG_D(@"didDiscoverServices:%@ error:%@", peripheral, error);
    if (error) {
        [self reportInitDeviceResult:nil error:error];
        return;
    }
    for (CBService *s in peripheral.services) {
        LOG_D(@"service UUID %@", s.UUID.UUIDString);
        if ([s.UUID isEqual:[CBUUID UUIDWithString:@"FFA0"]]) {
            NSArray *characters = @[[CBUUID UUIDWithString:@"FFA1"], [CBUUID UUIDWithString:@"FFA3"], [CBUUID UUIDWithString:@"FFA6"]];
            [peripheral discoverCharacteristics:characters forService:s];
        }
        else if ([s.UUID isEqual:[CBUUID UUIDWithString:@"180F"]]) {
            NSArray *characters = @[[CBUUID UUIDWithString:@"2A19"]];
            [peripheral discoverCharacteristics:characters forService:s];
        }
        else  {
            [self.updater didDiscoverServices:s];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    LOG_D(@"didDiscoverCharacteristicsForService:%@ error:%@", peripheral, error);
    if (error) {
        [self reportInitDeviceResult:nil error:error];
        return;
    }
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFA0"]]) {
        CBCharacteristic *character = [service findCharacteristic:@"FFA1"];
        [peripheral writeValue:[NSData dataWithBytes:"\x01" length:1] forCharacteristic:character type:CBCharacteristicWriteWithResponse];
        LOG_D(@"Write FFA1");
    }
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180F"]]) {
        CBCharacteristic *character = [service findCharacteristic:@"2A19"];
        [peripheral readValueForCharacteristic:character];
    }
    else {
        [self.updater didDiscoverCharacteristicsForService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    LOG_D(@"didWriteValueForCharacteristic:%@ characteristic:%@ error:%@", peripheral, characteristic, error);
    if (error) {
        [self reportInitDeviceResult:nil error:error];
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFA1"]]) {
        for (CBCharacteristic *character in characteristic.service.characteristics) {
            if ([character.UUID isEqual:[CBUUID UUIDWithString:@"FFA3"]]) {
                NSData *time = [Fun longToByteArray:TIME_STAMP];
                LOG_D(@"write FFA3 %@", time);
                [peripheral writeValue:time forCharacteristic:character type:CBCharacteristicWriteWithResponse];
            }
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFA3"]]) {
        for (CBCharacteristic *character in characteristic.service.characteristics) {
            if ([character.UUID isEqual:[CBUUID UUIDWithString:@"FFA6"]]) {
                LOG_D(@"read FFA6");
                [characteristic.service.peripheral readValueForCharacteristic:character];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    LOG_D(@"didUpdateValueForCharacteristic:%@ characteristic:%@ error:%@", peripheral, characteristic, error);
    if (error) {
        [self reportInitDeviceResult:nil error:error];
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFA6"]]) {
        LOG_D(@"FFA6 Value:%@", characteristic.value);
        [self reportInitDeviceResult:characteristic.value error:nil];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A19"]]) {
        const Byte* ptr = characteristic.value.bytes;
        LOG_D(@"Read Battery:%d%%", ptr[0]);
        [GlobalCache shareInstance].local.battery = ptr[0];
        [[GlobalCache shareInstance] saveInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:SWING_WATCH_BATTERY_NOTIFY object:[NSNumber numberWithInt:ptr[0]]];
    }
    else {
        [self.updater didUpdateValueForProfile:characteristic];
    }
}

- (void)initDevice:(CBPeripheral*)peripheral centralManager:(CBCentralManager *)central {
    self.peripheral = peripheral;
    self.manager = central;
    if (self.blockOnUpdateDevice) {
        self.updater = [[BLEUpdater alloc] init];
        self.updater.peripheral = peripheral;
        self.updater.delegate = self;
    }
    LOG_D(@"initDevice:%@", self.peripheral);
    [self checkBleStatus];
}

- (void)bleTimeout {
    [self reportInitDeviceResult:nil error:[NSError errorWithDomain:@"SwingBluetooth" code:-2 userInfo:[NSDictionary dictionaryWithObject:@"The bluetooth switch is closed." forKey:NSLocalizedDescriptionKey]]];
}

- (void)fire {
    self.tmpData = nil;
    [outTimer invalidate];
    outTimer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(operationTimeout) userInfo:nil repeats:NO];
    [self.manager connectPeripheral:self.peripheral options:nil];
}

- (void)operationTimeout {
    if (self.isCancel) {
        return;
    }
    NSError *err = [NSError errorWithDomain:@"SwingBluetooth" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"connectPeripheral timeout." forKey:NSLocalizedDescriptionKey]];
    [self reportInitDeviceResult:nil error:err];
}

- (void)getVersionTimeout:(NSTimer*)timer {
    //获取固件版本超时，正常返回
    LOG_D(@"getVersionTimeout return");
    //成功并且支持版本更新
    if (self.updater.readyUpdate) {
        if (self.updater.needUpdate) {
            self.tmpData = timer.userInfo;
            [outTimer invalidate];
            outTimer = nil;
            [self.updater startUpdate];
            return;
        }
        LOG_D(@"Device version is new.");
    }
    if ([self.delegate respondsToSelector:@selector(reportInitDeviceResult:error:)]) {
        [self.delegate reportInitDeviceResult:timer.userInfo error:nil];
    }
    [self cannel];
}

- (void)reportInitDeviceResult:(NSData*)data error:(NSError*)error {
    if (!error && [self.updater supportUpdate]) {
        self.tmpData = data;
        //成功并且支持版本更新
        if (self.updater.readyUpdate) {
            if (self.updater.needUpdate) {
                [outTimer invalidate];
                outTimer = nil;
                [self.updater startUpdate];
                return;
            }
            LOG_D(@"Device version is new.");
        }
        else {
            //等待获取固件版本号
            LOG_D(@"Wait get device version.");
            [outTimer invalidate];
            outTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(getVersionTimeout:) userInfo:data repeats:NO];
            return;
        }
        
    }
    if ([self.delegate respondsToSelector:@selector(reportInitDeviceResult:error:)]) {
        [self.delegate reportInitDeviceResult:data error:error];
    }
    [self cannel];
}

- (void)deviceUpdateProgress:(float)percent remainTime:(NSString*)text {
//    NSString *show = [NSString stringWithFormat:@"%0.1f%%", percent];
    if (self.blockOnUpdateDevice) {
        self.blockOnUpdateDevice(percent, text);
    }
}

- (void)deviceUpdateResult:(BOOL)success {
    LOG_D(@"deviceUpdateResult %d", success);
    
    if ([self.delegate respondsToSelector:@selector(reportInitDeviceResult:error:)]) {
        [self.delegate reportInitDeviceResult:self.tmpData error:nil];
    }
//    self.peripheral = nil;
    [self cannel];
}

@end

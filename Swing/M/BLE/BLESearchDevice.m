//
//  BLESearchDevice.m
//  BLETester
//
//  Created by Mapple on 2016/11/14.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import "BLESearchDevice.h"
#import "CommonDef.h"

@interface BLESearchDevice ()
{
    NSTimer *outTimer;
}

@property (nonatomic, strong) NSMutableArray *connectingDevices;
@property (nonatomic, strong) NSMutableDictionary *macAddressDict;
@property (nonatomic, strong) NSData *macAddress;

@end

@implementation BLESearchDevice

- (id)init {
    if (self = [super init]) {
        self.connectingDevices = [NSMutableArray array];
        self.macAddressDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)cannel {
    [super cannel];
    if (outTimer) {
        [outTimer invalidate];
        outTimer = nil;
    }
    for (CBPeripheral *peripheral in _connectingDevices) {
        [self.manager cancelPeripheralConnection:peripheral];
    }
    [_connectingDevices removeAllObjects];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
//    LOG_D(@"didDiscoverPeripheral:%@ advertisementData:%@ RSSI:%@", peripheral, advertisementData, RSSI);
    if ([peripheral.name.uppercaseString hasPrefix:@"SWING"]) {
        if (![self.connectingDevices containsObject:peripheral]) {
            [self.connectingDevices addObject:peripheral];
        }
        if (self.macAddressDict[peripheral]) {
            //该设备已经连接并得到MacAddress
            return;
        }
        LOG_D(@"connectPeripheral:%@", peripheral);
        [central connectPeripheral:peripheral options:nil];
        
//        LOG_D(@"connectPeripheral:%@", peripheral);
//        [central connectPeripheral:peripheral options:nil];
//        if (peripheral.state != CBPeripheralStateConnecting &&
//            peripheral.state != CBPeripheralStateConnected) {
//            LOG_D(@"connectPeripheral:%@", peripheral);
//            [central connectPeripheral:peripheral options:nil];
//        }
        
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    LOG_D(@"didConnectPeripheral:%@", peripheral);
    [peripheral setDelegate:self];
    NSArray *services = @[[CBUUID UUIDWithString:@"FFA0"]];
    [peripheral discoverServices:services];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    LOG_D(@"didFailToConnectPeripheral:%@ error:%@", peripheral, error);
    [self.connectingDevices removeObject:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    LOG_D(@"didDisconnectPeripheral:%@ error:%@", peripheral, error);
    if (error) {
        LOG_D(@"reconnectPeripheral:%@", peripheral);
        [central connectPeripheral:peripheral options:nil];
        return;
    }
    [self.connectingDevices removeObject:peripheral];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    LOG_D(@"didDiscoverServices:%@ error:%@", peripheral, error);
    if (error) {
        return;
    }
    for (CBService *s in peripheral.services) {
        if ([s.UUID isEqual:[CBUUID UUIDWithString:@"FFA0"]]) {
            NSArray *characters = @[[CBUUID UUIDWithString:@"FFA1"], [CBUUID UUIDWithString:@"FFA3"], [CBUUID UUIDWithString:@"FFA6"]];
            [peripheral discoverCharacteristics:characters forService:s];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    LOG_D(@"didDiscoverCharacteristicsForService:%@ error:%@", peripheral, error);
    if (error) {
        return;
    }
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFA0"]]) {
        for (CBCharacteristic *character in service.characteristics) {
            if ([character.UUID isEqual:[CBUUID UUIDWithString:@"FFA1"]]) {
                [peripheral writeValue:[NSData dataWithBytes:"\x01" length:1] forCharacteristic:character type:CBCharacteristicWriteWithResponse];
                LOG_D(@"Write FFA1");
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    LOG_D(@"didWriteValueForCharacteristic:%@ characteristic:%@ error:%@", peripheral, characteristic, error);
    if (error) {
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
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFA6"]]) {
        NSData *macReal = [Fun dataReversal:characteristic.value];
        self.macAddressDict[peripheral] = macReal;
        LOG_D(@"FFA6 Value:%@", characteristic.value);
        LOG_D(@"Mac Real:%@", macReal);
        if (self.macAddress) {
            //兼容原未倒置的MAC地址
            if ([self.macAddress isEqual:characteristic.value] || [self.macAddress isEqual:macReal]) {
                [GlobalCache shareInstance].peripheral = peripheral;
                [self reportSearchDeviceResult:peripheral error:nil];
            }
        }
        else {
            [self reportScanDeviceMacIdResult:peripheral mac:macReal error:nil];
        }
    }
}

- (void)searchDevice:(NSData*)macAddress centralManager:(CBCentralManager *)central {
    self.macAddress = macAddress;
    self.manager = central;
    LOG_D(@"searchDevice:%@", macAddress);
    [self checkBleStatus];
}

- (void)searchDeviceMacIdWithCentralManager:(CBCentralManager *)central {
    self.manager = central;
    self.macAddress = nil;
    LOG_D(@"scanDeviceMacAddress");
    [self checkBleStatus];
}

- (void)bleTimeout {
    NSError *err = [NSError errorWithDomain:@"SwingBluetooth" code:-2 userInfo:[NSDictionary dictionaryWithObject:LOC_STR(@"The bluetooth switch is closed.") forKey:NSLocalizedDescriptionKey]];
    
    if (self.macAddress) {
        [self reportSearchDeviceResult:nil error:err];
    }
    else {
        [self reportScanDeviceMacIdResult:nil mac:nil error:err];
    }
}

- (void)fire {
    [outTimer invalidate];
    if (self.macAddress) {
        //查找指定设备的时候打开超时功能
        outTimer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(operationTimeout) userInfo:nil repeats:NO];
    }
    
//    [self.manager scanForPeripheralsWithServices:nil options:nil];
    [self.manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    if ([GlobalCache shareInstance].peripheral) {
        if (![self.connectingDevices containsObject:[GlobalCache shareInstance].peripheral]) {
            [self.connectingDevices addObject:[GlobalCache shareInstance].peripheral];
        }
        LOG_D(@"connect Cache Peripheral:%@", [GlobalCache shareInstance].peripheral);
        [self.manager connectPeripheral:[GlobalCache shareInstance].peripheral options:nil];
    }
}

- (void)operationTimeout {
    if (self.isCancel) {
        return;
    }
    NSError *err = [NSError errorWithDomain:@"SwingBluetooth" code:-1 userInfo:[NSDictionary dictionaryWithObject:LOC_STR(@"We can't find your device!") forKey:NSLocalizedDescriptionKey]];
    [self reportSearchDeviceResult:nil error:err];
}

- (void)reportSearchDeviceResult:(CBPeripheral*)peripheral error:(NSError*)error {
    if ([self.delegate respondsToSelector:@selector(reportSearchDeviceResult:error:)]) {
        [self.delegate reportSearchDeviceResult:peripheral error:error];
    }
    [self cannel];
}

- (void)reportScanDeviceMacIdResult:(CBPeripheral*)peripheral mac:(NSData*)macId error:(NSError*)error {
    if ([self.delegate respondsToSelector:@selector(reportSearchDeviceMacId:mac:error:)]) {
        [self.delegate reportSearchDeviceMacId:peripheral mac:macId error:error];
    }
    if (error) {
        [self cannel];
    }
}

@end

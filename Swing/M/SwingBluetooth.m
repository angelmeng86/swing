//
//  SwingBluetooth.m
//  BabyBluetoothAppDemo
//
//  Created by Mapple on 16/8/19.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SwingBluetooth.h"
#import "BabyBluetooth.h"
#import "CBService+LMMethod.h"
#import "BatteryModel.h"
#import "EventModel.h"
#import "ActivityModel.h"
#import "Fun.h"
#import "GlobalCache.h"

#define SCAN_DEVIE_CHANEL   @"SCAN_DEVIE_CHANEL"
#define INIT_DEVIE_CHANEL   @"INIT_DEVIE_CHANEL"
#define READ_BATTERY_CHANEL   @"READ_BATTERY_CHANEL"
#define SYNC_DEVIE_CHANEL   @"SYNC_DEVIE_CHANEL"
#define SEARCH_DEVIE_CHANEL   @"SEARCH_DEVIE_CHANEL"

#define  TIME_ADJUST        [NSTimeZone localTimeZone].secondsFromGMT
#define  TIME_STAMP         [[NSDate date] timeIntervalSince1970] + TIME_ADJUST



typedef enum : NSUInteger {
    SwingSyncNone,
    SwingSyncBegin,
    SwingSyncTimeWrited,
    SwingSyncMacReaded,
    SwingSyncAlertNumberWrited,
    SwingSyncAlertTimeWrited,
    SwingSyncHeaderReaded,
    SwingSyncTimeReaded,
    SwingSyncData1Readed,
    SwingSyncData2Readed,
    SwingSyncChecksumWrited,
} SwingSyncState;

@interface SwingBluetooth ()
{
    BabyBluetooth *baby;
    SwingSyncState syncState;
}

@property (nonatomic, copy) SwingBluetoothInitDeviceBlock blockOnInitDevice;
@property (nonatomic, copy) SwingBluetoothScanDeviceBlock blockOnScanDevice;
@property (nonatomic, copy) SwingBluetoothQueryBatteryBlock blockOnQueryBattery;
//@property (nonatomic, copy) SwingBluetoothSearchDeviceBlock blockOnSearchDevice;
@property (nonatomic, copy) SwingBluetoothSyncDeviceBlock blockOnSyncDevice;

@property (nonatomic, strong) NSMutableArray *eventArray;
@property (nonatomic, strong) NSMutableArray *activityArray;
@property (nonatomic, strong) NSMutableDictionary *activityDict;
@property (nonatomic) long timeStamp;
@property (nonatomic, strong) NSData *ffa4Data1;
@property (nonatomic, strong) NSData *ffa4Data2;
@property (nonatomic, strong) NSData *macAddress;
@property (nonatomic, strong) NSMutableIndexSet *timeSet;

@property (nonatomic, strong) NSMutableDictionary *batteryModels;
@property (nonatomic, strong) NSMutableSet *macAddressList;
@property (nonatomic, strong) NSMutableArray *findedModels;

@property (nonatomic) BOOL deviceConnecting;
@property (nonatomic) BOOL isRetry;
@property (nonatomic, strong) NSMutableDictionary *reTryArray;

@end

@implementation SwingBluetooth

- (id)init {
    if (self = [super init]) {
        //初始化BabyBluetooth 蓝牙库
        baby = [BabyBluetooth shareBabyBluetooth];
//        baby = [[BabyBluetooth alloc]init];
        //设置蓝牙委托
        
        [self batteryDelegate];
        [self scanDelegate];
        [self deviceInitDelegate];
        [self syncDelegate];
    }
    return self;
}

#pragma mark -蓝牙配置和操作

- (void)invalidTimers {
    NSArray *allValues = [self.reTryArray allValues];
    for (NSTimer *timer in allValues) {
        [timer invalidate];
    }
    self.reTryArray = nil;
}

- (void)tryWriteFFA3:(NSArray*)userInfo {
    if (userInfo.count == 3) {
        CBCharacteristic *character = [userInfo objectAtIndex:0];
        CBPeripheral *peripheral = [userInfo objectAtIndex:1];
        NSNumber *times = [userInfo objectAtIndex:2];
        NSTimer *timer = [self.reTryArray objectForKey:peripheral];
        [timer invalidate];
        int count = [times intValue];
        if (count == 0) {
            LOG_D(@"retry write FFA3 outline.");
            [self.reTryArray removeObjectForKey:peripheral];
            return;
        }
        
        timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(tryWriteFFA3:) userInfo:@[character, peripheral, [NSNumber numberWithInt:[times intValue] - 1]] repeats:NO];
        [self.reTryArray setObject:timer forKey:peripheral];
        NSData *time = [Fun longToByteArray:TIME_STAMP];
        LOG_D(@"retry write FFA3 %@, times:%@", time, times);
        [peripheral writeValue:time forCharacteristic:character type:CBCharacteristicWriteWithResponse];
        
//        [self performSelector:@selector(tryWriteFFA3:) withObject:@[character, peripheral, [NSNumber numberWithInt:[times intValue] - 1]] afterDelay:3];
    }
}

- (void)tryReadFFA6:(NSArray*)userInfo {
    if (userInfo.count == 3) {
        CBCharacteristic *character = [userInfo objectAtIndex:0];
        CBPeripheral *peripheral = [userInfo objectAtIndex:1];
        NSNumber *times = [userInfo objectAtIndex:2];
        NSTimer *timer = [self.reTryArray objectForKey:peripheral];
        [timer invalidate];
        int count = [times intValue];
        if (count == 0) {
            LOG_D(@"retry read FFA6 outline.");
            [self.reTryArray removeObjectForKey:peripheral];
            return;
        }
        
        timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(tryReadFFA6:) userInfo:@[character, peripheral, [NSNumber numberWithInt:[times intValue] - 1]] repeats:NO];
        [self.reTryArray setObject:timer forKey:peripheral];
        
        LOG_D(@"retry read FFA6, times:%@", times);
        [peripheral readValueForCharacteristic:character];
//        [self performSelector:@selector(tryReadFFA6:) withObject:@[character, [NSNumber numberWithInt:[times intValue] - 1]] afterDelay:3];
    }
}

- (void)batteryDelegate {
    
    __weak typeof(self)weakSelf = self;
    NSString *channel = READ_BATTERY_CHANEL;
    
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripheralsAtChannel:channel block:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        LOG_D(@"搜索到了设备:%@ advertisementData:%@",peripheral.name, advertisementData);
        //        LOG_D(@"peripheral:%@",peripheral);
    }];
    
    
    //设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripheralsAtChannel:channel filter:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        //        LOG_D(@"advertisementData:%@", advertisementData);
        //最常用的场景是查找某一个前缀开头的设备
        if ([peripheralName hasPrefix:@"Swing"] ) {
            LOG_D(@"advertisementData:%@", advertisementData);
            weakSelf.deviceConnecting = YES;
            return YES;
        }
        return NO;
    }];
    
    [baby setBlockOnCancelAllPeripheralsConnectionBlockAtChannel:channel block:^(CBCentralManager *centralManager) {
        LOG_D(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    
    [baby setBlockOnCancelScanBlockAtChannel:channel block:^(CBCentralManager *centralManager) {
        LOG_D(@"setBlockOnCancelScanBlock");
    }];
    
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [baby setBlockOnConnectedAtChannel:channel block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        LOG_D(@"设备：%@--连接成功", peripheral.name);
    }];
    
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnectAtChannel:channel block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        LOG_D(@"设备：%@--连接失败, err:%@",peripheral.name, error);
    }];
    
    //设置设备断开连接的委托
    [baby setBlockOnDisconnectAtChannel:channel block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        LOG_D(@"设备：%@--断开连接, err:%@",peripheral.name, error);
        NSTimer *timer = [weakSelf.reTryArray objectForKey:peripheral];
        [timer invalidate];
        [weakSelf.reTryArray removeObjectForKey:peripheral];
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServicesAtChannel:channel block:^(CBPeripheral *peripheral, NSError *error) {
        LOG_D(@"setBlockOnDiscoverServicesAtChannel, err:%@", error);
    }];
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristicsAtChannel:channel block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        LOG_D(@"===service name:%@, %@, %@, err:%@",service.UUID, service.UUID.UUIDString, service.UUID.data, error);
        if (!error) {
            if ([service.UUID.UUIDString isEqualToString:@"180F"]) {
//                CBCharacteristic *character = [service findCharacteristic:@"2A19"];
//                [peripheral readValueForCharacteristic:character];
            }
            else if ([service.UUID.UUIDString isEqualToString:@"FFA0"]) {
                LOG_D(@"write FFA1");
                CBCharacteristic *character = [service findCharacteristic:@"FFA1"];
                [peripheral writeValue:[NSData dataWithBytes:"\x01" length:1] forCharacteristic:character type:CBCharacteristicWriteWithResponse];
            }
        }
        
    }];
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:channel block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        LOG_D(@"characteristic name:%@ value is:%@, err:%@",characteristic.UUID,characteristic.value, error);
        if (!error) {
            if ([characteristic.UUID.UUIDString isEqualToString:@"2A19"]) {
                const Byte* ptr = characteristic.value.bytes;
                LOG_D(@"Read Battery:%d%%", ptr[0]);
                [weakSelf reportQueryBatteryResult:characteristic.service.peripheral battery:ptr[0] mac:nil error:nil];
            }
            else if ([characteristic.UUID.UUIDString isEqualToString:@"FFA6"]) {
//                [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(tryReadFFA6:) object:nil];
                NSTimer *timer = [weakSelf.reTryArray objectForKey:characteristic.service.peripheral];
                [timer invalidate];
                [weakSelf.reTryArray removeObjectForKey:characteristic.service.peripheral];
                LOG_D(@"Mac Address:%@", characteristic.value);
                [weakSelf reportQueryBatteryResult:characteristic.service.peripheral battery:-1 mac:characteristic.value error:nil];
            }
        }
    }];
    
    [baby setBlockOnDidWriteValueForCharacteristicAtChannel:channel block:^(CBCharacteristic *characteristic, NSError *error) {
        LOG_D(@"DidWriteValueForCharacteristicAtChannel name:%@, err:%@",characteristic.UUID, error);
        if (!error) {
            if ([characteristic.UUID.UUIDString isEqualToString:@"FFA1"]) {
//                LOG_D(@"read FFA6");
//                CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA6"];
//                [characteristic.service.peripheral readValueForCharacteristic:character];
                
                CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA3"];
                NSData *time = [Fun longToByteArray:TIME_STAMP];
                LOG_D(@"write FFA3 %@", time);
                [characteristic.service.peripheral writeValue:time forCharacteristic:character type:CBCharacteristicWriteWithResponse];
                NSTimer *timer = [weakSelf.reTryArray objectForKey:character.service.peripheral];
                if (timer) {
                    [timer invalidate];
                }
                timer = [NSTimer scheduledTimerWithTimeInterval:3 target:weakSelf selector:@selector(tryWriteFFA3:) userInfo:@[character, character.service.peripheral, @3] repeats:NO];
                [weakSelf.reTryArray setObject:timer forKey:character.service.peripheral];
//                [weakSelf performSelector:@selector(tryWriteFFA3:) withObject:@[character, @3] afterDelay:3];
            }
            else if ([characteristic.UUID.UUIDString isEqualToString:@"FFA3"]) {
//                [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(tryWriteFFA3:) object:nil];
                NSTimer *timer = [weakSelf.reTryArray objectForKey:characteristic.service.peripheral];
                [timer invalidate];
                [weakSelf.reTryArray removeObjectForKey:characteristic.service.peripheral];
                LOG_D(@"read FFA6");
                CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA6"];
                [characteristic.service.peripheral readValueForCharacteristic:character];
            }
        }
    }];
    
//    NSArray *services = @[[CBUUID UUIDWithString:@"FFA0"], [CBUUID UUIDWithString:@"180F"]];
//    NSArray *characters = @[[CBUUID UUIDWithString:@"FFA1"], [CBUUID UUIDWithString:@"FFA3"], [CBUUID UUIDWithString:@"FFA6"], [CBUUID UUIDWithString:@"2A19"]];
    
    NSArray *services = @[[CBUUID UUIDWithString:@"FFA0"]];
    NSArray *characters = @[[CBUUID UUIDWithString:@"FFA1"], [CBUUID UUIDWithString:@"FFA3"], [CBUUID UUIDWithString:@"FFA6"]];
    
    [baby setBabyOptionsAtChannel:channel scanForPeripheralsWithOptions:nil connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:services discoverWithCharacteristics:characters];
}

- (void)deviceInitDelegate {
    __weak typeof(self)weakSelf = self;
    NSString *channel = INIT_DEVIE_CHANEL;
    
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    rhythm.beatsInterval = 5;
    
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [baby setBlockOnConnectedAtChannel:channel block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [rhythm beats];
    }];
    
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnectAtChannel:channel block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        LOG_D(@"设备：%@--连接失败",peripheral.name);
        [weakSelf reportInitDeviceResult:nil error:error];
    }];
    
    //设置设备断开连接的委托
    [baby setBlockOnDisconnectAtChannel:channel block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        LOG_D(@"设备：%@--断开连接",peripheral.name);
       [weakSelf reportInitDeviceResult:nil error:error];
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServicesAtChannel:channel block:^(CBPeripheral *peripheral, NSError *error) {
        if (error) {
            [weakSelf reportInitDeviceResult:nil error:error];
        }
        else {
            [rhythm beats];
        }
    }];
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristicsAtChannel:channel block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        LOG_D(@"===service name:%@ ,%@,%@",service.UUID, service.UUID.UUIDString, service.UUID.data);
        if (error) {
            [weakSelf reportInitDeviceResult:nil error:error];
        }
        else {
            if ([service.UUID.UUIDString isEqualToString:@"180F"]) {
                CBCharacteristic *character = [service findCharacteristic:@"2A19"];
                [peripheral readValueForCharacteristic:character];
            }
            else if ([service.UUID.UUIDString isEqualToString:@"FFA0"]) {
                LOG_D(@"write FFA1");
                CBCharacteristic *character = [service findCharacteristic:@"FFA1"];
                [peripheral writeValue:[NSData dataWithBytes:"\x01" length:1] forCharacteristic:character type:CBCharacteristicWriteWithResponse];
                [rhythm beats];
            }
        }
        
    }];
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:channel block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        LOG_D(@"characteristic name:%@ value is:%@",characteristic.UUID,characteristic.value);
        if (!error) {
            if ([characteristic.UUID.UUIDString isEqualToString:@"2A19"]) {
                const Byte* ptr = characteristic.value.bytes;
                LOG_D(@"Read Battery:%d%%", ptr[0]);
                [GlobalCache shareInstance].battery = ptr[0];
                [[NSNotificationCenter defaultCenter] postNotificationName:SWING_WATCH_BATTERY_NOTIFY object:[NSNumber numberWithInt:ptr[0]]];
            }
            else if ([characteristic.UUID.UUIDString isEqualToString:@"FFA6"]) {
                LOG_D(@"Mac Address:%@", characteristic.value);
                [weakSelf reportInitDeviceResult:characteristic.value error:nil];
                [rhythm beatsOver];
            }
        }
        else {
            if ([characteristic.UUID.UUIDString isEqualToString:@"FFA6"]) {
                [weakSelf reportInitDeviceResult:nil error:error];
            }
        }
    }];
    
    [baby setBlockOnDidWriteValueForCharacteristicAtChannel:channel block:^(CBCharacteristic *characteristic, NSError *error) {
        if (error) {
            [weakSelf reportInitDeviceResult:nil error:error];
        }
        else {
            if ([characteristic.UUID.UUIDString isEqualToString:@"FFA1"]) {
                CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA3"];
                NSData *time = [Fun longToByteArray:TIME_STAMP];
                LOG_D(@"write FFA3 %@", time);
                [characteristic.service.peripheral writeValue:time forCharacteristic:character type:CBCharacteristicWriteWithResponse];
                [rhythm beats];
            }
            else if ([characteristic.UUID.UUIDString isEqualToString:@"FFA3"]) {
                LOG_D(@"read FFA6");
                CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA6"];
                [characteristic.service.peripheral readValueForCharacteristic:character];
                [rhythm beats];
            }
        }
    }];
    
    //设置beats break委托
    [rhythm setBlockOnBeatsBreak:^(BabyRhythm *bry) {
        LOG_D(@"setBlockOnBeatsBreak call");
        NSError *err = [NSError errorWithDomain:@"SwingBluetooth" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"Operation timeout." forKey:NSLocalizedDescriptionKey]];
        [weakSelf reportInitDeviceResult:nil error:err];
    }];
    
    //设置beats over委托
    [rhythm setBlockOnBeatsOver:^(BabyRhythm *bry) {
        LOG_D(@"setBlockOnBeatsOver call");
    }];
    
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
//    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
     */
//    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
//                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
//                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    NSArray *services = @[[CBUUID UUIDWithString:@"FFA0"], [CBUUID UUIDWithString:@"180F"]];
    NSArray *characters = @[[CBUUID UUIDWithString:@"FFA1"], [CBUUID UUIDWithString:@"FFA3"], [CBUUID UUIDWithString:@"FFA6"], [CBUUID UUIDWithString:@"2A19"]];
    [baby setBabyOptionsAtChannel:channel scanForPeripheralsWithOptions:nil connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:services discoverWithCharacteristics:characters];
}

- (void)scanDelegate {
    NSString *channel = SCAN_DEVIE_CHANEL;
    __weak typeof(self) weakSelf = self;
    
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    rhythm.beatsInterval = 5;
    
    [baby setBlockOnCentralManagerDidUpdateStateAtChannel:channel block:^(CBCentralManager *central) {
        LOG_D(@"scan state %ld", (long)central.state);
        if (central.state == CBCentralManagerStatePoweredOn) {

        }
    }];
    
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripheralsAtChannel:channel block:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        LOG_D(@"搜索到了设备:%@",peripheral.name);
//        LOG_D(@"peripheral:%@",peripheral);
        [weakSelf reportScanDeviceResult:peripheral advertisementData:advertisementData error:nil];
    }];
    
    
    //设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripheralsAtChannel:channel filter:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
//        LOG_D(@"advertisementData:%@", advertisementData);
        //最常用的场景是查找某一个前缀开头的设备
//        if ([peripheralName hasPrefix:@"Swing-D-X"] ) {
//            return YES;
//        }
        return YES;
    }];
    
    [baby setBlockOnCancelAllPeripheralsConnectionBlockAtChannel:channel block:^(CBCentralManager *centralManager) {
        LOG_D(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    
    [baby setBlockOnCancelScanBlockAtChannel:channel block:^(CBCentralManager *centralManager) {
        LOG_D(@"setBlockOnCancelScanBlock");
    }];
    
    
    /*设置babyOptions
     
     参数分别使用在下面这几个地方，若不使用参数则传nil
     - [centralManager scanForPeripheralsWithServices:scanForPeripheralsWithServices options:scanForPeripheralsWithOptions];
     - [centralManager connectPeripheral:peripheral options:connectPeripheralWithOptions];
     - [peripheral discoverServices:discoverWithServices];
     - [peripheral discoverCharacteristics:discoverWithCharacteristics forService:service];
     
     该方法支持channel版本:
     [baby setBabyOptionsAtChannel:<#(NSString *)#> scanForPeripheralsWithOptions:<#(NSDictionary *)#> connectPeripheralWithOptions:<#(NSDictionary *)#> scanForPeripheralsWithServices:<#(NSArray *)#> discoverWithServices:<#(NSArray *)#> discoverWithCharacteristics:<#(NSArray *)#>]
     */
    
    //示例:
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //连接设备->
    [baby setBabyOptionsAtChannel:channel scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}

- (void)syncDelegate {
    __weak typeof(self)weakSelf = self;
    NSString *channel = SYNC_DEVIE_CHANEL;
    
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    rhythm.beatsInterval = 8;
    
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [baby setBlockOnConnectedAtChannel:channel block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(syncDeviceTimeout) object:nil];
        [rhythm beats];
    }];
    
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnectAtChannel:channel block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        LOG_D(@"设备：%@--连接失败",peripheral.name);
        [weakSelf reportSyncDeviceResult:error];
    }];
    
    //设置设备断开连接的委托
    [baby setBlockOnDisconnectAtChannel:channel block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        LOG_D(@"设备：%@--断开连接",peripheral.name);
        [weakSelf reportSyncDeviceResult:error];
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServicesAtChannel:channel block:^(CBPeripheral *peripheral, NSError *error) {
        if (error) {
            [weakSelf reportSyncDeviceResult:error];
        }
        else {
            [rhythm beats];
        }
    }];
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristicsAtChannel:channel block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        LOG_D(@"===service name:%@ ,%@,%@",service.UUID, service.UUID.UUIDString, service.UUID.data);
        if (error) {
            [weakSelf reportSyncDeviceResult:error];
        }
        else {
            if ([service.UUID.UUIDString isEqualToString:@"180F"]) {
                CBCharacteristic *character = [service findCharacteristic:@"2A19"];
                [peripheral readValueForCharacteristic:character];
            }
            else if ([service.UUID.UUIDString isEqualToString:@"FFA0"]) {
                LOG_D(@"write FFA1");
                syncState = SwingSyncBegin;
                CBCharacteristic *character = [service findCharacteristic:@"FFA1"];
                [peripheral writeValue:[NSData dataWithBytes:"\x01" length:1] forCharacteristic:character type:CBCharacteristicWriteWithResponse];
                [rhythm beats];
            }
        }
        
    }];
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:channel block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        LOG_D(@"characteristic name:%@ value is:%@",characteristic.UUID,characteristic.value);
        if (!error) {
            if ([characteristic.UUID.UUIDString isEqualToString:@"2A19"]) {
                const Byte* ptr = characteristic.value.bytes;
                LOG_D(@"Read Battery:%d%%", ptr[0]);
                [GlobalCache shareInstance].battery = ptr[0];
                [[NSNotificationCenter defaultCenter] postNotificationName:SWING_WATCH_BATTERY_NOTIFY object:[NSNumber numberWithInt:ptr[0]]];
            }
            else if ([characteristic.UUID.UUIDString isEqualToString:@"FFA6"]) {
                LOG_D(@"Mac Address:%@", characteristic.value);
                weakSelf.macAddress = characteristic.value;
                LOG_D(@"write FFA7");
                [weakSelf writeAlertNumber:characteristic.service];
                syncState = SwingSyncAlertNumberWrited;
                [rhythm beats];
            }
            else if ([characteristic.UUID.UUIDString isEqualToString:@"FFA9"]) {
                const Byte *ptr = characteristic.value.bytes;
                LOG_D(@"HeaderReaded len %d %02x%02x", (int)[characteristic.value length], ptr[0], ptr[1]);
                if (ptr[0] == 0x01 && ptr[1] == 0x00) {
                    LOG_D(@"Have Data!");
                    //FFA3
                    CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA3"];
                    [characteristic.service.peripheral readValueForCharacteristic:character];
                    [rhythm beats];
                    LOG_D(@"Read FFA3");
                    syncState = SwingSyncTimeReaded;
                }
                else {
                    LOG_D(@"No Data!");
                    syncState = SwingSyncNone;
                    //断开连接
                    [rhythm beatsOver];
                    [weakSelf reportSyncDeviceResult:nil];
                }
            }
            else if ([characteristic.UUID.UUIDString isEqualToString:@"FFA3"]) {
                long value = [Fun byteArrayToLong:characteristic.value];
                weakSelf.timeStamp = value;
                LOG_D(@"SwingSyncTimeReaded:%@", [NSDate dateWithTimeIntervalSince1970:value]);
                
                syncState = SwingSyncData1Readed;
                LOG_D(@"Read FFA4");
                CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA4"];
                [characteristic.service.peripheral readValueForCharacteristic:character];
                [rhythm beats];
            }
            else if ([characteristic.UUID.UUIDString isEqualToString:@"FFA4"]) {
                if (syncState == SwingSyncData1Readed) {
                    weakSelf.ffa4Data1 = characteristic.value;
                    syncState = SwingSyncData2Readed;
                    LOG_D(@"Read FFA4");
                    CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA4"];
                    [characteristic.service.peripheral readValueForCharacteristic:character];
                    
                }
                else {
                    LOG_D(@"SwingSyncData2Readed:%d", (int)characteristic.value.length);
                    
                    Byte array[1];
                    if ([weakSelf.ffa4Data1 isEqualToData:characteristic.value]) {
                        //数据有误
                        array[0] = 0x00;
                        weakSelf.ffa4Data2 = nil;
                    }
                    else {
                        array[0] = 0x01;
                        weakSelf.ffa4Data2 = characteristic.value;
                    }
                    LOG_D(@"Write FFA5");
                    NSData *data = [NSData dataWithBytes:array length:1];
                    CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA5"];
                    [characteristic.service.peripheral writeValue:data forCharacteristic:character type:CBCharacteristicWriteWithResponse];
                    syncState = SwingSyncChecksumWrited;
                }
                [rhythm beats];
            }
        }
        else {
            if (![characteristic.UUID.UUIDString isEqualToString:@"2A19"]) {
                [weakSelf reportSyncDeviceResult:error];
            }
        }
    }];
    
    [baby setBlockOnDidWriteValueForCharacteristicAtChannel:channel block:^(CBCharacteristic *characteristic, NSError *error) {
        if ([characteristic.UUID.UUIDString isEqualToString:@"FFA8"]) {
            LOG_D(@"FFA8 err:%@", error);
            [weakSelf writeAlertNumber:characteristic.service];
            LOG_D(@"write FFA7");
            [rhythm beats];
            return;
        }
        if (error) {
            [weakSelf reportInitDeviceResult:nil error:error];
        }
        else {
            if ([characteristic.UUID.UUIDString isEqualToString:@"FFA1"]) {
                CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA3"];
                NSData *time = [Fun longToByteArray:TIME_STAMP];
                LOG_D(@"write FFA3 %@", time);
                [characteristic.service.peripheral writeValue:time forCharacteristic:character type:CBCharacteristicWriteWithResponse];
            }
            else if ([characteristic.UUID.UUIDString isEqualToString:@"FFA3"]) {
                LOG_D(@"read FFA6");
                CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA6"];
                [characteristic.service.peripheral readValueForCharacteristic:character];
            }
            else if ([characteristic.UUID.UUIDString isEqualToString:@"FFA7"]) {
                
                if ([weakSelf writeAlertTimestmp:characteristic.service]) {
                    LOG_D(@"write FFA8");
                    syncState = SwingSyncTimeWrited;
                }
                else {
                    LOG_D(@"read FFA9");
                    syncState = SwingSyncHeaderReaded;
                    CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA9"];
                    [characteristic.service.peripheral readValueForCharacteristic:character];
                }
            }
            else if ([characteristic.UUID.UUIDString isEqualToString:@"FFA5"]) {
                if (weakSelf.ffa4Data2) {
                    //判断是否存在重复数据
                    if (![weakSelf.timeSet containsIndex:weakSelf.timeStamp]) {
                        [weakSelf.timeSet addIndex:weakSelf.timeStamp];
                        //处理Activity数据
                        static NSDateFormatter *df = nil;
                        if (df == nil) {
                            df = [[NSDateFormatter alloc] init];
                            df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                            [df setDateFormat:@"yyyy-MM-dd"];
                        }
                        NSString *key = [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:weakSelf.timeStamp]];
                        ActivityModel *model = [ActivityModel new];
                        model.time = weakSelf.timeStamp;
                        model.macId = [Fun dataToHex:weakSelf.macAddress];
                        [model setIndoorData:weakSelf.ffa4Data1];
                        [model setOutdoorData:weakSelf.ffa4Data2];
                        [weakSelf.activityArray addObject:model];
                        
                        NSString *local = [GlobalCache shareInstance].local.date;
                        if (local && [local isEqualToString:key]) {
                            //累加当天的步数
                            [GlobalCache shareInstance].local.indoorSteps += model.inData1;
                            [GlobalCache shareInstance].local.outdoorSteps += model.outData1;
                            [[GlobalCache shareInstance] saveInfo];
                        }
                        /*
                         if (weakSelf.activityDict[key]) {
                         ActivityModel *m = weakSelf.activityDict[key];
                         [m add:model];
                         [m reload];
                         }
                         else {
                         weakSelf.activityDict[key] = model;
                         }
                         */
                        LOG_D(@"activity: time:%ld indoor:%@ outdoor:%@ date:%@", model.time, model.indoorActivity, model.outdoorActivity, key);
                    }
                    else {
                        LOG_D(@"activity: time:%@ is repeat.", [NSDate dateWithTimeIntervalSince1970:weakSelf.timeStamp]);
                    }
                }
                
                LOG_D(@"read FFA9");
                syncState = SwingSyncHeaderReaded;
                CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA9"];
                [characteristic.service.peripheral readValueForCharacteristic:character];
            }
            [rhythm beats];
        }
    }];
    
    //设置beats break委托
    [rhythm setBlockOnBeatsBreak:^(BabyRhythm *bry) {
        LOG_D(@"setBlockOnBeatsBreak call");
        NSError *err = [NSError errorWithDomain:@"SwingBluetooth" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"Operation timeout." forKey:NSLocalizedDescriptionKey]];
        [weakSelf reportSyncDeviceResult:err];
    }];
    
    //设置beats over委托
    [rhythm setBlockOnBeatsOver:^(BabyRhythm *bry) {
        LOG_D(@"setBlockOnBeatsOver call");
    }];
    
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    //    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
     */
//    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
//                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
//                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    NSArray *services = @[[CBUUID UUIDWithString:@"FFA0"], [CBUUID UUIDWithString:@"180F"]];
    [baby setBabyOptionsAtChannel:channel scanForPeripheralsWithOptions:nil connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:services discoverWithCharacteristics:nil];
}

- (BOOL)writeAlertNumber:(CBService*)service {
    CBCharacteristic *characteristic = [service findCharacteristic:@"FFA7"];
    Byte array[1];
    array[0] = 0x00;
    if (_eventArray.count > 0) {
        //往FFA7里面写
        EventModel *model = [_eventArray firstObject];
        array[0] = model.alert;
        LOG_D(@"lwz alert:%d", model.alert);
    }
    NSData *data = [NSData dataWithBytes:array length:1];
    [service.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    return array[0] == 0x00 ? NO : YES;
}

- (BOOL)writeAlertTimestmp:(CBService*)service {
    if (_eventArray.count > 0) {
        // 往FFA8里面放未来的时间戳
        EventModel *model = [_eventArray firstObject];
        [_eventArray removeObjectAtIndex:0];
        long date = [model.startDate timeIntervalSince1970] + TIME_ADJUST;
        NSData *timedata = [Fun longToByteArray:date];
        LOG_D(@"date %@, timestamp:%@", model.startDate, timedata);
        CBCharacteristic *characteristic = [service findCharacteristic:@"FFA8"];
        [service.peripheral writeValue:timedata forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        return YES;
    }
    return NO;
}

- (void)scanDeviceWithCompletion:(SwingBluetoothScanDeviceBlock)completion {
    //停止之前的连接
    [self cannelAll];
    self.blockOnScanDevice = completion;
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
    baby.channel(SCAN_DEVIE_CHANEL).scanForPeripherals().begin();
}

- (void)reportScanDeviceResult:(CBPeripheral*)peripheral advertisementData:(NSDictionary *)advertisementData error:(NSError*)error {
    if (self.blockOnScanDevice) {
        self.blockOnScanDevice(peripheral, advertisementData, error);
        if (error) {
            self.blockOnInitDevice = nil;
        }
    }
}

- (void)stopScan {
    self.blockOnInitDevice = nil;
    [baby cancelScan];
}

- (void)cannelAll {
    self.blockOnInitDevice = nil;
    self.blockOnScanDevice = nil;
    self.blockOnQueryBattery = nil;
    self.blockOnSyncDevice = nil;
    [self invalidTimers];
    [baby cancelScan];
    [baby cancelAllPeripheralsConnection];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)queryBattery:(NSArray*)macAddressList completion:(SwingBluetoothQueryBatteryBlock)completion {
    [self cannelAll];
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(queryBatteryTimeout) object:nil];
    self.deviceConnecting = NO;
    self.macAddressList = [NSMutableSet setWithArray:macAddressList];
    self.batteryModels = [NSMutableDictionary dictionary];
    self.reTryArray = [NSMutableDictionary dictionary];
    self.findedModels = [NSMutableArray array];
    self.blockOnQueryBattery = completion;
    [self performSelector:@selector(queryBatteryTimeout) withObject:nil afterDelay:30];
    baby.channel(READ_BATTERY_CHANEL).scanForPeripherals().then.connectToPeripherals().discoverServices().discoverCharacteristics().begin();
}

- (void)reportQueryBatteryResult:(CBPeripheral*)peripheral battery:(int)value mac:(NSData*)mac error:(NSError*)error {
    if (!error) {
        BatteryModel *m = nil;
        if (!_batteryModels[peripheral]) {
            m = [BatteryModel new];
            m.peripheral = peripheral;
            _batteryModels[peripheral] = m;
        }
        else {
            m = _batteryModels[peripheral];
        }
        if (mac) {
            m.macAddress = mac;
        }
        if (value >= 0) {
            m.batteryValue = value;
        }
        
        NSArray *array = [_batteryModels allValues];
        for (BatteryModel *m in array) {
            if([m ready] && [_macAddressList containsObject:m.macAddress]) {
                [_findedModels addObject:m];
                [_macAddressList removeObject:m.macAddress];
            }
        }
        
        if (_macAddressList.count > 0) {
            return;
        }
    }
    if (self.blockOnQueryBattery) {
        self.blockOnQueryBattery(_findedModels, error);
        self.blockOnQueryBattery = nil;
        
        self.macAddressList = nil;
        self.batteryModels = nil;
        self.findedModels = nil;
        [self invalidTimers];
//        self.deviceConnecting = NO;
    }
    [baby cancelScan];
    [baby cancelAllPeripheralsConnection];
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(queryBatteryTimeout) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)queryBatteryTimeout {
    NSError *err = [NSError errorWithDomain:@"SwingBluetooth" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"Can not find device, operation timeout." forKey:NSLocalizedDescriptionKey]];
    [self reportQueryBatteryResult:nil battery:-1 mac:nil error:err];
}

- (void)initDevice:(CBPeripheral*)peripheral completion:(SwingBluetoothInitDeviceBlock)completion {
    [self cannelAll];
    self.blockOnInitDevice = completion;
    baby.having(peripheral).and.channel(INIT_DEVIE_CHANEL).then.connectToPeripherals().discoverServices().discoverCharacteristics().begin();
}

- (void)reportInitDeviceResult:(NSData*)data error:(NSError*)error {
    if (self.blockOnInitDevice) {
        self.blockOnInitDevice(data, error);
        self.blockOnInitDevice = nil;
    }
//    if (error) {
        [baby cancelScan];
        [baby cancelAllPeripheralsConnection];
//    }
}

- (void)searchDevice:(NSData*)macAddress completion:(SwingBluetoothSearchDeviceBlock)completion {
    self.isRetry = NO;
    [self searchDevice2:macAddress completion:completion];
}

- (void)searchDevice2:(NSData*)macAddress completion:(SwingBluetoothSearchDeviceBlock)completion {
    [self queryBattery:@[macAddress] completion:^(NSArray *batteryDevices, NSError *error) {
        BatteryModel *m = [batteryDevices firstObject];
        if (m == nil) {
//            if (self.deviceConnecting && !self.isRetry) {
//                //再进行一次超时连接
//                LOG_D(@"首次连接设备超时，再进行一次");
//                self.isRetry = YES;
//                [self searchDevice2:macAddress completion:completion];
//                return;
//            }
            if (!error) {
                error = [NSError errorWithDomain:@"SwingBluetooth" code:-2 userInfo:[NSDictionary dictionaryWithObject:@"can not find device." forKey:NSLocalizedDescriptionKey]];
            }
            completion(nil, error);
        }
        else {
            completion(m.peripheral, nil);
        }
    }];
}


- (void)syncDevice:(CBPeripheral*)peripheral event:(NSArray*)events completion:(SwingBluetoothSyncDeviceBlock)completion {
    [self cannelAll];
    syncState = SwingSyncNone;
    self.eventArray = [NSMutableArray arrayWithArray:events];
    for (int i = (int)_eventArray.count; --i >= 0;) {
        EventModel *obj = _eventArray[i];
        if (obj.alert < 34) {
            [_eventArray removeObjectAtIndex:i];
        }
    }
    self.activityArray = [NSMutableArray array];
    self.activityDict = [NSMutableDictionary dictionary];
    self.timeSet = [NSMutableIndexSet new];
    self.blockOnSyncDevice = completion;
    baby.having(peripheral).and.channel(SYNC_DEVIE_CHANEL).then.connectToPeripherals().discoverServices().discoverCharacteristics().begin();
    [self performSelector:@selector(syncDeviceTimeout) withObject:nil afterDelay:30];
}

- (void)syncDeviceTimeout {
    NSError *err = [NSError errorWithDomain:@"SwingBluetooth" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"connectPeripheral timeout." forKey:NSLocalizedDescriptionKey]];
    [self reportSyncDeviceResult:err];
}

- (void)reportSyncDeviceResult:(NSError*)error {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(syncDeviceTimeout) object:nil];
    if (self.blockOnSyncDevice) {
//        NSString *key = [GlobalCache shareInstance].local.date;
//        if (key && _activityDict[key]) {
//            //累加当天的步数
//            ActivityModel *m = _activityDict[key];
//            [GlobalCache shareInstance].local.indoorSteps += m.inData1;
//            [GlobalCache shareInstance].local.outdoorSteps += m.outData1;
//            [[GlobalCache shareInstance] saveInfo];
//        }
//        self.blockOnSyncDevice([NSMutableArray arrayWithArray:[_activityDict allValues]], error);
        self.blockOnSyncDevice(_activityArray, error);
        self.blockOnSyncDevice = nil;
        
        self.eventArray = nil;
        self.activityArray = nil;
        self.activityDict = nil;
        self.timeSet = nil;
        
        self.ffa4Data1 = nil;
        self.ffa4Data2 = nil;
        self.macAddress = nil;
    }
    [baby cancelScan];
    [baby cancelAllPeripheralsConnection];
}

@end

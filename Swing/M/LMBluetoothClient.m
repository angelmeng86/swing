//
//  LMBluetoothClient.m
//  Swing
//
//  Created by Mapple on 16/8/16.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBluetoothClient.h"
#import "BabyBluetooth.h"
#import "PeripheralInfo.h"
#import "CommonDef.h"

#define channelOnPeropheralView @"View2"
#define TimeStamp [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]]

typedef enum : NSUInteger {
    SwingSettingNone,
    SwingSettingTimeWrited,
    SwingSettingMacReaded,
} SwingSettingState;

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

@interface LMBluetoothClient () {
    NSMutableArray *peripherals;
    NSMutableArray *peripheralsAD;
    //lwz add
    SwingSettingState settingState;
    SwingSyncState syncState;
//    NSMutableArray *alertEvent;
    //lwz end
    BabyBluetooth *baby;
    NSMutableArray *sect;
    __block  NSMutableArray *readValueArray;
    __block  NSMutableArray *descriptors;
    int yunsuanfu;
}

@property __block NSMutableArray *services;
@property(strong,nonatomic)CBPeripheral *currPeripheral;
@property (nonatomic,strong)CBCharacteristic *characteristic;

@property (nonatomic, strong) NSData *ffa4Data;

@end

@implementation LMBluetoothClient

- (id)init {
    if (self = [super init]) {
        //初始化BabyBluetooth 蓝牙库
        baby = [BabyBluetooth shareBabyBluetooth];
        //设置蓝牙委托
        [self initBluetooth];
    }
    return self;
}

- (void)beginScan {
    baby.scanForPeripherals(1).begin();
}

- (void)syncDevice {
    if ([peripherals objectAtIndex:0] == nil) {
        NSLog(@"没找到设备");
    }else{
        self.currPeripheral = [peripherals objectAtIndex:0];
        
        baby.having(self.currPeripheral).and.channel(channelOnPeropheralView).then.connectToPeripherals().discoverServices().discoverCharacteristics().begin();
        
        [self performSelector:@selector(beginSync) withObject:nil afterDelay:8.0];
    }
}

- (void)beginSync {
    [self writeValue01];
    syncState = SwingSyncBegin;
}

-(void)writeValue01{
    self.characteristic =[[[self.services objectAtIndex:5] characteristics]objectAtIndex:0];
    //    int i = 1;
    Byte array[1];
    array[0] = 0x01;
    NSData *data = [NSData dataWithBytes:array length:1];
    [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    
}

- (BOOL)writeAlertNumber {
    if (_alertEvents.count > 0) {
        //往FFA7里面写
        self.characteristic =[[[self.services objectAtIndex:5] characteristics]objectAtIndex:6];
        Byte array[1];
        EventModel *model = [_alertEvents firstObject];
        array[0] = model.alert == 0 ? 40 : model.alert;
        NSData *data = [NSData dataWithBytes:array length:1];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        return YES;
    }
    //往FFA7里面写 0x00
    self.characteristic =[[[self.services objectAtIndex:5] characteristics]objectAtIndex:6];
    Byte array[1];
    array[0] = 0x00;
    NSData *data = [NSData dataWithBytes:array length:1];
    [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    return NO;
}

- (BOOL)writeAlertTimestmp {
    if (_alertEvents.count > 0) {
        // 往FFA8里面放未来的时间戳
        EventModel *model = [_alertEvents firstObject];
//        NSDate * twoM = [[NSDate date] dateByAddingTimeInterval:[[alertEvent firstObject] intValue]];
        [_alertEvents removeObjectAtIndex:0];
        long date = [model.startDate timeIntervalSince1970] ;
        NSData *timedata = [Fun longToByteArray:date];
        NSLog(@"穿进去的值是！！！！＝＝＝＝＝ %@",timedata);
        self.characteristic =[[[self.services objectAtIndex:5] characteristics]objectAtIndex:7];
        [self.currPeripheral writeValue:timedata forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        return YES;
    }
    return NO;
}

- (void)syncReaded:(CBCharacteristic*)characteristic {
    NSLog(@"syncReaded %lu", (unsigned long)syncState);
    switch (syncState) {
        case SwingSyncMacReaded:
        {
            NSLog(@"SwingSyncMacReaded %@", characteristic.value);
            
//            alertEvent = [NSMutableArray array];
//            [alertEvent addObject:@60];
//            [alertEvent addObject:@70];
//            [alertEvent addObject:@80];
//            [alertEvent addObject:@90];
            
            [self writeAlertNumber];
            syncState = SwingSyncAlertNumberWrited;
        }
            break;
        case SwingSyncHeaderReaded:
        {
            const Byte *ptr = characteristic.value.bytes;
            NSLog(@"SwingSyncHeaderReaded %x%x", ptr[0], ptr[1]);
            if (ptr[0] == 0x00 && ptr[1] == 0x01) {
                NSLog(@"Have Data!");
                //FFA3
                self.characteristic =[[[self.services objectAtIndex:5] characteristics]objectAtIndex:2];
                
                [self.currPeripheral readValueForCharacteristic:self.characteristic];
                syncState = SwingSyncTimeReaded;
            }
            else if (ptr[0] == 0x01 && ptr[1] == 0x00) {
                NSLog(@"No Data!");
                syncState = SwingSyncNone;
                //断开连接
                [baby cancelPeripheralConnection:self.currPeripheral];
                if ([_delegate respondsToSelector:@selector(bluetoothClientSyncFinished)]) {
                    [_delegate bluetoothClientSyncFinished];
                }
            }
        }
            break;
        case SwingSyncTimeReaded:
        {
            long value = [Fun byteArrayToLong:characteristic.value];
            NSLog(@"SwingSyncTimeReaded:%@", [NSDate dateWithTimeIntervalSince1970:value]);
            //FFA4
            self.characteristic =[[[self.services objectAtIndex:5] characteristics]objectAtIndex:3];
            
            [self.currPeripheral readValueForCharacteristic:self.characteristic];
            syncState = SwingSyncData1Readed;
        }
            break;
        case SwingSyncData1Readed:
        {
            NSLog(@"SwingSyncData1Readed:%lu", characteristic.value.length);
            self.ffa4Data = characteristic.value;
            //FFA4
            self.characteristic =[[[self.services objectAtIndex:5] characteristics]objectAtIndex:3];
            
            [self.currPeripheral readValueForCharacteristic:self.characteristic];
            syncState = SwingSyncData2Readed;
        }
            break;
        case SwingSyncData2Readed:
        {
            NSLog(@"SwingSyncData2Readed:%lu", characteristic.value.length);
            
            self.characteristic =[[[self.services objectAtIndex:5] characteristics]objectAtIndex:0];
            //    int i = 1;
            Byte array[1];
            if ([_ffa4Data isEqualToData:characteristic.value]) {
                //数据有误
                array[0] = 0x00;
            }
            else {
                array[0] = 0x01;
            }
            NSData *data = [NSData dataWithBytes:array length:1];
            [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
            syncState = SwingSyncChecksumWrited;
            
        }
            break;
        default:
            break;
    }
}

- (void)syncWrited:(CBCharacteristic*)characteristic {
    NSLog(@"syncWrited %lu", (unsigned long)syncState);
    switch (syncState) {
        case SwingSyncBegin:
        {
            //FFA3
            self.characteristic =[[[self.services objectAtIndex:5] characteristics]objectAtIndex:2];
            
            NSLog(@"时间戳为！！！！＝＝＝＝＝＝＝＝＝＝ @%@",TimeStamp);
            
            long date = [[NSDate date] timeIntervalSince1970] - 3 * 60 * 60;
            NSData *data = [Fun longToByteArray:date];
            
            self.characteristic =[[[self.services objectAtIndex:5] characteristics]objectAtIndex:2];
            [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
            syncState = SwingSyncTimeWrited;
        }
            break;
        case SwingSyncTimeWrited:
        {
            //FFA6
            self.characteristic =[[[self.services objectAtIndex:5] characteristics]objectAtIndex:5];
            
            [self.currPeripheral readValueForCharacteristic:self.characteristic];
            
            syncState = SwingSyncMacReaded;
        }
            break;
        case SwingSyncAlertNumberWrited:
        {
            if ([self writeAlertTimestmp]) {
                syncState = SwingSyncAlertTimeWrited;
            }
            else {
                //FFA9
                self.characteristic =[[[self.services objectAtIndex:5] characteristics]objectAtIndex:8];
                
                [self.currPeripheral readValueForCharacteristic:self.characteristic];
                syncState = SwingSyncHeaderReaded;
            }
        }
            break;
        case SwingSyncAlertTimeWrited:
        {
            [self writeAlertNumber];
            syncState = SwingSyncAlertNumberWrited;
        }
            break;
        case SwingSyncChecksumWrited:
        {
            //FFA9
            self.characteristic =[[[self.services objectAtIndex:5] characteristics]objectAtIndex:8];
            
            [self.currPeripheral readValueForCharacteristic:self.characteristic];
            syncState = SwingSyncHeaderReaded;
        }
            break;
        default:
            break;
    }
}

- (void)initBluetooth {
    //初始化其他数据 init other
    peripherals = [[NSMutableArray alloc]init];
    peripheralsAD = [[NSMutableArray alloc]init];
    
    //初始化BabyBluetooth 蓝牙库
    baby = [BabyBluetooth shareBabyBluetooth];
    //设置蓝牙委托
    [self babyDelegate];
    
    //链接后的数据准备
    self.services = [[NSMutableArray alloc]init];
    
}

#pragma mark -蓝牙配置和操作

//蓝牙网关初始化和委托方法设置
-(void)babyDelegate{
    
    __weak typeof(self) weakSelf = self;
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOn) {
            //            [SVProgressHUD showInfoWithStatus:@"设备打开成功，开始扫描设备"];
        }
    }];
    
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"搜索到了设备:%@",peripheral.name);
        [weakSelf insertTableView:peripheral advertisementData:advertisementData];
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *service in peripheral.services) {
            NSLog(@"搜索到服务:%@",service.UUID.UUIDString);
        }
    }];
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        for (CBCharacteristic *c in service.characteristics) {
            NSLog(@"charateristic name is :%@",c.UUID);
        }
    }];
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    
    //设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        //最常用的场景是查找某一个前缀开头的设备
        if ([peripheralName hasPrefix:@"Swing-D-X"] ) {
            return YES;
        }
        return NO;
        
    }];
    
    
    [baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    
    [baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelScanBlock");
    }];
    
    
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //连接设备->
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
#warning 此处是开始链接的delegate
    
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [baby setBlockOnConnectedAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        //        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功",peripheral.name]];
    }];
    
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
        //        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接失败",peripheral.name]];
    }];
    
    //设置设备断开连接的委托
    [baby setBlockOnDisconnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--断开连接",peripheral.name);
        //        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--断开失败",peripheral.name]];
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServicesAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *s in peripheral.services) {
            ///插入section到tableview
            [weakSelf insertSectionToTableView:s];
        }
        
        [rhythm beats];
    }];
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristicsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        //插入row到tableview
        [weakSelf insertRowToTableView:service];
        
    }];
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptorsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //读取rssi的委托
    [baby setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        NSLog(@"setBlockOnDidReadRSSI:RSSI:%@",RSSI);
    }];
    
    
    //设置beats break委托
    [rhythm setBlockOnBeatsBreak:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsBreak call");
        
        //如果完成任务，即可停止beat,返回bry可以省去使用weak rhythm的麻烦
        //        if (<#condition#>) {
        //            [bry beatsOver];
        //        }
        
    }];
    
    //设置beats over委托
    [rhythm setBlockOnBeatsOver:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsOver call");
    }];
    
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    //    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
     */
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    [baby setBabyOptionsAtChannel:channelOnPeropheralView scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
    
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        //        NSLog(@"CharacteristicViewController===characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
        if (settingState == SwingSettingMacReaded ) {
            NSLog(@"lwz %@", characteristic.value);
            //            self.ReadMacAddress.text = [NSString stringWithFormat:@"%@",self.characteristic.value];
            
            settingState = SwingSettingNone;
        }
        if (syncState > SwingSyncNone) {
            [weakSelf syncReaded:characteristic];
        }
        [weakSelf insertReadValues:characteristic];
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        //        NSLog(@"CharacteristicViewController===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            //            NSLog(@"CharacteristicViewController CBDescriptor name is :%@",d.UUID);
            [weakSelf insertDescriptor:d];
        }
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptorsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        for (int i =0 ; i<descriptors.count; i++) {
            if (descriptors[i]==descriptor) {
                
            }
        }
        NSLog(@">>>CharacteristicViewController Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //设置写数据成功的block
    [baby setBlockOnDidWriteValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"====这个坑爹的地方读出来的characteristic.value是不对的，因为写的操作在这个block执行的时候并没有完成 !!!");
        NSLog(@"setBlockOnDidWriteValueForCharacteristicAtChannel characteristic:%@ and new value:%@  error ==== %@",characteristic.UUID, characteristic.value, error);
        //lwz add
        if (settingState == SwingSettingTimeWrited && self.characteristic == characteristic) {
            NSLog(@"lwz writed");
            weakSelf.characteristic =[[[weakSelf.services objectAtIndex:5] characteristics]objectAtIndex:5];
            [weakSelf.currPeripheral readValueForCharacteristic:weakSelf.characteristic];
            settingState = SwingSettingMacReaded;
            
        }
        if (syncState > SwingSyncNone) {
            [weakSelf syncWrited:characteristic];
        }
        //lwz end
    }];
    
    //设置通知状态改变的block
    [baby setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:channelOnPeropheralView block:^(CBCharacteristic *characteristic, NSError *error) {
        //        //lwz add
        //        weakSelf.characteristic =[[[weakSelf.services objectAtIndex:5] characteristics]objectAtIndex:5];
        //        if (settingState == SwingSettingMacReaded ) {
        //            NSLog(@"lwz %@", characteristic.value);
        ////            weakSelf.ReadMacAddress.text = [NSString stringWithFormat:@"%@",self.characteristic.value];
        //            settingState = SwingSettingNone;
        //        }
        //        //lwz end
        NSLog(@"uid:%@,isNotifying:%@",characteristic.UUID,characteristic.isNotifying?@"on":@"off");
    }];
    
    
}

//插入读取的值
-(void)insertReadValues:(CBCharacteristic *)characteristics{
    [self->readValueArray addObject:[NSString stringWithFormat:@"%@",characteristics.value]];
    NSMutableArray *indexPaths = [[NSMutableArray alloc]init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self->readValueArray.count-1 inSection:0];
    //    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:self->readValueArray.count-1 inSection:0];
    [indexPaths addObject:indexPath];
    //    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    //    [self.tableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

//插入描述
-(void)insertDescriptor:(CBDescriptor *)descriptor{
    [self->descriptors addObject:descriptor];
    NSMutableArray *indexPahts = [[NSMutableArray alloc]init];
    NSIndexPath *indexPaht = [NSIndexPath indexPathForRow:self->descriptors.count-1 inSection:2];
    [indexPahts addObject:indexPaht];
    //    [self.tableView insertRowsAtIndexPaths:indexPahts withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)insertRowToTableView:(CBService *)service{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    int sectl = -1;
    for (int i=0;i<self.services.count;i++) {
        PeripheralInfo *info = [self.services objectAtIndex:i];
        if (info.serviceUUID == service.UUID) {
            sectl = i;
        }
    }
    if (sectl != -1) {
        PeripheralInfo *info =[self.services objectAtIndex:sectl];
        for (int row=0;row<service.characteristics.count;row++) {
            CBCharacteristic *c = service.characteristics[row];
            [info.characteristics addObject:c];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:sectl];
            [indexPaths addObject:indexPath];
            NSLog(@"add indexpath in row:%d, sect:%d",row,sectl);
        }
        PeripheralInfo *curInfo =[self.services objectAtIndex:sectl];
        NSLog(@"%@",curInfo.characteristics);
        //        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    
    
}

-(void)insertSectionToTableView:(CBService *)service{
    NSLog(@"搜索到服务:%@",service.UUID.UUIDString);
    PeripheralInfo *info = [[PeripheralInfo alloc]init];
    [info setServiceUUID:service.UUID];
    [self.services addObject:info];
    //    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:self.services.count-1];
    //    [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

//插入table数据
-(void)insertTableView:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData{
    if(![peripherals containsObject:peripheral]) {
//        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:peripherals.count inSection:0];
//        [indexPaths addObject:indexPath];
        [peripherals addObject:peripheral];
        [peripheralsAD addObject:advertisementData];
//        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    if ([_delegate respondsToSelector:@selector(bluetoothClientScanDevice:)]) {
        [_delegate bluetoothClientScanDevice:peripherals];
    }
}

@end

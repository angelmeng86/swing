//
//  BLEUpdater.m
//  Swing
//
//  Created by Mapple on 2017/2/24.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "BLEUpdater.h"
#import "BLEUtility.h"
#import "CBService+LMMethod.h"
#import "CommonDef.h"
#import "oad.h"

#define OAD_TRANSMIT_INTERVAL           0.03
#define OAD_ONCE_NUMBER                 1

//#define OAD_EVENT_TRIGGER

typedef enum : NSUInteger {
    BLEUpdaterStateNone,
    BLEUpdaterStateCheckImageA,
    BLEUpdaterStateCheckImageB,
    BLEUpdaterStateOk,
    BLEUpdaterStateProgramming,
} BLEUpdaterState;

@interface BLEUpdater ()

@property int nBlocks;
@property int nBytes;
@property int iBlocks;
@property int iBytes;

@property int state;


@end

@implementation BLEUpdater

- (id)init
{
    if (self = [super init]) {
        self.state = BLEUpdaterStateNone;
        self.imageVersion = @"KDV0004-A";
    }
    return self;
}

- (void)useImage:(BOOL)A
{
    //固件版本
    NSMutableString *path= [[NSMutableString  alloc] initWithString: [[NSBundle mainBundle] resourcePath]];
    [path appendString:@"/"];
    [path appendString:A ? @"A-052817.bin" : @"B-052817.bin"];
    //    [path appendString:A ? @"A-super-MP-OTA-64M-022317.bin" : @"B-super-MP-OTA-64M-022317.bin"];
    self.imageData = [NSData dataWithContentsOfFile:path];
    LOG_D(@"Loaded firmware \"%@\"of size : %ld",path, (unsigned long)self.imageData.length);
    
    img_hdr_t imgHeader;
    memcpy(&imgHeader, self.imageData.bytes + OAD_IMG_HDR_OSET, sizeof(img_hdr_t));
    LOG_D(@"image bin ver : %04hx", imgHeader.ver);
}

- (BOOL)isCorrectImage {
    if (!self.imageData || !self.imageVersion || !self.deviceVersion ) {
        return NO;
    }
    /*
     img_hdr_t imgHeader;
     memcpy(&imgHeader, self.imageData.bytes + OAD_IMG_HDR_OSET, sizeof(img_hdr_t));
     
     //    if ((imgHeader.ver & 0x01) != (self.imgVersion & 0x01)) return YES;
     if (imgHeader.ver != self.imgVersion) return YES;
     return NO;
     */
    return ![self.imageVersion isEqualToString:self.deviceVersion];
//    return YES;
}

//- (void)setState:(int)state
//{
//    LOG_D(@"updater state %d -> %d", _state, state);
//    _state = state;
//}


- (void)startUpdate
{
    if ([self isCorrectImage]) {
//        [self uploadImage];
        [self performSelector:@selector(uploadImage) withObject:nil afterDelay:1];
    }
}

- (BOOL)supportUpdate
{
    return self.state > BLEUpdaterStateNone;
}

- (BOOL)readyUpdate
{
    return self.state == BLEUpdaterStateOk;
}

- (BOOL)needUpdate
{
    if (self.state == BLEUpdaterStateOk) {
        return [self isCorrectImage];
    }
    return NO;
}

- (void)cancelUpdate
{
    self.state = BLEUpdaterStateNone;
}

- (void)didDiscoverServices:(CBService *)service
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:OAD_SERVICE_UUID]]) {
        [self.peripheral discoverCharacteristics:nil forService:service];
    }
    else if([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
    {
        [self.peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"2A26"]] forService:service];
    }
}

- (void)didDiscoverCharacteristicsForService:(CBService *)service
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:OAD_SERVICE_UUID]]) {
        self.imageData = nil;
        [self configureProfile];
    }
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]) {
        self.deviceVersion = nil;
        [BLEUtility readCharacteristic:self.peripheral sUUID:@"180A" cUUID:@"2A26"];
    }
}

- (void)didUpdateValueForProfile:(CBCharacteristic *)characteristic
{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A26"]]) {
        if (!self.deviceVersion) {
            self.deviceVersion = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        }
        LOG_D(@"Firmware Version: %@", self.deviceVersion);
        
        if (self.deviceVersion && self.imageData) {
            self.state = BLEUpdaterStateOk;
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:OAD_IMAGE_NOTIFY_UUID]]) {
        if (!self.imageData) {
            unsigned char data[characteristic.value.length];
            [characteristic.value getBytes:&data length:characteristic.value.length];
            uint16_t ver = ((uint16_t)data[1] << 8 & 0xff00) | ((uint16_t)data[0] & 0xff);
            LOG_D(@"current bin ver : %04hx", ver);
            LOG_D(@"Use Image %@", self.state == BLEUpdaterStateCheckImageB ? @"A" : @"B");
            [self useImage:self.state == BLEUpdaterStateCheckImageB];
            
            if (self.deviceVersion && self.imageData) {
                self.state = BLEUpdaterStateOk;
            }
        }
    }
}

- (void)didWriteValueForCharacteristic:(CBCharacteristic *)characteristic {
#ifdef OAD_EVENT_TRIGGER
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:OAD_IMAGE_BLOCK_REQUEST_UUID]]) {
        if(self.iBlocks < self.nBlocks) {
            [self programmingTimerTick:nil];
        }
    }
#endif
}

- (void)deviceDisconnected:(CBPeripheral *)peripheral
{
    if ([peripheral isEqual:self.peripheral]) {
        self.state = BLEUpdaterStateNone;
//        if ([_delegate respondsToSelector:@selector(deviceUpdateResult:)]) {
//            [_delegate deviceUpdateResult:NO];
//        }
    }
}

- (void)configureProfile {
    self.state = BLEUpdaterStateCheckImageA;
    LOG_D(@"Configurating OAD Profile");
    CBUUID *sUUID = [CBUUID UUIDWithString:OAD_SERVICE_UUID];
    CBUUID *cUUID = [CBUUID UUIDWithString:OAD_IMAGE_NOTIFY_UUID];
    //监听OAD_IMAGE_NOTIFY_UUID反馈数据
    [BLEUtility setNotificationForCharacteristic:self.peripheral sCBUUID:sUUID cCBUUID:cUUID enable:YES];
    //发送0x00检查当前固件是否是Image A，如果不回应则1.5s后发0x01检查当前固件是否是Image B
    unsigned char data = 0x00;
    [BLEUtility writeCharacteristic:self.peripheral sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
    [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(imageDetectTimerTick:) userInfo:nil repeats:NO];
}


- (void)imageDetectTimerTick:(NSTimer *)timer {
    if(self.imageData) {
        LOG_D(@"imageDetectTimerTick invalid.");
        return;
    }
    //IF we have come here, the image userID is B.
    self.state = BLEUpdaterStateCheckImageB;
    LOG_D(@"imageDetectTimerTick:");
    CBUUID *sUUID = [CBUUID UUIDWithString:OAD_SERVICE_UUID];
    CBUUID *cUUID = [CBUUID UUIDWithString:OAD_IMAGE_NOTIFY_UUID];
    unsigned char data = 0x01;
    [BLEUtility writeCharacteristic:self.peripheral sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
}

- (void) uploadImage {
    self.state = BLEUpdaterStateProgramming;

    const void *pData = self.imageData.bytes;
    uint8_t requestData[OAD_IMG_HDR_SIZE + 2 + 2]; // 12Bytes
    
    LOG_D(@"image header %@", [Fun dataToHex:[NSData dataWithBytes:pData length:self.imageData.length > 20 ? 20 : self.imageData.length]]);
    
    img_hdr_t imgHeader;
    memcpy(&imgHeader, pData + OAD_IMG_HDR_OSET, sizeof(img_hdr_t));
    
    
    
    requestData[0] = LO_UINT16(imgHeader.ver);
    requestData[1] = HI_UINT16(imgHeader.ver);
    
    requestData[2] = LO_UINT16(imgHeader.len);
    requestData[3] = HI_UINT16(imgHeader.len);
    
    LOG_D(@"Image version = %04hx, len = %04hx",imgHeader.ver,imgHeader.len);
    
    memcpy(requestData + 4, &imgHeader.uid, sizeof(imgHeader.uid));
    
    requestData[OAD_IMG_HDR_SIZE + 0] = LO_UINT16(12);
    requestData[OAD_IMG_HDR_SIZE + 1] = HI_UINT16(12);
    
    requestData[OAD_IMG_HDR_SIZE + 2] = LO_UINT16(15);
    requestData[OAD_IMG_HDR_SIZE + 1] = HI_UINT16(15);
    
    CBUUID *sUUID = [CBUUID UUIDWithString:OAD_SERVICE_UUID];
    CBUUID *cUUID = [CBUUID UUIDWithString:OAD_IMAGE_NOTIFY_UUID];
    
    [BLEUtility writeCharacteristic:self.peripheral sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:requestData length:OAD_IMG_HDR_SIZE + 2 + 2]];
    
    self.nBlocks = imgHeader.len / (OAD_BLOCK_SIZE / HAL_FLASH_WORD_SIZE);
    self.nBytes = imgHeader.len * HAL_FLASH_WORD_SIZE;
    self.iBlocks = 0;
    self.iBytes = 0;
    
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(programmingTimerTick:) userInfo:nil repeats:NO];
    
}

-(void) programmingTimerTick:(NSTimer *)timer {
    if (self.state != BLEUpdaterStateProgramming || self.peripheral.state != CBPeripheralStateConnected) {
        return;
    }
    
    const void *pData = self.imageData.bytes;
    
    //Prepare Block
    uint8_t requestData[2 + OAD_BLOCK_SIZE];
    
    // This block is run 4 times, this is needed to get CoreBluetooth to send consequetive packets in the same connection interval.
    for (int ii = 0; ii < OAD_ONCE_NUMBER; ii++) {
        
        requestData[0] = LO_UINT16(self.iBlocks);
        requestData[1] = HI_UINT16(self.iBlocks);
        
        memcpy(&requestData[2] , pData + self.iBytes, OAD_BLOCK_SIZE);
        
        CBUUID *sUUID = [CBUUID UUIDWithString:OAD_SERVICE_UUID];
        CBUUID *cUUID = [CBUUID UUIDWithString:OAD_IMAGE_BLOCK_REQUEST_UUID];
#ifdef OAD_EVENT_TRIGGER
        [BLEUtility writeCharacteristic:self.peripheral sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:requestData length:2 + OAD_BLOCK_SIZE]];
#else
        [BLEUtility writeNoResponseCharacteristic:self.peripheral sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:requestData length:2 + OAD_BLOCK_SIZE]];
#endif
        self.iBlocks++;
        self.iBytes += OAD_BLOCK_SIZE;
        
        if(self.iBlocks == self.nBlocks) {
            self.state = BLEUpdaterStateNone;
            if ([_delegate respondsToSelector:@selector(deviceUpdateResult:)]) {
                [_delegate deviceUpdateResult:YES];
            }
            return;
        }
        else {
#ifndef OAD_EVENT_TRIGGER
            if (ii == OAD_ONCE_NUMBER - 1)[NSTimer scheduledTimerWithTimeInterval:OAD_TRANSMIT_INTERVAL target:self selector:@selector(programmingTimerTick:) userInfo:nil repeats:NO];
#endif
        }
    }
    
    if ([_delegate respondsToSelector:@selector(deviceUpdateProgress:remainTime:)]) {
        float secondsPerBlock = OAD_TRANSMIT_INTERVAL / OAD_ONCE_NUMBER;
        float secondsLeft = (float)(self.nBlocks - self.iBlocks) * secondsPerBlock;
        [_delegate deviceUpdateProgress:(float)((float)self.iBlocks / (float)self.nBlocks) remainTime:[NSString stringWithFormat:@"%d:%02d",(int)(secondsLeft / 60),(int)secondsLeft - (int)(secondsLeft / 60) * (int)60]];
    }
    
    LOG_D(@". iBlocks %d / nBlocks %d", self.iBlocks, self.nBlocks);
}

@end

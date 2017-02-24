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

typedef enum : NSUInteger {
    BLEUpdaterStateNone,
    BLEUpdaterStateDiscover,
    BLEUpdaterStateGetVersion,
    BLEUpdaterStateOk,
    BLEUpdaterStateProgramming,
} BLEUpdaterState;

@interface BLEUpdater ()
{
    NSUInteger state;
}

@property int nBlocks;
@property int nBytes;
@property int iBlocks;
@property int iBytes;

@property uint16_t imgVersion;

@end

@implementation BLEUpdater

- (id)init
{
    if (self = [super init]) {
        state = BLEUpdaterStateNone;
    }
    return self;
}

- (void)startUpdate
{
    if ([self isCorrectImage]) {
        [self uploadImage];
    }
}

- (BOOL)supportUpdate
{
    return state > BLEUpdaterStateNone;
}

- (BOOL)needUpdate
{
    if (state == BLEUpdaterStateOk) {
        return [self isCorrectImage];
    }
    return NO;
}

- (void)cancelUpdate
{
    state = BLEUpdaterStateNone;
}

- (void)didDiscoverServices:(CBService *)service
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:OAD_SERVICE_UUID]]) {
        state = BLEUpdaterStateDiscover;
        [self.peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)didDiscoverCharacteristicsForService:(CBService *)service
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:OAD_SERVICE_UUID]]) {
        state = BLEUpdaterStateGetVersion;
        [self configureProfile];
    }
}

- (void)didUpdateValueForProfile:(CBCharacteristic *)characteristic
{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:OAD_IMAGE_NOTIFY_UUID]]) {
        if (self.imgVersion == 0xFFFF) {
            unsigned char data[characteristic.value.length];
            [characteristic.value getBytes:&data length:characteristic.value.length];
            self.imgVersion = ((uint16_t)data[1] << 8 & 0xff00) | ((uint16_t)data[0] & 0xff);
            LOG_D(@"self.imgVersion : %04hx",self.imgVersion);
            state = BLEUpdaterStateOk;
        }
        LOG_D(@"OAD Image notify : %@",characteristic.value);
    }
}

- (void)deviceDisconnected:(CBPeripheral *)peripheral
{
    if ([peripheral isEqual:self.peripheral]) {
        state = BLEUpdaterStateNone;
        if ([_delegate respondsToSelector:@selector(deviceUpdateResult:)]) {
            [_delegate deviceUpdateResult:NO];
        }
    }
}

- (void)configureProfile {
    LOG_D(@"Configurating OAD Profile");
    CBUUID *sUUID = [CBUUID UUIDWithString:OAD_SERVICE_UUID];
    CBUUID *cUUID = [CBUUID UUIDWithString:OAD_IMAGE_NOTIFY_UUID];
    //监听OAD_IMAGE_NOTIFY_UUID反馈数据
    [BLEUtility setNotificationForCharacteristic:self.peripheral sCBUUID:sUUID cCBUUID:cUUID enable:YES];
    //发送0x00要更新Image B，如果不回应则1.5s后发0x01要更新Image A
    unsigned char data = 0x00;
    [BLEUtility writeCharacteristic:self.peripheral sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
    [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(imageDetectTimerTick:) userInfo:nil repeats:NO];
    self.imgVersion = 0xFFFF;
}

//-(void) deconfigureProfile {
//    NSLog(@"Deconfiguring OAD Profile");
//    CBUUID *sUUID = [CBUUID UUIDWithString:OAD_SERVICE_UUID];
//    CBUUID *cUUID = [CBUUID UUIDWithString:OAD_IMAGE_NOTIFY_UUID];
//    [BLEUtility setNotificationForCharacteristic:self.peripheral sCBUUID:sUUID cCBUUID:cUUID enable:YES];
//}

- (BOOL)isCorrectImage {
    if (!self.imageData || self.imgVersion == 0xFFFF) {
        return NO;
    }
    
    unsigned char imageFileData[self.imageData.length];
    [self.imageData getBytes:imageFileData length:self.imageData.length];
    
    img_hdr_t imgHeader;
    memcpy(&imgHeader, &imageFileData[0 + OAD_IMG_HDR_OSET], sizeof(img_hdr_t));
    
//    if ((imgHeader.ver & 0x01) != (self.imgVersion & 0x01)) return YES;
    if (imgHeader.ver != self.imgVersion) return YES;
    return NO;
}

- (void)imageDetectTimerTick:(NSTimer *)timer {
    //IF we have come here, the image userID is B.
    LOG_D(@"imageDetectTimerTick:");
    CBUUID *sUUID = [CBUUID UUIDWithString:OAD_SERVICE_UUID];
    CBUUID *cUUID = [CBUUID UUIDWithString:OAD_IMAGE_NOTIFY_UUID];
    unsigned char data = 0x01;
    [BLEUtility writeCharacteristic:self.peripheral sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
}

- (void) uploadImage {
    state = BLEUpdaterStateProgramming;

    unsigned char imageFileData[self.imageData.length];
    [self.imageData getBytes:imageFileData length:self.imageData.length];
    uint8_t requestData[OAD_IMG_HDR_SIZE + 2 + 2]; // 12Bytes
    
    LOG_D(@"image header %@", [Fun dataToHex:[NSData dataWithBytes:imageFileData length:self.imageData.length]]);
    
    img_hdr_t imgHeader;
    memcpy(&imgHeader, &imageFileData[0 + OAD_IMG_HDR_OSET], sizeof(img_hdr_t));
    
    
    
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
    
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(programmingTimerTick:) userInfo:nil repeats:NO];
    
}

-(void) programmingTimerTick:(NSTimer *)timer {
    if (state != BLEUpdaterStateProgramming) {
        return;
    }
    
    unsigned char imageFileData[self.imageData.length];
    [self.imageData getBytes:imageFileData length:self.imageData.length];
    
    //Prepare Block
    uint8_t requestData[2 + OAD_BLOCK_SIZE];
    
    // This block is run 4 times, this is needed to get CoreBluetooth to send consequetive packets in the same connection interval.
    for (int ii = 0; ii < 4; ii++) {
        
        requestData[0] = LO_UINT16(self.iBlocks);
        requestData[1] = HI_UINT16(self.iBlocks);
        
        memcpy(&requestData[2] , &imageFileData[self.iBytes], OAD_BLOCK_SIZE);
        
        CBUUID *sUUID = [CBUUID UUIDWithString:OAD_SERVICE_UUID];
        CBUUID *cUUID = [CBUUID UUIDWithString:OAD_IMAGE_BLOCK_REQUEST_UUID];
        
        [BLEUtility writeNoResponseCharacteristic:self.peripheral sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:requestData length:2 + OAD_BLOCK_SIZE]];
        
        self.iBlocks++;
        self.iBytes += OAD_BLOCK_SIZE;
        
        if(self.iBlocks == self.nBlocks) {
            state = BLEUpdaterStateNone;
            if ([_delegate respondsToSelector:@selector(deviceUpdateResult:)]) {
                [_delegate deviceUpdateResult:YES];
            }
            return;
        }
        else {
            if (ii == 3)[NSTimer scheduledTimerWithTimeInterval:0.09 target:self selector:@selector(programmingTimerTick:) userInfo:nil repeats:NO];
        }
    }
    
    if ([_delegate respondsToSelector:@selector(deviceUpdateProgress:remainTime:)]) {
        float secondsPerBlock = 0.09 / 4;
        float secondsLeft = (float)(self.nBlocks - self.iBlocks) * secondsPerBlock;
        [_delegate deviceUpdateProgress:(float)((float)self.iBlocks / (float)self.nBlocks) remainTime:[NSString stringWithFormat:@"%d:%02d",(int)(secondsLeft / 60),(int)secondsLeft - (int)(secondsLeft / 60) * (int)60]];
    }
    
    LOG_D(@". iBlocks %d / nBlocks %d", self.iBlocks, self.nBlocks);
}

@end

//
//  BLEDelegate.h
//  Swing
//
//  Created by Mapple on 2016/11/29.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEDelegate : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@end

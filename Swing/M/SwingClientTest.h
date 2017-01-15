//
//  SwingClientTest.h
//  Swing
//
//  Created by Mapple on 16/8/3.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SwingClientTest : NSObject

@property (nonatomic) int times;

+ (void)test:(int)index times:(int)times;

+ (void)testAll:(int)index;

+ (void)testBluetooth;

@end

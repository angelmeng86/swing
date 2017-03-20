//
//  BLEWaitDevice.m
//  Swing
//
//  Created by Mapple on 2016/11/15.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "BLEWaitDevice.h"
#import "CommonDef.h"

@interface BLEWaitDevice ()
{
    NSTimer *waitTimer;
    int waitTimes;
}

@end

@implementation BLEWaitDevice

- (void)cannel {
    self.isCancel = YES;
    if (waitTimer) {
        [waitTimer invalidate];
        waitTimer = nil;
    }
}

- (void)checkBleStatus {
    self.isCancel = NO;
    if (waitTimer) {
        [waitTimer invalidate];
        waitTimer = nil;
    }
    
    if (_manager.state == CBManagerStatePoweredOn) {
        [self fire];
        return;
    }
    
    waitTimes = 5;
    waitTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeTick:) userInfo:nil repeats:YES];
}

- (void)timeTick:(NSTimer*)timer {
    LOG_D(@"wait for bluetooth up.");
    if (_manager.state == CBManagerStatePoweredOn) {
        if (waitTimer) {
            [waitTimer invalidate];
            waitTimer = nil;
        }
        [self fire];
    }
    else if (--waitTimes <= 0) {
        if (waitTimer) {
            [waitTimer invalidate];
            waitTimer = nil;
        }
        [self bleTimeout];
    }
}

- (void)bleTimeout {
    
}

- (void)fire {
    
}

@end

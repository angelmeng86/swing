//
//  ActivityModel.m
//  Swing
//
//  Created by Mapple on 16/8/16.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "ActivityModel.h"
#import "CommonDef.h"

@implementation ActivityModel
/*
indoorActivity:  1471185427,1,232,0,0,2,0,0,0,3,0,0,0,4,0,0,0,0
outdoorActivity: 1471185427,0,100,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
time:            1470885849
macId:           tester1
*/

- (void)reset {
    self.time = [[NSDate date] timeIntervalSince1970];
    self.indoorActivity = [NSString stringWithFormat:@"%ld,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0", _time];
    self.outdoorActivity = [NSString stringWithFormat:@"%ld,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0", _time];
}

- (void)setIndoorData:(NSData*)data {
    NSMutableString *info = [NSMutableString string];
    [info appendFormat:@"%ld,", [Fun byteArrayToLong:data length:4]];
    const Byte* ptr = data.bytes;
    for (int i = 4; i < data.length; i++) {
        if (i + 1 == data.length) {
            [info appendFormat:@"%d", ptr[i]];
        }
        else {
            [info appendFormat:@"%d,", ptr[i]];
        }
    }
    self.indoorActivity = info;
}

- (void)setOutdoorData:(NSData*)data {
    NSMutableString *info = [NSMutableString string];
    [info appendFormat:@"%ld,", [Fun byteArrayToLong:data length:4]];
    const Byte* ptr = data.bytes;
    for (int i = 4; i < data.length; i++) {
        if (i + 1 == data.length) {
            [info appendFormat:@"%d", ptr[i]];
        }
        else {
            [info appendFormat:@"%d,", ptr[i]];
        }
    }
    self.outdoorActivity = info;
}

@end

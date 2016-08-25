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

/*
indoorActivity:  1471185427,1,Dec,Dec,Dec,Dec
outdoorActivity: 1471185427,0,Dec,Dec,Dec,Dec
time:            1470885849
macId:           tester1
*/

- (void)reset {
    self.time = [[NSDate date] timeIntervalSince1970];
//    self.indoorActivity = [NSString stringWithFormat:@"%ld,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0", _time];
//    self.outdoorActivity = [NSString stringWithFormat:@"%ld,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0", _time];
    self.indoorActivity = [NSString stringWithFormat:@"%ld,0,0,0,0,0", _time];
    self.outdoorActivity = [NSString stringWithFormat:@"%ld,1,0,0,0,0", _time];
}

- (NSString*)parseData:(NSData*)data {
    NSMutableString *info = [NSMutableString string];
    [info appendFormat:@"%ld,", [Fun byteArrayToLong:data length:4]];
    const Byte* ptr = data.bytes;
    [info appendFormat:@"%d,", ptr[4]];
    for (int i = 5; i < data.length; i+=4) {
        if (i + 4 == data.length) {
            [info appendFormat:@"%ld", [Fun byteArrayToLong:data pos:i length:4]];
        }
        else {
            [info appendFormat:@"%ld,", [Fun byteArrayToLong:data pos:i length:4]];
        }
    }
//    for (int i = 4; i < data.length; i++) {
//        if (i + 1 == data.length) {
//            [info appendFormat:@"%d", ptr[i]];
//        }
//        else {
//            [info appendFormat:@"%d,", ptr[i]];
//        }
//    }
    return info;
}

- (void)setIndoorData:(NSData*)data {
    if (data.length != 21) {
        self.indoorActivity = [NSString stringWithFormat:@"%ld,0,0,0,0,0", _time == 0 ? (long)[[NSDate date] timeIntervalSince1970] : _time];
    }
    else {
        self.indoorActivity = [self parseData:data];
    }
}

- (void)setOutdoorData:(NSData*)data {
    if (data.length != 21) {
        self.outdoorActivity = [NSString stringWithFormat:@"%ld,1,0,0,0,0", _time == 0 ? (long)[[NSDate date] timeIntervalSince1970] : _time];
    }
    else {
        self.outdoorActivity = [self parseData:data];
    }
}

@end

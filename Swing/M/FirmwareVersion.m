//
//  FirmwareVersion.m
//  Swing
//
//  Created by Maple on 2017/7/14.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "FirmwareVersion.h"

@implementation FirmwareVersion

+ (JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"objId"
                                                       }];
}

@end

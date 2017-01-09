//
//  KidModel.m
//  Swing
//
//  Created by Mapple on 16/8/4.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "KidModel.h"

@implementation KidModel

+ (JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"objId"
                                                       }];
}

- (NSString*)deviceId {
    return _note ? _note : _macId;
}

@end

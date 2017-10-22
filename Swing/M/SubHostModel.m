//
//  SubHostModel.m
//  Swing
//
//  Created by Mapple on 2017/10/22.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "SubHostModel.h"

@implementation SubHostModel

+ (JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"objId"
                                                       }];
}


@end

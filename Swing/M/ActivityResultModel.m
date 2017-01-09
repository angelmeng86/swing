//
//  ActivityResultModel.m
//  Swing
//
//  Created by Mapple on 16/8/16.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "ActivityResultModel.h"

@implementation ActivityResultModel

+ (JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"objId"
                                                       }];
}

- (void)transDate {
    if (_receivedDate.length >= 10 ) {
        self.date = [_receivedDate substringToIndex:10];
    }
}

@end

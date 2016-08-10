//
//  UserModel.m
//  Swing
//
//  Created by Mapple on 16/8/5.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

+ (JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"objId"
                                                       }];
}

- (NSString*)address2 {
    NSMutableString *info = [NSMutableString new];
    if (self.city) {
        [info appendString:self.city];
        [info appendString:@", "];
    }
    if (self.state) {
        [info appendString:self.state];
        [info appendString:@" "];
    }
    if (self.zipCode) {
        [info appendString:self.zipCode];
    }
    return info;
}

@end

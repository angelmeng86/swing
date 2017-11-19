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

- (void)updateTo:(KidInfo*)m {
    m.objId = _objId;
    m.name = _name;
    m.profile = _profile;
    m.firmwareVersion = _firmwareVersion;
    m.macId = _macId;
}

- (void)updateFrom:(KidInfo*)m {
    self.objId = m.objId;
    self.name = m.name;
    self.profile = m.profile;
    self.firmwareVersion = m.firmwareVersion;
    self.macId = m.macId;
}

- (void)updateTo2:(EventKid*)m {
    m.objId = _objId;
    m.name = _name;
    m.profile = _profile;
    m.macId = _macId;
}

- (void)updateFrom2:(EventKid*)m {
    self.objId = m.objId;
    self.name = m.name;
    self.profile = m.profile;
    self.macId = m.macId;
}

@end

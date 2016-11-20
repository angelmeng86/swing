//
//  ToDoModel.m
//  Swing
//
//  Created by Mapple on 16/8/4.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "ToDoModel.h"

@implementation ToDoModel

+ (JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"objId"
                                                       }];
}

- (void)updateTo:(Todo*)todo {
    todo.objId = _objId;
    todo.status = _status;
    todo.text = _text;
}

- (void)updateFrom:(Todo*)todo {
    self.objId = todo.objId;
    self.status = todo.status;
    self.text = todo.text;
}

@end

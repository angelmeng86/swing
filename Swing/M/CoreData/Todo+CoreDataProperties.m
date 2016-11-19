//
//  Todo+CoreDataProperties.m
//  Swing
//
//  Created by Mapple on 2016/11/16.
//  Copyright © 2016年 zzteam. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Todo+CoreDataProperties.h"

@implementation Todo (CoreDataProperties)

+ (NSFetchRequest<Todo *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
}

@dynamic objId;
@dynamic text;
@dynamic status;
@dynamic inEvent;

@end

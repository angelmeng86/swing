//
//  Event+CoreDataProperties.m
//  Swing
//
//  Created by Mapple on 2016/11/16.
//  Copyright © 2016年 zzteam. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Event+CoreDataProperties.h"

@implementation Event (CoreDataProperties)

+ (NSFetchRequest<Event *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Event"];
}

@dynamic objId;
@dynamic eventName;
@dynamic startDate;
@dynamic endDate;
@dynamic timezoneOffset;
@dynamic color;
@dynamic status;
@dynamic desc;
@dynamic alert;
@dynamic city;
@dynamic state;
@dynamic todoList;

@end

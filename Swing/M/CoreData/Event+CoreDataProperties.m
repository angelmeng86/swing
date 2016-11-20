//
//  Event+CoreDataProperties.m
//  Swing
//
//  Created by Mapple on 2016/11/19.
//  Copyright © 2016年 zzteam. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Event+CoreDataProperties.h"

@implementation Event (CoreDataProperties)

+ (NSFetchRequest<Event *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Event"];
}

@dynamic alert;
@dynamic city;
@dynamic color;
@dynamic desc;
@dynamic endDate;
@dynamic eventName;
@dynamic objId;
@dynamic startDate;
@dynamic state;
@dynamic status;
@dynamic timezoneOffset;
@dynamic todoList;

@end

//
//  Event+CoreDataProperties.m
//  Swing
//
//  Created by Mapple on 2016/11/22.
//  Copyright © 2016年 zzteam. All rights reserved.
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
@dynamic repeat;
@dynamic todoList;

@end

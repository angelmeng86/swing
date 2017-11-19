//
//  Event+CoreDataProperties.m
//  
//
//  Created by Mapple on 2017/11/19.
//
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
@dynamic repeat;
@dynamic startDate;
@dynamic state;
@dynamic status;
@dynamic timezoneOffset;
@dynamic todoList;
@dynamic kidList;

@end

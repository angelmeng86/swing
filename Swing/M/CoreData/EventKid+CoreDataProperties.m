//
//  EventKid+CoreDataProperties.m
//  
//
//  Created by Mapple on 2017/11/19.
//
//

#import "EventKid+CoreDataProperties.h"

@implementation EventKid (CoreDataProperties)

+ (NSFetchRequest<EventKid *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"EventKid"];
}

@dynamic macId;
@dynamic name;
@dynamic objId;
@dynamic profile;
@dynamic eventKids;

@end

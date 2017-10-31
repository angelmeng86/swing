//
//  Kid+CoreDataProperties.m
//  
//
//  Created by Mapple on 2017/10/24.
//
//

#import "Kid+CoreDataProperties.h"

@implementation Kid (CoreDataProperties)

+ (NSFetchRequest<Kid *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Kid"];
}

@dynamic name;
@dynamic profile;
@dynamic firmwareVersion;
@dynamic macId;
@dynamic objId;
@dynamic currentVersion;
@dynamic battery;

@end

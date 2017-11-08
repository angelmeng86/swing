//
//  Kid+CoreDataProperties.m
//  
//
//  Created by Mapple on 2017/10/24.
//
//

#import "KidInfo+CoreDataProperties.h"

@implementation KidInfo (CoreDataProperties)

+ (NSFetchRequest<KidInfo *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"KidInfo"];
}

@dynamic name;
@dynamic profile;
@dynamic firmwareVersion;
@dynamic macId;
@dynamic objId;
@dynamic battery;

@dynamic currentVersion;
@dynamic subHostId;

@end

//
//  KidInfo+CoreDataProperties.m
//  
//
//  Created by Mapple on 2017/11/19.
//
//

#import "KidInfo+CoreDataProperties.h"

@implementation KidInfo (CoreDataProperties)

+ (NSFetchRequest<KidInfo *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"KidInfo"];
}

@dynamic battery;
@dynamic currentVersion;
@dynamic firmwareVersion;
@dynamic macId;
@dynamic name;
@dynamic objId;
@dynamic profile;
@dynamic subHostId;

@end

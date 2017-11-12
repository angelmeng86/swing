//
//  KidInfo+CoreDataProperties.m
//  
//
//  Created by Mapple on 2017/11/12.
//
//

#import "KidInfo+CoreDataProperties.h"

@implementation KidInfo (CoreDataProperties)

+ (NSFetchRequest<KidInfo *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"KidInfo"];
}

@dynamic currentVersion;
@dynamic firmwareVersion;
@dynamic macId;
@dynamic name;
@dynamic objId;
@dynamic profile;
@dynamic battery;
@dynamic subHostId;

@end

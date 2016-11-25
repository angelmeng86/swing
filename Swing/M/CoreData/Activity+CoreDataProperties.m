//
//  Activity+CoreDataProperties.m
//  Swing
//
//  Created by Mapple on 2016/11/25.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "Activity+CoreDataProperties.h"

@implementation Activity (CoreDataProperties)

+ (NSFetchRequest<Activity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Activity"];
}

@dynamic indoorActivity;
@dynamic outdoorActivity;
@dynamic time;
@dynamic macId;

@end

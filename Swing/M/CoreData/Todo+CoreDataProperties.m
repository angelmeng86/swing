//
//  Todo+CoreDataProperties.m
//  Swing
//
//  Created by Mapple on 2016/11/22.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "Todo+CoreDataProperties.h"

@implementation Todo (CoreDataProperties)

+ (NSFetchRequest<Todo *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
}

@dynamic objId;
@dynamic status;
@dynamic text;
@dynamic inEvent;

@end

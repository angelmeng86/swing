//
//  Event+CoreDataProperties.h
//  Swing
//
//  Created by Mapple on 2016/11/16.
//  Copyright © 2016年 zzteam. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Event+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Event (CoreDataProperties)

+ (NSFetchRequest<Event *> *)fetchRequest;

@property (nonatomic) int32_t objId;
@property (nullable, nonatomic, copy) NSString *eventName;
@property (nullable, nonatomic, copy) NSDate *startDate;
@property (nullable, nonatomic, copy) NSDate *endDate;
@property (nonatomic) int32_t timezoneOffset;
@property (nullable, nonatomic, retain) NSObject *color;
@property (nullable, nonatomic, copy) NSString *status;
@property (nullable, nonatomic, copy) NSString *desc;
@property (nonatomic) int32_t alert;
@property (nullable, nonatomic, copy) NSString *city;
@property (nullable, nonatomic, copy) NSString *state;
@property (nullable, nonatomic, retain) NSSet<Todo *> *todoList;

@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addTodoListObject:(Todo *)value;
- (void)removeTodoListObject:(Todo *)value;
- (void)addTodoList:(NSSet<Todo *> *)values;
- (void)removeTodoList:(NSSet<Todo *> *)values;

@end

NS_ASSUME_NONNULL_END

//
//  Event+CoreDataProperties.h
//  Swing
//
//  Created by Mapple on 2016/11/22.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "Event+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Event (CoreDataProperties)

+ (NSFetchRequest<Event *> *)fetchRequest;

@property (nonatomic) int32_t alert;
@property (nullable, nonatomic, copy) NSString *city;
@property (nullable, nonatomic, retain) UIColor *color;
@property (nullable, nonatomic, copy) NSString *desc;
@property (nullable, nonatomic, copy) NSDate *endDate;
@property (nullable, nonatomic, copy) NSString *eventName;
@property (nonatomic) int32_t objId;
@property (nullable, nonatomic, copy) NSDate *startDate;
@property (nullable, nonatomic, copy) NSString *state;
@property (nullable, nonatomic, copy) NSString *status;
@property (nonatomic) int32_t timezoneOffset;
@property (nullable, nonatomic, copy) NSString *repeat;
@property (nullable, nonatomic, retain) NSSet<Todo *> *todoList;

@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addTodoListObject:(Todo *)value;
- (void)removeTodoListObject:(Todo *)value;
- (void)addTodoList:(NSSet<Todo *> *)values;
- (void)removeTodoList:(NSSet<Todo *> *)values;

@end

NS_ASSUME_NONNULL_END

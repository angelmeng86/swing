//
//  Event+CoreDataProperties.h
//  
//
//  Created by Mapple on 2017/11/19.
//
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
@property (nonatomic) int64_t objId;
@property (nullable, nonatomic, copy) NSString *repeat;
@property (nullable, nonatomic, copy) NSDate *startDate;
@property (nullable, nonatomic, copy) NSString *state;
@property (nullable, nonatomic, copy) NSString *status;
@property (nonatomic) int32_t timezoneOffset;
@property (nullable, nonatomic, retain) NSSet<Todo *> *todoList;
@property (nullable, nonatomic, retain) NSSet<EventKid *> *kidList;

@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addTodoListObject:(Todo *)value;
- (void)removeTodoListObject:(Todo *)value;
- (void)addTodoList:(NSSet<Todo *> *)values;
- (void)removeTodoList:(NSSet<Todo *> *)values;

- (void)addKidListObject:(EventKid *)value;
- (void)removeKidListObject:(EventKid *)value;
- (void)addKidList:(NSSet<EventKid *> *)values;
- (void)removeKidList:(NSSet<EventKid *> *)values;

@end

NS_ASSUME_NONNULL_END

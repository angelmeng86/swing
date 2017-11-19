//
//  EventKid+CoreDataProperties.h
//  
//
//  Created by Mapple on 2017/11/19.
//
//

#import "EventKid+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface EventKid (CoreDataProperties)

+ (NSFetchRequest<EventKid *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *macId;
@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) int64_t objId;
@property (nullable, nonatomic, copy) NSString *profile;
@property (nullable, nonatomic, retain) Event *eventKids;

@end

NS_ASSUME_NONNULL_END

//
//  Activity+CoreDataProperties.h
//  Swing
//
//  Created by Mapple on 2016/11/25.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "Activity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Activity (CoreDataProperties)

+ (NSFetchRequest<Activity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *indoorActivity;
@property (nullable, nonatomic, copy) NSString *outdoorActivity;
@property (nonatomic) int64_t time;
@property (nullable, nonatomic, copy) NSString *macId;
@property (nonatomic) int64_t timeZoneOffset;

@end

NS_ASSUME_NONNULL_END

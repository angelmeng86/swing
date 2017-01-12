//
//  Todo+CoreDataProperties.h
//  Swing
//
//  Created by Mapple on 2016/11/22.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "Todo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Todo (CoreDataProperties)

+ (NSFetchRequest<Todo *> *)fetchRequest;

@property (nonatomic) int64_t objId;
@property (nullable, nonatomic, copy) NSString *status;
@property (nullable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, retain) Event *inEvent;

@end

NS_ASSUME_NONNULL_END

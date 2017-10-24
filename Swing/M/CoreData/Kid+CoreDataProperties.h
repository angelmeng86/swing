//
//  Kid+CoreDataProperties.h
//  
//
//  Created by Mapple on 2017/10/24.
//
//

#import "Kid+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Kid (CoreDataProperties)

+ (NSFetchRequest<Kid *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *profile;
@property (nullable, nonatomic, copy) NSString *firmwareVersion;
@property (nullable, nonatomic, copy) NSString *macId;
@property (nonatomic) int64_t objId;
@property (nullable, nonatomic, copy) NSString *currentVersion;

@end

NS_ASSUME_NONNULL_END

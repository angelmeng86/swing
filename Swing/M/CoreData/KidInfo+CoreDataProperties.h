//
//  Kid+CoreDataProperties.h
//  
//
//  Created by Mapple on 2017/10/24.
//
//

#import "KidInfo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface KidInfo (CoreDataProperties)

+ (NSFetchRequest<KidInfo *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *profile;
@property (nullable, nonatomic, copy) NSString *firmwareVersion;
@property (nullable, nonatomic, copy) NSString *macId;
@property (nonatomic) int64_t objId;
@property (nonatomic) int32_t battery;

@property (nullable, nonatomic, copy) NSString *currentVersion;
@property (nonatomic) int64_t subHostId;

@end

NS_ASSUME_NONNULL_END

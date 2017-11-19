//
//  KidInfo+CoreDataProperties.h
//  
//
//  Created by Mapple on 2017/11/19.
//
//

#import "KidInfo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface KidInfo (CoreDataProperties)

+ (NSFetchRequest<KidInfo *> *)fetchRequest;

@property (nonatomic) int32_t battery;
@property (nullable, nonatomic, copy) NSString *currentVersion;
@property (nullable, nonatomic, copy) NSString *firmwareVersion;
@property (nullable, nonatomic, copy) NSString *macId;
@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) int64_t objId;
@property (nullable, nonatomic, copy) NSString *profile;
@property (nonatomic) int64_t subHostId;

@end

NS_ASSUME_NONNULL_END

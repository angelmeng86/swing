//
//  KidModel.h
//  Swing
//
//  Created by Mapple on 16/8/4.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "JSONModel.h"
#import "UserModel.h"
#import "KidInfo+CoreDataClass.h"
#import "EventKid+CoreDataClass.h"

@protocol KidModel @end

@interface KidModel : JSONModel

@property (nonatomic) int64_t objId;

@property (strong, nonatomic) NSString* name;
//@property (strong, nonatomic) NSString<Optional>* firstName;
//@property (strong, nonatomic) NSString<Optional>* lastName;
//@property (strong, nonatomic) NSString<Optional>* nickName;
//@property (strong, nonatomic) NSDate<Optional>* birthday;

@property (strong, nonatomic) NSString<Optional>* profile;
@property (strong, nonatomic) NSString<Optional>* macId;//new api added
@property (strong, nonatomic) NSString<Optional>* firmwareVersion;

@property (nonatomic, strong) UserModel<Optional> *parent;

- (void)updateTo:(KidInfo*)m;
- (void)updateFrom:(KidInfo*)m;

- (void)updateTo2:(EventKid*)m;
- (void)updateFrom2:(EventKid*)m;

@end

//
//  EventModel.h
//  Swing
//
//  Created by Mapple on 16/7/31.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "ToDoModel.h"
#import "Event+CoreDataClass.h"

@class UIColor;
@interface EventModel : JSONModel

@property (nonatomic) int64_t objId;
@property (strong, nonatomic) NSString* eventName;
@property (strong, nonatomic) NSDate* startDate;
@property (strong, nonatomic) NSDate* endDate;

@property (nonatomic) int timezoneOffset;

@property (strong, nonatomic) UIColor<Optional>* color;
@property (strong, nonatomic) NSString<Optional>* status;

@property (nonatomic, strong) NSString<Optional> *desc;
@property (nonatomic) int alert;
@property (nonatomic, strong) NSString<Optional> *city;
@property (nonatomic, strong) NSString<Optional> *state;

@property (nonatomic, strong) NSArray<ToDoModel, Optional> *todo;

@property (strong, nonatomic) NSString<Optional>* repeat;

//@property (strong, nonatomic) NSString<Optional>* kidId;//new api add

- (void)updateTo:(Event*)event;
- (void)updateFrom:(Event*)event;

@end

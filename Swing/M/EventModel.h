//
//  EventModel.h
//  Swing
//
//  Created by Mapple on 16/7/31.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface EventModel : JSONModel

@property (nonatomic) int objId;
@property (strong, nonatomic) NSString* eventName;
@property (strong, nonatomic) NSDate* startDate;
@property (strong, nonatomic) NSDate* endDate;

@property (strong, nonatomic) NSString<Optional>* color;
@property (strong, nonatomic) NSString<Optional>* status;

@property (nonatomic, strong) NSString<Optional> *desc;
@property (nonatomic) int alert;
@property (nonatomic, strong) NSString<Optional> *city;
@property (nonatomic, strong) NSString<Optional> *state;

@end

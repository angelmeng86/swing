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

@property (strong, nonatomic) NSString* color;
@property (strong, nonatomic) NSString* status;

@property (nonatomic, strong) NSString *desc;
@property (nonatomic) int alert;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;

@end

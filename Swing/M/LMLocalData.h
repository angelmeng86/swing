//
//  UserLocalData.h
//  Swing
//
//  Created by Mapple on 16/8/26.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "JSONModel.h"

@interface LMLocalData : JSONModel

@property (nonatomic) long indoorSteps;
@property (nonatomic) long outdoorSteps;
@property (nonatomic, strong) NSString<Optional> *date;
@property (nonatomic, strong) NSData<Optional> *deviceMAC;
@property (nonatomic) int64_t kidId;
@property (nonatomic) int battery;

@property (nonatomic, strong) NSString<Optional> *language;

- (void)checkDate;

@end

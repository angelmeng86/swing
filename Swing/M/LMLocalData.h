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

@property (strong, nonatomic) NSString* access_token;

@property (nonatomic) int battery;

@property (nonatomic) BOOL disableSyncTip;

@property (nonatomic, strong) NSString<Optional> *language;

@property (nonatomic, strong) NSString<Optional> *firmwareVer;

- (void)checkDate;

@end

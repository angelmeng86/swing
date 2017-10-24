//
//  GlobalCache.h
//  GmatProject
//
//  Created by Mapple on 15-6-10.
//  Copyright (c) 2015年 Yan Cui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CommonDef.h"
#import "JSONModel.h"

#define USER_PROFILE_LOAD_NOTI @"USER_PROFILE_LOAD_NOTI"
#define KIDS_LIST_LOAD_NOTI @"KIDS_LIST_LOAD_NOTI"
#define EVENT_LIST_UPDATE_NOTI @"EVENT_LIST_UPDATE_NOTI"
#define WEATHER_UPDATE_NOTI @"WEATHER_UPDATE_NOTI"

@interface GlobalCache : NSObject

+ (GlobalCache*)shareInstance;
- (void)initConfig;
- (void)saveInfo;
- (void)clearInfo:(NSString*)key;
- (void)queryProfile;
//- (void)queryWeather;

- (void)logout;
- (void)logout:(BOOL)exit;

+ (NSString*)dateToMonthString:(NSDate*)date;
+ (NSString*)dateToDayString:(NSDate*)date;

- (void)postUpdateNotification:(NSDate*)date;

- (NSArray*)queryEventColorForDay:(NSDate *)date;
- (void)locationCountry;

@property (strong, nonatomic) UserModel* user;
@property (strong, nonatomic) KidModel* kid;
@property (strong, nonatomic) LMLocalData* local;
@property (strong, nonatomic) FirmwareVersion* firmwareVersion;

@property (strong, nonatomic) NSString* cacheLang;
@property (strong, nonatomic) NSString* cacheSupportUrl;

- (NSString*)curLanguage;
- (NSString*)curEventFile;
- (NSString *)showText:(NSString *)key;

//@property (strong, nonatomic) WeatherModel* wearther;
//@property (nonatomic) BOOL weartherRunning;

//@property (strong, nonatomic) NSArray* kidsList;
- (int64_t)getKidId;//获取第一个有效KidId

@property (strong, nonatomic) NSMutableSet* calendarQueue;

@property (strong, nonatomic) NSString* token;

//缓存已经同步的对象，缩短查找设备的时间
@property (strong, nonatomic) CBPeripheral *peripheral;

@end

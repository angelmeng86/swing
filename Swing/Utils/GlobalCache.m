//
//  GlobalCache.m
//  GmatProject
//
//  Created by Mapple on 15-6-10.
//  Copyright (c) 2015年 Yan Cui. All rights reserved.
//

#import "GlobalCache.h"
#import "KeyboardManager.h"
#import "AppDelegate.h"
#import "ActivityCache.h"
#import <INTULocationManager/INTULocationManager.h>
//#import <AVOSCloud/AVOSCloud.h>
@interface GlobalCache ()
{
    CGRect spanishLocalArea;
    CGRect russianLocalArea;
}

@end

@implementation GlobalCache

+ (GlobalCache*)shareInstance
{
    static GlobalCache* globalCache = nil;
    if (globalCache == nil) {
        globalCache = [[GlobalCache alloc] init];
    }
    return globalCache;
}

- (void)setKeyboradManager {
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.shouldResignOnTouchOutside = YES;
    manager.enableAutoToolbar = NO;
    
    //    [manager disableInViewControllerClass:[TagImageViewController class]];
    //    [manager disableInViewControllerClass:[PhotoDetailViewController class]];
    //    [manager disableInViewControllerClass:[LCUserFeedbackViewController class]];
}

- (void)initConfig {
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"Swing.sqlite"];
//    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Swing.sqlite"];
//#ifdef DEBUG
//    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelAll];
//#else
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelOff];
//#endif
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setMinimumDismissTimeInterval:3.0];
    [self setKeyboradManager];
    
    NSString *json = [[NSUserDefaults standardUserDefaults] objectForKey:@"firmware"];
    _firmwareVersion = [[FirmwareVersion alloc] initWithString:json error:nil];
    
    json = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    _user = [[UserModel alloc] initWithString:json error:nil];
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"localData"];
    _local = [[LMLocalData alloc] initWithDictionary:dict error:nil];
    
//    [self locationCountry];
}

- (void)setFirmwareVersion:(FirmwareVersion *)firmwareVersion
{
    _firmwareVersion = firmwareVersion;
    [[NSUserDefaults standardUserDefaults] setObject:[_firmwareVersion toJSONString] forKey:@"firmware"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setUser:(UserModel *)user {
    _user = user;
    [[NSUserDefaults standardUserDefaults] setObject:[_user toJSONString] forKey:@"user"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (LMLocalData*)local {
    if(_local == nil) {
        _local = [LMLocalData new];
        _local.date = [GlobalCache dateToDayString:[NSDate date]];
    }
    else {
        [_local checkDate];
    }
    return _local;
}

- (void)clearInfo:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveInfo {
    [[NSUserDefaults standardUserDefaults] setObject:[self.local toDictionary] forKey:@"localData"];
    if (_firmwareVersion) {
        [[NSUserDefaults standardUserDefaults] setObject:[_firmwareVersion toJSONString] forKey:@"firmware"];
    }
    if (_user) {
        [[NSUserDefaults standardUserDefaults] setObject:[_user toJSONString] forKey:@"user"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)logout {
    [self logout:YES];
}

- (void)logout:(BOOL)exit {
    self.user = nil;
    self.local = nil;
    self.peripheral = nil;
    self.currentKid = nil;
    
    self.subHostRequestTo = nil;
    self.subHostRequestFrom = nil;
    
//    [self.calendarEventsByMonth removeAllObjects];
    [self.calendarQueue removeAllObjects];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kid"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"localData"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user"];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"activitys"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [DBHelper clearDatabase];
    
    [[SwingClient sharedClient] logout];
    
//    [SVProgressHUD dismiss];
    if (exit) {
        AppDelegate *ad = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [ad goToLogin];
    }
}

- (void)queryProfile {
    [[SwingClient sharedClient] userRetrieveProfileWithCompletion:^(id user, NSArray *kids, NSError *error) {
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:USER_PROFILE_LOAD_NOTI object:nil];
        }
        else {
            LOG_D(@"retrieveProfile fail: %@", error);
        }
    }];
}

- (void)querySharedDevice {
    [[SwingClient sharedClient] subHostList:@"ACCEPTED" completion:^(NSArray *requestFrom, NSArray *requestTo, NSError *error) {
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:USER_PROFILE_LOAD_NOTI object:nil];
        }
        else {
            LOG_D(@"subHostList ACCEPTED fail: %@", error);
        }
    }];
}

- (KidInfo*)currentKid {
    if (_currentKid == nil) {
        _currentKid = [DBHelper queryKid:self.local.selectedKidId];
        if (_currentKid == nil) {
            _currentKid = [KidInfo MR_findFirst];
            self.local.selectedKidId = _currentKid.objId;
            [self saveInfo];
        }
    }
    return _currentKid;
}

- (BOOL)curKidUpdate {
    if(self.firmwareVersion.version.length > 0 && self.currentKid.currentVersion.length > 0 && ![self.currentKid.currentVersion isEqualToString:self.firmwareVersion.version]) {
        return YES;
    }
    return NO;
}

- (BOOL)switchKidAccount:(int64_t)kidId
{
    KidInfo *kid = [DBHelper queryKid:kidId];
    if (kid) {
        self.currentKid = kid;
        self.local.selectedKidId = kidId;
        self.local.indoorSteps = 0;
        self.local.outdoorSteps = 0;
        [self saveInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:KID_AVATAR_NOTIFICATION object:nil];
        LOG_D(@"switchKid %lld:%@", kidId, kid.macId);
        return YES;
    }
    return NO;
}

- (NSMutableSet*)calendarQueue {
    if (_calendarQueue == nil) {
        _calendarQueue = [[NSMutableSet alloc] init];
    }
    return _calendarQueue;
}

+ (NSString*)dateToMonthString:(NSDate*)date {
    static NSDateFormatter *df = nil;
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM"];
    }
    return [df stringFromDate:date];
}

+ (NSString*)dateToDayString:(NSDate*)date {
    static NSDateFormatter *df = nil;
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
    }
    return [df stringFromDate:date];
}

- (void)postUpdateNotification:(NSDate*)date {
    if (date) {
        NSString *month = [GlobalCache dateToMonthString:date];
        [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_LIST_UPDATE_NOTI object:month];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_LIST_UPDATE_NOTI object:nil];
    }
}

- (NSArray*)queryEventColorForDay:(NSDate *)date
{
    NSArray* events = [DBHelper queryEventModelByDay:date];
    if (events.count > 0) {
        NSMutableArray *array = [NSMutableArray new];
        int i = 0;
        for (EventModel *event in events) {
            [array addObject:event.color == nil ? [UIColor redColor] : event.color];
            if (++i >= 4) {
                break;
            }
        }
        return array;
    }
    
    return nil;
}

- (void)locationCountry {
//    NSTimeZone *tz = [NSTimeZone localTimeZone];
//    LOG_D(@"Local timezone: %@", tz.name);
//    NSLocale *countryLocale = [NSLocale currentLocale];
//    LOG_D(@"countryLocale: %@", countryLocale.countryCode);
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity
                                       timeout:10.0
                          delayUntilAuthorized:YES  // This parameter is optional, defaults to NO if omitted
                                         block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                             if (status == INTULocationStatusSuccess) {
                                                 // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                                                 // currentLocation contains the device's current location.
                                                 LOG_D(@"Location success %@", currentLocation);
//                                                 currentLocation = [[CLLocation alloc] initWithLatitude:40.5 longitude:-3.65];
//                                                 LOG_D(@"Location success2 %@", currentLocation);
                                                 CGPoint point = CGPointMake(currentLocation.coordinate.longitude, currentLocation.coordinate.latitude);
                                                 if (CGRectContainsPoint(spanishLocalArea, point) || CGRectContainsPoint(russianLocalArea, point)) {
                                                     self.cacheSupportUrl = @"http://www.imaginarium.info";
                                                 }
                                                 else
                                                 {
                                                     self.cacheSupportUrl = @"http://kidsdynamic.com";
                                                 }
                                                 LOG_D(@"Use %@", self.cacheSupportUrl);
                                                 /*
                                                 CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                                                 [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                                                     if (!error) {
//                                                         LOG_D(@"placemarks count %d", (int)placemarks.count);
                                                         CLPlacemark *placemark =[placemarks firstObject];
                                                        LOG_D(@"country:%@", placemark.country);
                                                         LOG_D(@"ISOcountryCode:%@", placemark.ISOcountryCode);
                                                         if ([placemark.country containsString:@"Spanish"] || [placemark.country containsString:@"Russian"] || [placemark.ISOcountryCode.lowercaseString isEqualToString:@"es"]
                                                             || [placemark.ISOcountryCode.lowercaseString isEqualToString:@"ru"]) {
                                                             self.cacheSupportUrl = @"http://www.imaginarium.info";
                                                         }
                                                         else
                                                         {
                                                             self.cacheSupportUrl = @"http://kidsdynamic.com";
                                                         }
                                                     }
                                                     else {
                                                         LOG_D(@"reverseGeocodeLocation err:%@", error);
                                                     }
                                                 }];
                                                  */
                                             }
                                             else if (status == INTULocationStatusTimedOut) {
                                                 // Wasn't able to locate the user with the requested accuracy within the timeout interval.
                                                 // However, currentLocation contains the best location available (if any) as of right now,
                                                 // and achievedAccuracy has info on the accuracy/recency of the location in currentLocation.
                                                 LOG_D(@"Location timeout.");
                                             }
                                             else {
                                                 // An error occurred, more info is available by looking at the specific status returned.
                                                 LOG_D(@"Location err:%ld", (long)status);
                                             }
                                         }];
}

- (NSString*)cacheSupportUrl {
    if (_cacheSupportUrl == nil) {
//        _cacheSupportUrl = @"http://kidsdynamic.com";
        _cacheSupportUrl = @"http://www.imaginarium.info";
    }
    return _cacheSupportUrl;
}

/*
- (void)queryWeather {
    if (_weartherRunning) {
        return;
    }
    _weartherRunning = YES;
    [[RCLocationManager sharedManager] requestUserLocationWhenInUseWithBlockOnce:^(CLLocationManager *manager, CLAuthorizationStatus status) {
        LOG_D(@"status:%d", status);
        [[RCLocationManager sharedManager] retrieveUserLocationWithBlock:^(CLLocationManager *manager, CLLocation *newLocation, CLLocation *oldLocation) {
            LOG_D(@"newLocation:%@ oldLocation:%@", newLocation, oldLocation);
            
            if (newLocation) {
                [WeatherModel weatherQuery:[NSString stringWithFormat:@"%f", newLocation.coordinate.latitude] lon:[NSString stringWithFormat:@"%f", newLocation.coordinate.longitude] completion:^(id weather, NSError *error) {
                    if (error) {
                        LOG_D(@"weatherQuery fail: %@", error);
                        _weartherRunning = NO;
                    }
                    else {
                        self.wearther = weather;
                        [[NSNotificationCenter defaultCenter] postNotificationName:WEATHER_UPDATE_NOTI object:weather];
                        _weartherRunning = NO;
                        LOG_D(@"weather:%@", weather);
                    }
                }];
            }
            
        } errorBlock:^(CLLocationManager *manager, NSError *error) {
            LOG_D(@"error:%@", error);
            _weartherRunning = NO;
            [SVProgressHUD showErrorWithStatus:@"User has explicitly denied authorization for this application, or location services are disabled in Settings."];
            [SVProgressHUD dismissWithDelay:1.5];
        }];
        
    }];
}
*/

- (NSString*)curLanguage
{
    //static NSString* cacheLang = nil;
    if (self.cacheLang) {
        return self.cacheLang;
    }
    if (self.local.language) {
        self.cacheLang = self.local.language;
    }
    else {
        NSString *languageID = [[NSBundle mainBundle] preferredLocalizations].firstObject;
        if ([languageID.lowercaseString isEqualToString:@"es"] || [languageID.lowercaseString isEqualToString:@"ru"] || [languageID.lowercaseString isEqualToString:@"ja"] || [languageID.lowercaseString isEqualToString:@"zh-hant"]/*zh-Hant*/) {
            self.cacheLang = languageID;
        }
        else {
            self.cacheLang = @"en";
        }
    }
    return self.cacheLang;
}

- (NSString*)curEventFile
{
    /*
     FW version
     KDV0005-A, KDV0105-A
     00 -> EN, 05 -> Version
     01 -> JP, 05 -> Version
     */
    NSString *version = [GlobalCache shareInstance].currentKid.currentVersion;
    if (version == nil) {
        version = [GlobalCache shareInstance].currentKid.firmwareVersion;
    }
    if (version.length > 0 && [version hasPrefix:@"KDV01"]) {
        return [[NSBundle mainBundle] pathForResource:@"alert2_jp" ofType:@"json"];
    }
//    if ([self.curLanguage isEqualToString:@"ja"] || [self.curLanguage hasPrefix:@"zh"]) {
//        return [[NSBundle mainBundle] pathForResource:@"alert_jp" ofType:@"json"];
//    }
    return [[NSBundle mainBundle] pathForResource:@"alert2" ofType:@"json"];;
}

- (NSString *)showText:(NSString *)key
{
    NSString *path = [[NSBundle mainBundle] pathForResource:self.curLanguage ofType:@"lproj"];
    return [[NSBundle bundleWithPath:path] localizedStringForKey:key value:nil table:@"Localizable"];
}

- (id)init
{
    if (self = [super init]) {
//        _weartherRunning = NO;
        //43.4374170000,-10.3827280000
        //35.5704490000,4.0959440000
        //纬度y，经度x
        spanishLocalArea = CGRectMake(-10.382728, 35.570449, 4.095944 + 10.382728, 43.437417 - 35.570449);
        
        //76.5577429390,30.9375000000
        //48.1074311885,-170.6835937500
        russianLocalArea = CGRectMake(-170.6835937500, 48.1074311885, 30.9375 + 170.6835937500, 76.5577429390 - 48.1074311885);
    }
    return self;
}

@end

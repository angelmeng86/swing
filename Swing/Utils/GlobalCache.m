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

#import <AVOSCloud/AVOSCloud.h>

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
#ifdef UPLOAD_DEBUG
    [AVOSCloud setAllLogsEnabled:NO];
    [AVOSCloud setVerbosePolicy:kAVVerboseNone];
    [AVOSCloud setApplicationId:@"zBJwrWLoydY2zVeSkxENhDL4-gzGzoHsz" clientKey:@"JPosFv55xiaCsCp6wNmfuejs"];
#endif
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"Swing.sqlite"];
//    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Swing.sqlite"];
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelOff];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [self setKeyboradManager];
    
    NSString *json = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    _info = [[LoginedModel alloc] initWithString:json error:nil];
    
    json = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    _user = [[UserModel alloc] initWithString:json error:nil];
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"localData"];
    _local = [[LMLocalData alloc] initWithDictionary:dict error:nil];
    
}

- (void)setInfo:(LoginedModel *)info {
    _info = info;
    [[NSUserDefaults standardUserDefaults] setObject:[_info toJSONString] forKey:@"token"];
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

- (void)saveInfo {
    [[NSUserDefaults standardUserDefaults] setObject:[_local toDictionary] forKey:@"localData"];
    [[NSUserDefaults standardUserDefaults] setObject:[_info toJSONString] forKey:@"token"];
    [[NSUserDefaults standardUserDefaults] setObject:[_user toJSONString] forKey:@"user"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)logout {
    self.info = nil;
    self.user = nil;
    self.kidsList = nil;
    self.local = nil;
    self.peripheral=nil;
//    self.activitys = nil;
//    [self.calendarEventsByMonth removeAllObjects];
    [self.calendarQueue removeAllObjects];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kids"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"localData"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user"];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"activitys"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [DBHelper clearDatabase];
    
    [[SwingClient sharedClient] logout];
    
//    [SVProgressHUD dismiss];
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateInitialViewController];
    AppDelegate *ad = (AppDelegate*)[UIApplication sharedApplication].delegate;
    ad.window.rootViewController = ctl;
}

- (void)queryProfile {
    [[SwingClient sharedClient] userRetrieveProfileWithCompletion:^(id user, NSArray *kids, NSError *error) {
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:USER_PROFILE_LOAD_NOTI object:user];
        }
        else {
            LOG_D(@"retrieveProfile fail: %@", error);
//            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }
    }];
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


- (void)queryMonthEvents:(NSDate*)date {
    if (/* DISABLES CODE */ (YES)) {
        //增加本地缓存后不需要每次进行查询
        return;
    }
    
    NSString *month = [GlobalCache dateToMonthString:date];
    if ([self.calendarQueue containsObject:month]) {
        LOG_D(@"containsObject date: %@", month);
        return;
    }
    
    [self.calendarQueue addObject:month];
    [[SwingClient sharedClient] calendarGetEvents:date type:GetEventTypeMonth completion:^(NSArray *eventArray, NSError *error) {
        if (error) {
            LOG_D(@"calendarGetEvents fail: %@", error);
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_LIST_UPDATE_NOTI object:month];
        }
        [self.calendarQueue removeObject:month];
    }];
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
        if ([languageID isEqualToString:@"es"] || [languageID isEqualToString:@"ru"]) {
            self.cacheLang = languageID;
        }
        else {
            self.cacheLang = @"en";
        }
    }
    return self.cacheLang;
}

- (NSString *)showText:(NSString *)key
{
    NSString *path = [[NSBundle mainBundle] pathForResource:self.curLanguage ofType:@"lproj"];
    return [[NSBundle bundleWithPath:path] localizedStringForKey:key value:nil table:@"Localizable"];
}

- (id)init
{
    if (self = [super init]) {
        _weartherRunning = NO;
    }
    return self;
}

@end

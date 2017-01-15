//
//  AppDelegate.m
//  Swing
//
//  Created by Mapple on 16/7/13.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "AppDelegate.h"
#import "CommonDef.h"
#import "SwingClientTest.h"

@interface AppDelegate ()

@property (nonatomic) BOOL isBackground;

@end

@implementation AppDelegate

- (void)test {
//    [SwingClientTest test:6 times:1];
    
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
//    
//    NSString *oye = [df stringFromDate:[NSDate date]];
//    NSDate *oye2 = [df dateFromString:@"2015-08-30T08:20:00"];
//    NSLog(@"oye:%@, oye2:%@", oye, oye2);
//    char *ptr = "\x76\x01\x00\x00\x01\x76\x01\x00\x00\x76\x01\x00\x00\x76\x01\x00\x00\x76\x01\x00\x00";
//    //    long data = [Fun byteArrayToLong:[NSData dataWithBytes:ptr length:4] length:4];
//    ActivityModel *m = [ActivityModel new];
//    [m setIndoorData:[NSData dataWithBytes:ptr length:21]];
//    NSLog(@"data:%@", m.indoorActivity);
//    
//    static NSDateFormatter *df = nil;
//    if (df == nil) {
//        df = [[NSDateFormatter alloc] init];
//        df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
//        //        [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
//        [df setTimeStyle:NSDateFormatterFullStyle];
//        [df setDateStyle:NSDateFormatterFullStyle];
//    }
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:1472164242];
//    NSLog(@"date:%@ df:%@", date, [df stringFromDate:date]);

    //    [SwingClientTest testAll:15];
    //    [SwingClientTest testBluetooth];
    
    
    /*
        NSDate * date  = [NSDate date];
        NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]; // 指定日历的算法 NSCalendarIdentifierGregorian,NSGregorianCalendar
        // NSDateComponent 可以获得日期的详细信息，即日期的组成
        NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:date];
        
        NSLog(@"年 = year = %ld",comps.year);
        NSLog(@"月 = month = %ld",comps.month);
        NSLog(@"日 = day = %ld",comps.day);
        NSLog(@"时 = hour = %ld",comps.hour);
        NSLog(@"分 = minute = %ld",comps.minute);
        NSLog(@"秒 = second = %ld",comps.second);
        NSLog(@"星期 =weekDay = %ld ",comps.weekday);
    
//    [DBHelper queryEventModelByDay:date];
    
    comps = [[DBHelper calendar] components:NSYearCalendarUnit|NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
    comps.month += 1;
    comps.day = 1;
    NSDate *oneDay = [[DBHelper calendar] dateFromComponents:comps];
    NSLog(@"day:%@", oneDay);
//    oneDay = [oneDay dateByAddingTimeInterval:-1];
    
    [[SwingClient sharedClient] calendarGetEvents:oneDay type:GetEventTypeMonth completion:^(NSArray *eventArray, NSError *error) {
        
    }];
     */
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    NSString *languageID = [[NSBundle mainBundle] preferredLocalizations].firstObject;
//    NSLog(@"languageID:%@",languageID);
    LOG_D(@"home:%@", NSHomeDirectory());
    [[GlobalCache shareInstance] initConfig];
//    [self test];
    
//    [DBHelper queryNearAlertEventModel:50];

    
    // Register for Push Notitications
    //推送默认至支持iOS 8以上
//    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
//    }
//    else {
//        [application registerForRemoteNotificationTypes:
//         UIRemoteNotificationTypeBadge |
//         UIRemoteNotificationTypeAlert |
//         UIRemoteNotificationTypeSound];
//    }
    
    //设置导航默认标题的颜色及字体大小
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:COMMON_TITLE_COLOR, NSFontAttributeName:[UIFont boldAvenirFontOfSize:22]};
    [UINavigationBar appearance].tintColor = COMMON_NAV_TINT_COLOR;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    NSString *name = [GlobalCache shareInstance].info == nil ? @"LoginFlow" : @"MainTab2";
//    NSString *name = @"MainTab2";
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:name bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateInitialViewController];
    self.window.rootViewController = ctl;
    
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    // 如果​remoteNotification不为空，代表有推送发过来，以下类似
    if (remoteNotification) {
        // 发通知
        [self handleRemoteNotification:remoteNotification active:NO];
    }
    else {
        // 把应用右上角的图标​去掉
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    
//    NSArray *locals = [NSLocale availableLocaleIdentifiers];
//    NSLog(@"locals:%@", locals);
    
//    [SwingClientTest testAll:11];
    
    /*
    NSArray *familyNames =[[NSArray alloc]initWithArray:[UIFont familyNames]];
    NSArray *fontNames;
    NSInteger indFamily, indFont;
    NSLog(@"[familyNames count]===%lu",(unsigned long)[familyNames count]);
    for(indFamily=0;indFamily<[familyNames count];++indFamily)
        
    {
//        if (![[familyNames objectAtIndex:indFamily] containsString:@"Avenir"]) {
//            continue;
//        }
        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
        fontNames =[[NSArray alloc]initWithArray:[UIFont fontNamesForFamilyName:[familyNames objectAtIndex:indFamily]]];
        
        for(indFont=0; indFont<[fontNames count]; ++indFont)
            
        {
            NSLog(@"Font name: %@",[fontNames objectAtIndex:indFont]);
            
        }
    }
    */
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    
    NSString *tokenStr = [Fun dataToHex:deviceToken];
    NSLog(@"token:%@", tokenStr);
    // Save the token to server
    [GlobalCache shareInstance].token = tokenStr;
    if ([GlobalCache shareInstance].info) {
        [[SwingClient sharedClient] userUpdateIOSRegistrationId:[GlobalCache shareInstance].token completion:^(NSError *error) {
            if (error) {
                NSLog(@"userUpdateIOSRegistrationId1 fail: %@", error);
            }
        }];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError:%@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    NSLog(@"didReceiveRemoteNotification");
    if (userInfo) {
        [self handleRemoteNotification:userInfo active:YES];
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler {
    completionHandler(UIBackgroundFetchResultNewData);
//    NSLog(@"forRemoteNotification");
    if (userInfo) {
        [self handleRemoteNotification:userInfo active:YES];
    }
}

- (void)handleRemoteNotification:(NSDictionary*)userInfo active:(BOOL)active {
    NSLog(@"handleRemoteNotification:%@", userInfo);
    NSString* alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    // 把应用右上角的图标​去掉
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if (active && [GlobalCache shareInstance].info && !_isBackground) {
        [Fun showMessageBoxWithTitle:@"Notification" andMessage:alert];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:REMOTE_NOTIFICATION object:userInfo];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
//    NSLog(@"applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
//    NSLog(@"applicationDidEnterBackground");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
//    NSLog(@"applicationWillEnterForeground");
    _isBackground = YES;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
//    NSLog(@"applicationDidBecomeActive");
    _isBackground = NO;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord cleanUp];
}

@end

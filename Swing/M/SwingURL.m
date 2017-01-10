//
//  SwingURL.m
//  Swing
//
//  Created by Mapple on 2017/1/9.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "SwingURL.h"

@implementation SwingURL

- (NSString*)baseURL {
    return @"https://childrenlab.com/";//启用https
//    return @"http://www.childrenLab.com/";
}

- (NSString*)isEmailRegistered {
    return @"/user/isEmailRegistered";
}

- (NSString*)userLogin {
    return @"/api/login";
}

- (NSString*)userRegister {
    return @"/user/register";
}

- (NSString*)updateIOSRegistrationId {
    return @"/user/updateIOSRegistrationId";
}

- (NSString*)retrieveUserProfile {
    return @"/user/retrieveUserProfile";
}

- (NSString*)uploadProfileImage {
    return @"/avatar/uploadProfileImageToS3";
}

- (NSString*)updateProfile {
    return @"/user/updateProfile";
}

- (NSString*)kidsAdd {
    return @"/kids/add";
}

- (NSString*)kidsRemove {
    return @"/kids/remove";
}

- (NSString*)uploadKidsProfileImage {
    return @"/avatar/uploadKidsProfileImage";
}

- (NSString*)kidsList {
    return @"/kids/list";
}

- (NSString*)addEvent {
    return @"/calendarEvent/addEvent";
}

- (NSString*)editEventWithTodo {
    return @"/calendarEvent/editEventWithTodo";
}

- (NSString*)addTodo {
    return @"/calendarEvent/addTodo";
}

- (NSString*)todoDone {
    return @"/calendarEvent/todoDone";
}

- (NSString*)deleteTodo {
    return @"/calendarEvent/deleteTodo";
}

- (NSString*)getEventsByUser {
    return @"/calendarEvent/getEventsByUser";
}

- (NSString*)deleteEvent {
    return @"/calendarEvent/deleteEvent";
}

- (NSString*)retrieveAllEventsWithTodo {
    return nil;
}

- (NSString*)uploadRawData {
    return @"/device/uploadRawData";
}

- (NSString*)getDailyActivity {
    return @"/device/getDailyActivity";
}

- (NSString*)getYearlyActivity {
    return @"/device/getYearlyActivity";
}

- (NSString*)getMonthlyActivity {
    return @"/device/getMonthlyActivity";
}

- (NSString*)getWeeklyActivity {
    return @"/device/getWeeklyActivity";
}

@end

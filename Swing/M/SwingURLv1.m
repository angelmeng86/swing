//
//  SwingURLv1.m
//  Swing
//
//  Created by Mapple on 2017/1/9.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "SwingURLv1.h"

@implementation SwingURLv1

- (NSString*)baseURL {
    return @"https://childrenlab.com:8111/";
}

- (NSString*)isEmailRegistered {
    return @"/user/isEmailRegistered";
}

- (NSString*)userLogin {
    return @"/v1/user/login";
}

- (NSString*)userRegister {
    return @"/v1/user/register";
}

- (NSString*)updateIOSRegistrationId {
    return @"/user/updateIOSRegistrationId";
}

- (NSString*)retrieveUserProfile {
    return @"/v1/user/retrieveUserProfile";
}

- (NSString*)uploadProfileImage {
    return @"/v1/user/avatar/upload";
}

- (NSString*)updateProfile {
    return @"/v1/user/updateProfile";
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

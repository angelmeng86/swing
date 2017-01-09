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
    return @"/v1/kids/add";
}

- (NSString*)kidsRemove {
    return @"/v1/kids/remove";
}

- (NSString*)uploadKidsProfileImage {
    return @"/v1/user/avatar/uploadKid";
}

- (NSString*)kidsList {
    return @"/kids/list";
}

- (NSString*)addEvent {
    return @"/v1/event/add";
}

- (NSString*)editEventWithTodo {
    return @"/v1/event/update";
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
    return @"/v1/activity/uploadRawData";
}

- (NSString*)getDailyActivity {
    return @"/v1/activity/retrieveData";
}

- (NSString*)getYearlyActivity {
    return @"/v1/activity/retrieveData";
}

- (NSString*)getMonthlyActivity {
    return @"/v1/activity/retrieveData";
}

- (NSString*)getWeeklyActivity {
    return @"/v1/activity/retrieveData";
}

@end

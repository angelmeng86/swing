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
//未实现
- (NSString*)isEmailRegistered {
    return @"/user/isEmailRegistered";
}

- (NSString*)userLogin {
    return @"/v1/user/login";
}

- (NSString*)userRegister {
    return @"/v1/user/register";
}
//未实现
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
//废弃
- (NSString*)kidsList {
    return @"/kids/list";
}

- (NSString*)addEvent {
    return @"/v1/event/add";
}

- (NSString*)editEventWithTodo {
    return @"/v1/event/update";
}
//废弃
- (NSString*)addTodo {
    return @"/calendarEvent/addTodo";
}
//未实现
- (NSString*)todoDone {
    return @"/calendarEvent/todoDone";
}
//废弃
- (NSString*)deleteTodo {
    return @"/calendarEvent/deleteTodo";
}

- (NSString*)getEventsByUser {
    return @"/v1/event/retrieveEvents";
}

- (NSString*)deleteEvent {
    return @"/v1/event/delete";
}

- (NSString*)retrieveAllEventsWithTodo {
    return @"/v1/event/retrieveAllEventsWithTodo";
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

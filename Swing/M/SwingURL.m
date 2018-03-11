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
#ifdef DEBUG
    return @"http://dev.childrenlab.com:8080/";
#else
    return @"https://childrenlab.com/";
#endif
}

- (NSString*)myCountryCode {
    return @"/v1/user/myCountryCode";
}

- (NSString*)isEmailRegistered {
    return @"/v1/user/isEmailAvailableToRegister";
}

- (NSString*)whoRegisteredMacID {
    return @"/v1/kids/whoRegisteredMacID";
}

- (NSString*)userLogin {
    return @"/v1/user/login";
}

- (NSString*)userLogout {
    return @"/v1/user/logout";
}

- (NSString*)userRegister {
    return @"/v1/user/register";
}

- (NSString*)updateLanguage {
    return @"/v1/user/updateLanguage";
}

- (NSString*)updateIOSRegistrationId {
    return @"/v1/user/updateIOSRegistrationId";
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

- (NSString*)kidsUpdate {
    return @"/v1/kids/update";
}

- (NSString*)updateKidRevertMacID {
    return @"/v1/kids/updateKidRevertMacID";
}

- (NSString*)kidsDelete {
    return @"/v1/kids/delete";
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

- (NSString*)todoDone {
    return @"/v1/event/todo/done";
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

- (NSString*)batteryStatus {
    return @"/v1/kids/batteryStatus";
}

- (NSString*)getRetrieveActivity {
    return @"/v1/activity/retrieveData";
}

- (NSString*)retrieveActivityByTime {
    return @"/v1/activity/retrieveDataByTime";
}

- (NSString*)retrieveMonthlyActivity {
    return @"/v1/activity/retrieveMonthlyActivity";
}

- (NSString*)retrieveHourlyDataByTime {
    return @"/v1/activity/retrieveHourlyDataByTime";
}

- (NSString*)currentVersion {
    return @"/v1/fw/currentVersion";
}

- (NSString*)putFirmwareVersion {
    return @"/v1/fw/firmwareVersion";
}


- (NSString*)sendResetPasswordEmail {
    return @"/v1/user/sendResetPasswordEmail";
}

- (NSString*)updatePassword {
    return @"/v1/user/updatePassword";
}

- (NSString*)getUserByEmail {
    return @"/v1/user/getUserByEmail";
}

- (NSString*)subHostAdd {
    return @"/v1/subHost/add";
}

- (NSString*)subHostAccept {
    return @"/v1/subHost/accept";
}

- (NSString*)subHostDeny {
    return @"/v1/subHost/deny";
}

- (NSString*)subHostList {
    return @"/v1/subHost/list";
}

- (NSString*)subHostRemoveKid {
    return @"/v1/subHost/removeKid";
}

- (NSString*)subHostDelete {
    return @"/v1/subHost/delete";
}

@end

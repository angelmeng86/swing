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
    return @"http://dev.childrenlab.com/";
#else
    return @"https://childrenlab.com/";
#endif
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

//废弃
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

@end

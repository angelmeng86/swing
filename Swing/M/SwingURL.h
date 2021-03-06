//
//  SwingURL.h
//  Swing
//
//  Created by Mapple on 2017/1/9.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SwingURL : NSObject

@property (nonatomic, readonly, strong) NSString* baseURL;
@property (nonatomic, readonly, strong) NSString* myCountryCode;
@property (nonatomic, readonly, strong) NSString* isEmailRegistered;

@property (nonatomic, readonly, strong) NSString* whoRegisteredMacID;

@property (nonatomic, readonly, strong) NSString* userLogin;
@property (nonatomic, readonly, strong) NSString* userLogout;
@property (nonatomic, readonly, strong) NSString* userRegister;
@property (nonatomic, readonly, strong) NSString* updateLanguage;
@property (nonatomic, readonly, strong) NSString* updateIOSRegistrationId;
@property (nonatomic, readonly, strong) NSString* retrieveUserProfile;
@property (nonatomic, readonly, strong) NSString* uploadProfileImage;
@property (nonatomic, readonly, strong) NSString* updateProfile;

@property (nonatomic, readonly, strong) NSString* kidsAdd;
@property (nonatomic, readonly, strong) NSString* kidsUpdate;
@property (nonatomic, readonly, strong) NSString* updateKidRevertMacID;
@property (nonatomic, readonly, strong) NSString* kidsDelete;
@property (nonatomic, readonly, strong) NSString* uploadKidsProfileImage;
@property (nonatomic, readonly, strong) NSString* kidsList;

@property (nonatomic, readonly, strong) NSString* addEvent;
@property (nonatomic, readonly, strong) NSString* editEventWithTodo;
@property (nonatomic, readonly, strong) NSString* addTodo;
@property (nonatomic, readonly, strong) NSString* todoDone;
@property (nonatomic, readonly, strong) NSString* deleteTodo;
@property (nonatomic, readonly, strong) NSString* getEventsByUser;
@property (nonatomic, readonly, strong) NSString* deleteEvent;
@property (nonatomic, readonly, strong) NSString* retrieveAllEventsWithTodo;

@property (nonatomic, readonly, strong) NSString* uploadRawData;
@property (nonatomic, readonly, strong) NSString* batteryStatus;
@property (nonatomic, readonly, strong) NSString* getRetrieveActivity;

@property (nonatomic, readonly, strong) NSString* retrieveActivityByTime;
@property (nonatomic, readonly, strong) NSString* retrieveMonthlyActivity;
@property (nonatomic, readonly, strong) NSString* retrieveHourlyDataByTime;

@property (nonatomic, readonly, strong) NSString* currentVersion;
@property (nonatomic, readonly, strong) NSString* putFirmwareVersion;

@property (nonatomic, readonly, strong) NSString* sendResetPasswordEmail;
@property (nonatomic, readonly, strong) NSString* updatePassword;
@property (nonatomic, readonly, strong) NSString* getUserByEmail;

@property (nonatomic, readonly, strong) NSString* subHostAdd;
@property (nonatomic, readonly, strong) NSString* subHostAccept;
@property (nonatomic, readonly, strong) NSString* subHostDeny;
@property (nonatomic, readonly, strong) NSString* subHostList;
@property (nonatomic, readonly, strong) NSString* subHostRemoveKid;
@property (nonatomic, readonly, strong) NSString* subHostDelete;

@end

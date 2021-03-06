//
//  SwingClient.h
//  Swing
//
//  Created by Mapple on 16/7/17.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "SwingURL.h"
#import "CommonDef.h"

typedef enum : NSUInteger {
    GetEventTypeMonth,
    GetEventTypeDay,
} GetEventType;

typedef enum : NSUInteger {
    GetActivityTypeYear,
    GetActivityTypeMonth,
    GetActivityTypeWeekly,
    GetActivityTypeDay,
    GetActivityTypeHourly,
} GetActivityType;

@class ActivityModel;
@interface SwingClient : NSObject

+ (SwingClient *)sharedClient;

- (void)logout;

- (NSURLSessionDataTask *)userIsEmailRegistered:(NSString*)email completion:( void (^)(NSNumber *result, NSString* msg, NSError *error) )completion;

- (NSURLSessionDataTask *)whoRegisteredMacID:(NSString*)macId completion:( void (^)(id  kid, NSError *error) ) completion;

- (NSURLSessionDataTask *)userLogin:(NSString*)email password:(NSString*)pwd completion:( void (^)(NSError *error) )completion;

- (NSURLSessionDataTask *)myCountryCodeWithCompletion:( void (^)(NSString *countryCode ,NSError *error) )completion;

- (NSURLSessionDataTask *)userLogoutWithCompletion:( void (^)(NSError *error) )completion;

- (NSURLSessionDataTask *)userRegister:(NSDictionary*)data completion:( void (^)(id user, NSError *error) )completion;

- (NSURLSessionDataTask *)updateLanguageWithCompletion:( void (^)(NSError *error) )completion;

- (NSURLSessionDataTask *)userUpdateIOSRegistrationId:(NSString*)token completion:( void (^)(NSError *error) )completion;

- (NSURLSessionDataTask *)userRetrieveProfileWithCompletion:( void (^)(id user, NSArray *kids, NSError *error) )completion;

- (NSURLSessionDataTask *)userUploadProfileImage:(UIImage*)image completion:( void (^)(NSString *profileImage, NSError *error) )completion;

- (NSURLSessionDataTask *)userUpdateProfile:(NSDictionary*)data completion:( void (^)(id user, NSError *error) )completion;


- (NSURLSessionDataTask *)kidsAdd:(NSDictionary*)data completion:( void (^)(id kid, NSError *error) )completion;

- (NSURLSessionDataTask *)updateKidRevertMacID:(int64_t)kidId macId:(NSString*)macId completion:( void (^)(NSError *error) )completion;

- (NSURLSessionDataTask *)kidsUpdate:(NSDictionary*)data completion:( void (^)(id kid, NSError *error) )completion;


- (NSURLSessionDataTask *)kidsDelete:(int64_t)kidId completion:( void (^)(NSError *error) )completion;

- (NSURLSessionDataTask *)kidsUploadKidsProfileImage:(UIImage*)image kidId:(int64_t)kidId completion:( void (^)(NSString *profileImage, NSError *error) )completion;

//- (NSURLSessionDataTask *)kidsListWithCompletion:( void (^)(NSArray *list, NSError *error) )completion;


- (NSURLSessionDataTask *)calendarAddEvent:(NSDictionary*)data completion:( void (^)(id event, NSError *error) )completion;

- (NSURLSessionDataTask *)calendarEditEvent:(NSDictionary*)data completion:( void (^)(id event, NSError *error) )completion;

- (NSURLSessionDataTask *)calendarAddTodo:(int64_t)eventId todoList:(NSString*)todoList completion:( void (^)(id event, NSArray* todoArray, NSError *error) )completion;

- (NSURLSessionDataTask *)calendarTodoDone:(int64_t)todoId eventId:(int64_t)eventId completion:( void (^)(NSError *error) )completion;

//- (NSURLSessionDataTask *)calendarTodoDelete:(NSString*)eventId todoId:(NSString*)todoId completion:( void (^)(NSError *error) )completion;

//- (NSURLSessionDataTask *)calendarGetEvents:(NSDate*)date type:(GetEventType)type completion:( void (^)(NSArray* eventArray, NSError *error) )completion;

//new api added
- (NSURLSessionDataTask *)calendarGetAllEventsWithCompletion:( void (^)(NSArray* eventArray, NSError *error) )completion;

- (NSURLSessionDataTask *)calendarDeleteEvent:(int64_t)eventId completion:( void (^)(NSError *error) )completion;

- (NSURLSessionDataTask *)deviceUploadRawData:(ActivityModel*)model completion:( void (^)(NSError *error) )completion;

- (NSURLSessionDataTask *)kidsUploadBatteryStatus:(int)battery macId:(NSString*)macId completion:( void (^)(NSError *error) )completion;

- (NSURLSessionDataTask *)deviceGetActivity:(int64_t)kidId type:(GetActivityType)type completion:( void (^)(id dailyActs ,NSError *error) )completion;

- (NSURLSessionDataTask *)deviceGetActivityByTime:(int64_t)kidId beginTimestamp:(NSDate*)beginTime endTimestamp:(NSDate*)endTime completion:( void (^)(id dailyActs ,NSError *error) )completion;

- (NSURLSessionDataTask *)deviceGetMonthlyActivityByTime:(int64_t)kidId beginTimestamp:(NSDate*)beginTime endTimestamp:(NSDate*)endTime completion:( void (^)(id monthlyActs ,NSError *error) )completion;

- (NSURLSessionDataTask *)deviceGetActivityHourlyByTime:(int64_t)kidId beginTimestamp:(NSDate*)beginTime endTimestamp:(NSDate*)endTime completion:( void (^)(id dailyActs ,NSError *error) )completion;

- (NSURLSessionDataTask *)getFirmwareVersion:(NSString*)macId version:(NSString*)version completion:( void (^)(id version, NSError *error) )completion;

- (NSURLSessionDataTask *)putFirmwareVersion:(NSString*)version macId:(NSString*)macId completion:( void (^)(NSError *error) )completion;

- (NSURLSessionDataTask *)sendResetPasswordEmail:(NSString*)email completion:( void (^)(NSError *error) )completion;

- (NSURLSessionDataTask *)updatePassword:(NSString*)newpwd completion:( void (^)(NSError *error) )completion;

- (NSURLSessionDataTask *)getUserByEmail:(NSString*)email completion:( void (^)(id user, NSError *error) )completion;

//subHost API

- (NSURLSessionDataTask *)subHostAdd:(int64_t)kidId completion:( void (^)(id subHost, NSError *error) )completion;

- (NSURLSessionDataTask *)subHostAccept:(int64_t)subHostId kidIds:(NSArray*)kidIds completion:( void (^)(id subHost, NSError *error) )completion;

- (NSURLSessionDataTask *)subHostDeny:(int64_t)subHostId completion:( void (^)(NSError *error) )completion;

//status : PENDING, ACCEPTED, DENIED
- (NSURLSessionDataTask *)subHostList:(NSString*)status completion:( void (^)(NSArray* requestFrom, NSArray* requestTo, NSError *error) )completion;

- (NSURLSessionDataTask *)subHostRemoveKid:(int64_t)subHostId kidId:(int64_t)kidId completion:( void (^)(id subHost, NSError *error) )completion;

- (NSURLSessionDataTask *)subHostDelete:(int64_t)subHostId completion:( void (^)(NSError *error) )completion;

@end

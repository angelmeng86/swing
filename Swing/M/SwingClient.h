//
//  SwingClient.h
//  Swing
//
//  Created by Mapple on 16/7/17.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "AFHTTPSessionManager.h"
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
} GetActivityType;

@class ActivityModel;
@interface SwingClient : AFHTTPSessionManager

+ (SwingClient *)sharedClient;

- (void)logout;



- (NSURLSessionDataTask *)userIsEmailRegistered:(NSString*)email completion:( void (^)(NSNumber *result, NSError *error) ) completion;

- (NSURLSessionDataTask *)userLogin:(NSString*)email password:(NSString*)pwd completion:( void (^)(NSError *error) )completion;

- (NSURLSessionDataTask *)userRegister:(NSDictionary*)data completion:( void (^)(id user, NSError *error) )completion;

- (NSURLSessionDataTask *)userRetrieveProfileWithCompletion:( void (^)(id user, NSArray *kids, NSError *error) )completion;

- (NSURLSessionDataTask *)userUploadProfileImage:(UIImage*)image completion:( void (^)(NSString *profileImage, NSError *error) )completion;

- (NSURLSessionDataTask *)userUpdateProfile:(NSDictionary*)data completion:( void (^)(id user, NSError *error) )completion;


- (NSURLSessionDataTask *)kidsAdd:(NSDictionary*)data completion:( void (^)(id kid, NSError *error) )completion;

//- (NSURLSessionDataTask *)kidsRemove:(NSString*)kidid completion:( void (^)(NSError *error) )completion;

- (NSURLSessionDataTask *)kidsUploadKidsProfileImage:(UIImage*)image kidId:(NSString*)kidId completion:( void (^)(NSString *profileImage, NSError *error) )completion;

- (NSURLSessionDataTask *)kidsListWithCompletion:( void (^)(NSArray *list, NSError *error) )completion;


- (NSURLSessionDataTask *)calendarAddEvent:(NSDictionary*)data completion:( void (^)(id event, NSError *error) )completion;

- (NSURLSessionDataTask *)calendarAddTodo:(NSString*)eventId todoList:(NSString*)todoList completion:( void (^)(id event, NSArray* todoArray, NSError *error) )completion;

- (NSURLSessionDataTask *)calendarTodoDone:(NSString*)todoId completion:( void (^)(NSError *error) )completion;

- (NSURLSessionDataTask *)calendarGetEvents:(NSDate*)date type:(GetEventType)type completion:( void (^)(NSArray* eventArray, NSError *error) )completion;

- (NSURLSessionDataTask *)calendarDeleteEvent:(NSString*)eventId completion:( void (^)(NSError *error) )completion;

- (NSURLSessionDataTask *)deviceUploadRawData:(ActivityModel*)model completion:( void (^)(NSError *error) )completion;

- (NSURLSessionDataTask *)deviceGetActivity:(NSString*)macId type: completion:( void (^)(id dailyActs ,NSError *error) )completion;

@end

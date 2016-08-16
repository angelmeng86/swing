//
//  SwingClient.m
//  Swing
//
//  Created by Mapple on 16/7/17.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SwingClient.h"

@interface SwingClient ()

@property (readwrite, nonatomic, strong) NSURLSessionConfiguration *config;

@end

@implementation SwingClient

+ (SwingClient *)sharedClient {
    static SwingClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:@"http://www.childrenLab.com/"];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//        [config setHTTPAdditionalHeaders:@{ @"User-Agent" : @"TuneStore iOS 1.0"}];
        
        if ([GlobalCache shareInstance].info.access_token.length > 0) {
            [config setHTTPAdditionalHeaders:@{@"x-auth-token":[GlobalCache shareInstance].info.access_token}];
        }
        
        config.timeoutIntervalForRequest = 30;//请求超时时间
        
        //设置缓存大小 其中内存缓存大小设置1M  磁盘缓存5M
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:1 * 1024 * 1024
                                                          diskCapacity:5 * 1024 * 1024
                                                              diskPath:nil];
        
        [config setURLCache:cache];
        
        _sharedClient = [[SwingClient alloc] initWithBaseURL:baseURL
                                         sessionConfiguration:config];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
        _sharedClient.config = config;
    });
    
    return _sharedClient;
}

- (void)logout {
    [self.config setHTTPAdditionalHeaders:nil];
}

- (NSError*)getErrorMessage:(NSDictionary*)response {
    if ([response[@"success"] boolValue]) {
        return nil;
    }
    NSString *msg = response[@"message"];
    if (msg == nil) {
        msg = @"Server unknown error.";
    }
    return [NSError errorWithDomain:@"SwingDomain" code:-1 userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
}

- (NSURLSessionDataTask *)userIsEmailRegistered:(NSString*)email completion:( void (^)(NSNumber *result, NSError *error) )completion {
    NSURLSessionDataTask *task = [self POST:@"/user/isEmailRegistered" parameters:@{@"email":email} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"isEmailRegistered info:%@", responseObject);
            completion([responseObject valueForKey:@"registered"], nil);
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)userLogin:(NSString*)email password:(NSString*)pwd completion:( void (^)(NSError *error) )completion {
    NSURLSessionDataTask *task = [self POST:@"/api/login" parameters:@{@"email":email, @"password":pwd} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"login info:%@", responseObject);
            NSError *err = nil;
            LoginedModel* model = [[LoginedModel alloc] initWithDictionary:responseObject error:&err];
            if (err) {
                completion(err);
            }
            else {
                UserModel *user = [[UserModel alloc] initWithDictionary:responseObject[@"user"] error:nil];
                if (user) {
                    [GlobalCache shareInstance].user = user;
                }
                
                [self.config setHTTPAdditionalHeaders:@{@"x-auth-token":model.access_token}];
                [GlobalCache shareInstance].info = model;
                completion(nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)userRegister:(NSDictionary*)data completion:( void (^)(id user, NSError *error) )completion {
    NSURLSessionDataTask *task = [self POST:@"/user/register" parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"registerUser info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(nil, err);
            }
            else {
                UserModel *model = [[UserModel alloc] initWithDictionary:responseObject[@"user"] error:nil];
                [GlobalCache shareInstance].user = model;
                completion(model, nil);
            }
            
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)userRetrieveProfileWithCompletion:( void (^)(id user, NSArray *kids, NSError *error) )completion {
    NSURLSessionDataTask *task = [self GET:@"/user/retrieveUserProfile" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"userRetrieveProfile info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(nil, nil, err);
            }
            else {
                UserModel *model = [[UserModel alloc] initWithDictionary:responseObject[@"user"] error:nil];
                NSArray *kids = [KidModel arrayOfModelsFromDictionaries:responseObject[@"kids"] error:nil];
                [GlobalCache shareInstance].kidsList = kids;
                [GlobalCache shareInstance].user = model;
                completion(model, kids, nil);
            }
            
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, nil, error);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)userUploadProfileImage:(UIImage*)image completion:( void (^)(NSString *profileImage, NSError *error) )completion {
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *content = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
//    NSLog(@"image:%@", content);
    NSURLSessionDataTask *task = [self POST:@"/avatar/uploadProfileImage" parameters:@{@"encodedImage":[@"data:image/png;base64," stringByAppendingString:content]} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"uploadProfileImage info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(nil, err);
            }
            else {
                [GlobalCache shareInstance].info.profileImage = responseObject[@"profileImage"];
                [[GlobalCache shareInstance] saveInfo];
                completion(responseObject[@"profileImage"], nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)userUpdateProfile:(NSDictionary*)data completion:( void (^)(id user, NSError *error) )completion {
    NSURLSessionDataTask *task = [self POST:@"/user/updateProfile" parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"updateProfile info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(nil, err);
            }
            else {
                UserModel *model = [[UserModel alloc] initWithDictionary:responseObject[@"user"] error:nil];
                [GlobalCache shareInstance].user = model;
                completion(model, nil);
            }
            
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)kidsAdd:(NSDictionary*)data completion:( void (^)(id kid, NSError *error) )completion {
    NSURLSessionDataTask *task = [self POST:@"/kids/add" parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"kidsAdd info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(nil, err);
            }
            else {
                KidModel *kid = [[KidModel alloc] initWithDictionary:responseObject[@"kid"] error:nil];
                completion(kid, nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)kidsRemove:(NSString*)kidid completion:( void (^)(NSError *error) )completion {
    NSURLSessionDataTask *task = [self POST:@"/kids/remove" parameters:@{@"kidId":kidid} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"kidsRemove info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(err);
            }
            else {
                completion(nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)kidsUploadKidsProfileImage:(UIImage*)image kidId:(NSString*)kidId completion:( void (^)(NSString *profileImage, NSError *error) )completion {
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *content = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    //    NSLog(@"image:%@", content);
    NSURLSessionDataTask *task = [self POST:@"/avatar/uploadKidsProfileImage" parameters:@{@"encodedImage":[@"data:image/png;base64," stringByAppendingString:content], @"kidId":kidId} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"uploadKidsProfileImage info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(nil, err);
            }
            else {
                completion(responseObject[@"profileImage"], nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)kidsListWithCompletion:( void (^)(NSArray *list, NSError *error) )completion {
    NSURLSessionDataTask *task = [self POST:@"/kids/list" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"kidsListWithCompletion info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(nil, err);
            }
            else {
                completion([KidModel arrayOfModelsFromDictionaries:responseObject[@"kids"] error:nil], nil);
            }
            
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)calendarAddEvent:(NSDictionary*)data completion:( void (^)(id event, NSError *error) )completion{
    NSURLSessionDataTask *task = [self POST:@"/calendarEvent/addEvent" parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"calendarAddEvent info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(nil, err);
            }
            else {
                EventModel *event = [[EventModel alloc] initWithDictionary:responseObject[@"newEvent"] error:&err];
                completion(event, nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)calendarAddTodo:(NSString*)eventId todoList:(NSString*)todoList completion:( void (^)(id event, NSArray* todoArray, NSError *error) )completion {
    NSURLSessionDataTask *task = [self POST:@"/calendarEvent/addTodo" parameters:@{@"eventId":eventId, @"todoList":todoList} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"calendarAddTodo info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(nil, nil, err);
            }
            else {
                EventModel *event = [[EventModel alloc] initWithDictionary:responseObject[@"event"] error:nil];
                NSArray *todoList = [ToDoModel arrayOfModelsFromDictionaries:responseObject[@"todo"] error:nil];
                completion(event, todoList, nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, nil, error);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)calendarTodoDone:(NSString*)todoId completion:( void (^)(NSError *error) )completion {
    NSURLSessionDataTask *task = [self POST:@"/calendarEvent/todoDone" parameters:@{@"todoId":todoId} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"calendarTodoDone info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(err);
            }
            else {
                completion(nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)calendarGetEvents:(NSDate*)date type:(GetEventType)type completion:( void (^)(NSArray* eventArray, NSError *error) )completion {
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *component = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    
    NSDictionary *data = @{@"query":type == GetEventTypeMonth ? @"month" : @"day", @"month":[NSString stringWithFormat:@"%ld",(long)[component month]], @"year":[NSString stringWithFormat:@"%ld",(long)[component year]], @"day":[NSString stringWithFormat:@"%ld",(long)[component day]]};
    
    NSURLSessionDataTask *task = [self POST:@"/calendarEvent/getEventsByUser" parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"getEventsByUser info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(nil, err);
            }
            else {
                NSArray *list = [EventModel arrayOfModelsFromDictionaries:responseObject[@"events"] error:nil];
                completion(list, nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)calendarDeleteEvent:(NSString*)eventId completion:( void (^)(NSError *error) )completion {
    NSURLSessionDataTask *task = [self POST:@"/calendarEvent/deleteEvent" parameters:@{@"id":eventId} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"calendarDeleteEvent info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(err);
            }
            else {
                completion(nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)deviceUploadRawData:(ActivityModel*)model completion:( void (^)(NSError *error) )completion {
    NSDictionary *data = [model toDictionary];
    LOG_D(@"deviceUploadRawData: %@", data);
    NSURLSessionDataTask *task = [self POST:@"/device/uploadRawData" parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"deviceUploadRawData info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(err);
            }
            else {
                completion(nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)deviceGetDailyActivity:(NSString*)macId completion:( void (^)(id dailyAct ,NSError *error) )completion {
    NSURLSessionDataTask *task = [self POST:@"/device/getDailyActivity" parameters:@{@"macId":macId} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"deviceUploadRawData info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(nil ,err);
            }
            else {
                completion(nil ,nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil ,error);
        });
    }];
    
    return task;
}

@end

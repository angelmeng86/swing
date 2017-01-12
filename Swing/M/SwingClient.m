//
//  SwingClient.m
//  Swing
//
//  Created by Mapple on 16/7/17.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SwingClient.h"


#define IS_V1       YES

@interface SwingClient ()

@property (readwrite, nonatomic, strong) NSURLSessionConfiguration *config;
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) AFHTTPRequestSerializer *httpSerializer;
@property (nonatomic, strong) SwingURL *URL;

@end

@implementation SwingClient

+ (SwingClient *)sharedClient {
    static SwingClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SwingClient alloc] init];
    });
    
    return _sharedClient;
}

- (id)init {
    if (self = [super init]) {
        _URL = [[SwingURL alloc] init];
    }
    return self;
}

- (AFHTTPRequestSerializer*)httpSerializer {
    if (_httpSerializer == nil) {
        _httpSerializer = [AFHTTPRequestSerializer serializer];
        if ([GlobalCache shareInstance].info.access_token.length > 0) {
            [_httpSerializer setValue:[GlobalCache shareInstance].info.access_token forHTTPHeaderField:@"x-auth-token"];
        }

    }
    return _httpSerializer;
}

- (AFHTTPSessionManager*)sessionManager {
    if (_sessionManager == nil) {
        NSURL *baseURL = [NSURL URLWithString:_URL.baseURL];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        //        [config setHTTPAdditionalHeaders:@{ @"User-Agent" : @"TuneStore iOS 1.0"}];
        
        if ([GlobalCache shareInstance].info.access_token.length > 0) {
            [config setHTTPAdditionalHeaders:@{@"x-auth-token":[GlobalCache shareInstance].info.access_token}];
            LOG_D(@"access_token:%@", [GlobalCache shareInstance].info.access_token);
        }
        
        config.timeoutIntervalForRequest = 30;//请求超时时间
        
        //设置缓存大小 其中内存缓存大小设置1M  磁盘缓存5M
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:1 * 1024 * 1024
                                                          diskCapacity:5 * 1024 * 1024
                                                              diskPath:nil];
        
        [config setURLCache:cache];
        
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL
                                        sessionConfiguration:config];
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        //去除DELETE，DELETE参数由URI变为BODY
//        _sessionManager.requestSerializer.HTTPMethodsEncodingParametersInURI =[NSSet setWithObjects:@"GET", @"HEAD", /*@"DELETE",*/ nil];
        
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
//        _sessionManager.responseSerializer.acceptableContentTypes = [_sessionManager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
        self.config = config;
    }
    return _sessionManager;
}

- (void)logout {
    [_sessionManager.operationQueue cancelAllOperations];
    _sessionManager = nil;
    _httpSerializer = nil;
}

- (NSError*)filterTokenInvalid:(NSURLResponse*)urlResponse err:(NSError*)error {
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)urlResponse;
    if(response.statusCode == 403) {
        [[GlobalCache shareInstance] logout];
        [SVProgressHUD showInfoWithStatus:@"Token invalid, please login again."];
    }
    else if(response.statusCode == 400) {
        NSData *data = [error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"];
        NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:data
                                                 options:kNilOptions
                                                   error:nil];
        LOG_D(@"HTTP:%@", obj);
        if ([obj objectForKey:@"message"]) {
            return [NSError errorWithDomain:@"SwingDomain" code:-2 userInfo:[NSDictionary dictionaryWithObject:[obj objectForKey:@"message"] forKey:NSLocalizedDescriptionKey]];
        }
    }
    else if(response.statusCode == 409 || response.statusCode == 500) {//json error
        NSData *data = [error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"];
        NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:data
                                                            options:kNilOptions
                                                              error:nil];
        LOG_D(@"HTTP2:%@", obj);
        if ([obj objectForKey:@"message"]) {
            return [NSError errorWithDomain:@"SwingDomain" code:-3 userInfo:[NSDictionary dictionaryWithObject:[obj objectForKey:@"message"] forKey:NSLocalizedDescriptionKey]];
        }
    }
    return error;
}

- (NSError*)getErrorMessage:(NSDictionary*)response {
    if (IS_V1) {
        //new api返回状态码200表示成功
        return nil;
    }
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
    NSURLSessionDataTask *task = [self.sessionManager GET:_URL.isEmailRegistered parameters:@{@"email":email} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"isEmailRegistered info:%@", responseObject);
            completion(@NO, nil);
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            if(response.statusCode == 409) {
                completion(@YES, nil);
            }
            else {
                completion(nil, error);
            }
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)userLogin:(NSString*)email password:(NSString*)pwd completion:( void (^)(NSError *error) )completion {
    NSURLSessionDataTask *task = [self.sessionManager POST:_URL.userLogin parameters:@{@"email":email, @"password":pwd} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"login info:%@", responseObject);
            NSError *err = nil;
            LoginedModel* model = [[LoginedModel alloc] initWithDictionary:responseObject error:&err];
            if (err) {
                completion(err);
            }
            else {
                [self.config setHTTPAdditionalHeaders:@{@"x-auth-token":model.access_token}];
                [_sessionManager.requestSerializer setValue:model.access_token forHTTPHeaderField:@"x-auth-token"];
                LOG_D(@"access_token:%@", model.access_token);
                [GlobalCache shareInstance].info = model;

                if (!IS_V1) {
                    UserModel *user = [[UserModel alloc] initWithDictionary:responseObject[@"user"] error:nil];
                    if (user) {
                        [GlobalCache shareInstance].user = user;
                    }
                }
                else {
                    [[GlobalCache shareInstance] queryProfile];
                }
                
                if ([GlobalCache shareInstance].token) {
                    [[SwingClient sharedClient] userUpdateIOSRegistrationId:[GlobalCache shareInstance].token completion:^(NSError *error) {
                        if (error) {
                            LOG_D(@"userUpdateIOSRegistrationId2 fail: %@", error);
                        }
                    }];
                }
                
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
    NSURLSessionDataTask *task = [self.sessionManager POST:_URL.userRegister parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"registerUser info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(nil, err);
            }
            else {
                UserModel *model = [[UserModel alloc] initWithDictionary:(IS_V1 ? data : responseObject[@"user"]) error:nil];
                [GlobalCache shareInstance].user = model;
                completion(model, nil);
            }
            
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *err = [self filterTokenInvalid:task.response err:error];
            completion(nil, err);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)userUpdateIOSRegistrationId:(NSString*)token completion:( void (^)(NSError *error) )completion {
    NSURLSessionDataTask *task = [self.sessionManager PUT:_URL.updateIOSRegistrationId parameters:@{@"registrationId":token} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"login updateIOSRegistrationId:%@", responseObject);
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

- (NSURLSessionDataTask *)userRetrieveProfileWithCompletion:( void (^)(id user, NSArray *kids, NSError *error) )completion {
    NSURLSessionDataTask *task = [self.sessionManager GET:_URL.retrieveUserProfile parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"userRetrieveProfile info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(nil, nil, err);
            }
            else {
                UserModel *model = [[UserModel alloc] initWithDictionary:responseObject[@"user"] error:nil];
                NSArray *kids = [KidModel arrayOfModelsFromDictionaries:responseObject[@"kids"] error:nil];
                for (KidModel *kid in kids) {
                    if (kid.macId.length > 0) {
                        //默认设置第一个Kid的设备为当前设备
                        [GlobalCache shareInstance].local.deviceMAC = [Fun hexToData:kid.macId];
                        break;
                    }
                }
                [GlobalCache shareInstance].kidsList = kids;
                [GlobalCache shareInstance].user = model;
                
                completion(model, kids, nil);
            }
            
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *err = [self filterTokenInvalid:task.response err:error];
            completion(nil, nil, err);
            
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)userUploadProfileImage:(UIImage*)image completion:( void (^)(NSString *profileImage, NSError *error) )completion {
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    if(IS_V1) {
        NSMutableURLRequest *request = [[self httpSerializer] multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:_URL.uploadProfileImage relativeToURL:self.sessionManager.baseURL] absoluteString] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imageData name:@"upload" fileName:@"avatar.jpg" mimeType:@"image/jpg"];
        } error:nil];
        NSURLSessionDataTask *task = [self.sessionManager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    NSError *err = [self filterTokenInvalid:response err:error];
                    completion(nil, err);
                }
                else {
                    LOG_D(@"uploadProfileImage info:%@", responseObject);
                    NSError *err = [self getErrorMessage:responseObject];
                    if (err) {
                        completion(nil, err);
                    }
                    else {
                        UserModel *model = [[UserModel alloc] initWithDictionary:responseObject[@"user"] error:nil];
//                        if ([GlobalCache shareInstance].user) {
//                            [GlobalCache shareInstance].user.profile = model.profile;
//                        }
//                        else {
                            [GlobalCache shareInstance].user = model;
//                        }
                        
                        //判断缓存中是否存在同名图片，需要清空该图片缓存保证加载最新
                        NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:[GlobalCache shareInstance].user.profile]]];
                        if (key) {
                            [[SDWebImageManager sharedManager].imageCache removeImageForKey:key];
                        }
                        
                        completion(model.profile, nil);
                    }
                }
            });
        }];
        [task resume];
        return task;
    }
    
    NSString *content = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
//    NSLog(@"image:%@", content);
    NSURLSessionDataTask *task = [self.sessionManager POST:_URL.uploadProfileImage parameters:@{@"encodedImage":[@"data:image/jpg;base64," stringByAppendingString:content]} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"uploadProfileImage info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(nil, err);
            }
            else {
                [GlobalCache shareInstance].user.profile = responseObject[@"profileImage"];
                [[GlobalCache shareInstance] saveInfo];
                completion(responseObject[@"profileImage"], nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *err = [self filterTokenInvalid:task.response err:error];
            completion(nil, err);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)userUpdateProfile:(NSDictionary*)data completion:( void (^)(id user, NSError *error) )completion {
    if (IS_V1) {
        NSURLSessionDataTask *task = [self.sessionManager PUT:_URL.updateProfile parameters:data success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
                NSError *err = [self filterTokenInvalid:task.response err:error];
                completion(nil, err);
            });
        }];
        
        return task;
    }
    NSURLSessionDataTask *task = [self.sessionManager POST:_URL.updateProfile parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
            NSError *err = [self filterTokenInvalid:task.response err:error];
            completion(nil, err);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)kidsAdd:(NSDictionary*)data completion:( void (^)(id kid, NSError *error) )completion {
    NSURLSessionDataTask *task = [self.sessionManager POST:_URL.kidsAdd parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
            NSError *err = [self filterTokenInvalid:task.response err:error];
            completion(nil, err);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)kidsRemove:(NSString*)kidid completion:( void (^)(NSError *error) )completion {
    NSURLSessionDataTask *task = [self.sessionManager POST:_URL.kidsRemove parameters:@{@"kidId":kidid} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
            NSError *err = [self filterTokenInvalid:task.response err:error];
            completion(err);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)kidsUploadKidsProfileImage:(UIImage*)image kidId:(int64_t)kidId completion:( void (^)(NSString *profileImage, NSError *error) )completion {
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    NSMutableURLRequest *request = [[self httpSerializer] multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:_URL.uploadKidsProfileImage relativeToURL:self.sessionManager.baseURL] absoluteString] parameters:@{@"kidId":@(kidId)} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"upload" fileName:@"avatar.jpg" mimeType:@"image/jpg"];
    } error:nil];
    NSURLSessionDataTask *task = [self.sessionManager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSError *err = [self filterTokenInvalid:response err:error];
                completion(nil, err);
            }
            else {
                LOG_D(@"uploadKidsProfileImage info:%@", responseObject);
                NSError *err = [self getErrorMessage:responseObject];
                if (err) {
                    completion(nil, err);
                }
                else {
                    KidModel *model = [[KidModel alloc] initWithDictionary:responseObject[@"kid"] error:nil];
                    
                    //判断缓存中是否存在同名图片，需要清空该图片缓存保证加载最新
                    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:model.profile]]];
                    if (key) {
                        [[SDWebImageManager sharedManager].imageCache removeImageForKey:key];
                    }
                    
                    completion(model.profile, nil);
                }
            }
        });
    }];
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)kidsListWithCompletion:( void (^)(NSArray *list, NSError *error) )completion {
    NSURLSessionDataTask *task = [self.sessionManager POST:_URL.kidsList parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
            NSError *err = [self filterTokenInvalid:task.response err:error];
            completion(nil, err);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)calendarAddEvent:(NSDictionary*)data completion:( void (^)(id event, NSError *error) )completion{
    LOG_D(@"calendarAddEvent data:%@", data);
    NSURLSessionDataTask *task = [self.sessionManager POST:_URL.addEvent parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"calendarAddEvent info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(nil, err);
            }
            else {
                EventModel *event = [[EventModel alloc] initWithDictionary:responseObject[IS_V1 ? @"event" : @"newEvent"] error:&err];
                [DBHelper addEvent:event];
                completion(event, nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSData *oye = task.originalRequest.HTTPBody;
//            NSString *oye2 = [[NSString alloc] initWithData:oye encoding:NSUTF8StringEncoding];
//            LOG_D(@"oye2:%@", oye2);
            NSError *err = [self filterTokenInvalid:task.response err:error];
            completion(nil, err);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)calendarEditEvent:(NSDictionary*)data completion:( void (^)(id event, NSError *error) )completion {
    LOG_D(@"data:%@", data);
    if (IS_V1) {
        NSURLSessionDataTask *task = [self.sessionManager PUT:_URL.editEventWithTodo parameters:data success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                LOG_D(@"calendarEditEvent info:%@", responseObject);
                NSError *err = [self getErrorMessage:responseObject];
                if (err) {
                    completion(nil, err);
                }
                else {
                    EventModel *event = [[EventModel alloc] initWithDictionary:responseObject[@"event"] error:&err];
                    [DBHelper addEvent:event];
                    completion(event, nil);
                }
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *err = [self filterTokenInvalid:task.response err:error];
                completion(nil, err);
            });
        }];
        
        return task;
    }
    
    NSURLSessionDataTask *task = [self.sessionManager POST:_URL.editEventWithTodo parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"calendarEditEvent info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(nil, err);
            }
            else {
                EventModel *event = [[EventModel alloc] initWithDictionary:responseObject[@"event"] error:&err];
                completion(event, nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *err = [self filterTokenInvalid:task.response err:error];
           completion(nil, err);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)calendarAddTodo:(int64_t)eventId todoList:(NSString*)todoList completion:( void (^)(id event, NSArray* todoArray, NSError *error) )completion {
    LOG_D(@"eventId:%lld todoList:%@", eventId, todoList);
    NSURLSessionDataTask *task = [self.sessionManager POST:_URL.addTodo parameters:@{@"eventId":@(eventId), @"todoList":todoList} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"calendarAddTodo info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(nil, nil, err);
            }
            else {
                EventModel *event = [[EventModel alloc] initWithDictionary:responseObject[@"event"] error:nil];
                [DBHelper addEvent:event];
                NSArray *todoList = [ToDoModel arrayOfModelsFromDictionaries:responseObject[@"todo"] error:nil];
                completion(event, todoList, nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *err = [self filterTokenInvalid:task.response err:error];
            completion(nil, nil, err);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)calendarTodoDone:(int64_t)todoId eventId:(int64_t)eventId completion:( void (^)(NSError *error) )completion {
    NSURLSessionDataTask *task = [self.sessionManager PUT:_URL.todoDone parameters:@{@"todoId":@(todoId), @"eventId":@(eventId)} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
            NSError *err = [self filterTokenInvalid:task.response err:error];
            completion(err);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)calendarTodoDelete:(NSString*)eventId todoId:(NSString*)todoId completion:( void (^)(NSError *error) )completion {
    NSURLSessionDataTask *task = [self.sessionManager POST:_URL.deleteTodo parameters:@{@"eventId":todoId, @"todoId":todoId} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"calendarTodoDelete info:%@", responseObject);
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
            NSError *err = [self filterTokenInvalid:task.response err:error];
            completion(err);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)calendarGetEvents:(NSDate*)date type:(GetEventType)type completion:( void (^)(NSArray* eventArray, NSError *error) )completion {
    
    if (IS_V1) {
        static NSDateFormatter *df = nil;
        if (df == nil) {
            df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        }
        NSDictionary *data = @{@"period":type == GetEventTypeMonth ? @"MONTH" : @"DAY", @"date":[df stringFromDate:date]};
        LOG_D(@"calendarGetEvents data:%@", data);
//        NSString *urlEncode = [NSString stringWithFormat:@"%@?period=%@&date=%@", _URL.getEventsByUser, type == GetEventTypeMonth ? @"MONTH" : @"DAY", [df stringFromDate:date]];
        NSURLSessionDataTask *task = [self.sessionManager GET:_URL.getEventsByUser parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                LOG_D(@"getEventsByUser info:%@", responseObject);
                NSError *err = [self getErrorMessage:responseObject];
                if (err) {
                    completion(nil, err);
                }
                else {
                    NSArray *list = [EventModel arrayOfModelsFromDictionaries:responseObject[@"events"] error:nil];
                    
                    [DBHelper addEvents:list];
                    
                    completion(list, nil);
                }
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *err = [self filterTokenInvalid:task.response err:error];
                completion(nil, err);
            });
        }];
        
        return task;
    }
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *component = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSDictionary *data = @{@"query":type == GetEventTypeMonth ? @"month" : @"day", @"month":[NSString stringWithFormat:@"%ld",(long)[component month]], @"year":[NSString stringWithFormat:@"%ld",(long)[component year]], @"day":[NSString stringWithFormat:@"%ld",(long)[component day]]};
    
    LOG_D(@"calendarGetEvents data:%@", data);
    NSURLSessionDataTask *task = [self.sessionManager POST:_URL.getEventsByUser parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"getEventsByUser info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(nil, err);
            }
            else {
                NSArray *list = [EventModel arrayOfModelsFromDictionaries:responseObject[@"events"] error:nil];
                
                [DBHelper addEvents:list];
                
                completion(list, nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *err = [self filterTokenInvalid:task.response err:error];
            completion(nil, err);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)calendarGetAllEventsWithCompletion:( void (^)(NSArray* eventArray, NSError *error) )completion {
    if (!IS_V1) {
        return nil;
    }
    NSURLSessionDataTask *task = [self.sessionManager GET:_URL.retrieveAllEventsWithTodo parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"getAllEvents info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(nil, err);
            }
            else {
                NSArray *list = [EventModel arrayOfModelsFromDictionaries:responseObject[@"events"] error:nil];
                
                [DBHelper addEvents:list];
                
                completion(list, nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *err = [self filterTokenInvalid:task.response err:error];
            completion(nil, err);
        });
    }];
    return task;
}

- (NSURLSessionDataTask *)calendarDeleteEvent:(int64_t)eventId completion:( void (^)(NSError *error) )completion {
    NSURLSessionDataTask *task = [self.sessionManager DELETE:_URL.deleteEvent parameters:@{@"eventId":@(eventId)} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"calendarDeleteEvent info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(err);
            }
            else {
                [DBHelper delEvent:eventId];
                completion(nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSData *oye = task.originalRequest.HTTPBody;
//            NSString *oye2 = [[NSString alloc] initWithData:oye encoding:NSUTF8StringEncoding];
//            LOG_D(@"oye2:%@", oye2);
            NSError *err = [self filterTokenInvalid:task.response err:error];
            completion(err);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)deviceUploadRawData:(ActivityModel*)model completion:( void (^)(NSError *error) )completion {
    NSDictionary *data = [model toDictionaryWithKeys:@[@"indoorActivity",@"outdoorActivity",@"time",@"macId"]];
    LOG_D(@"deviceUploadRawData: %@", data);
    NSURLSessionDataTask *task = [self.sessionManager POST:_URL.uploadRawData parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
            NSError *err = [self filterTokenInvalid:task.response err:error];
            completion(err);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)deviceGetActivity:(NSString*)macId type:(GetActivityType)type completion:( void (^)(id dailyActs ,NSError *error) )completion {
    NSString *period = @"DAILY";
    NSString *url = _URL.getDailyActivity;
    switch (type) {
        case GetActivityTypeYear:
            url = _URL.getYearlyActivity;
            period = @"YEARLY";
            break;
        case GetActivityTypeMonth:
            url = _URL.getMonthlyActivity;
            period = @"MONTHLY";
            break;
        case GetActivityTypeWeekly:
            url = _URL.getWeeklyActivity;
            period = @"WEEKLY";
            break;
        default:
            break;
    }
    LOG_D(@"macId:%@", macId);
    if (IS_V1) {
        //new api macId change to kidId ?
        NSString *urlEncode = [NSString stringWithFormat:@"%@?kidId=%@&period=%@", _URL.getDailyActivity, macId, period];
        NSURLSessionDataTask *task = [self.sessionManager GET:urlEncode parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                LOG_D(@"deviceGetActivity info:%@", responseObject);
                NSError *err = [self getErrorMessage:responseObject];
                if (err) {
                    completion(nil ,err);
                }
                else {
                    NSArray *list = [ActivityResultModel arrayOfModelsFromDictionaries:responseObject[@"activity"] error:nil];
                    if (IS_V1) {
                        for (ActivityResultModel *m in list) {
                            [m transDate];
                        }
                    }
                    completion(list, nil);
                }
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *err = [self filterTokenInvalid:task.response err:error];
                completion(nil ,err);
            });
        }];
        return task;
    }
    NSURLSessionDataTask *task = [self.sessionManager POST:url parameters:@{@"macId":macId} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"deviceGetActivity info:%@", responseObject);
            NSError *err = [self getErrorMessage:responseObject];
            if (err) {
                completion(nil ,err);
            }
            else {
                NSArray *list = [ActivityResultModel arrayOfModelsFromDictionaries:responseObject[@"activity"] error:nil];
                completion(list, nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *err = [self filterTokenInvalid:task.response err:error];
            completion(nil ,err);
        });
    }];
    
    return task;
}

@end

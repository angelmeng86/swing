//
//  SwingClient.m
//  Swing
//
//  Created by Mapple on 16/7/17.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SwingClient.h"
#import "CommonDef.h"

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

- (NSURLSessionDataTask *)isEmailRegistered:(NSString*)email completion:( void (^)(NSNumber *result, NSError *error) )completion {
    NSURLSessionDataTask *task = [self POST:@"/user/isEmailRegistered" parameters:@{@"email":email} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([responseObject valueForKey:@"registered"], nil);
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)login:(NSString*)email password:(NSString*)pwd completion:( void (^)(NSNumber *result, NSError *error) )completion {
    NSURLSessionDataTask *task = [self POST:@"/api/login" parameters:@{@"email":email, @"password":pwd} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LoginedModel* model = [[LoginedModel alloc] initWithDictionary:responseObject error:nil];
            [GlobalCache shareInstance].info = model;
            LOG_D(@"login info:%@", responseObject);
            
            [self.config setHTTPAdditionalHeaders:@{@"x-auth-token":model.access_token}];
            
            completion([NSNumber numberWithBool:YES], nil);
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }];
    
    return task;
}

@end

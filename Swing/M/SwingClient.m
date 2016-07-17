//
//  SwingClient.m
//  Swing
//
//  Created by 刘武忠 on 16/7/17.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SwingClient.h"

@implementation SwingClient

+ (SwingClient *)sharedClient {
    static SwingClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:@"http://www.childrenLab.com/"];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//        [config setHTTPAdditionalHeaders:@{ @"User-Agent" : @"TuneStore iOS 1.0"}];
        
        //设置我们的缓存大小 其中内存缓存大小设置1M  磁盘缓存5M
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:1 * 1024 * 1024
                                                          diskCapacity:5 * 1024 * 1024
                                                              diskPath:nil];
        
        [config setURLCache:cache];
        
        _sharedClient = [[SwingClient alloc] initWithBaseURL:baseURL
                                         sessionConfiguration:config];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
    });
    
    return _sharedClient;
}

- (NSURLSessionDataTask *)isEmailRegistered:(id)parameters completion:( void (^)(NSNumber *result, NSError *error) )completion {
    NSURLSessionDataTask *task = [self POST:@"/user/isEmailRegistered" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

- (NSURLSessionDataTask *)searchForTerm:(NSString *)term completion:( void (^)(NSArray *results, NSError *error) )completion {
    NSURLSessionDataTask *task = [self GET:@"/search"
                                  //为了速度我们将地区设置为台湾
                                  
                                parameters:@{ @"country" : @"TW",
                                              @"term" : term }
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                                       if (httpResponse.statusCode == 200) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               completion(responseObject[@"results"], nil);
                                           });
                                       } else {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               completion(nil, nil);
                                           });
                                           NSLog(@"Received: %@", responseObject);
                                           NSLog(@"Received HTTP %d", httpResponse.statusCode);
                                       }
                                       
                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           completion(nil, error);
                                       });
                                   }];
    return task;
}

@end

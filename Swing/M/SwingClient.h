//
//  SwingClient.h
//  Swing
//
//  Created by 刘武忠 on 16/7/17.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface SwingClient : AFHTTPSessionManager

+ (SwingClient *)sharedClient;
- (NSURLSessionDataTask *)searchForTerm:(NSString *)term completion:( void (^)(NSArray *results, NSError *error) )completion;

- (NSURLSessionDataTask *)isEmailRegistered:(id)parameters completion:( void (^)(NSNumber *result, NSError *error) ) completion;

@end

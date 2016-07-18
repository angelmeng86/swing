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

- (NSURLSessionDataTask *)isEmailRegistered:(NSString*)email completion:( void (^)(NSNumber *result, NSError *error) ) completion;

- (NSURLSessionDataTask *)login:(NSString*)email password:(NSString*)pwd completion:( void (^)(NSNumber *result, NSError *error) )completion;

@end

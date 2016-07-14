//
//  Fun.h
//
//  Created by Mapple on 12-5-23.
//  Copyright (c) 2012年 Triggeronce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Fun : NSObject

+ (void)showMessageBoxWithTitle:(NSString*)title andMessage:(NSString*)msg;

+ (void)showMessageBoxWithTitle:(NSString*)title andMessage:(NSString*)msg delegate:(id)delegate;

+ (void)showMessageBox:(NSString*)title andFormat:(NSString*)format, ...;

+ (void)log:(NSString*)info;

+ (void)logInfo:(NSString *)format, ...;

+ (NSString*)getLogInfo;

+ (void)showLog;

//利用正则表达式验证
+ (BOOL)isValidateEmail:(NSString *)email;

+ (NSString*)getTimeString:(NSDate*)updatedAt;

@end

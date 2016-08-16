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

+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage maxWidth:(CGFloat)maxWidth;

+ (NSDate*)dateFromString:(NSString*)str;
+ (NSString*)dateToString:(NSDate*)date;

+ (UIColor*)colorFromNSString:(NSString *)string;
+ (NSString*)stringFromColor:(UIColor*)color;

+ (NSData*)longToByteArray:(long)data;
+ (long)byteArrayToLong:(NSData*)data;
+ (long)byteArrayToLong:(NSData*)data length:(int)len;
+ (long)byteArrayToLong:(NSData*)data pos:(int)pos length:(int)len;

+ (NSString*)dataToHex:(NSData*)data;
+ (NSData*)hexToData:(NSString*)data;

@end

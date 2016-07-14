//
//  Fun.m
//
//  Created by Mapple on 12-5-23.
//  Copyright (c) 2012年 Triggeronce. All rights reserved.
//

#import "Fun.h"
#import "CommonDef.h"

@implementation Fun

+ (void)showMessageBoxWithTitle:(NSString*)title andMessage:(NSString*)msg
{
	UIAlertView *alertView = [[UIAlertView alloc]
							  initWithTitle:title
							  message:msg
							  delegate:self 
							  cancelButtonTitle:NSLocalizedString(@"Ok", nil)
							  otherButtonTitles:nil];
	[alertView show];
}

+ (void)showMessageBoxWithTitle:(NSString*)title andMessage:(NSString*)msg delegate:(id)delegate
{
	UIAlertView *alertView = [[UIAlertView alloc]
                                initWithTitle:title
                                message:msg
                                delegate:delegate
                                cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                otherButtonTitles:nil];
	[alertView show];
}

+ (void)showMessageBox:(NSString*)title andFormat:(NSString*)format, ...
{
    va_list argList;  
    if(format)  
    {  
        va_start(argList, format);
        NSString *content = [[NSString alloc] initWithFormat:format arguments:argList];
        va_end(argList);  
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:title
                                  message:content
                                  delegate:nil 
                                  cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                  otherButtonTitles:nil];
        [alertView show];
    }  
    
}

+ (void)log:(NSString*)info
{
    NSArray *pathsToDocuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [pathsToDocuments objectAtIndex:0];
    NSString *logName = [documentsDirectory stringByAppendingPathComponent:@"log.txt"];
    NSError *err;
    NSMutableString *text = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:logName]) 
    {
        NSStringEncoding enc = NSUTF8StringEncoding;
        text = [NSMutableString stringWithContentsOfFile:logName usedEncoding:&enc error:&err];
    }
    else {
        text = [NSMutableString stringWithCapacity:256];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss SSS"];
    [text appendFormat:@"Log:%@\n%@\n", [formatter stringFromDate:[NSDate date]], info];
    [text writeToFile:logName atomically:YES encoding:NSUTF8StringEncoding error:&err];
}

+ (void)logInfo:(NSString *)format, ...
{
    va_list argList;  
    if(format)  
    {  
        va_start(argList, format);  
        NSString *info = [[NSString alloc] initWithFormat:format arguments:argList];
        va_end(argList);  
        [Fun log:info];
    }   
    
}

+ (NSString*)getLogInfo
{
    NSArray *pathsToDocuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [pathsToDocuments objectAtIndex:0];
    NSString *logName = [documentsDirectory stringByAppendingPathComponent:@"log.txt"];
    NSError *err;
    NSStringEncoding enc = NSUTF8StringEncoding;
    return [NSString stringWithContentsOfFile:logName usedEncoding:&enc error:&err];
}

+ (void)showLog
{
    [Fun showMessageBoxWithTitle:@"日志" andMessage:[Fun getLogInfo]];
}

//利用正则表达式验证
+ (BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (NSString*)getTimeString:(NSDate*)updatedAt
{
    //    NSTimeInterval aTimer = [[NSDate date] timeIntervalSinceDate:updatedAt];
    //    int days = (int)aTimer/(3600*24);
    //    int hour = (int)(aTimer/3600);
    //    int minute = (int)(aTimer - hour*3600)/60;
    //    if (updatedAt == nil) {
    //        LOG_D(@"updatedAt is nil");
    //        updatedAt = [NSDate date];
    //    }
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:updatedAt toDate:[NSDate date] options:NSCalendarWrapComponents];
    if (components.year > 0) {
        return [NSString stringWithFormat:@"%ld year ago", (long)components.year];
    }
    else if(components.month > 0) {
        return [NSString stringWithFormat:@"%ld month ago", (long)components.month];
    }
    else if(components.day > 0) {
        return [NSString stringWithFormat:@"%ld day ago", (long)components.day];
    }
    else if(components.hour > 0) {
        return [NSString stringWithFormat:@"%ld hour ago", (long)components.hour];
    }
    else {
        return [NSString stringWithFormat:@"%ld min ago", components.minute == 0 ? 1 : (long)components.minute];
    }
}

@end

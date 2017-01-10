//
//  JSONValueTransformer+NSDate.m
//  Swing
//
//  Created by Mapple on 16/8/5.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "JSONValueTransformer+NSDate.h"
#import "CommonDef.h"

@implementation JSONValueTransformer (NSDate)

- (NSDateFormatter*)dateFormatter1
{
    static dispatch_once_t onceInput;
    static NSDateFormatter* inputDateFormatter;
    dispatch_once(&onceInput, ^{
        inputDateFormatter = [[NSDateFormatter alloc] init];
//        [inputDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        if (IS_SWING_V1) {
            [inputDateFormatter setDateFormat:@"yyyy/MM/dd'T'HH:mm:ss'Z'"];
        }
        else {
            [inputDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        }
        
    });
    return inputDateFormatter;
}

- (NSDateFormatter*)dateFormatter2
{
    static dispatch_once_t onceInput;
    static NSDateFormatter* inputDateFormatter;
    dispatch_once(&onceInput, ^{
        inputDateFormatter = [[NSDateFormatter alloc] init];
        //        [inputDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [inputDateFormatter setDateFormat:@"yyyy-MM-dd"];
    });
    return inputDateFormatter;
}

- (NSDate*)NSDateFromNSString:(NSString*)string {
    NSDate *date = [self.dateFormatter1 dateFromString:string];
    if (date == nil) {
        date = [self.dateFormatter2 dateFromString:string];
    }
    return date;
}

- (NSString*)JSONObjectFromNSDate:(NSDate*)date {
    return [self.dateFormatter1 stringFromDate:date];
}

@end

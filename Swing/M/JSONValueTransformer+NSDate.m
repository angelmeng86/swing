//
//  JSONValueTransformer+NSDate.m
//  Swing
//
//  Created by Mapple on 16/8/5.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "JSONValueTransformer+NSDate.h"

@implementation JSONValueTransformer (NSDate)

- (NSDateFormatter*)mappleDateFormatter
{
    static dispatch_once_t onceInput;
    static NSDateFormatter* inputDateFormatter;
    dispatch_once(&onceInput, ^{
        inputDateFormatter = [[NSDateFormatter alloc] init];
//        [inputDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [inputDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    });
    return inputDateFormatter;
}

- (NSDate*)NSDateFromNSString:(NSString*)string {
    return [self.mappleDateFormatter dateFromString: string];
}

- (NSString*)JSONObjectFromNSDate:(NSDate*)date {
    return [self.mappleDateFormatter stringFromDate:date];
}

@end

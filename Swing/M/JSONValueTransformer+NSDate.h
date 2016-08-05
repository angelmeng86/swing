//
//  JSONValueTransformer+NSDate.h
//  Swing
//
//  Created by Mapple on 16/8/5.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "JSONValueTransformer.h"

@interface JSONValueTransformer (NSDate)

- (NSDate*)NSDateFromNSString:(NSString*)string;
- (NSString*)JSONObjectFromNSDate:(NSDate*)date;

@end

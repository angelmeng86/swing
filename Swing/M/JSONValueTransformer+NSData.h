//
//  JSONValueTransformer+NSData.h
//  Swing
//
//  Created by Mapple on 16/8/26.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONValueTransformer.h"

@interface JSONValueTransformer (NSData)

- (NSData*)NSDataFromNSString:(NSString*)string;
- (NSString*)JSONObjectFromNSData:(NSData*)data;

@end

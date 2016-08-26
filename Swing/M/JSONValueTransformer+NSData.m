//
//  JSONValueTransformer+NSData.m
//  Swing
//
//  Created by Mapple on 16/8/26.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "JSONValueTransformer+NSData.h"

@implementation JSONValueTransformer (NSData)

- (NSData*)NSDataFromNSString:(NSString*)string {
    return [[NSData alloc] initWithBase64EncodedString:string options:0];
}

- (NSString*)JSONObjectFromNSData:(NSData*)data {
    return [data base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
}

@end

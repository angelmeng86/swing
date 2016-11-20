//
//  ColorTransformer.m
//  Swing
//
//  Created by Mapple on 2016/11/19.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "ColorTransformer.h"
#import "JSONValueTransformer+UIColor.h"

@implementation ColorTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (nullable id)transformedValue:(nullable id)value {
    UIColor *color = (UIColor*)value;
    return [NSString stringWithFormat:@"#%02X%02X%02X", (int)((CGColorGetComponents(color.CGColor))[0]*255.0), (int)((CGColorGetComponents(color.CGColor))[1]*255.0), (int)((CGColorGetComponents(color.CGColor))[2]*255.0)];
}

- (nullable id)reverseTransformedValue:(nullable id)value {
    NSString *string = (NSString*)value;
    NSString *noHashString = [string stringByReplacingOccurrencesOfString:@"#" withString:@""]; // remove the #
    NSScanner *scanner = [NSScanner scannerWithString:noHashString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]]; // remove + and $
    
    unsigned hex;
    if (![scanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
#else
    return [NSColor colorWithCalibratedRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
#endif
}

@end

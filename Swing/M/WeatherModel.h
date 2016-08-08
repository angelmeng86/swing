//
//  UVIndexModel.h
//  Swing
//
//  Created by Mapple on 16/8/5.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WeatherModel : NSObject

+ (void)weatherQuery:(NSString*)lat lon:(NSString*)lon completion:( void (^)(id weather, NSError *error) )completion;

@property (nonatomic) int uvi;
@property (nonatomic, strong) NSNumber* temp_c;
@property (nonatomic, strong) NSNumber* temp_f;
@property (nonatomic, strong) NSString* relative_humidity;
@property (nonatomic, strong) NSString* state;
@property (nonatomic, strong) NSString* city;

- (UIColor*)color;
- (NSString*)desc;
- (NSString*)recommend;

@end

//
//  UVIndexModel.m
//  Swing
//
//  Created by Mapple on 16/8/5.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "WeartherModel.h"
#import "CommonDef.h"

@implementation WeartherModel

+ (void)weatherQuery:(NSString*)lat lon:(NSString*)lon completion:( void (^)(id weather, NSError *error) )completion {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString *url = [NSString stringWithFormat:@"http://api.wunderground.com/api/4e52e4fac905f5f7/geolookup/q/%@,%@.json", lat, lon];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_D(@"geolookup info:%@", responseObject);
            NSString *state = responseObject[@"location"][@"state"];
            NSString *city = responseObject[@"location"][@"city"];
            if (state && city) {
                NSString *url2 = [NSString stringWithFormat:@"http://api.wunderground.com/api/4e52e4fac905f5f7/conditions/q/%@/%@.json", state, [city stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
                [manager GET:url2 parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        LOG_D(@"conditions info:%@", responseObject);
                        NSString *uv = responseObject[@"current_observation"][@"UV"];
                        NSString *temp_c = responseObject[@"current_observation"][@"temp_c"];
                        NSString *relative_humidity = responseObject[@"current_observation"][@"relative_humidity"];
                        if (uv && temp_c && relative_humidity) {
                            WeartherModel *model = [WeartherModel new];
                            model.uvi = [uv intValue];
                            model.temp_c = temp_c;
                            model.relative_humidity = relative_humidity;
                            completion(model, nil);
                        }
                        else {
                            NSError* err = [NSError errorWithDomain:@"SwingDomain" code:-2 userInfo:[NSDictionary dictionaryWithObject:@"can't find." forKey:NSLocalizedDescriptionKey]];
                            completion(nil, err);
                        }
                    });
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil, error);
                    });
                }];
            }
            else {
                NSError* err = [NSError errorWithDomain:@"SwingDomain" code:-2 userInfo:[NSDictionary dictionaryWithObject:@"can't find." forKey:NSLocalizedDescriptionKey]];
                completion(nil, err);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }];
}

- (UIColor*)colorFromNSString:(NSString *)string
{
    //
    // http://stackoverflow.com/a/13648705
    //
    
    NSString *noHashString = [string stringByReplacingOccurrencesOfString:@"#" withString:@""]; // remove the #
    NSScanner *scanner = [NSScanner scannerWithString:noHashString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]]; // remove + and $
    
    unsigned hex;
    if (![scanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return RGBA(r, g, b, 1.0f);
}

- (UIColor*)color {
    static NSArray *array = nil;
    if (array == nil) {
        array = @[
//                  [self colorFromNSString:@"#4eb400"],
                  RGBA(0x4e, 0xb4, 0x00, 1.0f),
//                  [self colorFromNSString:@"#a0ce00"],
                  RGBA(0xa0, 0xce, 0x00, 1.0f),
//                  [self colorFromNSString:@"#f7e400"],
                  RGBA(0xf7, 0xe4, 0x00, 1.0f),
//                  [self colorFromNSString:@"#f8b600"],
                  RGBA(0xf8, 0xb6, 0x00, 1.0f),
//                  [self colorFromNSString:@"#f88700"],
                  RGBA(0xf8, 0x87, 0x00, 1.0f),
//                  [self colorFromNSString:@"#f85900"],
                  RGBA(0xf8, 0x59, 0x00, 1.0f),
//                  [self colorFromNSString:@"#e82c0e"],
                  RGBA(0xe8, 0x2c, 0x0e, 1.0f),
//                  [self colorFromNSString:@"#d8001d"],
                  RGBA(0xd8, 0x00, 0x1d, 1.0f),
//                  [self colorFromNSString:@"#ff0099"],
                  RGBA(0xff, 0x00, 0x99, 1.0f),
//                  [self colorFromNSString:@"#b54cff"],
                  RGBA(0xb5, 0x4c, 0xff, 1.0f),
//                  [self colorFromNSString:@"#998cff"]
                  RGBA(0x99, 0x8c, 0xff, 1.0f)
                  ];
    }
    int index = _uvi;
    if (index < 1) {
        index = 1;
    }
    else if (index > 1){
        index = 11;
    }
    
    return [array objectAtIndex:index - 1];
}

- (NSString*)desc {
    return nil;
}

- (NSString*)recommend {
    static NSArray *array = nil;
    if (array == nil) {
        array = @[
                  @"Wearing a Hat and/or Sunglasses is Sufficient.",
                  @"Wear a Hat and Sunglasses. Use SPF 15+ Sunscreen.",
                  @"Wear a Hat and Sunglasses. Use SPF 30+ Sunscreen. Cover the Body With Clothing Avoid the Sun if Possible.",
                  @"Take All Precautions Possible. It is Advised to Stay Indoors."
                  ];
    }
    int index = _uvi;
    if (index <= 2) {
        index = 0;
    }
    else if(index >=3 && index <= 5) {
        index = 1;
    }
    else if(index >=6 && index <= 10) {
        index = 2;
    }
    else {
        index = 3;
    }
    
    return [array objectAtIndex:index];
}

@end

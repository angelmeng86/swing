//
//  UVIndexModel.h
//  Swing
//
//  Created by Mapple on 16/8/5.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WeartherModel : NSObject

+ (void)weatherQuery:(NSString*)lat lon:(NSString*)lon completion:( void (^)(id weather, NSError *error) )completion;

@property (nonatomic) int uvi;
@property (nonatomic, strong) NSString* temp_c;
@property (nonatomic, strong) NSString* relative_humidity;

- (UIColor*)color;
- (NSString*)desc;
- (NSString*)recommend;

@end

//
//  ActivityModel.h
//  Swing
//
//  Created by Mapple on 16/8/16.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface ActivityModel : JSONModel

@property (nonatomic, strong) NSString *indoorActivity;
@property (nonatomic, strong) NSString *outdoorActivity;
@property (nonatomic) long time;
@property (nonatomic, strong) NSString *macId;

- (void)setIndoorData:(NSData*)data;
- (void)setOutdoorData:(NSData*)data;

- (void)reset;

@end

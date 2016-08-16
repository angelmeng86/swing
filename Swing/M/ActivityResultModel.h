//
//  ActivityResultModel.h
//  Swing
//
//  Created by Mapple on 16/8/16.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "JSONModel.h"

@interface ActivityResultModel : JSONModel
/*
"id": 18,
"steps": 400,
"type": "OUTDOOR",
"distance": 0,
"calories": 400,
"receivedTime": 1471185427000,
"receivedDate": "2016-08-14T14:37:07Z"
*/
@property (nonatomic) int objId;
@property (nonatomic) long steps;
@property (nonatomic) long distance;
@property (nonatomic) long calories;

@property (nonatomic) long receivedTime;
@property (nonatomic, strong) NSString *receivedDate;
@property (nonatomic, strong) NSString *type;

@end

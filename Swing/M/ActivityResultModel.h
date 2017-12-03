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
/*
{
    "steps": 242,
    "date": "2016-08-21",
    "type": "INDOOR"
},
 */
//@property (nonatomic) int objId;
@property (nonatomic) long steps;
@property (nonatomic, strong) NSDate<Optional> *receivedDate;
//@property (nonatomic) long distance;
//@property (nonatomic) long calories;

//@property (nonatomic) long receivedTime;
@property (nonatomic, strong) NSString *type;

@property (nonatomic) NSNumber<Optional> *month;

@end

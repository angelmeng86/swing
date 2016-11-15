//
//  ActivityCache.h
//  Swing
//
//  Created by Mapple on 2016/11/15.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "ActivityModel.h"

@interface ActivityCache : JSONModel

@property (nonatomic, strong) NSArray<ActivityModel, Optional> *array;

@end

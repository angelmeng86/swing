//
//  ToDoModel.h
//  Swing
//
//  Created by Mapple on 16/8/4.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "JSONModel.h"
#import "Todo+CoreDataClass.h"

@protocol ToDoModel @end

@interface ToDoModel : JSONModel

@property (nonatomic) int64_t objId;
@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSString* status;

- (void)updateTo:(Todo*)todo;
- (void)updateFrom:(Todo*)todo;

@end

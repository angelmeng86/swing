//
//  ToDoModel.h
//  Swing
//
//  Created by Mapple on 16/8/4.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "JSONModel.h"

@interface ToDoModel : JSONModel

@property (nonatomic) int objId;
@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSString* status;

@end

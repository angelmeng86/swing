//
//  SubHostModel.h
//  Swing
//
//  Created by Mapple on 2017/10/22.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "KidModel.h"

@class UserModel;
@interface SubHostModel : JSONModel

@property (nonatomic) int64_t objId;

@property (nonatomic, strong) UserModel<Optional> *requestFromUser;

@property (nonatomic, strong) UserModel<Optional> *requestToUser;

//PENDING, ACCEPTED, DENIED
@property (nonatomic, strong) NSString *status;

@property (nonatomic, strong) NSArray<KidModel, Optional> *kids;

+ (NSArray*)loadSubHost:(NSArray*)requests status:(NSString*)status;

@end

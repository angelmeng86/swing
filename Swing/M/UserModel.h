//
//  UserModel.h
//  Swing
//
//  Created by Mapple on 16/8/5.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "JSONModel.h"

@interface UserModel : JSONModel

@property (nonatomic) int objId;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSString* phoneNumber;

@property (strong, nonatomic) NSString<Optional>* birthday;
@property (strong, nonatomic) NSString<Optional>* nickName;

@property (nonatomic, strong) NSString<Optional> *profile;
@property (nonatomic, strong) NSString<Optional> *sex;

@end
//
//  LoginedModel.h
//  Swing
//
//  Created by Mapple on 16/7/18.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "JSONModel.h"

@interface LoginedModel : JSONModel

@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* access_token;
@property (strong, nonatomic) NSString* token_type;

@property (strong, nonatomic) NSArray* roles;

@end

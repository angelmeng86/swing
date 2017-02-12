//
//  LoginedModel.h
//  Swing
//
//  Created by Mapple on 16/7/18.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "JSONModel.h"

@interface LoginedModel : JSONModel

//@property (strong, nonatomic) NSString<Optional>* email;
//@property (strong, nonatomic) NSString<Optional>* username;
@property (strong, nonatomic) NSString* access_token;
//@property (strong, nonatomic) NSString<Optional>* profileImage;
@property (strong, nonatomic) NSArray<Optional>* rule;
@end

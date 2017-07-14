//
//  FirmwareVersion.h
//  Swing
//
//  Created by Maple on 2017/7/14.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface FirmwareVersion : JSONModel

@property (nonatomic) int64_t objId;
@property (strong, nonatomic) NSString* version;
@property (strong, nonatomic) NSString* fileAUrl;
@property (strong, nonatomic) NSString* fileBUrl;
@property (strong, nonatomic) NSDate<Optional>* uploadedDate;

@end

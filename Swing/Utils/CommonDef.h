//
//  CommonDef.h
//
//
//  Created by Mapple on 14-5-24.
//  Copyright (c) 2014年 Triggeronce. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef Mapple_CommonDef_h
#define Mapple_CommonDef_h

#define IS_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)

#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

#define kDeviceWidth                [UIScreen mainScreen].bounds.size.width
#define KDeviceHeight               [UIScreen mainScreen].bounds.size.height

#define LOAD_IMAGE(name)                [UIImage imageNamed:name]

#define COMMON_TITLE_COLOR              RGBA(0xff, 0x72, 0x31, 1.0f)//RGBA(240, 92, 37, 1.0f)
#define COMMON_BACKGROUND_COLOR         RGBA(194, 235, 246, 1.0f)//RGBA(185, 232, 245, 1.0f)
#define COMMON_NAV_TINT_COLOR           RGBA(0x67, 0xc8, 0xe5, 1.0f)//RGBA(0x7E, 0xAD, 0xBB, 1.0f)

#define ORIGINAL_MAX_WIDTH 640.0f
#define TAGET_MAX_WIDTH 160.0f

#define REMOTE_NOTIFICATION     @"REMOTE_NOTIFICATION"
#define KID_AVATAR_NOTIFICATION     @"KID_AVATAR_NOTIFICATION"
#define SWING_WATCH_BATTERY_NOTIFY  @"SWING_WATCH_BATTERY_NOTIFY"

#define  TIME_ADJUST        [NSTimeZone localTimeZone].secondsFromGMT
#define  TIME_STAMP         [[NSDate date] timeIntervalSince1970] + TIME_ADJUST

//#define AVATAR_BASE_URL     @"http://avatar.childrenlab.com/"
#define AVATAR_BASE_URL     @"https://childrenlab.s3.amazonaws.com/userProfile/"
//userProfile/

#define STEPS_LEVEL_LOW         7000
#define STEPS_LEVEL_GOOD        10000
#define STEPS_LEVEL_HIGH        15000

//------------------------------------------------------------------

#import "SwingClient.h"
#import "LoginedModel.h"
#import "EventModel.h"
#import "KidModel.h"
#import "ToDoModel.h"
#import "UserModel.h"
#import "WeatherModel.h"
#import "AlertModel.h"
#import "ActivityModel.h"
#import "ActivityResultModel.h"
#import "LMLocalData.h"

#import "Fun.h"
#import "CameraUtility.h"
#import "ControlFactory.h"
#import "LMBaseViewController.h"
#import "LMBaseTableViewController.h"
#import "LMBaseTableViewController2.h"
#import "LMArrowView.h"

#import "GlobalCache.h"
#import "SVProgressHUD.h"
//#import "RCLocationManager.h"
#import <PureLayout/PureLayout.h>

//#define LOC_STR(key)        NSLocalizedString(key,nil)
#define LOC_STR(key)        [[GlobalCache shareInstance] showText:key]

#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

#import "SimpleLogger.h"
#import <AFNetworking.h>

#import "MDRadialProgressView.h"
#import "MDRadialProgressLabel.h"
#import "MDRadialProgressTheme.h"

#import "UIFont+AvenirFont.h"
#import <MagicalRecord/MagicalRecord.h>

#import "Event+CoreDataClass.h"
#import "Todo+CoreDataClass.h"
#import "Activity+CoreDataClass.h"
#import "DBHelper.h"

#endif

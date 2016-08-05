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

#define DATA_BUNDLE(name)          [[[NSBundle mainBundle] pathForResource:@"Data" ofType:@"bundle"] stringByAppendingPathComponent:name]

#define BOOK_FILE(name)            [DATA_BUNDLE(@"Book") stringByAppendingPathComponent:name]
#define KNOWLEDGE_FILE(name)            [DATA_BUNDLE(@"Knowledge") stringByAppendingPathComponent:name]

#define COMMON_TITLE_COLOR              RGBA(240, 92, 37, 1.0f)
#define COMMON_BACKGROUND_COLOR         RGBA(194, 235, 246, 1.0f)//RGBA(185, 232, 245, 1.0f)

#define ORIGINAL_MAX_WIDTH 640.0f
#define TAGET_MAX_WIDTH 160.0f

//------------------------------------------------------------------

#import "SwingClient.h"
#import "LoginedModel.h"
#import "EventModel.h"
#import "KidModel.h"
#import "ToDoModel.h"
#import "UserModel.h"
#import "WeartherModel.h"

#import "Fun.h"
#import "CameraUtility.h"
#import "ControlFactory.h"
#import "LMBaseViewController.h"
#import "LMBaseTableViewController.h"
#import "LMBaseTableViewController2.h"

#import "GlobalCache.h"
#import "SVProgressHUD.h"

#import <PureLayout/PureLayout.h>

#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

#import "SimpleLogger.h"
#import <AFNetworking.h>

#import "MDRadialProgressView.h"
#import "MDRadialProgressLabel.h"
#import "MDRadialProgressTheme.h"

#import "UIFont+AvenirFont.h"

#endif

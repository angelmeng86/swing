//
//  CameraUtility.h
//  Swing
//
//  Created by Mapple on 16/7/30.
//  Copyright © 2016年 zzteam. All rights reserved.
//
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>

@protocol CameraUtilityDelegate <NSObject>

- (void)cameraUtilityFinished:(UIImage*)image;

@end

@interface CameraUtility2 : NSObject

@property (nonatomic) CGFloat originMaxWidth;
@property (nonatomic) CGFloat targetMaxWidth;

@property (nonatomic) BOOL dontCustom;

- (void)getPhoto:(UIViewController<CameraUtilityDelegate>*)ctl;

@end

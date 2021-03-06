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

@interface CameraUtility : NSObject

@property (nonatomic) CGFloat originMaxWidth;
@property (nonatomic) CGFloat targetMaxWidth;

@property (nonatomic) BOOL dontCustom;

- (void)getPhoto:(UIViewController<CameraUtilityDelegate>*)ctl;

+ (BOOL) isCameraAvailable;

+ (BOOL) isRearCameraAvailable;

+ (BOOL) isFrontCameraAvailable;

+ (BOOL) doesCameraSupportTakingPhotos;

+ (BOOL) isPhotoLibraryAvailable;

+ (BOOL) canUserPickVideosFromPhotoLibrary;

+ (BOOL) canUserPickPhotosFromPhotoLibrary;

+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage maxWidth:(CGFloat)maxWidth;

@end

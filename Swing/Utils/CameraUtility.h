//
//  CameraUtility.h
//  Swing
//
//  Created by Mapple on 16/7/30.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CameraUtility : NSObject

+ (BOOL) isCameraAvailable;

+ (BOOL) isRearCameraAvailable;

+ (BOOL) isFrontCameraAvailable;

+ (BOOL) doesCameraSupportTakingPhotos;

+ (BOOL) isPhotoLibraryAvailable;

+ (BOOL) canUserPickVideosFromPhotoLibrary;

+ (BOOL) canUserPickPhotosFromPhotoLibrary;

@end

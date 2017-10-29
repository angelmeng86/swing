//
//  CameraUtility.m
//  Swing
//
//  Created by Mapple on 16/7/30.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "CameraUtility2.h"
#import "VPImageCropperViewController.h"
#import "CommonDef.h"
#import "PhotoTweakView.h"

@interface CameraUtility2 ()<VPImageCropperDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIViewController<CameraUtilityDelegate> *delegate;
    UIImage *image;
}

@property (strong, nonatomic) PhotoTweakView *photoView;
    
@end

@implementation CameraUtility2

- (id)init {
    if (self = [super init]) {
        _originMaxWidth = ORIGINAL_MAX_WIDTH;
        _targetMaxWidth = TAGET_MAX_WIDTH;
    }
    return self;
}

#pragma mark camera utility
+ (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

+ (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

+ (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

+ (BOOL) doesCameraSupportTakingPhotos {
    return [CameraUtility2 cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

+ (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}

+ (BOOL) canUserPickVideosFromPhotoLibrary{
    return [CameraUtility2
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

+ (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [CameraUtility2
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

+ (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark image scale utility
+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage maxWidth:(CGFloat)maxWidth {
    if (sourceImage.size.width < maxWidth) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = maxWidth;
        btWidth = sourceImage.size.width * (maxWidth / sourceImage.size.height);
    } else {
        btWidth = maxWidth;
        btHeight = sourceImage.size.height * (maxWidth / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [CameraUtility2 imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}
    
- (void)getPhoto:(UIViewController<CameraUtilityDelegate>*)ctl
{
    delegate = ctl;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:LOC_STR(@"Take a picture") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
#if TARGET_IPHONE_SIMULATOR
        [Fun showMessageBoxWithTitle:NSLocalizedString(@"Prompt", nil) andMessage:@"Simulator does not support camera."];
#else
        // 拍照
        if ([CameraUtility2 isCameraAvailable] && [CameraUtility2 doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            //            if ([CameraUtility isFrontCameraAvailable]) {
            //                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            //            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [delegate presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     LOG_D(@"Picker View Controller is presented");
                                 }];
        }
#endif
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:LOC_STR(@"Choose from library") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 从相册中选取
        if ([CameraUtility2 isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [delegate presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     LOG_D(@"Picker View Controller is presented");
                                 }];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:LOC_STR(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [ctl presentViewController:alertController animated:YES completion:nil];

}
    
#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
        UIImage *img = editedImage;
        if (_targetMaxWidth > 0) {
            img = [CameraUtility2 imageByScalingToMaxSize:editedImage maxWidth:_targetMaxWidth];
        }
        if ([delegate respondsToSelector:@selector(cameraUtilityFinished:)]) {
            [delegate cameraUtilityFinished:img];
        }
    }];
}
    
- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}
    
    
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        if (_originMaxWidth > 0) {
            portraitImg = [CameraUtility2 imageByScalingToMaxSize:portraitImg maxWidth:_originMaxWidth];
        }
        
        if (self.dontCustom) {
            if ([delegate respondsToSelector:@selector(cameraUtilityFinished:)]) {
                [delegate cameraUtilityFinished:portraitImg];
            }
            return;
        }
        
        // present the cropper view controller
        image = portraitImg;
        [self setupSubviews:portraitImg];
    }];
}

- (void)setupSubviews:(UIImage*)img
{
    self.photoView = [[PhotoTweakView alloc] initWithFrame:delegate.view.bounds image:img];
    self.photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [delegate.view addSubview:self.photoView];
    
    [self.photoView.saveBtn addTarget:self action:@selector(saveBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.photoView.cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
}
    
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveBtnTapped
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    // translate
    CGPoint translation = [self.photoView photoTranslation];
    transform = CGAffineTransformTranslate(transform, translation.x, translation.y);
    
    // rotate
    transform = CGAffineTransformRotate(transform, self.photoView.angle);
    
    // scale
    CGAffineTransform t = self.photoView.photoContentView.transform;
    CGFloat xScale =  sqrt(t.a * t.a + t.c * t.c);
    CGFloat yScale = sqrt(t.b * t.b + t.d * t.d);
    transform = CGAffineTransformScale(transform, xScale, yScale);
    
    CGImageRef imageRef = [self newTransformedImage:transform
                                        sourceImage:image.CGImage
                                         sourceSize:image.size
                                  sourceOrientation:image.imageOrientation
                                        outputWidth:image.size.width
                                           cropSize:self.photoView.cropView.frame.size
                                      imageViewSize:self.photoView.photoContentView.bounds.size];
    
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    if ([delegate respondsToSelector:@selector(cameraUtilityFinished:)]) {
        [delegate cameraUtilityFinished:img];
    }
    [self cancelAction];
}

- (void)cancelAction
{
    [UIView animateWithDuration:0.25 animations:^{
        self.photoView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.photoView removeFromSuperview];
        self.photoView = nil;
    }];
}

- (CGImageRef)newScaledImage:(CGImageRef)source withOrientation:(UIImageOrientation)orientation toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality
{
    CGSize srcSize = size;
    CGFloat rotation = 0.0;
    
    switch(orientation)
    {
        case UIImageOrientationUp: {
            rotation = 0;
        } break;
        case UIImageOrientationDown: {
            rotation = M_PI;
        } break;
        case UIImageOrientationLeft:{
            rotation = M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        case UIImageOrientationRight: {
            rotation = -M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        default:
            break;
    }
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 size.width,
                                                 size.height,
                                                 8,  //CGImageGetBitsPerComponent(source),
                                                 0,
                                                 rgbColorSpace,//CGImageGetColorSpace(source),
                                                 kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big//(CGBitmapInfo)kCGImageAlphaNoneSkipFirst  //CGImageGetBitmapInfo(source)
                                                 );
    CGColorSpaceRelease(rgbColorSpace);
    
    CGContextSetInterpolationQuality(context, quality);
    CGContextTranslateCTM(context,  size.width/2,  size.height/2);
    CGContextRotateCTM(context,rotation);
    
    CGContextDrawImage(context, CGRectMake(-srcSize.width/2 ,
                                           -srcSize.height/2,
                                           srcSize.width,
                                           srcSize.height),
                       source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    return resultRef;
}

- (CGImageRef)newTransformedImage:(CGAffineTransform)transform
                      sourceImage:(CGImageRef)sourceImage
                       sourceSize:(CGSize)sourceSize
                sourceOrientation:(UIImageOrientation)sourceOrientation
                      outputWidth:(CGFloat)outputWidth
                         cropSize:(CGSize)cropSize
                    imageViewSize:(CGSize)imageViewSize
{
    CGImageRef source = [self newScaledImage:sourceImage
                             withOrientation:sourceOrientation
                                      toSize:sourceSize
                                 withQuality:kCGInterpolationNone];
    
    CGFloat aspect = cropSize.height/cropSize.width;
    CGSize outputSize = CGSizeMake(outputWidth, outputWidth*aspect);
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 outputSize.width,
                                                 outputSize.height,
                                                 CGImageGetBitsPerComponent(source),
                                                 0,
                                                 CGImageGetColorSpace(source),
                                                 CGImageGetBitmapInfo(source));
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, outputSize.width, outputSize.height));
    
    CGAffineTransform uiCoords = CGAffineTransformMakeScale(outputSize.width / cropSize.width,
                                                            outputSize.height / cropSize.height);
    uiCoords = CGAffineTransformTranslate(uiCoords, cropSize.width/2.0, cropSize.height / 2.0);
    uiCoords = CGAffineTransformScale(uiCoords, 1.0, -1.0);
    CGContextConcatCTM(context, uiCoords);
    
    CGContextConcatCTM(context, transform);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(-imageViewSize.width/2.0,
                                           -imageViewSize.height/2.0,
                                           imageViewSize.width,
                                           imageViewSize.height)
                       , source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGImageRelease(source);
    return resultRef;
}


@end

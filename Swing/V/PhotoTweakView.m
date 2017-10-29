//
//  PhotoView.m
//  PhotoTweaks
//
//  Created by Tu You on 14/12/2.
//  Copyright (c) 2014年 Tu You. All rights reserved.
//

#import "PhotoTweakView.h"
#import "CommonDef.h"
#import "RoundButton.h"
#import <math.h>

const CGFloat kMaxRotationAngle = 0.5;

static const CGFloat kCropViewCornerLength = 22;

//#define kInstruction

@implementation PhotoContentView

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init]) {
        _image = image;
        
        self.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.image = self.image;
        _imageView.userInteractionEnabled = YES;
        [self addSubview:_imageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
}

@end

@interface PhotoScrollView : UIScrollView

@property (nonatomic, strong) PhotoContentView *photoContentView;

@end

@implementation PhotoScrollView

- (void)setContentOffsetY:(CGFloat)offsetY
{
    CGPoint contentOffset = self.contentOffset;
    contentOffset.y = offsetY;
    self.contentOffset = contentOffset;
}

- (void)setContentOffsetX:(CGFloat)offsetX
{
    CGPoint contentOffset = self.contentOffset;
    contentOffset.x = offsetX;
    self.contentOffset = contentOffset;
}

- (CGFloat)zoomScaleToBound
{
    CGFloat scaleW = self.bounds.size.width / self.photoContentView.bounds.size.width;
    CGFloat scaleH = self.bounds.size.height / self.photoContentView.bounds.size.height;
    CGFloat max = MAX(scaleW, scaleH);
    
    return max;
}

@end

typedef NS_ENUM(NSInteger, CropCornerType) {
    CropCornerTypeUpperLeft,
    CropCornerTypeUpperRight,
    CropCornerTypeLowerRight,
    CropCornerTypeLowerLeft
};

@interface CropView ()

@property (nonatomic, strong) NSMutableArray *horizontalCropLines;
@property (nonatomic, strong) NSMutableArray *verticalCropLines;

@property (nonatomic, strong) NSMutableArray *horizontalGridLines;
@property (nonatomic, strong) NSMutableArray *verticalGridLines;

@property (nonatomic, weak) id<CropViewDelegate> delegate;

@property (nonatomic, assign) BOOL cropLinesDismissed;
@property (nonatomic, assign) BOOL gridLinesDismissed;

@end

@implementation CropView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
//        self.layer.borderColor = [UIColor cropLineColor].CGColor;
//        self.layer.borderWidth = 1;
        
        
    }
    return self;
}

@end

@interface PhotoTweakView () <UIScrollViewDelegate, CropViewDelegate>

@property (nonatomic, strong) PhotoScrollView *scrollView;
@property (nonatomic, strong) CropView *cropView;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) CGSize originalSize;
@property (nonatomic, assign) CGFloat angle;

@property (nonatomic, assign) BOOL manualZoomed;
// constants
@property (nonatomic, assign) CGSize maximumCanvasSize;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGPoint originalPoint;

@end

@implementation PhotoTweakView

- (instancetype)initWithFrame:(CGRect)frame
                        image:(UIImage *)image
{
    if (self = [super init]) {
        
        self.frame = frame;
        
        _image = image;
        
        _cropView = [[CropView alloc] initWithFrame:CGRectMake(20, 60, CGRectGetWidth(self.frame) - 40, CGRectGetWidth(self.frame) - 40)];
        _cropView.layer.masksToBounds = YES;
        _cropView.layer.cornerRadius = _cropView.frame.size.width / 2;
        _cropView.delegate = self;
        [self addSubview:_cropView];
        
        // scale the image
        _maximumCanvasSize = _cropView.frame.size;
        
        CGFloat scaleX = image.size.width / self.maximumCanvasSize.width;
        CGFloat scaleY = image.size.height / self.maximumCanvasSize.height;
        CGFloat scale = MIN(scaleX, scaleY);
        
        CGRect bounds = CGRectMake(0, 0, image.size.width / scale, image.size.height / scale);
        
        _originalSize = bounds.size;
        
        _centerY = _cropView.center.y;
        
        _scrollView = [[PhotoScrollView alloc] initWithFrame:_cropView.bounds];
        
        _scrollView.bounces = YES;
        _scrollView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 10;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.clipsToBounds = NO;
        _scrollView.contentSize = CGSizeMake(bounds.size.width, bounds.size.height);
        _scrollView.contentOffset = CGPointMake((bounds.size.width - _cropView.frame.size.width) / 2, (bounds.size.height - _cropView.frame.size.height) / 2);
        [_cropView addSubview:_scrollView];
#ifdef kInstruction
        _scrollView.layer.borderColor = [UIColor redColor].CGColor;
        _scrollView.layer.borderWidth = 1;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.showsHorizontalScrollIndicator = YES;
#endif
        
        _photoContentView = [[PhotoContentView alloc] initWithImage:image];
        _photoContentView.frame = bounds;
        _photoContentView.backgroundColor = [UIColor clearColor];
        _photoContentView.userInteractionEnabled = YES;
        _scrollView.photoContentView = self.photoContentView;
        [self.scrollView addSubview:_photoContentView];
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
        _originalPoint = [self convertPoint:self.scrollView.center toView:self];
        
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.frame.size.height - 130.0f, self.frame.size.width - 40, 40)];
        infoLabel.text = LOC_STR(@"Use your finger to adjust picture position.");
        infoLabel.textColor = [UIColor whiteColor];
        infoLabel.textAlignment = NSTextAlignmentCenter;
        [infoLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
        [self addSubview:infoLabel];
        
        UIButton *confirmBtn = [[RoundButton alloc] initWithFrame:CGRectMake((self.frame.size.width - 220.0f) / 2, self.frame.size.height - 80.0f, 220, 30)];
        confirmBtn.backgroundColor = COMMON_TITLE_COLOR;
        [confirmBtn setTitle:LOC_STR(@"Save") forState:UIControlStateNormal];
        [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [confirmBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        confirmBtn.titleLabel.textColor = [UIColor whiteColor];
        [confirmBtn.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [confirmBtn.titleLabel setNumberOfLines:0];
        [confirmBtn setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
        
        [self addSubview:confirmBtn];
        _saveBtn = confirmBtn;
        
        UIButton *confirmBtn2 = [[RoundButton alloc] initWithFrame:CGRectMake((self.frame.size.width - 220.0f) / 2, self.frame.size.height - 40.0f, 220, 30)];
        confirmBtn2.backgroundColor = COMMON_TITLE_COLOR;
        [confirmBtn2 setTitle:LOC_STR(@"Cancel") forState:UIControlStateNormal];
        [confirmBtn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmBtn2.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [confirmBtn2.titleLabel setTextAlignment:NSTextAlignmentCenter];
        confirmBtn2.titleLabel.textColor = [UIColor whiteColor];
        [confirmBtn2.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [confirmBtn2.titleLabel setNumberOfLines:0];
        [confirmBtn2 setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
        
        [self addSubview:confirmBtn2];
        _cancelBtn = confirmBtn2;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.saveBtn.frame, point)) {
        return self.saveBtn;
    }
    else if (CGRectContainsPoint(self.cancelBtn.frame, point)) {
        return self.cancelBtn;
    }
    return self.scrollView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.photoContentView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    self.manualZoomed = YES;
}

#pragma mark - Crop View Delegate

- (void)cropMoved:(CropView *)cropView
{
    
}

- (void)cropEnded:(CropView *)cropView
{
    CGFloat scaleX = self.originalSize.width / cropView.bounds.size.width;
    CGFloat scaleY = self.originalSize.height / cropView.bounds.size.height;
    CGFloat scale = MIN(scaleX, scaleY);
    
    // calculate the new bounds of crop view
    CGRect newCropBounds = CGRectMake(0, 0, scale * cropView.frame.size.width, scale * cropView.frame.size.height);
    
    // calculate the new bounds of scroll view
    CGFloat width = fabs(cos(self.angle)) * newCropBounds.size.width + fabs(sin(self.angle)) * newCropBounds.size.height;
    CGFloat height = fabs(sin(self.angle)) * newCropBounds.size.width + fabs(cos(self.angle)) * newCropBounds.size.height;
    
    // calculate the zoom area of scroll view
    CGRect scaleFrame = cropView.frame;
    if (scaleFrame.size.width >= self.scrollView.bounds.size.width) {
        scaleFrame.size.width = self.scrollView.bounds.size.width - 1;
    }
    if (scaleFrame.size.height >= self.scrollView.bounds.size.height) {
        scaleFrame.size.height = self.scrollView.bounds.size.height - 1;
    }
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGPoint contentOffsetCenter = CGPointMake(contentOffset.x + self.scrollView.bounds.size.width / 2, contentOffset.y + self.scrollView.bounds.size.height / 2);
    CGRect bounds = self.scrollView.bounds;
    bounds.size.width = width;
    bounds.size.height = height;
    self.scrollView.bounds = CGRectMake(0, 0, width, height);
    CGPoint newContentOffset = CGPointMake(contentOffsetCenter.x - self.scrollView.bounds.size.width / 2, contentOffsetCenter.y - self.scrollView.bounds.size.height / 2);
    self.scrollView.contentOffset = newContentOffset;
    
    [UIView animateWithDuration:0.25 animations:^{
        // animate crop view
        cropView.bounds = CGRectMake(0, 0, newCropBounds.size.width, newCropBounds.size.height);
        cropView.center = CGPointMake(CGRectGetWidth(self.frame) / 2, self.centerY);
        
        // zoom the specified area of scroll view
        CGRect zoomRect = [self convertRect:scaleFrame toView:self.scrollView.photoContentView];
        [self.scrollView zoomToRect:zoomRect animated:NO];
    }];

    self.manualZoomed = YES;
    
    
    CGFloat scaleH = self.scrollView.bounds.size.height / self.scrollView.contentSize.height;
    CGFloat scaleW = self.scrollView.bounds.size.width / self.scrollView.contentSize.width;
    __block CGFloat scaleM = MAX(scaleH, scaleW);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (scaleM > 1) {
            scaleM = scaleM * self.scrollView.zoomScale;
            [self.scrollView setZoomScale:scaleM animated:NO];
        }
        [UIView animateWithDuration:0.2 animations:^{
            [self checkScrollViewContentOffset];
        }];
    });
}

- (void)checkScrollViewContentOffset
{
    self.scrollView.contentOffsetX = MAX(self.scrollView.contentOffset.x, 0);
    self.scrollView.contentOffsetY = MAX(self.scrollView.contentOffset.y, 0);
    
    if (self.scrollView.contentSize.height - self.scrollView.contentOffset.y <= self.scrollView.bounds.size.height) {
        self.scrollView.contentOffsetY = self.scrollView.contentSize.height - self.scrollView.bounds.size.height;
    }
    
    if (self.scrollView.contentSize.width - self.scrollView.contentOffset.x <= self.scrollView.bounds.size.width) {
        self.scrollView.contentOffsetX = self.scrollView.contentSize.width - self.scrollView.bounds.size.width;
    }
}

- (CGPoint)photoTranslation
{
    CGRect rect = [self.photoContentView convertRect:self.photoContentView.bounds toView:self];
    CGPoint point = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
    CGPoint zeroPoint = CGPointMake(CGRectGetWidth(self.frame) / 2, self.centerY);
    return CGPointMake(point.x - zeroPoint.x, point.y - zeroPoint.y);
}

@end

//
//  TodayIntroSheet.m
//  Swing
//
//  Created by Mapple on 2017/11/19.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "TodayIntroSheet.h"
#import "CommonDef.h"

@interface TodayIntroSheet ()

@property (nonatomic, weak) UIView *actionSheet;
@property (nonatomic, weak) UIButton *btn;
@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation TodayIntroSheet

- (void)setupActionSheet {
    [self.cover addSubview:({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:LOAD_IMAGE(@"monster-yellow")];
        _imageView = imageView;
    })];
    
    [self.cover addSubview:({
        UIView *actionSheet = [[UIView alloc] init];
        actionSheet.backgroundColor = [UIColor whiteColor];
        actionSheet.layer.cornerRadius = 10.0f;
        actionSheet.layer.masksToBounds = YES;
        _actionSheet = actionSheet;
    })];
    
    [_imageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [_imageView autoSetDimensionsToSize:CGSizeMake(120, 120)];
    [_imageView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:_actionSheet withOffset:-90];
    
    [_actionSheet autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:40];
    [_actionSheet autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:40];
    [_actionSheet autoSetDimension:ALDimensionHeight toSize:160];
    [_actionSheet autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20];
    
    [_actionSheet addSubview:({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.layer.cornerRadius = 5.0f;
        btn.backgroundColor = COMMON_TITLE_COLOR;
        btn.titleLabel.font = [UIFont boldAvenirFontOfSize:15];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitle:LOC_STR(@"Okay") forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        _btn = btn;
    })];
    
    [_btn autoSetDimensionsToSize:CGSizeMake(60, 30)];
    [_btn autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20];
    [_btn autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.textColor = COMMON_TITLE_COLOR;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = LOC_STR(@"Tap on the date or event to see today's full schedule.");
    label.font = [UIFont boldAvenirFontOfSize:20];
    [_actionSheet addSubview:label];
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [label autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
    [label autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
    [label autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:_btn withOffset:-20];
    
}

- (void)btnAction:(UIButton*)button
{
    [self dismiss];
}

- (void)show:(CGRect)todayRect time:(CGRect)timeRect
{
    UIImage *image = LOAD_IMAGE(@"arrow_line");
    UIImageView *line = [[UIImageView alloc] initWithImage:[image stretchableImageWithLeftCapWidth:image.size.width / 2 topCapHeight:image.size.height / 2]];
    [self.cover addSubview:line];
    line.transform = CGAffineTransformMakeRotation(M_PI);
    [line autoSetDimension:ALDimensionHeight toSize:40];
    [line autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:CGRectGetMaxY(timeRect) + 5];
    [line autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    line = [[UIImageView alloc] initWithImage:[image stretchableImageWithLeftCapWidth:image.size.width / 2 topCapHeight:image.size.height / 2]];
    [self.cover addSubview:line];
    line.transform = CGAffineTransformMakeRotation(M_PI);
    [line autoSetDimension:ALDimensionHeight toSize:40];
    [line autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:CGRectGetMaxY(todayRect) + 5];
    [line autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:CGRectGetMidX(todayRect) - 6];
    
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.cover.frame];
    [path appendPath:[[UIBezierPath bezierPathWithRoundedRect: timeRect cornerRadius:10.0f] bezierPathByReversingPath]];
    [path appendPath:[[UIBezierPath bezierPathWithRoundedRect: todayRect cornerRadius:5.0f] bezierPathByReversingPath]];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    [self.cover.layer setMask:shapeLayer];
    
    [super show];
}

@end

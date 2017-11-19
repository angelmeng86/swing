//
//  EventEditIntroSheet.m
//  Swing
//
//  Created by Mapple on 2017/11/19.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "EventEditIntroSheet.h"
#import "CommonDef.h"

@interface EventEditIntroSheet ()

@property (nonatomic, weak) UIView *actionSheet;
@property (nonatomic, weak) UIButton *btn;
@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation EventEditIntroSheet

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
    [_actionSheet autoSetDimension:ALDimensionHeight toSize:200];
    [_actionSheet autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
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
    label.text = LOC_STR(@"Edit your existing schedule by tapping on the pen icon.");
    label.font = [UIFont boldAvenirFontOfSize:20];
    [_actionSheet addSubview:label];
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [label autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
    [label autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
    [label autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:_btn withOffset:-20];
    
    CGRect target = CGRectMake(kDeviceWidth - 50, 20, 44, 44);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.cover.frame];
    [path appendPath:[[UIBezierPath bezierPathWithRoundedRect: target cornerRadius:5.0f] bezierPathByReversingPath]];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    [self.cover.layer setMask:shapeLayer];
    
    UIImage *image = LOAD_IMAGE(@"arrow_line");
    UIImageView *line = [[UIImageView alloc] initWithImage:[image stretchableImageWithLeftCapWidth:image.size.width / 2 topCapHeight:image.size.height / 2]];
    [self.cover addSubview:line];
    
    line.transform = CGAffineTransformMakeRotation(M_PI);
    
    //    [line autoSetDimension:ALDimensionWidth toSize:2.0f];
    [line autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
    [line autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:CGRectGetMaxY(target) + 5];
    [line autoSetDimension:ALDimensionHeight toSize:40];
}

- (void)btnAction:(UIButton*)button
{
    [self dismiss];
}


@end

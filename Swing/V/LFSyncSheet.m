//
//  LFCommentSheet.m
//  TaTaYue
//
//  Created by Mapple on 2017/6/15.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "LFSyncSheet.h"
#import "CommonDef.h"

#define SCREEN_BOUNDS         [UIScreen mainScreen].bounds
#define SCREEN_WIDTH          [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT         [UIScreen mainScreen].bounds.size.height
#define SCREEN_ADJUST(Value)  SCREEN_WIDTH * (Value) / 375.0

#define kActionItemHeight  SCREEN_ADJUST(50)
#define kLineHeight        0.5
#define kDividerHeight     7.5

#define kTitleFontSize       SCREEN_ADJUST(15)
#define kActionItemFontSize  SCREEN_ADJUST(17)

#define kActionSheetColor            [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f]
#define kDividerColor                [UIColor colorWithRed:0xF6/255.0f green:0xF6/255.0f blue:0xF6/255.0f alpha:1.0f]

#define kButtonColor                [UIColor colorWithRed:0xC7/255.0f green:0xC7/255.0f blue:0xC7/255.0f alpha:1.0f]

@interface LFSyncSheet ()


@property (nonatomic, copy) LFSyncSheetDidActionBlock selectActionBlock;

@property (nonatomic, weak) UIView *actionSheet;
@property (nonatomic, weak) UIButton *btn;
@property (nonatomic, weak) UIButton *checkBtn;

@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation LFSyncSheet

- (instancetype)initWithBlock:(LFSyncSheetDidActionBlock)actionBlock {
    
    if (self = [super initWithFrame:SCREEN_BOUNDS]) {
        _selectActionBlock = actionBlock;
    }
    return self;
}

+ (instancetype)actionSheetViewWithBlock:(LFSyncSheetDidActionBlock)actionBlock
{
    return [[self alloc] initWithBlock:actionBlock];
}

- (void)showArrow:(CGRect)target
{
    UIImage *image = LOAD_IMAGE(@"arrow_line");
    UIImageView *line = [[UIImageView alloc] initWithImage:[image stretchableImageWithLeftCapWidth:image.size.width / 2 topCapHeight:image.size.height / 2]];
//    line.backgroundColor = [UIColor whiteColor];
    [self.cover addSubview:line];
//    [line autoSetDimension:ALDimensionWidth toSize:2.0f];
    [line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.actionSheet withOffset:20];
    [line autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [line autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:SCREEN_HEIGHT - target.origin.y + 10];

    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.cover.frame];
    [path appendPath:[[UIBezierPath bezierPathWithRoundedRect: target cornerRadius:5.0f] bezierPathByReversingPath]];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    [self.cover.layer setMask:shapeLayer];
    
    [super show];
}

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
    NSLayoutConstraint *lc = [_actionSheet autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    lc.constant = -80.0f;
    
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
    
    UILabel *label1 = [UILabel new];
    label1.textColor = [UIColor grayColor];
    label1.text = LOC_STR(@"Hide this reminder");
    label1.numberOfLines = 2;
    label1.font = [UIFont avenirFontOfSize:15];
    [_actionSheet addSubview:label1];
    [ControlFactory setClickAction:label1 target:self action:@selector(labelAction)];
    
//    [label1 autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:50];
//    [label1 autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
    [label1 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [label1 autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:_btn withOffset:-20];
    
    UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    checkBtn.layer.cornerRadius = 10.f;
    checkBtn.layer.borderColor = COMMON_TITLE_COLOR.CGColor;
    checkBtn.layer.borderWidth = 2.f;
    checkBtn.layer.masksToBounds = YES;
    checkBtn.backgroundColor = [UIColor clearColor];
    [checkBtn setTitle:@"" forState:UIControlStateNormal];
    [checkBtn setTitle:@"●" forState:UIControlStateSelected];
    [checkBtn setTitleColor:COMMON_TITLE_COLOR forState:UIControlStateSelected];
//    _checkBtn.userInteractionEnabled = false;
    
    [_actionSheet addSubview:checkBtn];
    [checkBtn autoSetDimensionsToSize:CGSizeMake(20, 20)];
    [checkBtn autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:label1 withOffset:-10];
    [checkBtn autoAlignAxis:ALAxisHorizontal toSameAxisOfView:label1];
    [checkBtn addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
    _checkBtn = checkBtn;
    
    
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.textColor = COMMON_TITLE_COLOR;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = LOC_STR(@"Please sync after editing events");
    label.font = [UIFont boldAvenirFontOfSize:20];
    [_actionSheet addSubview:label];
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [label autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
    [label autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
    [label autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:label1 withOffset:-20];
    
}

- (void)labelAction
{
    [self checkAction:_checkBtn];
}

- (void)checkAction:(UIButton*)button
{
    button.selected = !button.selected;
}

- (void)btnAction:(UIButton*)button
{
    if (_selectActionBlock) {
        _selectActionBlock(self, self.checkBtn.selected);
    }
    [self dismiss];
}

@end

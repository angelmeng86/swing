//
//  LMCalendarDayView.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "LMCalendarDayView.h"

#import "JTCalendarManager.h"
#import "CommonDef.h"

NSInteger const kLMCalendarDayViewDotViewFlex = 3;

@interface LMCalendarDayView ()

@property (nonatomic, strong) NSMutableArray* dotViews;

@end

@implementation LMCalendarDayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (void)commonInit
{
    self.clipsToBounds = YES;
    
    _circleRatio = .9;
    _dotRatio = 1. / 9.;
    
    {
        _circleView = [UIView new];
        [self addSubview:_circleView];
        
        _circleView.backgroundColor = [UIColor colorWithRed:0x33/256. green:0xB3/256. blue:0xEC/256. alpha:.5];
        _circleView.hidden = YES;

        _circleView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _circleView.layer.shouldRasterize = YES;
    }
    
    {
        _dotViews = [NSMutableArray array];
        for (int i = 0; i < 4; i++) {
            UIView *dot = [UIView new];
            [self addSubview:dot];
            
            dot.backgroundColor = [UIColor redColor];
            dot.hidden = YES;
            
            dot.layer.rasterizationScale = [UIScreen mainScreen].scale;
            dot.layer.shouldRasterize = YES;
            [_dotViews addObject:dot];
        }
    }
    
    {
        _textLabel = [UILabel new];
        [self addSubview:_textLabel];
        _textLabel.font = [UIFont boldAvenirFontOfSize:15];
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    
    {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouch)];
        
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:gesture];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _textLabel.frame = self.bounds;
    
    CGFloat sizeCircle = MIN(self.frame.size.width, self.frame.size.height);
    CGFloat sizeDot = sizeCircle;
    
    sizeCircle = sizeCircle * _circleRatio;
    sizeDot = sizeDot * _dotRatio;
    
    sizeCircle = roundf(sizeCircle);
    sizeDot = roundf(sizeDot);
    
    _circleView.frame = CGRectMake(0, 0, sizeCircle, sizeCircle);
    _circleView.center = CGPointMake(self.frame.size.width / 2., self.frame.size.height / 2.);
    _circleView.layer.cornerRadius = sizeCircle / 2.;
    
    CGPoint center = CGPointMake(self.frame.size.width / 2., (self.frame.size.height / 2.) +sizeDot * 2.5);
    int count = (int)_dotColors.count;
    float x = (kLMCalendarDayViewDotViewFlex + sizeDot) * (count - 1) / 2;
    int i = 0;
    for (UIView *dotView in _dotViews) {
        if (i < count) {
            dotView.frame = CGRectMake(0, 0, sizeDot, sizeDot);
            dotView.center = CGPointMake(center.x - x + i * (kLMCalendarDayViewDotViewFlex + sizeDot), center.y);
            dotView.layer.cornerRadius = sizeDot / 2.;
            dotView.backgroundColor = [_dotColors objectAtIndex:i];
            dotView.hidden = NO;
        }
        else {
            dotView.hidden = YES;
        }
        i++;
    }
}

- (void)setDate:(NSDate *)date
{
    NSAssert(date != nil, @"date cannot be nil");
    NSAssert(_manager != nil, @"manager cannot be nil");
    
    self->_date = date;
    [self reload];
}

- (void)reload
{    
    static NSDateFormatter *dateFormatter = nil;
    if(!dateFormatter){
        dateFormatter = [_manager.dateHelper createDateFormatter];
    }
    [dateFormatter setDateFormat:self.dayFormat];

    _textLabel.text = [ dateFormatter stringFromDate:_date];       
    [_manager.delegateManager prepareDayView:self];
}

- (void)didTouch
{
    [_manager.delegateManager didTouchDayView:self];
}

- (NSString *)dayFormat
{
    return self.manager.settings.zeroPaddedDayFormat ? @"dd" : @"d";
}

@end

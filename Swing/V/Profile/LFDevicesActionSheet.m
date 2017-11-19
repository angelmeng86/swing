//
//  LFDevicesActionSheet.m
//  Swing
//
//  Created by Mapple on 2017/11/12.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "LFDevicesActionSheet.h"
#import "DeviceSmallCell.h"
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

#define kActionSheetColor            [UIColor whiteColor]

#define kButtonColor                [UIColor colorWithRed:0xC7/255.0f green:0xC7/255.0f blue:0xC7/255.0f alpha:1.0f]

@interface LFDevicesActionSheet ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) LFDevicesActionSheetDidSelectBlock actionBlock;

@property (nonatomic, weak) UIView *actionSheet;

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, assign) CGFloat actionSheetHeight;

@property (nonatomic, strong) NSArray* kids;
@property (nonatomic, strong) NSArray* sharedKids;

@end

@implementation LFDevicesActionSheet

- (NSArray*)kids
{
    if (_kids == nil) {
        _kids = [DBHelper queryKids:NO];
    }
    return _kids;
}

- (NSArray*)sharedKids
{
    if (_sharedKids == nil) {
        _sharedKids = [DBHelper queryKids:YES];;
    }
    return _sharedKids;
}

- (instancetype)initWithBlock:(LFDevicesActionSheetDidSelectBlock)block
{
    
    if (self = [super initWithFrame:SCREEN_BOUNDS]) {
        self.actionBlock = block;
    }
    return self;
}

+ (instancetype)actionSheetViewWithBlock:(LFDevicesActionSheetDidSelectBlock)actionBlock
{
    return [[self alloc] initWithBlock:actionBlock];
}

#pragma mark - Animations

- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.9
          initialSpringVelocity:0.7
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.cover.alpha = 1.0;
                         self.actionSheet.transform = CGAffineTransformMakeTranslation(0, -self.actionSheetHeight);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.9
          initialSpringVelocity:0.7
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.cover.alpha = 0.0;
                         self.actionSheet.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void)setupActionSheet {
    
    [self addSubview:({
        UIView *actionSheet = [[UIView alloc] init];
        actionSheet.backgroundColor = kActionSheetColor;
        actionSheet.layer.cornerRadius = 5.0f;
        _actionSheet = actionSheet;
    })];
    
    _offsetY = 0;
    
    _offsetY += 5;
    [_actionSheet addSubview:({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, _offsetY, self.frame.size.width - 40, SCREEN_ADJUST(240)) style:UITableViewStylePlain];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerNib:[UINib nibWithNibName:@"DeviceSmallCell" bundle:nil] forCellReuseIdentifier:@"DeviceSmallCell"];
        
        _tableView = tableView;
    })];
    _offsetY += SCREEN_ADJUST(240);

    _offsetY += 5;
    
    _actionSheet.frame = CGRectMake(10, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame) - 20, _offsetY);
    _actionSheetHeight = _offsetY + 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = COMMON_HEADER_BORDER_COLOR;
    label.font = [UIFont boldAvenirFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    if (section == 0) {
        label.text = LOC_STR(@"My devices");
    }
    else {
        label.text = LOC_STR(@"Devices shared with me");
    }
    return label;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.kids.count;
    }
    else {
        return self.sharedKids.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceSmallCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceSmallCell" forIndexPath:indexPath];
    
    KidInfo *kid = nil;
    if (indexPath.section == 0) {
        kid = self.kids[indexPath.row];
    }
    else {
        kid = self.sharedKids[indexPath.row];
    }
    
    cell.nameLabel.text = kid.name;
    if (kid.profile.length > 0) {
        [cell.headerView sd_setImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:kid.profile]]];
    }
    else {
        cell.headerView.image = nil;
    }
    cell.checked = [GlobalCache shareInstance].currentKid.objId == kid.objId;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KidInfo *kid = nil;
    if (indexPath.section == 0) {
        kid = self.kids[indexPath.row];
    }
    else {
        kid = self.sharedKids[indexPath.row];
    }
    
    if (_actionBlock) {
        _actionBlock(self, kid);
    }
    [self dismiss];
}

@end

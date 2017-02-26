//
//  AddEventViewController.m
//  Swing
//
//  Created by Mapple on 16/8/2.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "AddEventViewController2.h"
#import "AlertSelectViewController.h"
#import "ChoicesViewController.h"
#import "CommonDef.h"
#import "KeyboardManager.h"
#import "LMArrowView.h"

#define TAG_REPEAT  2017

@interface AddEventViewController2 ()<UITextFieldDelegate>
{
    BOOL isAddTip;
    
    BOOL isCustom;
    NSArray *alertArray;
    int repeatIndex;
    
    NSArray *repeatArray;
}

@property (nonatomic, strong) AlertModel* alert;

@end

@implementation AddEventViewController2

- (NSDate*)dateFromString:(NSString*)str {
    static NSDateFormatter *df = nil;
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    }
    return [df dateFromString:str];
}

- (NSString*)dateToString:(NSDate*)date {
    static NSDateFormatter *df = nil;
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    }
    return [df stringFromDate:date];
}

- (NSString*)dateToString2:(NSDate*)date {
    static NSDateFormatter *df = nil;
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
        //[df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    }
    return [df stringFromDate:date];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.repeatTF.enabled = NO;
//    self.stateTF.enabled = NO;
//    self.cityTF.enabled = NO;
    isCustom = NO;
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    datePicker.minimumDate = [NSDate date];
//    datePicker.minuteInterval = 5;
    self.startTF.inputView = datePicker;
    [datePicker addTarget:self action:@selector(startChange:) forControlEvents:UIControlEventValueChanged];
    
    UIControl *bgView = [UIControl new];
    bgView.frame = CGRectMake(0, 0, 30, 30);
    LMArrowView *arrow = [[LMArrowView alloc]initWithFrame:CGRectMake(0, 0, 10, 6)];
    arrow.arrow = LMArrowDown;
    arrow.color = RGBA(0xfd, 0x73, 0x3e, 1.0f);
    arrow.isNotFill = YES;
    [bgView addSubview:arrow];
    [arrow autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [arrow autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:5];
    arrow.userInteractionEnabled = NO;
    [arrow autoSetDimensionsToSize:CGSizeMake(10, 6)];
    [bgView addTarget:self action:@selector(dorpdownAction) forControlEvents:UIControlEventTouchUpInside];
    self.nameTF.rightView = bgView;
    self.nameTF.rightViewMode = UITextFieldViewModeAlways;
    
    bgView = [UIControl new];
    bgView.frame = CGRectMake(0, 0, 110, 30);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    label.textAlignment = NSTextAlignmentRight;
    label.tag = 2016;
    label.font = self.repeatTF.font;
    label.textColor = RGBA(187, 186, 194, 1.0f);
    [bgView addSubview:label];
    
    arrow = [[LMArrowView alloc]initWithFrame:CGRectMake(0, 0, 10, 6)];
    arrow.arrow = LMArrowDown;
    arrow.color = RGBA(0xfd, 0x73, 0x3e, 1.0f);
    arrow.isNotFill = YES;
    [bgView addSubview:arrow];
    [arrow autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [arrow autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:15];
    [arrow autoSetDimensionsToSize:CGSizeMake(10, 6)];
    arrow.userInteractionEnabled = NO;
    [bgView addTarget:self action:@selector(repeatAction) forControlEvents:UIControlEventTouchUpInside];
    self.repeatTF.rightView = bgView;
    self.repeatTF.rightViewMode = UITextFieldViewModeAlways;
//    self.repeatTF.enabled = NO;
    repeatArray = @[LOC_STR(@"Never"), LOC_STR(@"Every Day"), LOC_STR(@"Every Week")/*, @"Every Month"*/];
    
    self.navigationItem.title = LOC_STR(@"Calendar");
    [self.shortSaveBtn setTitle:LOC_STR(@"Save") forState:UIControlStateNormal];
    [self.longSaveBtn setTitle:LOC_STR(@"Save") forState:UIControlStateNormal];
    [self.advanceBtn setTitle:LOC_STR(@"Advance") forState:UIControlStateNormal];
    self.advanceBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.nameTF.placeholder = LOC_STR(@"Select Event");
    self.startTF.placeholder = LOC_STR(@"Start");
    self.endTF.placeholder = LOC_STR(@"End");
    self.cityTF.placeholder = LOC_STR(@"City");
    self.stateTF.placeholder = LOC_STR(@"State");
    self.repeatTF.placeholder = LOC_STR(@"Repeat");
    self.descTF.placeholder = LOC_STR(@"Description");
    
    UIDatePicker *datePicker2 = [[UIDatePicker alloc] init];
    datePicker2.datePickerMode = UIDatePickerModeTime;
    datePicker2.minimumDate = [datePicker.date dateByAddingTimeInterval:30 * 60];
//    datePicker2.minuteInterval = 5;
    self.endTF.inputView = datePicker2;
    [datePicker2 addTarget:self action:@selector(endChange:) forControlEvents:UIControlEventValueChanged];
    
    self.repeatTF.delegate = self;
    
    self.nameTF.delegate = self;
    self.stateTF.delegate = self;
    self.cityTF.delegate = self;
    self.descTF.delegate = self;
    
//    isAddTip = NO;
    
    isAddTip = YES;
    [self addRedTip:self.nameTF];
    [self addRedTip:self.startTF];
    [self addRedTip:self.endTF];
    [self changeAdvance:NO];
    [self hideAdvance:YES];
    if (self.model) {
        self.nameTF.text = self.model.eventName;
        
        AlertModel *alert = [AlertModel new];
        alert.text = self.model.eventName;
        alert.value = [NSString stringWithFormat:@"%d", self.model.alert];
        self.alert = alert;
        
        self.startTF.text = [self dateToString:self.model.startDate];;
        self.endTF.text = [self dateToString:self.model.endDate];
        
        self.colorCtl.selectedColor = self.model.color;
        
        self.descTF.text = self.model.desc;
        self.stateTF.text = self.model.state;
        self.cityTF.text = self.model.city;
        
        if (self.model.repeat.length > 0) {
            UILabel *label = (UILabel*)[self.repeatTF.rightView viewWithTag:2016];
            if ([self.model.repeat isEqualToString:@"DAILY"]) {
                label.text = repeatArray[1];
                self.repeatTF.tag = TAG_REPEAT + 1;
            }
            else if ([self.model.repeat isEqualToString:@"WEEKLY"]) {
                label.text = repeatArray[2];
                self.repeatTF.tag = TAG_REPEAT + 2;
            }
        }
        
        
        
        [self.todoCtl setItemList:self.model.todo];
        
        if (self.model.desc.length > 0 ||
            self.model.state.length > 0 ||
            self.model.city.length > 0 ||
            self.model.todo.count > 0 ||
            self.model.repeat.length > 0) {
            [self changeAdvance:YES];
        }
    }
    else {
        self.startTF.text = [self dateToString:datePicker.minimumDate];
        self.endTF.text = [self dateToString:datePicker2.minimumDate];
        
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Advance" style:UIBarButtonItemStyleDone target:self action:@selector(changeAction)];
        [self hideAdvance:NO];
    }
}

- (void)setRepeatText:(NSString*)text {
    UILabel *label = (UILabel*)[self.repeatTF.rightView viewWithTag:2016];
    label.text = text;
}

- (void)hideAdvance:(BOOL)hidden {
    self.advanceBtn.hidden = hidden;
    self.shortSaveBtn.hidden = hidden;
    self.longSaveBtn.hidden = !hidden;
}

- (IBAction)changeAction:(UIButton*)sender {
    BOOL hidden = self.todoCtl.hidden;
    if (hidden) {
        [sender setTitle:LOC_STR(@"Normal") forState:UIControlStateNormal];
        [self hideAdvance:YES];
    }
    else {
        [sender setTitle:LOC_STR(@"Advance") forState:UIControlStateNormal];
    }
    [self changeAdvance:hidden];
}

- (void)changeAction {
    BOOL hidden = self.todoCtl.hidden;
    if (hidden) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Normal" style:UIBarButtonItemStyleDone target:self action:@selector(changeAction)];
    }
    else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Advance" style:UIBarButtonItemStyleDone target:self action:@selector(changeAction)];
    }
    [self changeAdvance:hidden];
}

- (void)changeAdvance:(BOOL)show {
    BOOL hidden = !show;
    self.cityTF.hidden = hidden;
    self.stateTF.hidden = hidden;
    self.repeatTF.hidden = hidden;
    self.descTF.hidden = hidden;
    self.todoCtl.hidden = hidden;
}

- (void)dorpdownAction {
    [[IQKeyboardManager sharedManager] resignFirstResponder];
    AlertSelectViewController *ctl = [[AlertSelectViewController alloc] initWithStyle:UITableViewStylePlain];
    ctl.delegate = self;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)repeatAction {
    [[IQKeyboardManager sharedManager] resignFirstResponder];
    ChoicesViewController *ctl = [[ChoicesViewController alloc] initWithStyle:UITableViewStylePlain];
    ctl.delegate = self;
    ctl.navigationItem.title = self.repeatTF.placeholder;
    ctl.textArray = repeatArray;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.nameTF && self.nameTF.text.length > 0) {
        if (alertArray == nil) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"alert2" ofType:@"json"];
            id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:kNilOptions error:NULL];
            if ([json isKindOfClass:[NSArray class]]) {
                alertArray = json;
            }
        }
        
        for (NSDictionary *dict in alertArray) {
            NSArray *items = dict[@"items"];
            for (NSDictionary *item in items) {
                if ([[item[@"text"] lowercaseString] isEqualToString:[textField.text lowercaseString]]) {
                    AlertModel *m = [[AlertModel alloc] initWithDictionary:item error:NULL];
                    self.alert = m;
                    self.nameTF.text = m.text;
                    return;
                }
            }
        }
        
        NSDictionary *item = alertArray[0];
        NSArray *items = item[@"items"];
        NSDictionary *model = items[0];
        AlertModel *m = [[AlertModel alloc] initWithDictionary:model error:NULL];
        m.text = textField.text;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (textField == self.nameTF && !isCustom) {
        [[IQKeyboardManager sharedManager] resignFirstResponder];
        AlertSelectViewController *ctl = [[AlertSelectViewController alloc] initWithStyle:UITableViewStylePlain];
        ctl.delegate = self;
        [self.navigationController pushViewController:ctl animated:YES];
        return NO;
    }
    else if (textField == self.repeatTF) {
        [self repeatAction];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    if (textField == self.nameTF) {
//        isCustom = NO;
//    }
    [textField resignFirstResponder];
    return YES;
}

- (void)choicesViewControllerDidSelectedIndex:(int)index {
//    self.repeatTF.text = text;
    [self setRepeatText:repeatArray[index]];
    self.repeatTF.tag = TAG_REPEAT + index;
    [[IQKeyboardManager sharedManager] resignFirstResponder];
}

- (void)alertSelectViewControllerDidSelected:(AlertModel*)alert {
    if ([alert.value isEqualToString:@"0"]) {
        self.alert = nil;
        isCustom = YES;
        self.nameTF.text = nil;
        [self.nameTF becomeFirstResponder];
    }
    else {
        isCustom = NO;
        self.alert = alert;
        self.nameTF.text = LOC_STR(alert.text);
    }
}

- (void)startChange:(UIDatePicker*)datePicker {
    NSDate *sDate = datePicker.date;
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:kCFCalendarUnitYear|kCFCalendarUnitMonth|kCFCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:sDate];
    //开始时间只能设定在一天的6：00~23：30
    if (comps.hour == 23 && comps.minute > 30) {
        comps.hour = 23;
        comps.minute = 30;
        sDate = [datePicker.minimumDate laterDate:[[NSCalendar currentCalendar] dateFromComponents:comps]];
        [datePicker setDate:sDate animated:YES];
    }
    else if (comps.hour < 6) {
        comps.hour = 6;
        comps.minute = 0;
        sDate = [datePicker.minimumDate laterDate:[[NSCalendar currentCalendar] dateFromComponents:comps]];
        [datePicker setDate:sDate animated:YES];
    }
    self.startTF.text = [self dateToString:sDate];
    
    UIDatePicker* dp = (UIDatePicker*)self.endTF.inputView;
    dp.minimumDate = [datePicker.date dateByAddingTimeInterval:30 * 60 - 1];
    
    comps.hour = 23;
    comps.minute = 59;
    comps.second = 59;
    dp.maximumDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
    if (NSOrderedDescending == [dp.date compare:datePicker.date]) {
        self.endTF.text = [self dateToString:dp.minimumDate];
    }
    
}

- (void)endChange:(UIDatePicker*)datePicker {
    self.endTF.text = [self dateToString:datePicker.date];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addRedTip:(UIView*)view {
    UILabel *label = [UILabel new];
    label.text = @"*";
    label.textColor = [UIColor redColor];
    [self.view addSubview:label];
    [label autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:view withOffset:-2];
    [label autoAlignAxis:ALAxisHorizontal toSameAxisOfView:view];
}

- (BOOL)validateTextField {
    if (self.nameTF.text.length == 0
         || self.startTF.text.length == 0
         || self.endTF.text.length == 0) {
        [Fun showMessageBoxWithTitle:LOC_STR(@"Error") andMessage:LOC_STR(@"Please input info.")];
        if (!isAddTip) {
            isAddTip = YES;
            [self addRedTip:self.nameTF];
            [self addRedTip:self.startTF];
            [self addRedTip:self.endTF];
        }
        return NO;
    }
    
    //判断设置的时间范围是否是每天的6点至24点
    NSDate *startDate = [self dateFromString:self.startTF.text];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *start = [cal components:NSCalendarUnitHour fromDate:startDate];
    NSDate *endDate = [self dateFromString:self.endTF.text];
    NSDateComponents *end = [cal components:NSCalendarUnitHour fromDate:endDate];
    if (![cal isDate:startDate inSameDayAsDate:endDate]) {
        [Fun showMessageBoxWithTitle:LOC_STR(@"Error") andMessage:LOC_STR(@"The date must in the same day.")];
        return NO;
    }
    if ([start hour] < 6 || [end hour] < 6) {
        [Fun showMessageBoxWithTitle:LOC_STR(@"Error") andMessage:LOC_STR(@"Please select a date between 6:00 and 24:00.")];
        return NO;
    }
    
    return YES;
}

- (IBAction)saveAction:(id)sender {
    [[IQKeyboardManager sharedManager] resignFirstResponder];
    if ([self validateTextField]) {
        [self saveEventV1];
    }
    
}

- (void)saveEventV1 {
    int64_t kidId = [[GlobalCache shareInstance] getKidId];
    if (kidId == -1) {
        [Fun showMessageBoxWithTitle:LOC_STR(@"Error") andMessage:LOC_STR(@"you have not bind device yet, please sync a watch.")];
        return;
    }
    
    [SVProgressHUD showWithStatus:LOC_STR(@"Saving, please wait...")];
    
//eventName, startDate, endDate, color, status, description, alert, city, state
    UILabel *label = (UILabel*)[self.repeatTF.rightView viewWithTag:2016];
    NSString *repeat = @"";
    if (label.text.length > 0) {
        switch (self.repeatTF.tag - TAG_REPEAT) {
            case 1:
                repeat = @"DAILY";
                break;
            case 2:
                repeat = @"WEEKLY";
                break;
            default:
                break;
        }
    }
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data addEntriesFromDictionary:@{@"kidId":@[@(kidId)], @"name":self.nameTF.text, @"startDate":[self dateToString2:[self dateFromString:self.startTF.text]]
                                     , @"endDate":[self dateToString2:[self dateFromString:self.endTF.text]]
                                     , @"color":[Fun stringFromColor:self.colorCtl.selectedColor]
                                     , @"timezoneOffset" : @([NSTimeZone localTimeZone].secondsFromGMT / 60)}];
    
    if (self.alert) {
        [data setObject:@(self.alert.value.intValue) forKey:@"alert"];
    }
    
    if (repeat.length > 0) {
        [data setObject:repeat forKey:@"repeat"];
    }
    
    if (!self.todoCtl.hidden) {
        if (self.descTF.text.length > 0) {
            [data setObject:self.descTF.text forKey:@"description"];
        }
        if (self.cityTF.text.length > 0) {
            [data setObject:self.cityTF.text forKey:@"city"];
        }
        if (self.stateTF.text.length > 0) {
            [data setObject:self.stateTF.text forKey:@"state"];
        }
    }
    
    if (self.todoCtl.itemList.count > 0) {
        [data setObject:self.todoCtl.itemList forKey:@"todo"];
    }
    
    
    if (self.model) {
        [data setObject:[NSNumber numberWithLongLong:self.model.objId] forKey:@"eventId"];
        
        [[SwingClient sharedClient] calendarEditEvent:data completion:^(id event,NSError *error) {
            if (!error) {
                
                [self.model mergeFromDictionary:[event toDictionary] useKeyMapping:YES error:nil];
                EventModel *m = event;
                self.model.todo = m.todo;
                
                [SVProgressHUD dismiss];
                if ([_delegate respondsToSelector:@selector(eventViewDidAdded:)]) {
                    [_delegate eventViewDidAdded:_model.startDate];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                LOG_D(@"calendarEditEvent fail: %@", error);
                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
            }
        }];
        return;
    }
    
    [[SwingClient sharedClient] calendarAddEvent:data completion:^(id event, NSError *error) {
        if (!error) {
            EventModel *m = event;
            [[GlobalCache shareInstance] postUpdateNotification:m.startDate];
            [SVProgressHUD dismiss];
            if ([_delegate respondsToSelector:@selector(eventViewDidAdded:)]) {
                UIDatePicker *datePicker = (UIDatePicker*)self.startTF.inputView;
                [_delegate eventViewDidAdded:datePicker.date];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            LOG_D(@"calendarAddEvent fail: %@", error);
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }
    }];
}



@end

//
//  AddEventViewController.m
//  Swing
//
//  Created by Mapple on 16/8/2.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "AddEventViewController.h"
#import "AlertSelectViewController.h"
#import "ChoicesViewController.h"
#import "CommonDef.h"
#import "KeyboardManager.h"

@interface AddEventViewController ()<UITextFieldDelegate>
{
    BOOL isAddTip;
}

@property (nonatomic, strong) AlertModel* alert;

@end

@implementation AddEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.repeatTF.enabled = NO;
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    datePicker.minimumDate = [NSDate date];
//    datePicker.minuteInterval = 5;
    self.startTF.inputView = datePicker;
    [datePicker addTarget:self action:@selector(startChange:) forControlEvents:UIControlEventValueChanged];
    
    UIDatePicker *datePicker2 = [[UIDatePicker alloc] init];
    datePicker2.datePickerMode = UIDatePickerModeTime;
    datePicker2.minimumDate = [datePicker.date dateByAddingTimeInterval:30 * 60];
//    datePicker2.minuteInterval = 5;
    self.endTF.inputView = datePicker2;
    [datePicker2 addTarget:self action:@selector(endChange:) forControlEvents:UIControlEventValueChanged];
    
    self.alertTF.delegate = self;
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
    
    if (self.model) {
        self.nameTF.text = self.model.eventName;
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"alert" ofType:@"json"];
        NSArray *alertArray = [AlertModel arrayOfModelsFromString:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] error:nil];
        for (AlertModel *m in alertArray) {
            if ([m.value intValue] == self.model.alert) {
                self.alertTF.text = m.text;
                break;
            }
        }
        self.descTF.text = self.model.desc;
        self.stateTF.text = self.model.state;
        self.cityTF.text = self.model.city;
        
        self.startTF.text = [Fun dateToString:self.model.startDate];;
        self.endTF.text = [Fun dateToString:self.model.endDate];
        
        self.colorCtl.selectedColor = self.model.color;
        [self.todoCtl setItemList:self.model.todo];
    }
    else {
        self.startTF.text = [Fun dateToString:datePicker.minimumDate];
        self.endTF.text = [Fun dateToString:datePicker2.minimumDate];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (textField == self.alertTF) {
        [[IQKeyboardManager sharedManager] resignFirstResponder];
        AlertSelectViewController *ctl = [[AlertSelectViewController alloc] initWithStyle:UITableViewStylePlain];
        ctl.delegate = self;
        [self.navigationController pushViewController:ctl animated:YES];
        return NO;
    }
    else if (textField == self.repeatTF) {
        [[IQKeyboardManager sharedManager] resignFirstResponder];
        ChoicesViewController *ctl = [[ChoicesViewController alloc] initWithStyle:UITableViewStylePlain];
        ctl.delegate = self;
        ctl.navigationItem.title = self.repeatTF.placeholder;
        ctl.textArray = @[@"", @"Daily repeat", @"Weekly repeat", @"Monthly repeat"];
        [self.navigationController pushViewController:ctl animated:YES];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)choicesViewControllerDidSelected:(NSString*)text {
    self.repeatTF.text = text;
    [[IQKeyboardManager sharedManager] resignFirstResponder];
}

- (void)alertSelectViewControllerDidSelected:(AlertModel*)alert {
    self.alert = alert;
    self.alertTF.text = alert.text;
    
}

- (void)startChange:(UIDatePicker*)datePicker {
    self.startTF.text = [Fun dateToString:datePicker.date];
    UIDatePicker* dp = (UIDatePicker*)self.endTF.inputView;
    dp.minimumDate = [datePicker.date dateByAddingTimeInterval:30 * 60];
    if (NSOrderedDescending == [dp.date compare:datePicker.date]) {
//        dp.date = datePicker.date;
        self.endTF.text = [Fun dateToString:dp.minimumDate];
    }
    
}

- (void)endChange:(UIDatePicker*)datePicker {
    self.endTF.text = [Fun dateToString:datePicker.date];
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
        [Fun showMessageBoxWithTitle:@"Error" andMessage:@"Please input info."];
        if (!isAddTip) {
            isAddTip = YES;
            [self addRedTip:self.nameTF];
            [self addRedTip:self.startTF];
            [self addRedTip:self.endTF];
        }
        return NO;
    }
    
//    if ([self.startTF.text isEqualToString:self.endTF.text]) {
//        [Fun showMessageBoxWithTitle:@"Error" andMessage:@"Event time is valid."];
//        return NO;
//    }
    
    if (self.todoCtl.itemList.count == 0) {
        [Fun showMessageBoxWithTitle:@"Error" andMessage:@"Please input to do list."];
        return NO;
    }
    
    return YES;
}

- (IBAction)saveAction:(id)sender {
    if ([self validateTextField]) {
        [SVProgressHUD showWithStatus:@"Saving, please wait..."];
        
        //eventName, startDate, endDate, color, status, description, alert, city, state
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        [data addEntriesFromDictionary:@{@"eventName":self.nameTF.text , @"startDate":self.startTF.text
                                        , @"endDate":self.endTF.text
                                        , @"color":[Fun stringFromColor:self.colorCtl.selectedColor]}];
        if (self.descTF.text.length > 0) {
            [data setObject:self.descTF.text forKey:@"description"];
        }
        if (self.alert.text.length > 0) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"alert" ofType:@"json"];
            NSArray *alertArray = [AlertModel arrayOfModelsFromString:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] error:nil];
            for (AlertModel *m in alertArray) {
                if ([m.text isEqualToString:self.alertTF.text]) {
                    [data setObject:m.value forKey:@"alert"];
                    break;
                }
            }
            
        }
        if (self.cityTF.text.length > 0) {
            [data setObject:self.cityTF.text forKey:@"city"];
        }
        if (self.stateTF.text.length > 0) {
            [data setObject:self.stateTF.text forKey:@"state"];
        }
        
        if (self.model) {
            [data setObject:[NSNumber numberWithInt:self.model.objId] forKey:@"id"];
            [[SwingClient sharedClient] calendarEditEvent:data completion:^(NSError *error) {
                if (!error) {
                    self.model.eventName = data[@"eventName"];
                    self.model.alert = [data[@"alert"] intValue];
                    self.model.city = data[@"city"];
                    self.model.state = data[@"state"];
                    self.model.desc = data[@"description"];
                    self.model.color = _colorCtl.selectedColor;
                    UIDatePicker *datePicker = (UIDatePicker*)self.startTF.inputView;
                    self.model.startDate = datePicker.date;
                    UIDatePicker *datePicker2 = (UIDatePicker*)self.endTF.inputView;
                    self.model.endDate = datePicker2.date;
                    
                    [[SwingClient sharedClient] calendarAddTodo:[NSString stringWithFormat:@"%d", _model.objId] todoList:[self.todoCtl.itemList componentsJoinedByString:@"|"] completion:^(id event, NSArray<ToDoModel> *todoArray, NSError *error) {
                        if (!error) {
//                            [[GlobalCache shareInstance] addEvent:event];
                            self.model.todo = todoArray;
                            [SVProgressHUD dismiss];
                            if ([_delegate respondsToSelector:@selector(eventViewDidAdded:)]) {
                                UIDatePicker *datePicker = (UIDatePicker*)self.startTF.inputView;
                                [_delegate eventViewDidAdded:datePicker.date];
                            }
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                        else {
                            LOG_D(@"calendarAddTodo fail: %@", error);
                            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                        }
                    }];
                }
                else {
                    LOG_D(@"calendarAddEvent fail: %@", error);
                    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                }
            }];
            return;
        }
        
        [[SwingClient sharedClient] calendarAddEvent:data completion:^(id event, NSError *error) {
            if (!error) {
                EventModel *model = event;
                [[SwingClient sharedClient] calendarAddTodo:[NSString stringWithFormat:@"%d", model.objId] todoList:[self.todoCtl.itemList componentsJoinedByString:@"|"] completion:^(id event, NSArray *todoArray, NSError *error) {
                    if (!error) {
                        [[GlobalCache shareInstance] addEvent:event];
                        [SVProgressHUD dismiss];
                        if ([_delegate respondsToSelector:@selector(eventViewDidAdded:)]) {
                            UIDatePicker *datePicker = (UIDatePicker*)self.startTF.inputView;
                            [_delegate eventViewDidAdded:datePicker.date];
                        }
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    else {
                        LOG_D(@"calendarAddTodo fail: %@", error);
                        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                    }
                }];
            }
            else {
                LOG_D(@"calendarAddEvent fail: %@", error);
                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
            }
        }];
    }
}

@end

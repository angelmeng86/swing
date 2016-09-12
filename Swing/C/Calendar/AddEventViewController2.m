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

@interface AddEventViewController2 ()<UITextFieldDelegate>
{
    BOOL isAddTip;
}

@property (nonatomic, strong) AlertModel* alert;

@end

@implementation AddEventViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.repeatTF.enabled = NO;
    self.stateTF.enabled = NO;
    self.cityTF.enabled = NO;
    
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
    if (self.model) {
        self.nameTF.text = self.model.eventName;
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"alert" ofType:@"json"];
        NSArray *alertArray = [AlertModel arrayOfModelsFromString:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] error:nil];
        for (AlertModel *m in alertArray) {
            if ([m.value intValue] == self.model.alert) {
                self.nameTF.text = m.text;
                break;
            }
        }
        
        self.startTF.text = [Fun dateToString:self.model.startDate];;
        self.endTF.text = [Fun dateToString:self.model.endDate];
        
        self.colorCtl.selectedColor = self.model.color;
        
        self.descTF.text = self.model.desc;
        self.stateTF.text = self.model.state;
        self.cityTF.text = self.model.city;
        
        [self.todoCtl setItemList:self.model.todo];
        
        if (self.model.desc.length > 0 ||
            self.model.state.length > 0 ||
            self.model.city.length ||
            self.model.todo.count > 0) {
            [self changeAdvance:YES];
        }
    }
    else {
        self.startTF.text = [Fun dateToString:datePicker.minimumDate];
        self.endTF.text = [Fun dateToString:datePicker2.minimumDate];
    }
    
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStyleDone target:self action:@selector(testAction)];
}

- (void)testAction {
    BOOL hidden = self.todoCtl.hidden;
    [self changeAdvance:!hidden];
}

- (void)changeAdvance:(BOOL)show {
    BOOL hidden = !show;
    self.cityTF.hidden = hidden;
    self.stateTF.hidden = hidden;
    self.repeatTF.hidden = hidden;
    self.descTF.hidden = hidden;
    self.todoCtl.hidden = hidden;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (textField == self.nameTF) {
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
    self.nameTF.text = alert.text;
    
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
                if ([m.text isEqualToString:self.nameTF.text]) {
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
            if (self.todoCtl.itemList.count > 0) {
                [data setObject:[self.todoCtl.itemList componentsJoinedByString:@"|"] forKey:@"todoList"];
            }
            else {
                 [data setObject:@"" forKey:@"todoList"];
            }
            [[SwingClient sharedClient] calendarEditEvent:data completion:^(id event,NSError *error) {
                if (!error) {
                    
                    [self.model mergeFromDictionary:[event toDictionary] useKeyMapping:YES error:nil];
                    
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
                EventModel *model = event;
                
                if (self.todoCtl.itemList.count > 0) {
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
                    [[GlobalCache shareInstance] addEvent:event];
                    [SVProgressHUD dismiss];
                    if ([_delegate respondsToSelector:@selector(eventViewDidAdded:)]) {
                        UIDatePicker *datePicker = (UIDatePicker*)self.startTF.inputView;
                        [_delegate eventViewDidAdded:datePicker.date];
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            else {
                LOG_D(@"calendarAddEvent fail: %@", error);
                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
            }
        }];
    }
}

@end

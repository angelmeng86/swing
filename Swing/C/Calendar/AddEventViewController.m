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
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    datePicker.minimumDate = [NSDate date];
    datePicker.minuteInterval = 30;
    self.startTF.inputView = datePicker;
    [datePicker addTarget:self action:@selector(startChange:) forControlEvents:UIControlEventValueChanged];
    
    UIDatePicker *datePicker2 = [[UIDatePicker alloc] init];
    datePicker2.datePickerMode = UIDatePickerModeTime;
    datePicker2.minimumDate = [NSDate date];
    datePicker2.minuteInterval = 30;
    self.endTF.inputView = datePicker2;
    [datePicker2 addTarget:self action:@selector(endChange:) forControlEvents:UIControlEventValueChanged];
    
    self.alertTF.delegate = self;
    self.repeatTF.delegate = self;
    isAddTip = NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.alertTF) {
        AlertSelectViewController *ctl = [[AlertSelectViewController alloc] initWithStyle:UITableViewStylePlain];
        ctl.delegate = self;
        [self.navigationController pushViewController:ctl animated:YES];
    }
    else if (textField == self.repeatTF) {
        ChoicesViewController *ctl = [[ChoicesViewController alloc] initWithStyle:UITableViewStylePlain];
        ctl.delegate = self;
        ctl.navigationItem.title = self.repeatTF.placeholder;
        ctl.textArray = @[@"", @"Daily repeat", @"Weekly repeat", @"Monthly repeat"];
        [self.navigationController pushViewController:ctl animated:YES];
    }
    return NO;
}

- (void)choicesViewControllerDidSelected:(NSString*)text {
    self.repeatTF.text = text;
}

- (void)alertSelectViewControllerDidSelected:(AlertModel*)alert {
    self.alert = alert;
    self.alertTF.text = alert.text;
}

- (void)startChange:(UIDatePicker*)datePicker {
    self.startTF.text = [Fun dateToString:datePicker.date];
    UIDatePicker* dp = (UIDatePicker*)self.endTF.inputView;
    dp.minimumDate = datePicker.date;
    if (NSOrderedDescending == [dp.date compare:datePicker.date]) {
//        dp.date = datePicker.date;
        self.endTF.text = self.startTF.text;
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
    [label autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:view withOffset:2];
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
    
    if ([self.startTF.text isEqualToString:self.endTF.text]) {
        [Fun showMessageBoxWithTitle:@"Error" andMessage:@"Event time is valid."];
        return NO;
    }
    
    //if (self.todoCtl.itemList.count == 0) {
    //    [Fun showMessageBoxWithTitle:@"Error" andMessage:@"Please input to do list."];
    //    return NO;
    //}
    
    return YES;
}

- (IBAction)saveAction:(id)sender {
    if ([self validateTextField]) {
        [SVProgressHUD showWithStatus:@"Saving, please wait..."];
        
        //eventName, startDate, endDate, color, status, description, alert, city, state
        NSDictionary *data = @{@"eventName":self.nameTF.text , @"startDate":self.startTF.text
                               , @"endDate":self.endTF.text
                               , @"description":self.descTF.text
                               , @"alert":self.alert.value
                               , @"city":self.cityTF.text
                               , @"state":self.stateTF.text
                               , @"color":[Fun stringFromColor:self.colorCtl.selectedColor]};
        
        [[SwingClient sharedClient] calendarAddEvent:data completion:^(id event, NSError *error) {
            if (!error) {
                EventModel *model = event;
                [[SwingClient sharedClient] calendarAddTodo:[NSString stringWithFormat:@"%d", model.objId] todoList:[self.todoCtl.itemList componentsJoinedByString:@"|"] completion:^(id event, NSArray *todoArray, NSError *error) {
                    if (!error) {
                        [[GlobalCache shareInstance] addEvent:event];
                        [SVProgressHUD dismiss];
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

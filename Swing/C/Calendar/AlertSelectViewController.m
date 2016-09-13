//
//  AlertSelectViewController.m
//  Swing
//
//  Created by Mapple on 16/8/11.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "AlertSelectViewController.h"
#import "CommonDef.h"

@interface AlertSelectViewController () <UITextFieldDelegate>

@property (nonatomic, strong) NSArray *alertArray;

@end

@implementation AlertSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Select Event";//@"Alert";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"alert" ofType:@"json"];
    self.alertArray = [AlertModel arrayOfModelsFromString:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] error:nil];
    self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([_delegate respondsToSelector:@selector(alertSelectViewControllerDidSelected:)]) {
        AlertModel *m = _alertArray[0];
        m.text = textField.text;
        [_delegate alertSelectViewControllerDidSelected:m];
    }
    [self.navigationController popViewControllerAnimated:YES];
    return YES;
}

- (void)alertClickAction:(id)sender {
    [SVProgressHUD showInfoWithStatus:@"Event Will Have A Sound Alert"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _alertArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UITableViewCell *inputCell = [tableView dequeueReusableCellWithIdentifier:@"inputReuseIdentifier"];
        if (inputCell == nil) {
            inputCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"inputReuseIdentifier"];
            inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITextField *textField = [UITextField new];
            textField.font = [UIFont avenirFontOfSize:17];
            textField.placeholder = @"Customize Your Event";
            textField.returnKeyType = UIReturnKeyDone;
            [inputCell.contentView addSubview:textField];
            [textField autoSetDimension:ALDimensionHeight toSize:30];
            [textField autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
            [textField autoPinEdgeToSuperviewMargin:ALEdgeLeading];
            [textField autoPinEdgeToSuperviewMargin:ALEdgeTrailing];
            textField.delegate = self;
        }
        
        return inputCell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        //        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = [UIFont avenirFontOfSize:17];
        UIButton *btn = [UIButton new];
        btn.frame = CGRectMake(0, 0, 40, 40);
        [btn setImage:LOAD_IMAGE(@"alert_icon") forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(alertClickAction:) forControlEvents:UIControlEventTouchUpInside];
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:LOAD_IMAGE(@"alert_icon")];
        cell.accessoryView = btn;
    }
    
    AlertModel *model = _alertArray[indexPath.row];
    cell.textLabel.text = model.text;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(alertSelectViewControllerDidSelected:)]) {
        [_delegate alertSelectViewControllerDidSelected:_alertArray[indexPath.row]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end

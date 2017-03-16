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
    self.navigationItem.title = LOC_STR(@"Select Event");
    NSString *path = [[NSBundle mainBundle] pathForResource:@"alert2" ofType:@"json"];
    id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:kNilOptions error:NULL];
    if ([json isKindOfClass:[NSArray class]]) {
        self.alertArray = json;
    }

    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0 && [_delegate respondsToSelector:@selector(alertSelectViewControllerDidSelected:)]) {
        for (NSDictionary *dict in _alertArray) {
            NSArray *items = dict[@"items"];
            for (NSDictionary *item in items) {
                if ([[LOC_STR(item[@"text"]) lowercaseString] isEqualToString:[textField.text lowercaseString]]) {
                    AlertModel *m = [[AlertModel alloc] initWithDictionary:item error:NULL];
                    [_delegate alertSelectViewControllerDidSelected:m];
                    [self.navigationController popViewControllerAnimated:YES];
                    return YES;
                }
            }
        }
        
        NSDictionary *item = _alertArray[0];
        NSArray *items = item[@"items"];
        NSDictionary *model = items[0];
        AlertModel *m = [[AlertModel alloc] initWithDictionary:model error:NULL];
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
    return self.alertArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSDictionary *item = _alertArray[section];
    NSArray *items = item[@"items"];
    return items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 40;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    NSDictionary *item = _alertArray[section];
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor whiteColor];
    label.text = LOC_STR(item[@"text"]);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldAvenirFontOfSize:17];
    label.textColor = COMMON_TITLE_COLOR;
    
    UIView *topLine = [UIView new];
    [label addSubview:topLine];
    [topLine autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [topLine autoSetDimension:ALDimensionHeight toSize:1];
    topLine.backgroundColor = RGBA(0xc8, 0xc7, 0xcc, 1.0f);
    
    UIView *downLine = [UIView new];
    [label addSubview:downLine];
    [downLine autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [downLine autoSetDimension:ALDimensionHeight toSize:1];
    downLine.backgroundColor = RGBA(0xc8, 0xc7, 0xcc, 1.0f);
    
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        UITableViewCell *inputCell = [tableView dequeueReusableCellWithIdentifier:@"inputReuseIdentifier"];
        if (inputCell == nil) {
            inputCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"inputReuseIdentifier"];
            
            inputCell.textLabel.textAlignment = NSTextAlignmentLeft;
            inputCell.textLabel.font = [UIFont avenirFontOfSize:17];
            inputCell.textLabel.textColor = RGBA(0x97, 0x96, 0x97, 1.0f);
            inputCell.textLabel.adjustsFontSizeToFitWidth = YES;
            /*
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
             */
        }
        NSDictionary *item = _alertArray[indexPath.section];
        NSArray *items = item[@"items"];
        NSDictionary *model = items[indexPath.row];
        inputCell.textLabel.text = LOC_STR(model[@"text"]);
        return inputCell;
    }
    
    if (indexPath.section == 1) {
        UITableViewCell *alarmcell = [tableView dequeueReusableCellWithIdentifier:@"alarmreuseIdentifier"];
        if (alarmcell == nil) {
            alarmcell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"alarmreuseIdentifier"];
            alarmcell.textLabel.textAlignment = NSTextAlignmentLeft;
            //        cell.selectionStyle = UITableViewCellSelectionStyleGray;
            alarmcell.textLabel.font = [UIFont avenirFontOfSize:17];
            alarmcell.textLabel.textColor = RGBA(0x97, 0x96, 0x97, 1.0f);
            UIButton *btn = [UIButton new];
            btn.frame = CGRectMake(0, 0, 40, 40);
            [btn setImage:LOAD_IMAGE(@"clock_icon") forState:UIControlStateNormal];
//            [btn addTarget:self action:@selector(alertClickAction:) forControlEvents:UIControlEventTouchUpInside];
            //        UIImageView *imageView = [[UIImageView alloc] initWithImage:LOAD_IMAGE(@"alert_icon")];
            alarmcell.accessoryView = btn;
        }
        NSDictionary *item = _alertArray[indexPath.section];
        NSArray *items = item[@"items"];
        NSDictionary *model = items[indexPath.row];
        alarmcell.textLabel.text = LOC_STR(model[@"text"]);
        return alarmcell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        //        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = [UIFont avenirFontOfSize:17];
        cell.textLabel.textColor = RGBA(0x97, 0x96, 0x97, 1.0f);
        UIButton *btn = [UIButton new];
        btn.frame = CGRectMake(0, 0, 40, 40);
        [btn setImage:LOAD_IMAGE(@"alert_icon") forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(alertClickAction:) forControlEvents:UIControlEventTouchUpInside];
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:LOAD_IMAGE(@"alert_icon")];
        cell.accessoryView = btn;
    }
    
    NSDictionary *item = _alertArray[indexPath.section];
    NSArray *items = item[@"items"];
    NSDictionary *model = items[indexPath.row];
//    AlertModel *model = _alertArray[indexPath.row];
    cell.textLabel.text = LOC_STR(model[@"text"]);
//    cell.accessoryView.hidden = [model[@"value"] intValue] > 73;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(alertSelectViewControllerDidSelected:)]) {
        NSDictionary *item = _alertArray[indexPath.section];
        NSArray *items = item[@"items"];
        NSDictionary *model = items[indexPath.row];
        
        [_delegate alertSelectViewControllerDidSelected:[[AlertModel alloc] initWithDictionary:model error:NULL]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end

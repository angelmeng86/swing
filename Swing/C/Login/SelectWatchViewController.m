//
//  SelectWatchViewController.m
//  Swing
//
//  Created by Mapple on 16/7/21.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SelectWatchViewController.h"
#import "DeviceTableViewCell.h"
#import "CommonDef.h"
#import "BLEClient.h"
#import "KidBindViewController.h"

@interface SelectWatchViewController ()<DeviceTableViewCellDelegate>
{
    BLEClient *client;
}

@property (strong, nonatomic) NSMutableArray *peripherals;

@end

@implementation SelectWatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = bgView;
    
    self.label1.adjustsFontSizeToFitWidth = YES;
    
    self.label1.text = LOC_STR(@"Please select your Swing Watch");
    self.peripherals = [NSMutableArray array];
    self.navigationItem.title = nil;
    [self setCustomBackButton];
}

- (void)backAction {
    NSUInteger count = self.navigationController.viewControllers.count;
    if(count > 2) {
        [self.navigationController popToViewController:self.navigationController.viewControllers[count - 3] animated:YES];
    }
    else {
        [super backAction];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
#if TARGET_IPHONE_SIMULATOR
    
#else
    client = [[BLEClient alloc] init];
    [client scanDeviceWithCompletion:^(CBPeripheral *peripheral, NSDictionary *advertisementData, NSError *error) {
        if (!error) {
            if (peripheral && ![_peripherals containsObject:peripheral]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_peripherals.count inSection:0];
                [_peripherals addObject:peripheral];
                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
        else {
            LOG_D(@"scanDeviceWithCompletion:%@", error);
            [self backAction];
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }
    }];
#endif
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.peripherals = [NSMutableArray array];
    [self.tableView reloadData];
    [client stopScan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#if TARGET_IPHONE_SIMULATOR
    return 2;
#else
    return _peripherals.count;
#endif
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"DeviceCell";
    DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
#if TARGET_IPHONE_SIMULATOR
    if (indexPath.row == 0) {
        cell.titleLabel.text = @"SWING WATCH 123DAF523";
    }
    else {
        cell.titleLabel.text = @"SWING WATCH 568DANG5E";
    }
#else
    CBPeripheral *peripheral = [_peripherals objectAtIndex:indexPath.row];
    cell.titleLabel.text = peripheral.name;
#endif
    return cell;
}

- (void)deviceTableViewCellDidClicked:(DeviceTableViewCell*)cell {
#if TARGET_IPHONE_SIMULATOR
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
    KidBindViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"KidBind"];
    ctl.macAddress = [Fun hexToData:@"012345678915"];
    [self.navigationController pushViewController:ctl animated:YES];
#else
    [client stopScan];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CBPeripheral *peripheral = [_peripherals objectAtIndex:indexPath.row];
    
    [SVProgressHUD showWithStatus:LOC_STR(@"Syncing")];
    [client initDevice:peripheral completion:^(NSData *macAddress, NSError *error) {
        if (!error) {
            [SVProgressHUD dismiss];
            UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
            KidBindViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"KidBind"];
            ctl.macAddress = macAddress;
            [self.navigationController pushViewController:ctl animated:YES];
        }
        else {
            LOG_D(@"initDevice fail: %@", error);
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }
    }/* update:^(float percent, NSString *remainTime) {
        [SVProgressHUD showProgress:percent status:[@"Update Device, Time remaining : " stringByAppendingString:remainTime]];
    }*/];
#endif
}

@end

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

#define SHOW_MACADDRESS

@interface SelectWatchViewController ()<DeviceTableViewCellDelegate>
{
    BLEClient *client;
}

@property (strong, nonatomic) NSMutableArray *peripherals;

@property (strong, nonatomic) NSMutableDictionary *macAddressDict;
@property (strong, nonatomic) NSMutableDictionary *versionDict;
@property (strong, nonatomic) NSMutableArray *tasks;

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
    self.macAddressDict = [NSMutableDictionary dictionary];
    self.versionDict = [NSMutableDictionary dictionary];
    self.tasks = [NSMutableArray array];
    self.navigationItem.title = nil;
    [self setCustomBackButton];
}

- (void)cancelTasks {
    for (NSURLSessionDataTask *task in _tasks) {
        [task cancel];
    }
    self.tasks = [NSMutableArray array];
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
#ifdef SHOW_MACADDRESS
    [client scanDeviceMacAddressWithCompletion:^(CBPeripheral *peripheral, NSData *macAddress, NSString* version, NSError *error) {
        if (!error) {
            if (peripheral && ![_peripherals containsObject:peripheral]) {
                
                [[SwingClient sharedClient] whoRegisteredMacID:[Fun dataToHex:macAddress] completion:^(id kid, NSError *error) {
                    if (!error) {
                        if (kid) {
                            LOG_D(@"%@ is registed.", macAddress);
                        }
                        else {
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_peripherals.count inSection:0];
                            [_peripherals addObject:peripheral];
                            self.macAddressDict[peripheral] = macAddress;
                            self.versionDict[peripheral] = version;
                            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                        }
                    }
                    else {
                        LOG_D(@"whoRegisteredMacID error:%@", error);
                    }
                }];
                /*
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_peripherals.count inSection:0];
                [_peripherals addObject:peripheral];
                self.macAddressDict[peripheral] = macAddress;
                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                 */
            }
        }
        else {
            LOG_D(@"scanDeviceMacIdWithCompletion:%@", error);
            [self backAction];
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }
    }];
#else
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
    
#endif
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.peripherals = [NSMutableArray array];
    self.macAddressDict = [NSMutableDictionary dictionary];
    self.versionDict = [NSMutableDictionary dictionary];
    [self.tableView reloadData];
#ifdef SHOW_MACADDRESS
    [client stopScanMacAddress];
    [self cancelTasks];
#else
    [client stopScan];
#endif
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
    if (self.macAddressDict[peripheral]) {
        NSString *mac = [Fun dataToHex:self.macAddressDict[peripheral]];
        NSMutableString *macShow = [NSMutableString string];
        for (int i = 0; i < mac.length; i+=2) {
            [macShow appendString:[mac substringWithRange:NSMakeRange(i, 2)]];
            if (i + 2 < mac.length) {
                [macShow appendString:@":"];
            }
        }
        cell.titleLabel.text = [peripheral.name stringByAppendingFormat:@"-%@", macShow];
    }
    else {
        cell.titleLabel.text = peripheral.name;
    }
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
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CBPeripheral *peripheral = [_peripherals objectAtIndex:indexPath.row];
    
#ifdef SHOW_MACADDRESS
    [client stopScanMacAddress];
    if (self.macAddressDict[peripheral]) {
        UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
        KidBindViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"KidBind"];
        ctl.macAddress = self.macAddressDict[peripheral];
        ctl.version = self.versionDict[peripheral];
        [self.navigationController pushViewController:ctl animated:YES];
    }
#else
    
    [client stopScan];
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
    
#endif
}

@end

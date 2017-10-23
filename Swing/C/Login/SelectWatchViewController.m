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
#import "AskStepViewController.h"

#define SHOW_MACADDRESS

@interface SelectWatchViewController ()<DeviceTableViewCellDelegate>
{
    BLEClient *client;
}

@property (strong, nonatomic) NSMutableArray *peripherals;

@property (strong, nonatomic) NSMutableDictionary *macAddressDict;
@property (strong, nonatomic) NSMutableDictionary *versionDict;
@property (strong, nonatomic) NSMutableDictionary *kidDict;
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
    self.kidDict = [NSMutableDictionary dictionary];
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
                
                NSURLSessionDataTask *task = [[SwingClient sharedClient] whoRegisteredMacID:[Fun dataToHex:macAddress] completion:^(KidModel *kid, NSError *error) {
                    if (!error) {
                        if (kid) {
                            LOG_D(@"%@ is registed.", macAddress);
                            if ([GlobalCache shareInstance].user.objId == kid.parent.objId) {
                                LOG_D(@"Current user is registed.");
                                return;
                            }
                            self.kidDict[peripheral] = kid;
                            
                        }
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_peripherals.count inSection:0];
                        [_peripherals addObject:peripheral];
                        self.macAddressDict[peripheral] = macAddress;
                        self.versionDict[peripheral] = version;
                        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                    else {
                        LOG_D(@"whoRegisteredMacID error:%@", error);
                    }
                }];
                [self.tasks addObject:task];
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
    self.kidDict = [NSMutableDictionary dictionary];
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
    cell.iconView.image = LOAD_IMAGE(@"icon_profile");
    if (self.kidDict[peripheral]) {
        KidModel *kid = self.kidDict[peripheral];
        cell.titleLabel.text = kid.name;
        
        if (kid.profile) {
            [cell.iconView sd_setImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:kid.profile]] placeholderImage:LOAD_IMAGE(@"icon_profile")];
        }
        
        [cell.btn setImage:LOAD_IMAGE(@"icon_request") forState:UIControlStateNormal];
    }
    else if (self.macAddressDict[peripheral]) {
        NSString *mac = [Fun dataToHex:self.macAddressDict[peripheral]];
        NSMutableString *macShow = [NSMutableString string];
        for (int i = 0; i < mac.length; i+=2) {
            [macShow appendString:[mac substringWithRange:NSMakeRange(i, 2)]];
            if (i + 2 < mac.length) {
                [macShow appendString:@":"];
            }
        }
        cell.titleLabel.text = [peripheral.name stringByAppendingFormat:@"-%@", macShow];
        
        [cell.btn setImage:LOAD_IMAGE(@"icon_add") forState:UIControlStateNormal];
    }
    else {
        cell.titleLabel.text = peripheral.name;
    }
#endif
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectAction:indexPath];
}

- (void)deviceTableViewCellDidClicked:(DeviceTableViewCell*)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self selectAction:indexPath];
}

- (void)selectAction:(NSIndexPath*)indexPath
{
#if TARGET_IPHONE_SIMULATOR
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
    KidBindViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"KidBind"];
    ctl.macAddress = [Fun hexToData:@"012345678915"];
    [self.navigationController pushViewController:ctl animated:YES];
#else
    CBPeripheral *peripheral = [_peripherals objectAtIndex:indexPath.row];
    
#ifdef SHOW_MACADDRESS
    [client stopScanMacAddress];
    if (self.kidDict[peripheral]) {
        KidModel *kid = self.kidDict[peripheral];
        UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
        AskStepViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"AskStep"];
        ctl.type = AskTypeWatchRegisted;
        ctl.kid = kid;
        [self.navigationController pushViewController:ctl animated:YES];
    }
    else if (self.macAddressDict[peripheral]) {
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

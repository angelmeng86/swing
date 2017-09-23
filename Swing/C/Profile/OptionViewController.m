//
//  OptionViewController.m
//  Swing
//
//  Created by Mapple on 2017/2/11.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "OptionViewController.h"
#import "ChoicesViewController.h"
#import "AppDelegate.h"
#import "CommonDef.h"
#import "SyncNavViewController.h"
#import "SearchDeviceViewController.h"

@interface OptionViewController ()
{
    NSArray *items;
}

@end

@implementation OptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = LOC_STR(@"Option");
    
    items = @[@[LOC_STR(@"Edit Profile"), LOC_STR(@"Edit Your Kid's Profile"), LOC_STR(@"Reset Password"), LOC_STR(@"Logout")], @[LOC_STR(@"Language"), LOC_STR(@"Swing watch update"), LOC_STR(@"Contact Us"), LOC_STR(@"User Guide"), LOC_STR(@"Version")]];
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [items[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    
    UILabel *label = [UILabel new];
    label.text = section == 0 ? LOC_STR(@"Account") : LOC_STR(@"About");
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont boldAvenirFontOfSize:17];
    label.textColor = COMMON_TITLE_COLOR;
    [view addSubview:label];
    [label autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    
    view.backgroundColor = COMMON_BACKGROUND_COLOR;
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"reuseIdentifier"];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        //        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont avenirFontOfSize:16];
        cell.textLabel.textColor = RGBA(0x97, 0x96, 0x97, 1.0f);
        
        cell.detailTextLabel.font = [UIFont avenirFontOfSize:16];
        cell.detailTextLabel.textColor = RGBA(0x97, 0x96, 0x97, 1.0f);
    }
    
    NSArray *array = items[indexPath.section];
    cell.detailTextLabel.textColor = RGBA(0x97, 0x96, 0x97, 1.0f);
    if (indexPath.section == 1 && indexPath.row == array.count - 1) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        // app版本
        NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        cell.detailTextLabel.text = app_Version;
    }
    else if(indexPath.section == 1 && indexPath.row == 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = nil;
        if ([GlobalCache shareInstance].firmwareVersion.version.length > 0 && [GlobalCache shareInstance].local.firmwareVer.length > 0 && ![[GlobalCache shareInstance].local.firmwareVer isEqualToString:[GlobalCache shareInstance].firmwareVersion.version]) {
            cell.detailTextLabel.text = @"1";
            cell.detailTextLabel.textColor = [UIColor redColor];
        }
        else {
            cell.detailTextLabel.text = nil;
        }
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = nil;
    }
    
    cell.textLabel.text = array[indexPath.row];
  
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
                    UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"EditProfile2"];
                    [self.navigationController pushViewController:ctl animated:YES];
                }
                    break;
                case 1:
                {
                    if (![GlobalCache shareInstance].kid) {
                        [SVProgressHUD showErrorWithStatus:LOC_STR(@"you have not bind device yet, please sync a watch.")];
                        return;
                    }
                    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
                    UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"EditKid"];
                    [self.navigationController pushViewController:ctl animated:YES];
                }
                    break;
                case 2:
                {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LOC_STR(@"Reset Password") message:LOC_STR(@"Are you sure you want to reset your password?") preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alertController addAction:[UIAlertAction actionWithTitle:LOC_STR(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                        
                    }]];
                    [alertController addAction:[UIAlertAction actionWithTitle:LOC_STR(@"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [SVProgressHUD show];
                        [[SwingClient sharedClient] sendResetPasswordEmailWithCompletion:^(NSError *error) {
                            if(!error) {
                                [SVProgressHUD dismiss];
                                [Fun showMessageBox:LOC_STR(@"") andFormat:LOC_STR(@"Please check your email at '%@' for the link to reset your password.This link will expire in 24 hours"), [GlobalCache shareInstance].user.email];
                            }
                            else {
                            LOG_D(@"sendResetPasswordEmailWithCompletion fail: %@", error);
                                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                            }
                        }];
                    }]];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
                    break;
                case 3:
                    [[GlobalCache shareInstance] logout];
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                    [self languageAction];
                    break;
                case 1:
                {
                    if ([GlobalCache shareInstance].firmwareVersion.version.length > 0 && [GlobalCache shareInstance].local.firmwareVer.length > 0 && ![[GlobalCache shareInstance].local.firmwareVer isEqualToString:[GlobalCache shareInstance].firmwareVersion.version]) {
                        [self checkFirmwareVerison];
                    }
                    else {
                        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                   
                }
                    break;
                case 2:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[GlobalCache shareInstance].cacheSupportUrl]];
//                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.imaginarium.info"]];
                    break;
                case 3:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://childrenlab.s3.amazonaws.com/pdf/Swing_User_Guide.pdf"]];
                    break;
                case 4:
                    
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}

- (void)checkFirmwareVerison {
    [SVProgressHUD show];
    [[SwingClient sharedClient] getFirmwareVersionWithCompletion:^(FirmwareVersion *version, NSError *error) {
        if (!error) {
            [GlobalCache shareInstance].firmwareVersion = version;
            __block BOOL isDownloaded = NO;
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            configuration.timeoutIntervalForRequest = 30;
            AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
            
            NSURL *URL = [NSURL URLWithString:[FILE_BASE_URL stringByAppendingString:version.fileAUrl]];
            NSURLRequest *request1 = [NSURLRequest requestWithURL:URL];
            
            NSURLSessionDownloadTask *downloadTask1 = [manager downloadTaskWithRequest:request1 progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                return [documentsDirectoryURL URLByAppendingPathComponent:[version.version stringByAppendingString:@"_A.hex"]];
                //                                return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                LOG_D(@"FileA response:%@", response);
                if (!error) {
                    LOG_D(@"FileA downloaded to: %@", filePath);
                    if (isDownloaded) {
                        [self syncAction];
                    }
                    else {
                        isDownloaded = YES;
                    }
                }
                else {
                    LOG_D(@"FileA download err: %@", error);
                    [SVProgressHUD showErrorWithStatus:LOC_STR(@"download failed.")];
                }
                
            }];
            [downloadTask1 resume];
            
            URL = [NSURL URLWithString:[FILE_BASE_URL stringByAppendingString:version.fileBUrl]];
            NSURLRequest *request2 = [NSURLRequest requestWithURL:URL];
            NSURLSessionDownloadTask *downloadTask2 = [manager downloadTaskWithRequest:request2 progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                return [documentsDirectoryURL URLByAppendingPathComponent:[version.version stringByAppendingString:@"_B.hex"]];
                //                                return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                LOG_D(@"FileB response:%@", response);
                if (!error) {
                    LOG_D(@"FileB downloaded to: %@", filePath);
                    if (isDownloaded) {
                        [self syncAction];
                    }
                    else {
                        isDownloaded = YES;
                    }
                }
                else {
                    LOG_D(@"FileB download err: %@", error);
                    [SVProgressHUD showErrorWithStatus:LOC_STR(@"download failed.")];
                }
            }];
            [downloadTask2 resume];
        }
        else {
            LOG_D(@"getFirmwareVersion err %@", error);
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }
    }];
}

- (void)syncAction {
    if ([GlobalCache shareInstance].kid) {
        [SVProgressHUD dismiss];
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"SyncDevice" bundle:nil];
        SearchDeviceViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"Syncing"];
        ctl.needUpdate = YES;
        SyncNavViewController *navCtl = [[SyncNavViewController alloc] initWithRootViewController:ctl];
        [self presentViewController:navCtl animated:YES completion:nil];
    }
    else {
        [SVProgressHUD showErrorWithStatus:LOC_STR(@"you have not bind device yet, please sync a watch.")];
    }
}

- (void)languageAction {
    ChoicesViewController *ctl = [[ChoicesViewController alloc] initWithStyle:UITableViewStylePlain];
    ctl.delegate = self;
    ctl.navigationItem.title = LOC_STR(@"Language");
    ctl.textArray = @[LOC_STR(@"English"), LOC_STR(@"Spanish"), LOC_STR(@"Russian"), LOC_STR(@"Japanese"), LOC_STR(@"Chinese Traditional")];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)choicesViewControllerDidSelectedIndex:(int)index {
    NSString *lang = @"en";
    switch (index) {
        case 1:
            lang = @"es";
            break;
        case 2:
            lang = @"ru";
            break;
        case 3:
            lang = @"ja";
            break;
        case 4:
            lang = @"zh-Hant";
            break;
        default:
            break;
    }
    [GlobalCache shareInstance].local.language = lang;
    [[GlobalCache shareInstance] saveInfo];
    [self performSelector:@selector(goToMain) withObject:nil afterDelay:0.5];
}

- (void)goToMain {
    [GlobalCache shareInstance].cacheLang = nil;
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab2" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateInitialViewController];
    AppDelegate *ad = (AppDelegate*)[UIApplication sharedApplication].delegate;
    ad.window.rootViewController = ctl;
    
    [[SwingClient sharedClient] updateLanguageWithCompletion:^(NSError *error) {
        if (error) {
            LOG_D(@"update language err:%@", error);
        }
    }];
}


@end

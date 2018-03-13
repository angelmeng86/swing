//
//  LMTabBarController2.m
//  Swing
//
//  Created by Mapple on 16/8/10.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMTabBarController2.h"
#import "UIImage+wiRoundedRectImage.h"
#import "CommonDef.h"
#import "LFDevicesActionSheet.h"
#import "MutiConfirmViewController.h"
#import "JPNoticeViewController.h"

@interface LMTabBarController2 ()<UITabBarControllerDelegate>
{
    id <SDWebImageOperation> runOperation;
}

@property (nonatomic, assign) UIViewController *syncDialog;

@end

@implementation LMTabBarController2

- (void)awakeFromNib {
    [super awakeFromNib];
    
    for (UITabBarItem *item in self.tabBar.items) {
        item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        item.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = [item.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    int i = 0;
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
    for (UINavigationController *navCtl in self.viewControllers) {
        if(i == 3) {
            i++;
        }
        
        if(i == 2) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Dashboard" bundle:nil];
            UIViewController *ctl = [sb instantiateInitialViewController];
            [navCtl setViewControllers:@[ctl] animated:NO];
            i++;
            continue;
        }
        else if(i == 4) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
            UIViewController *ctl = [sb instantiateInitialViewController];
            [navCtl setViewControllers:@[ctl] animated:NO];
            i++;
            continue;
        }
        UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"SwingTab%d", i]];
        [navCtl setViewControllers:@[ctl] animated:NO];
        i++;
    }
    
    
}

- (BOOL)checkIsDoubleClick:(UIViewController *)viewController
{
    static UIViewController *lastViewController = nil;
    static NSTimeInterval lastClickTime = 0;
    
    if (lastViewController != viewController) {
        lastViewController = viewController;
        lastClickTime = [NSDate timeIntervalSinceReferenceDate];
        
        return NO;
    }
    
    NSTimeInterval clickTime = [NSDate timeIntervalSinceReferenceDate];
    if (clickTime - lastClickTime > 0.5 ) {
        lastClickTime = clickTime;
        return NO;
    }
    
    lastClickTime = clickTime;
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.viewControllers[1] == viewController) {
        [[SwingClient sharedClient] calendarGetAllEventsWithCompletion:^(NSArray *eventArray, NSError *error) {
            if(!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_LIST_UPDATE_NOTI object:nil];
            }
        }];
    }
    else if (tabBarController.viewControllers[2] == viewController) {
        [self showSyncDialog];
        //如果存在未上传的Activity，则进行后台上传操作。
        [[GlobalCache shareInstance] uploadActivity];
    }
    else if(tabBarController.viewControllers[3] == viewController) {
        [self newFirmwareVersion:nil];
        if ([self checkIsDoubleClick:viewController]) {
            [self selectDevice:(UINavigationController*)viewController];
        }
    }
}

- (void)showSyncDialog {
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"SyncDevice" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateInitialViewController];
    [self presentViewController:ctl animated:YES completion:nil];
    self.syncDialog = ctl;
}

- (void)showJPNotice {
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
    JPNoticeViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"JPNotice"];
    ctl.delegate = self;
    [self presentViewController:ctl animated:YES completion:nil];
}

- (void)noticeViewControllerBack {
    [self performSelector:@selector(showSyncDialog) withObject:nil afterDelay:0];
}

- (void)newFirmwareVersion:(NSNotification*)notification {
    UITabBarItem *item = [self.tabBar.items lastObject];
    if ([GlobalCache shareInstance].firmwareVersion.version.length > 0 && [GlobalCache shareInstance].currentKid.currentVersion.length > 0 && ![[GlobalCache shareInstance].currentKid.currentVersion isEqualToString:[GlobalCache shareInstance].firmwareVersion.version]) {
        item.badgeValue = @"1";
    }
    else {
        item.badgeValue = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[GlobalCache shareInstance] queryWeather];
    
    self.delegate = self;
    self.selectedIndex = 2;
    if ([GlobalCache shareInstance].local.showJPNoticTip) {
        [self performSelector:@selector(showJPNotice) withObject:nil afterDelay:0.3];
    }
    else {
        [self performSelector:@selector(showSyncDialog) withObject:nil afterDelay:0.3];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRemoteInfo:) name:REMOTE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newFirmwareVersion:) name:SWING_WATCH_NEW_UPDATE_NOTIFY object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadKidPicture) name:KID_AVATAR_NOTIFICATION object:nil];
    [self loadKidPicture];
    [self newFirmwareVersion:nil];
    
    /*
    NSString *url = @"https://github.com/angelmeng86/swing/archive/master.zip";
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = 30;
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request1 = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask1 = [manager downloadTaskWithRequest:request1 progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        LOG_D(@"FileA response:%@", response);
        if (!error) {
            LOG_D(@"FileA download err: %@", error);
        }
        else {
            LOG_D(@"FileA downloaded to: %@", filePath);
        }
        
    }];
    [downloadTask1 resume];
    
    URL = [NSURL URLWithString:url];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:URL];
    NSURLSessionDownloadTask *downloadTask2 = [manager downloadTaskWithRequest:request2 progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        LOG_D(@"FileB response:%@", response);
        if (!error) {
            LOG_D(@"FileB download err: %@", error);
        }
        else {
            LOG_D(@"FileB downloaded to: %@", filePath);
        }
    }];
    [downloadTask2 resume];
    */
    /*
    [[SwingClient sharedClient] getFirmwareVersionWithCompletion:^(FirmwareVersion *version, NSError *error) {
        if (!error) {
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            configuration.timeoutIntervalForRequest = 30;
            AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
            
            NSURL *URL = [NSURL URLWithString:[FILE_BASE_URL stringByAppendingString:version.fileAUrl]];
            NSURLRequest *request1 = [NSURLRequest requestWithURL:URL];
            
            NSURLSessionDownloadTask *downloadTask1 = [manager downloadTaskWithRequest:request1 progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                LOG_D(@"FileA response:%@", response);
                if (!error) {
                    LOG_D(@"FileA download err: %@", error);
                }
                else {
                    LOG_D(@"FileA downloaded to: %@", filePath);
                }
                
            }];
            [downloadTask1 resume];
            
            URL = [NSURL URLWithString:[FILE_BASE_URL stringByAppendingString:version.fileBUrl]];
            NSURLRequest *request2 = [NSURLRequest requestWithURL:URL];
            NSURLSessionDownloadTask *downloadTask2 = [manager downloadTaskWithRequest:request2 progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                LOG_D(@"FileB response:%@", response);
                if (!error) {
                    LOG_D(@"FileB download err: %@", error);
                }
                else {
                    LOG_D(@"FileB downloaded to: %@", filePath);
                }
            }];
            [downloadTask2 resume];
        }
        else {
            LOG_D(@"getFirmwareVersion err %@", error);
        }
    }];
    */
}

- (void)loadKidPicture
{
    UITabBarItem *item = [self.tabBar.items lastObject];
    UIImage *defaultImage = [UIImage createRoundedRectBlank:[UIColor whiteColor] size:CGSizeMake(84, 84) radius:42 scale:3.0f color:COMMON_TITLE_COLOR];
    item.image = [defaultImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    item.selectedImage = [LOAD_IMAGE(@"tab_profile_selected") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.selectedImage = item.image;
    if ([GlobalCache shareInstance].currentKid.profile) {
        if (runOperation) {
            [runOperation cancel];
        }
        __weak __typeof(self)wself = self;
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:[GlobalCache shareInstance].currentKid.profile]] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                if (!wself) return;
                if (image) {
                    UITabBarItem *item = [wself.tabBar.items lastObject];
                    UIImage *image2 = [UIImage createRoundedRectImage:image size:CGSizeMake(84, 84) radius:42 scale:3.0f color:COMMON_TITLE_COLOR];
                    item.image = [image2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    item.selectedImage = item.image;
                }
            });
        }];
        runOperation = operation;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleRemoteInfo:(NSNotification*)noti {
    self.selectedIndex = 1;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showSyncDialog) object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectDevice:(UINavigationController*)navCtl
{
    
    LFDevicesActionSheet *sheet = [LFDevicesActionSheet actionSheetViewWithBlock:^(LFDevicesActionSheet *actionSheet, KidInfo *kid) {
        if ([GlobalCache shareInstance].currentKid.objId != kid.objId)
        {
            UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
            MutiConfirmViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"MutiConfirm"];
            ctl.kid = kid;
            ctl.type = MutiConfirmTypeSwitch;
            [navCtl pushViewController:ctl animated:YES];
        }
    }];
    [sheet show];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

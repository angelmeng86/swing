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
        UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"SwingTab%d", i]];
        [navCtl setViewControllers:@[ctl] animated:NO];
        i++;
    }
    
    
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.viewControllers[2] == viewController) {
        [self showSyncDialog];
    }
}

- (void)showSyncDialog {
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"SyncDevice" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateInitialViewController];
    [self presentViewController:ctl animated:YES completion:nil];
    self.syncDialog = ctl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[GlobalCache shareInstance] queryWeather];
    
    self.delegate = self;
    self.selectedIndex = 2;
    [self performSelector:@selector(showSyncDialog) withObject:nil afterDelay:0.3];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRemoteInfo:) name:REMOTE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncDismiss) name:@"SYNC_DISMISS" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadKidPicture) name:KID_AVATAR_NOTIFICATION object:nil];
    [self loadKidPicture];
}

- (void)loadKidPicture
{
    UITabBarItem *item = [self.tabBar.items lastObject];
    UIImage *defaultImage = [UIImage createRoundedRectBlank:[UIColor whiteColor] size:CGSizeMake(84, 84) radius:42 scale:3.0f color:COMMON_TITLE_COLOR];
    item.image = [defaultImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    item.selectedImage = [LOAD_IMAGE(@"tab_profile_selected") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.selectedImage = item.image;
    if ([GlobalCache shareInstance].kid.profile) {
        if (runOperation) {
            [runOperation cancel];
        }
        __weak __typeof(self)wself = self;
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:[GlobalCache shareInstance].kid.profile]] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
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

- (void)syncDismiss {
    self.syncDialog = nil;
}

- (void)handleRemoteInfo:(NSNotification*)noti {
    self.selectedIndex = 1;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showSyncDialog) object:nil];
    if (self.syncDialog) {
        [self.syncDialog dismissViewControllerAnimated:YES completion:nil];
        self.syncDialog = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

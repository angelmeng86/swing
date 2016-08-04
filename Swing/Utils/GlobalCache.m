//
//  GlobalCache.m
//  GmatProject
//
//  Created by Mapple on 15-6-10.
//  Copyright (c) 2015年 Yan Cui. All rights reserved.
//

#import "GlobalCache.h"
#import "KeyboardManager.h"

@implementation GlobalCache

+ (GlobalCache*)shareInstance
{
    static GlobalCache* globalCache = nil;
    if (globalCache == nil) {
        globalCache = [[GlobalCache alloc] init];
    }
    return globalCache;
}

- (void)setKeyboradManager {
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.shouldResignOnTouchOutside = YES;
    manager.enableAutoToolbar = NO;
    
    //    [manager disableInViewControllerClass:[TagImageViewController class]];
    //    [manager disableInViewControllerClass:[PhotoDetailViewController class]];
    //    [manager disableInViewControllerClass:[LCUserFeedbackViewController class]];
}

- (void)initConfig {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [self setKeyboradManager];
    
    NSString *json = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    _info = [[LoginedModel alloc] initWithString:json error:nil];
}

- (void)setInfo:(LoginedModel *)info {
    _info = info;
    [self saveInfo];
}

- (void)saveInfo {
    [[NSUserDefaults standardUserDefaults] setObject:[_info toJSONString] forKey:@"token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)queryKids {
    self.kidsTask = [[SwingClient sharedClient] kidsListWithCompletion:^(NSArray *list, NSError *error) {
        if (error) {
            LOG_D(@"kidsListWithCompletion fail: %@", error);
        }
        else {
            self.kidsList = list;
            [[NSNotificationCenter defaultCenter] postNotificationName:KIDS_LIST_LOAD_NOTI object:list];
        }
    }];
}

- (id)init
{
    if (self = [super init]) {

    }
    return self;
}

@end

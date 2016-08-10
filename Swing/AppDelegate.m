//
//  AppDelegate.m
//  Swing
//
//  Created by Mapple on 16/7/13.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "AppDelegate.h"
#import "CommonDef.h"
#import "SwingClientTest.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[GlobalCache shareInstance] initConfig];
    
    //设置导航默认标题的颜色及字体大小
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:COMMON_TITLE_COLOR, NSFontAttributeName:[UIFont boldAvenirFontOfSize:18]};
    [UINavigationBar appearance].tintColor = COMMON_NAV_TINT_COLOR;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    NSString *name = [GlobalCache shareInstance].info == nil ? @"LoginFlow" : @"MainTab2";
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:name bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateInitialViewController];
    self.window.rootViewController = ctl;
    
//    NSArray *locals = [NSLocale availableLocaleIdentifiers];
//    NSLog(@"locals:%@", locals);
    
//    [SwingClientTest testAll:11];
    
    /*
    NSArray *familyNames =[[NSArray alloc]initWithArray:[UIFont familyNames]];
    NSArray *fontNames;
    NSInteger indFamily, indFont;
    NSLog(@"[familyNames count]===%lu",(unsigned long)[familyNames count]);
    for(indFamily=0;indFamily<[familyNames count];++indFamily)
        
    {
//        if (![[familyNames objectAtIndex:indFamily] containsString:@"Avenir"]) {
//            continue;
//        }
        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
        fontNames =[[NSArray alloc]initWithArray:[UIFont fontNamesForFamilyName:[familyNames objectAtIndex:indFamily]]];
        
        for(indFont=0; indFont<[fontNames count]; ++indFont)
            
        {
            NSLog(@"Font name: %@",[fontNames objectAtIndex:indFont]);
            
        }
    }
    */
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

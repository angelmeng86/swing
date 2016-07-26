//
//  FirstViewController.m
//  Swing
//
//  Created by Mapple on 16/7/13.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "FirstViewController.h"
#import "CommonDef.h"
#import "AppDelegate.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnAction:(id)sender {
    
    UIStoryboard *secondStroyBoard=[UIStoryboard storyboardWithName:@"Test" bundle:nil];
    
    UIViewController *test2obj = [secondStroyBoard instantiateInitialViewController];
    
    AppDelegate *ad = [UIApplication sharedApplication].delegate;
    ad.window.rootViewController = test2obj;
    
//    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
//    
//    NSDictionary *parameters = @{@"email":@"angelmeng86@sohu.com", @"password":@"123456"};
//    [session POST:@"http://www.childrenLab.com/api/login" parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"成功 %@", responseObject);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"失败 %@", error);
//
//    }];
    
//    NSDictionary *parameters = @{@"email":@"angelmeng86@sohu.com", @"password":@"123456"};
//    [session POST:@"http://www.childrenLab.com/user/register" parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"成功 %@", responseObject);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"失败 %@", error);
//        
//    }];
    
//    [session GET:@"http://www.childrenLab.com/api/login" parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"成功 %@", responseObject);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"失败 %@", error);
//    }];

}

@end

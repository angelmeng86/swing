//
//  SwingClientTest.m
//  Swing
//
//  Created by Mapple on 16/8/3.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SwingClientTest.h"
#import "CommonDef.h"


@implementation SwingClientTest

+ (void)testAll {
    [SwingClientTest test:0];
}

+ (void)test:(int)index {
    switch (index) {
        case 0:
        {
            //Params(required) email
            [[SwingClient sharedClient] userIsEmailRegistered:@"test1@swing.com" completion:^(NSNumber *result, NSError *error) {
                if (error) {
                    LOG_D(@"isEmailRegistered fail: %@", error);
                }
                [SwingClientTest test:index + 1];
            }];
        }
            break;
        case 1:
        {
            //Params(required) - email, password, phoneNumber, firstName, lastName
            //other Params - birthday, nickName, sex, address, city, zipCode, role(2 type: ROLE_USER, ROLE_NANNY)
            [[SwingClient sharedClient] userRegister:@{@"email":@"test1@swing.com", @"password":@"111111", @"phoneNumber":@"13838078273", @"firstName":@"Mapple", @"lastName":@"Liu", @"zipCode":@"123456"} completion:^(NSError *error) {
                if (error) {
                    LOG_D(@"registerUser fail: %@", error);
                }
                [SwingClientTest test:index + 1];
            }];
        }
            break;
        case 2:
        {
            [[SwingClient sharedClient]userLogin:@"test1@swing.com" password:@"111111" completion:^(NSError *error) {
                if (error) {
                    LOG_D(@"login fail: %@", error);
                }
                [SwingClientTest test:index + 1];
            }];
        }
            break;
        case 3:
        {
            [[SwingClient sharedClient] userUploadProfileImage:LOAD_IMAGE(@"battery_icon") completion:^(NSString *profileImage, NSError *error) {
                if (error) {
                    LOG_D(@"uploadProfileImage fail: %@", error);
                }
                [SwingClientTest test:index + 1];
            }];
        }
            break;
        case 4:
        {
            //Params(required) - firstName, lastName, birthday(Format must be: "yyyy-MM-dd")
            //Params(not required) - nickName, note
            [[SwingClient sharedClient] kidsAdd:@{@"firstName":@"Lucy", @"lastName":@"Kid", @"":@"1900-08-04"} completion:^(NSError *error) {
                if (error) {
                    LOG_D(@"kidsAdd fail: %@", error);
                }
                [SwingClientTest test:index + 1];
            }];
        }
            break;
        case 5:
        {
            [[SwingClient sharedClient] kidsUploadKidsProfileImage:LOAD_IMAGE(@"battery_icon") kidId:@"2" completion:^(NSString *profileImage, NSError *error) {
                if (error) {
                    LOG_D(@"kidsUploadKidsProfileImage fail: %@", error);
                }
                [SwingClientTest test:index + 1];
            }];
        }
            break;
        case 6:
        {
            [[SwingClient sharedClient] kidsListWithCompletion:^(NSArray *list, NSError *error) {
                if (error) {
                    LOG_D(@"kidsListWithCompletion fail: %@", error);
                }
                [SwingClientTest test:index + 1];
            }];
        }
            break;
        case 7:
        {
            [[SwingClient sharedClient] kidsListWithCompletion:^(NSArray *list, NSError *error) {
                if (error) {
                    LOG_D(@"kidsListWithCompletion fail: %@", error);
                }
                [SwingClientTest test:index + 1];
            }];
        }
            break;
        case 8:
        {
            [[SwingClient sharedClient] kidsListWithCompletion:^(NSArray *list, NSError *error) {
                if (error) {
                    LOG_D(@"kidsListWithCompletion fail: %@", error);
                }
                [SwingClientTest test:index + 1];
            }];
        }
            break;
        default:
            break;
    }
}

@end

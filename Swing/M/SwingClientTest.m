//
//  SwingClientTest.m
//  Swing
//
//  Created by Mapple on 16/8/3.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SwingClientTest.h"
#import "CommonDef.h"
#import "RCLocationManager.h"

@interface SwingClientTest ()

@property (nonatomic, strong) KidModel* kid;
@property (nonatomic, strong) EventModel* event;

@end

@implementation SwingClientTest

+ (void)testAll:(int)index {
    SwingClientTest *test = [[SwingClientTest alloc] init];
    [test test:index];
}

- (void)test:(int)index {
    NSLog(@"test[%d]----------------", index);
    switch (index) {
        case 0:
        {
            //Params(required) email
            [[SwingClient sharedClient] userIsEmailRegistered:@"test10@swing.com" completion:^(NSNumber *result, NSError *error) {
                if (error) {
                    LOG_D(@"isEmailRegistered fail: %@", error);
                }
                [self test:index + 1];
            }];
        }
            break;
        case 1:
        {
            //Params(required) - email, password, phoneNumber, firstName, lastName
            //other Params - birthday, nickName, sex, address, city, zipCode, role(2 type: ROLE_USER, ROLE_NANNY)
            [[SwingClient sharedClient] userRegister:@{@"email":@"test10@swing.com", @"password":@"111111", @"phoneNumber":@"13838078273", @"firstName":@"Mapple", @"lastName":@"Liu", @"zipCode":@"123456"} completion:^(id user, NSError *error) {
                if (error) {
                    LOG_D(@"registerUser fail: %@", error);
                }
                else {
                    NSLog(@"user:%@", user);
                }
                [self test:index + 1];
            }];
        }
            break;
        case 2:
        {
            [[SwingClient sharedClient]userLogin:@"test10@swing.com" password:@"111111" completion:^(NSError *error) {
                if (error) {
                    LOG_D(@"login fail: %@", error);
                }
                [self test:index + 1];
            }];
        }
            break;
        case 3:
        {
            [[SwingClient sharedClient] userUploadProfileImage:LOAD_IMAGE(@"battery_icon") completion:^(NSString *profileImage, NSError *error) {
                if (error) {
                    LOG_D(@"uploadProfileImage fail: %@", error);
                }
                [self test:index + 1];
            }];
        }
            break;
        case 4:
        {
            //Params(required) - firstName, lastName, birthday(Format must be: "yyyy-MM-dd")
            //Params(not required) - nickName, note
            [[SwingClient sharedClient] kidsAdd:@{@"firstName":@"Lucy", @"lastName":@"Kid", @"birthday":@"1900-08-04"} completion:^(id kid,NSError *error) {
                if (error) {
                    LOG_D(@"kidsAdd fail: %@", error);
                }
                else {
                    NSLog(@"kid:%@", kid);
                    self.kid = kid;
                }
                [self test:index + 1];
            }];
        }
            break;
        case 5:
        {
            NSString *objId = @"2";
            if (self.kid) {
                objId = [NSString stringWithFormat:@"%d", self.kid.objId];
            }
            [[SwingClient sharedClient] kidsUploadKidsProfileImage:LOAD_IMAGE(@"battery_icon") kidId:objId completion:^(NSString *profileImage, NSError *error) {
                if (error) {
                    LOG_D(@"kidsUploadKidsProfileImage fail: %@", error);
                }
                else {
                    NSLog(@"profileImage:%@", profileImage);
                }
                [self test:index + 1];
            }];
        }
            break;
        case 6:
        {
            [[SwingClient sharedClient] kidsListWithCompletion:^(NSArray *list, NSError *error) {
                if (error) {
                    LOG_D(@"kidsListWithCompletion fail: %@", error);
                }
                else {
                    NSLog(@"list:%@", list);
                }
                [self test:index + 1];
            }];
        }
            break;
        case 7:
        {
            //Params(required) - eventName, startDate, endDate, color, status, description, alert, city, state
            //startDate and endDate format: yyyy/MM/dd HH:mm:ss
            NSDictionary *data = @{@"eventName":@"Swing", @"startDate":@"2016/08/04 08:30:00", @"endDate":@"2016/08/04 10:40:00", @"color":@"blue", @"status":@"", @"description":@"Test", @"alert":@"0", @"city":@"Cechi"};
            [[SwingClient sharedClient] calendarAddEvent:data completion:^(id event, NSError *error) {
                if (error) {
                    LOG_D(@"calendarAddEvent fail: %@", error);
                }
                else {
                    NSLog(@"event:%@", event);
                    self.event = event;
                }
                [self test:index + 1];
            }];
        }
            break;
        case 8:
        {
            NSString *objId = @"10";
            if (self.event) {
                objId = [NSString stringWithFormat:@"%d", self.event.objId];
            }
            //Params(required) - eventId, todoList
            [[SwingClient sharedClient] calendarAddTodo:objId todoList:@"hello|world" completion:^(id event, NSArray *todoArray, NSError *error) {
                if (error) {
                    LOG_D(@"calendarAddTodo fail: %@", error);
                }
                else {
                    NSLog(@"event:%@", event);
                    NSLog(@"todoArray:%@", todoArray);
                }
                [self test:index + 1];
            }];
        }
            break;
        case 9:
        {
            //Params - query, month, year, day
            //query - month or day.
            //If query == month, only month and year are required from parameters.
            //If query == day, month, year, and day are required from parameters.
            [[SwingClient sharedClient] calendarGetEvents:[NSDate date] type:GetEventTypeMonth completion:^(NSArray *eventArray, NSError *error) {
                if (error) {
                    LOG_D(@"calendarGetEvents1 fail: %@", error);
                }
                else {
                    NSLog(@"eventArray:%@", eventArray);
                }
                [self test:index + 1];
            }];
        }
            break;
        case 10:
        {
            //Params - query, month, year, day
            //query - month or day.
            //If query == month, only month and year are required from parameters.
            //If query == day, month, year, and day are required from parameters.
            [[SwingClient sharedClient] calendarGetEvents:[NSDate date] type:GetEventTypeDay completion:^(NSArray *eventArray, NSError *error) {
                if (error) {
                    LOG_D(@"calendarGetEvents2 fail: %@", error);
                }
                else {
                    NSLog(@"eventArray:%@", eventArray);
                }
                [self test:index + 1];
            }];
        }
            break;
        case 11:
        {
            [WeatherModel weatherQuery:@"37.793293" lon:@"-122.404442" completion:^(id weather, NSError *error) {
                if (error) {
                    LOG_D(@"weatherQuery fail: %@", error);
                }
                else {
                    NSLog(@"weather:%@", weather);
                }
                [self test:index + 1];
            }];
        }
            break;
            case 12:
        {
//            [[MMLocationManager shareLocation] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate) {
//                NSLog(@"latitude:%f longitude:%f", locationCorrrdinate.latitude,locationCorrrdinate.longitude);
//            }];
            [[RCLocationManager sharedManager] requestUserLocationWhenInUseWithBlockOnce:^(CLLocationManager *manager, CLAuthorizationStatus status) {
                NSLog(@"status:%d", status);
                [[RCLocationManager sharedManager] retrieveUserLocationWithBlock:^(CLLocationManager *manager, CLLocation *newLocation, CLLocation *oldLocation) {
                    NSLog(@"newLocation:%@ oldLocation:%@", newLocation, oldLocation);
                    
                    if (newLocation) {
                        [WeatherModel weatherQuery:[NSString stringWithFormat:@"%f", newLocation.coordinate.latitude] lon:[NSString stringWithFormat:@"%f", newLocation.coordinate.longitude] completion:^(id weather, NSError *error) {
                            if (error) {
                                LOG_D(@"weatherQuery fail: %@", error);
                            }
                            else {
                                NSLog(@"weather:%@", weather);
                            }
                            [self test:index + 1];
                        }];
                    }
                    
                } errorBlock:^(CLLocationManager *manager, NSError *error) {
                    NSLog(@"error:%@", error);
                }];
                
            }];
            
            
        }
            break;
            case 13:
        {
            long test = [[NSDate date] timeIntervalSince1970];
            NSData *data = [Fun longToByteArray:test];
            long test2 = [Fun byteArrayToLong:data];
            
            NSLog(@"test:%ld data:%@ test2:%ld", test, data, test2);
        }
            break;
        case 14:
        {
            long test = [[NSDate date] timeIntervalSince1970];
            NSData *data = [Fun longToByteArray:test];
            long test2 = [Fun byteArrayToLong:data];
            
            NSLog(@"test:%ld data:%@ test2:%ld", test, data, test2);
        }
            break;
        case 15:
        {
            [[SwingClient sharedClient]userLogin:@"lwz@swing.com" password:@"111111" completion:^(NSError *error) {
                if (error) {
                    LOG_D(@"userLogin fail: %@", error);
                }
                [self test:index + 1];
            }];
        }
            break;
        case 16:
        {
            long time = [[NSDate date] timeIntervalSince1970];
            NSMutableData *data = [NSMutableData data];
            [data appendData:[Fun longToByteArray:time]];
            char *ptr = "\x01\x76\x01\x00\x00\x76\x01\x00\x00\x76\x01\x00\x00\x76\x01\x00\x00";
            [data appendBytes:ptr length:17];
            ActivityModel *m = [ActivityModel new];
            m.macId = @"maple";
             m.time = time;
//            [m setIndoorData:data];
//            [m setOutdoorData:data];
            [m reset];
            
            [[SwingClient sharedClient] deviceUploadRawData:m completion:^(NSError *error) {
                if (error) {
                    LOG_D(@"deviceUploadRawData fail: %@", error);
                }
                [self test:index + 1];
            }];
        }
            break;
        case 17:
        {
            [[SwingClient sharedClient] deviceGetActivity:@"maple" type:GetActivityTypeDay completion:^(id dailyActs, NSError *error) {
                if (error) {
                    LOG_D(@"deviceGetActivity fail: %@", error);
                }
                else {
                    LOG_D(@"deviceGetActivity:%@", dailyActs);
                }
            }];
        }
            break;
        default:
            break;
    }
}

@end

//
//  SwingClientTest.m
//  Swing
//
//  Created by Mapple on 16/8/3.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SwingClientTest.h"
#import "CommonDef.h"
//#import "RCLocationManager.h"
#import "BLEClient.h"

@interface SwingClientTest ()

@property (nonatomic, strong) KidModel* kid;
@property (nonatomic, strong) EventModel* event;

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) BLEClient *client;



@end

@implementation SwingClientTest

+ (void)test:(int)index times:(int)times {
    SwingClientTest *test = [[SwingClientTest alloc] init];
    test.times = times;
    [test test:index];
}

+ (void)testAll:(int)index {
    SwingClientTest *test = [[SwingClientTest alloc] init];
    test.times = 100;
    [test test:index];
}

- (void)test:(int)index {
    int64_t kidId = 3;
    if (--_times < 0) {
        NSLog(@"test end----------------");
        return;
    }
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
            [[SwingClient sharedClient] userRegister:@{@"email":@"test10@swing.com", @"password":@"111111", @"phoneNumber":@"13838078273", @"firstName":@"Maple", @"lastName":@"Liu", @"zipCode":@"123456"} completion:^(id user, NSError *error) {
                if (error) {
                    LOG_D(@"registerUser fail: %@", error);
                    NSData *data = [error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"];
                    if (data) {
                        LOG_D(@"HTTP:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    }
                    
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
                    NSData *data = [error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"];
                    if (data) {
                        LOG_D(@"HTTP:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    }
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
            [[SwingClient sharedClient] kidsAdd:@{@"firstName":@"Lucy", @"lastName":@"Kid", @"note":@"19000804", @"macId":@"19000804"} completion:^(id kid,NSError *error) {
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
            int64_t objId = 2;
            if (self.kid) {
                objId = self.kid.objId;
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
//            [[SwingClient sharedClient] kidsListWithCompletion:^(NSArray *list, NSError *error) {
//                if (error) {
//                    LOG_D(@"kidsListWithCompletion fail: %@", error);
//                }
//                else {
//                    NSLog(@"list:%@", list);
//                }
//                [self test:index + 1];
//            }];
            
            [[SwingClient sharedClient] calendarGetAllEventsWithCompletion:^(NSArray *eventArray, NSError *error) {
                if (error) {
                    LOG_D(@"calendarGetAllEventsWithCompletion fail: %@", error);
                }
                else {
                    NSLog(@"eventArray:%@", eventArray);
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
            int64_t objId = 10;
            if (self.event) {
                objId = self.event.objId;
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
            /*
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
            */
            
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
            long time = [[NSDate date] timeIntervalSince1970]; //+ 15 * 24 * 60 * 60;
//            NSLog(@"date1:%@", [NSDate dateWithTimeIntervalSince1970:1472611041]);
            NSLog(@"date2:%@", [NSDate dateWithTimeIntervalSince1970:time]);
            NSMutableData *data = [NSMutableData data];
            [data appendData:[Fun longToByteArray:time]];
            char *ptr = "\x00\x76\x01\x00\x00\x76\x01\x00\x00\x76\x01\x00\x00\x76\x01\x00\x00";
            [data appendBytes:ptr length:17];
            NSMutableData *data2 = [NSMutableData data];
            [data2 appendData:[Fun longToByteArray:time]];
            char *ptr2 = "\x01\x76\x01\x00\x00\x76\x01\x00\x00\x76\x01\x00\x00\x76\x01\x00\x00";
            [data2 appendBytes:ptr2 length:17];
            ActivityModel *m = [ActivityModel new];
            m.macId = @"maple";
             m.time = time;
            [m setIndoorData:data];
            [m setOutdoorData:data2];
//            [m reset];
            
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
            [[SwingClient sharedClient] deviceGetActivity:kidId type:GetActivityTypeDay completion:^(id dailyActs, NSError *error) {
                if (error) {
                    LOG_D(@"deviceGetActivity fail: %@", error);
                }
                else {
                    LOG_D(@"deviceGetActivity:%@", dailyActs);
                }
                [self test:index + 1];
            }];
        }
            break;
        case 18:
        {
            [[SwingClient sharedClient] deviceGetActivity:kidId type:GetActivityTypeWeekly completion:^(id dailyActs, NSError *error) {
                if (error) {
                    LOG_D(@"deviceGetActivity fail: %@", error);
                }
                else {
                    LOG_D(@"deviceGetActivity:%@", dailyActs);
                }
                [self test:index + 1];
            }];
        }
            break;
        case 19:
        {
            [[SwingClient sharedClient] deviceGetActivity:kidId type:GetActivityTypeMonth completion:^(id dailyActs, NSError *error) {
                if (error) {
                    LOG_D(@"deviceGetActivity fail: %@", error);
                }
                else {
                    LOG_D(@"deviceGetActivity:%@", dailyActs);
                }
                [self test:index + 1];
            }];
        }
            break;
        case 20:
        {
            [[SwingClient sharedClient] deviceGetActivity:kidId type:GetActivityTypeYear completion:^(id dailyActs, NSError *error) {
                if (error) {
                    LOG_D(@"deviceGetActivity fail: %@", error);
                }
                else {
                    LOG_D(@"deviceGetActivity:%@", dailyActs);
                }
                [self test:index + 1];
            }];
        }
            break;
        case 21:
        {
            static NSDateFormatter *df = nil;
            if (df == nil) {
                df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            }
//            NSDate *date = [df dateFromString:@"2017-02-14 00:01:00"];//[NSDate date]
            NSDate *date = [df dateFromString:@"2017-02-13 23:59:01"];
            long time = [date timeIntervalSince1970]; //+ 15 * 24 * 60 * 60;
            NSLog(@"date GMT:%@", [NSDate dateWithTimeIntervalSince1970:time]);
            NSLog(@"date LOCAL:%@", [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]]);
            ActivityModel *m = [ActivityModel new];
            m.macId = @"57FF1ECFE5E0";
            m.time = time;
            m.timeZoneOffset = [NSTimeZone localTimeZone].secondsFromGMT / 60;
            m.inData1 = 25;
            
            [[SwingClient sharedClient] deviceUploadRawData:m completion:^(NSError *error) {
                if (error) {
                    LOG_D(@"deviceUploadRawData fail: %@", error);
                }
                [self test:index + 1];
            }];
        }
            break;
        default:
            break;
    }
}

+ (void)testBluetooth {
    SwingClientTest *test = [[SwingClientTest alloc] init];
    [test testBLE];
}

- (void)testBLE {
    _client = [[BLEClient alloc] init];
    
    [_client scanDeviceWithCompletion:^(CBPeripheral *peripheral, NSDictionary *advertisementData, NSError *error) {
        if (!error) {
            self.peripheral = peripheral;
            [_client initDevice:peripheral completion:^(NSData *macAddress, NSError *error) {
                if (!error) {
                    [self performSelector:@selector(testBLE2) withObject:nil afterDelay:5];
                }
            }];
        }
    }];
}

- (void)testBLE2 {
    int start = 30;
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 34; i < 77; i++) {
        EventModel *model = [[EventModel alloc] init];
        model.alert = i;
        model.startDate = [[NSDate date] dateByAddingTimeInterval:start];
        start += 6;
        [array addObject:model];
    }
    /*
    EventModel *model = [[EventModel alloc] init];
    model.alert = 34;
    model.startDate = [[NSDate date] dateByAddingTimeInterval:start];
    start += 10;
    [array addObject:model];
    model = [[EventModel alloc] init];
    model.alert = 35;
    model.startDate = [[NSDate date] dateByAddingTimeInterval:start];
    start += 10;
    [array addObject:model];
    model = [[EventModel alloc] init];
    model.alert = 36;
    model.startDate = [[NSDate date] dateByAddingTimeInterval:start];
    start += 10;
    [array addObject:model];
    model = [[EventModel alloc] init];
    model.alert = 37;
    model.startDate = [[NSDate date] dateByAddingTimeInterval:start];
    start += 10;
    [array addObject:model];
    model = [[EventModel alloc] init];
    model.alert = 38;
    model.startDate = [[NSDate date] dateByAddingTimeInterval:start];
    start += 10;
    [array addObject:model];
    model = [[EventModel alloc] init];
    model.alert = 39;
    model.startDate = [[NSDate date] dateByAddingTimeInterval:start];
    start += 10;
    [array addObject:model];
    model = [[EventModel alloc] init];
    model.alert = 40;
    model.startDate = [[NSDate date] dateByAddingTimeInterval:start];
    start += 10;
    [array addObject:model];
    model = [[EventModel alloc] init];
    model.alert = 41;
    model.startDate = [[NSDate date] dateByAddingTimeInterval:start];
    start += 10;
    [array addObject:model];
    
    model = [[EventModel alloc] init];
    model.alert = 42;
    model.startDate = [[NSDate date] dateByAddingTimeInterval:start];
    start += 10;
    [array addObject:model];
    
    model = [[EventModel alloc] init];
    model.alert = 43;
    model.startDate = [[NSDate date] dateByAddingTimeInterval:start];
    start += 10;
    [array addObject:model];
     */
//    [_client syncDevice:_peripheral event:array completion:^(NSMutableArray *activities, NSError *error) {
//        LOG_D(@"syncDevice error %@", error);
//        LOG_D(@"syncDevice activities count %d", (int)activities.count);
//    }];
}

@end

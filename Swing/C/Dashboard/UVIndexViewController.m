//
//  UVIViewController.m
//  Swing
//
//  Created by Mapple on 16/7/30.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "UVIndexViewController.h"
#import "CommonDef.h"

@interface UVIndexViewController ()

@property (strong, nonatomic) UIView* bgView;

@end

@implementation UVIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    _uvi = [[WeatherModel alloc] init];
//    _uvi.uvi = (rand() % 10) + 1;
    
    self.uvLabel.layer.cornerRadius = 50.f;
    self.uvLabel.layer.borderWidth = 5.f;
    self.uvLabel.layer.masksToBounds = YES;
    self.uvLabel.layer.borderColor = [self.uvLabel titleColorForState:UIControlStateNormal].CGColor;
    self.infoLabel.adjustsFontSizeToFitWidth = YES;
    
    self.bgView = [UIView new];
    [self.view addSubview:self.bgView];
    [self.bgView autoPinEdgesToSuperviewEdges];
    [self.view sendSubviewToBack:self.bgView];
    
    /*
    [SVProgressHUD showWithStatus:@"Location, please wait..."];
    [[RCLocationManager sharedManager] requestUserLocationWhenInUseWithBlockOnce:^(CLLocationManager *manager, CLAuthorizationStatus status) {
        LOG_D(@"status:%d", status);
        [[RCLocationManager sharedManager] retrieveUserLocationWithBlock:^(CLLocationManager *manager, CLLocation *newLocation, CLLocation *oldLocation) {
            LOG_D(@"newLocation:%@ oldLocation:%@", newLocation, oldLocation);
            
            if (newLocation) {
                [WeatherModel weatherQuery:[NSString stringWithFormat:@"%f", newLocation.coordinate.latitude] lon:[NSString stringWithFormat:@"%f", newLocation.coordinate.longitude] completion:^(id weather, NSError *error) {
                    if (error) {
                        LOG_D(@"weatherQuery fail: %@", error);
                        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                    }
                    else {
                        self.weather = weather;
                        [GlobalCache shareInstance].wearther = weather;
                        [self loadWeather];
                        [SVProgressHUD dismiss];
                    }
                }];
            }
//            else {
//                [SVProgressHUD showErrorWithStatus:@"location failed."];
//            }
            
        } errorBlock:^(CLLocationManager *manager, NSError *error) {
            LOG_D(@"error:%@", error);
            [SVProgressHUD showErrorWithStatus:@"User has explicitly denied authorization for this application, or location services are disabled in Settings."];
        }];
        
    }];
     */
    
    [self reset];
    self.weather = [GlobalCache shareInstance].wearther;
    [self loadWeather];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weatherLoaded:) name:WEATHER_UPDATE_NOTI object:nil];
    [[GlobalCache shareInstance] queryWeather];
}

- (void)reset {
    self.addressLabel.text = nil;
    [self.uvLabel setTitle:@"N" forState:UIControlStateNormal];
    self.infoLabel.text = nil;
}

- (void)weatherLoaded:(NSNotification*)notification {
    self.weather = notification.object;
    [self loadWeather];
}

- (void)loadWeather {
    if (self.weather == nil) {
        return;
    }
    
    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@", self.weather.city, self.weather.state];
    [self.uvLabel setTitleColor:[self.weather color] forState:UIControlStateNormal];
    self.uvLabel.layer.borderColor = [self.uvLabel titleColorForState:UIControlStateNormal].CGColor;

    self.infoLabel.textColor = [self.weather color];
    self.titleLabel.textColor = [self.weather color];
    
    [self.uvLabel setTitle:[NSString stringWithFormat:@"%d", self.weather.uvi] forState:UIControlStateNormal];
    self.infoLabel.text = [self.weather recommend];
    
    self.bgView.backgroundColor = [[self.weather color] colorWithAlphaComponent:0.3f];
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

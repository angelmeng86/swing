//
//  UVIViewController.h
//  Swing
//
//  Created by Mapple on 16/7/30.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"
#import "CommonDef.h"

@interface UVIndexViewController : LMBaseViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *uvLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (strong, nonatomic) WeatherModel* weather;

@end

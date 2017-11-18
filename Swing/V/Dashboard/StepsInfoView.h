//
//  StepsInfoView.h
//  Swing
//
//  Created by Mapple on 2017/11/15.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import <UIKit/UIKit.h>
//IB_DESIGNABLE
@interface StepsInfoView : UIView

@property (weak, nonatomic) IBOutlet UILabel *leftLabel1;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel2;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

- (void)setThemeColor:(UIColor*)color;

@end

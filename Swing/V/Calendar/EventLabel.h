//
//  EventLabel.h
//  Swing
//
//  Created by Mapple on 16/8/1.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EventModel;
@interface EventLabel : UILabel

@property (weak, nonatomic) NSLayoutConstraint *positionLayoutConstaint;
@property (strong, nonatomic) EventModel *model;

@end

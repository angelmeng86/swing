//
//  RoundButton.m
//  Swing
//
//  Created by Mapple on 16/7/26.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "RoundButton.h"

@implementation RoundButton

- (void)awakeFromNib {
    self.layer.cornerRadius = 5.f;
}

@end

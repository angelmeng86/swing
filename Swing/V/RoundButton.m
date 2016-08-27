//
//  RoundButton.m
//  Swing
//
//  Created by Mapple on 16/7/26.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "RoundButton.h"

@implementation RoundButton

- (id)init {
    if (self = [super init]) {
        self.layer.cornerRadius = 5.f;
    }
    return self;
}

- (void)awakeFromNib {
    self.layer.cornerRadius = 5.f;
}

@end

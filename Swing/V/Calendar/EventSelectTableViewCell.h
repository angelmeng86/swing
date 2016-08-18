//
//  EventSelectTableViewCell.h
//  Swing
//
//  Created by Mapple on 16/8/1.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventSelectTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *checkBtn;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

- (void)update:(BOOL)selected;

@end

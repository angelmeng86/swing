//
//  AddEventViewController.h
//  Swing
//
//  Created by Mapple on 16/8/2.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"
#import "ColorLabel.h"
#import "ToDoListView.h"

@interface AddEventViewController : LMBaseViewController
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *alertTF;
@property (weak, nonatomic) IBOutlet UITextField *descTF;
@property (weak, nonatomic) IBOutlet UITextField *cityTF;
@property (weak, nonatomic) IBOutlet UITextField *stateTF;
@property (weak, nonatomic) IBOutlet UITextField *startTF;
@property (weak, nonatomic) IBOutlet UITextField *endTF;
@property (weak, nonatomic) IBOutlet UITextField *repeatTF;

@property (weak, nonatomic) IBOutlet ColorLabel *colorCtl;
@property (weak, nonatomic) IBOutlet ToDoListView *todoCtl;

- (IBAction)saveAction:(id)sender;

@end

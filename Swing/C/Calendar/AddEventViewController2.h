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

@class EventModel;
@protocol AddEventViewDelegate <NSObject>

- (void)eventViewDidAdded:(NSDate*)date;

@end

@interface AddEventViewController2 : LMBaseViewController
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *descTF;
@property (weak, nonatomic) IBOutlet UITextField *cityTF;
@property (weak, nonatomic) IBOutlet UITextField *stateTF;
@property (weak, nonatomic) IBOutlet UITextField *startTF;
@property (weak, nonatomic) IBOutlet UITextField *endTF;
@property (weak, nonatomic) IBOutlet UITextField *repeatTF;

@property (weak, nonatomic) IBOutlet ColorLabel *colorCtl;
@property (weak, nonatomic) IBOutlet ToDoListView *todoCtl;

@property (strong, nonatomic) NSDate* currentDate;
@property (weak, nonatomic) id delegate;
//if exits, edit mode
@property (strong, nonatomic) EventModel* model;
@property (weak, nonatomic) IBOutlet UIButton *advanceBtn;
@property (weak, nonatomic) IBOutlet UIButton *shortSaveBtn;
@property (weak, nonatomic) IBOutlet UIButton *longSaveBtn;

- (IBAction)saveAction:(id)sender;
- (IBAction)changeAction:(id)sender;

@end

//
//  ToDoListView.m
//  Swing
//
//  Created by Mapple on 16/8/2.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "ToDoListView.h"
#import "CommonDef.h"
#import "DoItemLabel.h"

@interface ToDoListView ()
{
    NSLayoutConstraint *listViewHeight;
}

@property (nonatomic, strong) UIView* listView;

@end

@implementation ToDoListView


- (id)init {
    if (self = [super init]) {
        [self initView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.itemList = [NSMutableArray array];
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5.f;
    self.layer.masksToBounds = YES;
    
    self.listView = [UIView new];
    self.listView.backgroundColor = [UIColor clearColor];
    [self addSubview:_listView];
    
    self.textField = [UITextField new];
    [self addSubview:_textField];
    
    [_listView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    listViewHeight = [_listView autoSetDimension:ALDimensionHeight toSize:0];
    
    [_textField autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_listView];
    
    [_textField autoPinEdgeToSuperviewMargin:ALEdgeLeading];
    [_textField autoPinEdgeToSuperviewMargin:ALEdgeTrailing];
    [_textField autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [_textField autoSetDimension:ALDimensionHeight toSize:30];
    
    _textField.placeholder = @"To Do List";
    _textField.font = [UIFont avenirFontOfSize:15];
    
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [addBtn setTitle:@"+" forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addBtn.backgroundColor = COMMON_TITLE_COLOR;
    addBtn.layer.cornerRadius = 10.f;
    addBtn.layer.masksToBounds = YES;
    [addBtn addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    _textField.rightView = addBtn;
    _textField.rightViewMode = UITextFieldViewModeAlways;
}

- (void)addAction:(id)sender {
    if (_textField.text.length == 0) {
        return;
    }
    
    DoItemLabel *label = [[DoItemLabel alloc] init];
    label.textLabel.text = _textField.text;
    [self.itemList addObject:_textField.text];
    _textField.text = nil;
    
    UIView* view = [self.listView.subviews lastObject];
    [self.listView addSubview:label];
    [label autoPinEdgeToSuperviewMargin:ALEdgeLeading];
    [label autoPinEdgeToSuperviewMargin:ALEdgeTrailing];
    [label autoSetDimension:ALDimensionHeight toSize:30];
    
    if (view) {
        [label autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:view];
    }
    else {
        [label autoPinEdgeToSuperviewEdge:ALEdgeTop];
    }
    [self.listView layoutIfNeeded];
    listViewHeight.constant += 30;
    
    [UIView animateWithDuration:0.3f animations:^{
        [self.superview layoutIfNeeded];
    }];
}

@end

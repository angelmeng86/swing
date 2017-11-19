//
//  ChoicesViewController.m
//  Swing
//
//  Created by Mapple on 16/8/15.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "ChoicesViewController.h"
#import "KidInfoTableViewCell.h"
#import "CommonDef.h"

@interface ChoicesViewController ()

@end

@implementation ChoicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    self.selectArray = [NSMutableSet set];
    [self.tableView registerNib:[UINib nibWithNibName:@"KidInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"KidInfoTableViewCell"];
    if (self.mutiSelected) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:LOAD_IMAGE(@"navi_save") style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
    }
}

- (void)doneAction {
    if (self.selectArray.count == 0) {
        return;
    }
    if ([_delegate respondsToSelector:@selector(choicesViewController:didMutiSelected:)]) {
        [_delegate choicesViewController:self didMutiSelected:[self.selectArray allObjects]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _array.count;
}

- (void)setCell:(UITableViewCell*)cell checked:(BOOL)checked
{
    cell.accessoryType = checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
//    if (checked) {
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:LOAD_IMAGE(@"icon_check")];
//        cell.accessoryView = imageView;
//    }
//    else {
//        cell.accessoryView = nil;
//    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    id data = _array[indexPath.row];
    
    if ([data isKindOfClass:[KidInfo class]]) {
        KidInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KidInfoTableViewCell" forIndexPath:indexPath];

        KidInfo *kid = data;
        cell.infoLabel.text = kid.name;
        
        
        if (kid.profile.length > 0) {
            [cell.iconView sd_setImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:kid.profile]] placeholderImage:LOAD_IMAGE(@"icon_profile")];
        }
        else {
            cell.iconView.image = LOAD_IMAGE(@"icon_profile");
        }
        
        [self setCell:cell checked:[self.selectArray containsObject:indexPath]];
        
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
//        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        //        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = [UIFont avenirFontOfSize:17];
    }
    
    cell.textLabel.text = data;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.mutiSelected) {
        if ([self.selectArray containsObject:indexPath]) {
            [self.selectArray removeObject:indexPath];
        }
        else {
            [self.selectArray addObject:indexPath];
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    else {
        if ([_delegate respondsToSelector:@selector(choicesViewController:didSelected:)]) {
            [_delegate choicesViewController:self didSelected:_array[indexPath.row]];
        }
        else if ([_delegate respondsToSelector:@selector(choicesViewController:didSelectedIndex:)]) {
            [_delegate choicesViewController:self didSelectedIndex:(int)indexPath.row];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end

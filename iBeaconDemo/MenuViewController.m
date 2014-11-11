//
//  MenuViewController.m
//  iBeaconDemo
//
//  Created by Rachel Bobbins on 11/10/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentifier"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Act as iBeacon";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Search for iBeacons";
    } else {
        cell.textLabel.text = @"All of the above!";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *viewController;
    if (indexPath.row == 0) {
        viewController = [storyboard instantiateViewControllerWithIdentifier:@"BeaconEmitterViewController"];
    } else if (indexPath.row == 1) {
        viewController = [storyboard instantiateViewControllerWithIdentifier:@"BeaconFinderViewController"];
    } else {
        viewController = [storyboard instantiateViewControllerWithIdentifier:@"DualModeViewController"];
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end

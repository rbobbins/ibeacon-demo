//
//  ViewController.m
//  BeaconEmitterObjc
//
//  Created by Rachel Bobbins on 11/9/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "BeaconEmitterViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>


static NSString * const kCellIdentifier = @"kCellIdentifier";

@interface BeaconEmitterViewController () <CBPeripheralManagerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) CBPeripheralManager *peripheralManager;
@property (nonatomic) NSMutableArray *messages;
@end

@implementation BeaconEmitterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    self.messages = [NSMutableArray array];
}


#pragma mark - CBPeriphermalManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSString *state;
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn: {
            NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"62d8c7b8-d78b-4cbf-a800-d2183d960808"];
            CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"only identifier"];
            
            [peripheral startAdvertising:[region peripheralDataWithMeasuredPower:nil]];
            state = @"CBPeripheralManagerStatePoweredOn";
            break;
            
        }
        case CBPeripheralManagerStateUnauthorized:
            state = @"CBPeripheralManagerStateUnauthorized";
        case CBPeripheralManagerStatePoweredOff:
            state = @"CBPeripheralManagerStatePoweredOff";
        case CBPeripheralManagerStateResetting:
            state = @"CBPeripheralManagerStateResetting";
        case CBPeripheralManagerStateUnknown:
            state = @"CBPeripheralManagerStateUnknown";
        case CBPeripheralManagerStateUnsupported:
            state = @"CBPeripheralManagerStateUnsupported";
    }
    
    NSString *message = [NSString stringWithFormat:@"Peripheral manager state is %@", state];
    [self logMessage:message];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell.textLabel.text = self.messages[indexPath.row];
    return cell;
}

#pragma mark - Private

- (void)logMessage:(NSString *)message {
    [self.messages addObject:message];
    [self.tableView reloadData];
}

@end

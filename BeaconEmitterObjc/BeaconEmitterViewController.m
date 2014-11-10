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
@property (nonatomic) CBPeripheralManager *peripheralManager;
@property (nonatomic) NSMutableArray *messages;
@property (nonatomic) NSDateFormatter *dateFormatter;

- (IBAction)didTapStartButton:(id)sender;
- (IBAction)didTapStopButton:(id)sender;
- (IBAction)didTapClearButton:(id)sender;

@end


@implementation BeaconEmitterViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.messages = [NSMutableArray array];
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"H:mm:SS";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    [self logMessage:@"Initialized CBPeripheralManager"];
}


#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSString *state;
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            state = @"CBPeripheralManagerStatePoweredOn";
            break;
        case CBPeripheralManagerStateUnauthorized:
            state = @"CBPeripheralManagerStateUnauthorized";
            break;
        case CBPeripheralManagerStatePoweredOff:
            state = @"CBPeripheralManagerStatePoweredOff";
            break;
        case CBPeripheralManagerStateResetting:
            state = @"CBPeripheralManagerStateResetting";
            break;
        case CBPeripheralManagerStateUnknown:
            state = @"CBPeripheralManagerStateUnknown";
            break;
        case CBPeripheralManagerStateUnsupported:
            state = @"CBPeripheralManagerStateUnsupported";
            break;
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
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    return cell;
}

#pragma mark - Actions

- (IBAction)didTapStartButton:(id)sender {
    
    if (!self.peripheralManager.isAdvertising) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"62d8c7b8-d78b-4cbf-a800-d2183d960808"];
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"only identifier"];
        NSDictionary *advertisingData = [region peripheralDataWithMeasuredPower:nil];
        [self.peripheralManager startAdvertising:advertisingData];
        [self logMessage:@"User tapped START button: started advertising as iBeacon"];
        
        for (NSString *key in advertisingData.allKeys) {
            NSString *logData = [NSString stringWithFormat:@"-- %@ = %@", key, advertisingData[key]];
            [self logMessage:logData];
        }
        
    } else {
        [self logMessage:@"User tapped START button: already advertising; tap ignored"];
    }
    
}

- (IBAction)didTapStopButton:(id)sender {
    NSMutableString *message = [@"User tapped STOP button: " mutableCopy];
    
    if (self.peripheralManager.isAdvertising) {
        [self.peripheralManager stopAdvertising];
        [message appendString:@"stopped advertising"];
    } else {
        [message appendString:@"not currently advertising; tap ignored"];
    }
    [self logMessage:message];
}

- (IBAction)didTapClearButton:(id)sender {
    self.messages = [NSMutableArray array];
    [self.tableView reloadData];
}


#pragma mark - Private

- (void)logMessage:(NSString *)message {
    NSString *timestamp = [self.dateFormatter stringFromDate:[NSDate date]];
    NSString *completeMessage = [NSString stringWithFormat:@"%@: %@", timestamp, message];
    
    [self.messages addObject:completeMessage];
    [self.tableView reloadData];
}

@end

//
//  BeaconFinderViewController.m
//  BeaconEmitterObjc
//
//  Created by Rachel Bobbins on 11/9/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "BeaconFinderViewController.h"
#import "CLBeaconRegion+Sample.h"
#import <CoreLocation/CoreLocation.h>


static NSString * const kCellIdentifier = @"kCellIdentifier";


@interface BeaconFinderViewController () <UITableViewDataSource, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *messages;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL *enableAutoscroll;

- (IBAction)didTapStartButton:(id)sender;
- (IBAction)didTapStopButton:(id)sender;
- (IBAction)didTapClearButton:(id)sender;
- (IBAction)didToggleAutoscroll:(id)sender;

@end

@implementation BeaconFinderViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.messages = [NSMutableArray array];
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.locationManager = [[CLLocationManager alloc] init];
        self.dateFormatter.dateFormat = @"H:mm:SS";
        self.enableAutoscroll = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    self.locationManager.delegate = self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell.textLabel.text = self.messages[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.f];
    return cell;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region {

    NSString *stateString;
    switch (state) {
        case CLRegionStateInside:
            stateString = @"CLRegionStateInside";
            break;
        case CLRegionStateOutside:
            stateString = @"CLRegionStateOutside";
            break;
        case CLRegionStateUnknown:
            stateString = @"CLRegionStateUnknown";
    }
    
    NSString *message = [NSString stringWithFormat:@"Determined state for region. State is: %@", stateString];
    [self logMessage:message];
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    NSString *statusString;
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
            statusString = @"kCLAuthorizationStatusAuthorizedAlways";
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            statusString = @"kCLAuthorizationStatusAuthorizedWhenInUse";
            [self beginRegionMonitoring];
            break;
        }

        case kCLAuthorizationStatusDenied:
            statusString = @"kCLAuthorizationStatusDenied";
            break;
        case kCLAuthorizationStatusNotDetermined:
            statusString = @"kCLAuthorizationStatusNotDetermined";
        case kCLAuthorizationStatusRestricted:
            statusString = @"kCLAuthorizationStatusRestricted";
    }
    
    NSString *message = [NSString stringWithFormat:@"Location authorization status changed to: %@", statusString];
    [self logMessage:message];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSString *message =  [NSString stringWithFormat:@"Started monitoring for region: %@", [(CLBeaconRegion *)region proximityUUID]];
    [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    [self logMessage:message];
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"Monitoring failed with error: %@", error];
    [self logMessage:message];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self logMessage:@"Did enter region"];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self logMessage:@"Did exit region"];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    CLBeacon *beacon = [beacons firstObject];

    NSString *proximityString;
    switch (beacon.proximity) {
        case CLProximityImmediate:
            proximityString = @"IMMEDIATE";
            break;
        case CLProximityNear:
            proximityString = @"NEAR";
            break;
        case CLProximityFar:
            proximityString = @"FAR";
        case CLProximityUnknown:
            proximityString = @"UNKNOWN";
    }
    
   
    NSString *message = [NSString stringWithFormat:@"Proximity to beacon: %@ (with accuracy: %fm)", proximityString, beacon.accuracy];
    [self logMessage:message];
}

#pragma mark - Actions

- (IBAction)didTapStartButton:(id)sender {
    [self logMessage:@"Tapped start button"];
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self logMessage:@"Requesting location permission before trying to find beacon"];

        //If we wanted to observe iBeacons in the background, we'd request Always authorization
        [self.locationManager requestWhenInUseAuthorization];
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self beginRegionMonitoring];
    } else {
        [self logMessage:@"Ignoring tap; authorization status is not good enough"];
    }
    
}

- (IBAction)didTapStopButton:(id)sender {
    [self logMessage:@"Tapped stop button"];
    [self.locationManager stopMonitoringForRegion:[CLBeaconRegion exampleRegion]];
    [self.locationManager stopRangingBeaconsInRegion:[CLBeaconRegion exampleRegion]];
}

- (IBAction)didTapClearButton:(id)sender {
    [self logMessage:@"Tapped clear button"];
    self.messages = [NSMutableArray array];
    [self.tableView reloadData];
}

- (IBAction)didToggleAutoscroll:(id)sender {
    self.enableAutoscroll = !self.enableAutoscroll;
}


#pragma mark - Private

- (void)beginRegionMonitoring {
    CLBeaconRegion *region = [CLBeaconRegion exampleRegion];
    [self.locationManager startMonitoringForRegion:region];
    [self logMessage:@"Attempting to monitor iBeacon region"];
}

- (void)logMessage:(NSString *)message {
    NSString *timestamp = [self.dateFormatter stringFromDate:[NSDate date]];
    NSString *completeMessage = [NSString stringWithFormat:@"%@: %@", timestamp, message];
    
    [self.messages addObject:completeMessage];
    [self.tableView reloadData];
    
    if (self.enableAutoscroll) {
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:(self.messages.count - 1) inSection:0];
        [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

@end

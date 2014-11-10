//
//  BeaconFinderViewController.m
//  BeaconEmitterObjc
//
//  Created by Rachel Bobbins on 11/9/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "BeaconFinderViewController.h"


static NSString * const kCellIdentifier = @"kCellIdentifier";


@interface BeaconFinderViewController () <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *messages;
@property (nonatomic) NSDateFormatter *dateFormatter;

- (IBAction)didTapStartButton:(id)sender;
- (IBAction)didTapStopButton:(id)sender;
- (IBAction)didTapClearButton:(id)sender;

@end

@implementation BeaconFinderViewController

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


#pragma mark - Actions

- (IBAction)didTapStartButton:(id)sender {
    [self logMessage:@"Tapped start button"];
}

- (IBAction)didTapStopButton:(id)sender {
    [self logMessage:@"Tapped stop button"];
}

- (IBAction)didTapClearButton:(id)sender {
    [self logMessage:@"Tapped clear button"];
}

#pragma mark - Private

- (void)logMessage:(NSString *)message {
    NSString *timestamp = [self.dateFormatter stringFromDate:[NSDate date]];
    NSString *completeMessage = [NSString stringWithFormat:@"%@: %@", timestamp, message];
    
    [self.messages addObject:completeMessage];
    [self.tableView reloadData];
}

@end

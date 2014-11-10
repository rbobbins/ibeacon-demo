//
//  CLBeaconRegion+Sample.m
//  iBeaconDemo
//
//  Created by Rachel Bobbins on 11/9/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "CLBeaconRegion+Sample.h"

@implementation CLBeaconRegion (Sample)

+ (CLBeaconRegion *)exampleRegion {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"62d8c7b8-d78b-4cbf-a800-d2183d960808"];
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"only identifier"];
    
    return region;
}

@end

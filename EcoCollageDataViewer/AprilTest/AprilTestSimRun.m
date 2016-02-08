//
//  AprilTestSimRun.m
//  AprilTest
//
//  Created by Tia on 4/14/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import "AprilTestSimRun.h"

@implementation AprilTestSimRun
@synthesize map = _map;
@synthesize publicInstallCost = _publicInstallCost;
@synthesize privateInstallCost = _privateInstallCost;
@synthesize publicDamages = _publicDamages;
@synthesize privateDamages = _privateDamages;
@synthesize publicMaintenanceCost = _publicMaintenanceCost;
@synthesize privateMaintenanceCost = _privateMaintenanceCost;
@synthesize standingWater = _standingWater;
@synthesize impactNeighbors = _impactNeighbors;
@synthesize sewerLoad = _sewerLoad;
@synthesize infiltration = _infiltration;
@synthesize efficiency = _efficiency;
@synthesize maxWaterHeights = _maxWaterHeights;
@synthesize dollarsGallons = _dollarsGallons;


-(id) init: (NSString *) pageResults withTrialNum:(int)trialNum {
    NSArray * components = [pageResults componentsSeparatedByString:@"\n\n"];
    
    [[[components objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
    _map = [components objectAtIndex:0];
    _publicInstallCost = [[[components objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
    _privateInstallCost = [[[components objectAtIndex:2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
    _publicDamages = [[[components objectAtIndex:3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
    _privateDamages = [[[components objectAtIndex:4] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
    _publicMaintenanceCost = [[[components objectAtIndex:5] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
    _privateMaintenanceCost = [[[components objectAtIndex:6] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
    _standingWater = [components objectAtIndex:7];
    _impactNeighbors = [[[components objectAtIndex:8] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] floatValue];
    _sewerLoad = [[[components objectAtIndex:9] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] floatValue];
    _infiltration = [[[components objectAtIndex:10] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] floatValue];
    _efficiency = [[components objectAtIndex:11] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _maxWaterHeights = [[components objectAtIndex:12] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _dollarsGallons = [[[components objectAtIndex:13] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] floatValue];
    _trialNum = trialNum;
    
    //NSLog(@"%f", _infiltration);
    
    return self;
}
@end

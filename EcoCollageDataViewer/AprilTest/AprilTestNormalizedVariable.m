//
//  AprilTestNormalizedVariable.m
//  AprilTest
//
//  Created by Joey Shelley on 4/20/14.
//  Copyright (c) 2014 Joey Shelley. All rights reserved.
//

#import "AprilTestNormalizedVariable.h"

@implementation AprilTestNormalizedVariable
@synthesize publicInstallCost = _publicInstallCost;
@synthesize publicDamages = _publicDamages;
@synthesize publicMaintenanceCost = _publicMaintenanceCost;
@synthesize privateInstallCost = _privateInstallCost;
@synthesize privateDamages = _privateDamages;
@synthesize privateMaintenanceCost = _privateMaintenanceCost;
@synthesize standingWater = _standingWater;
@synthesize impactNeighbors = _impactNeighbors;
@synthesize sewerLoad = _sewerLoad;
@synthesize infiltration = _infiltration;
@synthesize efficiency = _efficiency;
@synthesize trialNum = _trialNum;

-(id) init: (NSString *) pageResults withTrialNum:(int)trialNum {
    NSArray * components = [pageResults componentsSeparatedByString:@"\n\n"];
    
    //NSLog(@"%@", components);
    _publicInstallCost = [[components objectAtIndex :0] floatValue];
    _privateInstallCost = [[components objectAtIndex:1] floatValue];
    _publicDamages = [[components objectAtIndex:2] floatValue];
    _privateDamages = [[components objectAtIndex:3] floatValue];
    _publicMaintenanceCost = [[components objectAtIndex:4] floatValue];
    _privateMaintenanceCost = [[components objectAtIndex:5]floatValue];
    _standingWater = [[components objectAtIndex:6]floatValue];
    _impactNeighbors = [[components objectAtIndex:7] floatValue];
    _sewerLoad = [[components objectAtIndex:8] floatValue];
    _infiltration = [[components objectAtIndex:9] floatValue];
    _efficiency = [[components objectAtIndex:10] floatValue];
    _floodedStreets = [[components objectAtIndex:12] floatValue];
    _trialNum = trialNum;
    
    //NSLog(@"%f", _infiltration);
    
    return self;
}
@end

//
//  AprilTestNormalizedVariable.m
//  AprilTest
//
//  Created by Joey Shelley on 4/20/14.
//  Copyright (c) 2014 Joey Shelley. All rights reserved.
//

#import "AprilTestNormalizedVariable.h"

@implementation AprilTestNormalizedVariable

@synthesize normalizedLandscapeCostInstallPlusMaintenance = _normalizedLandscapeCostInstallPlusMaintenance;

//all of these are superceeded by normalizedLandscapeCostInstallPlusMaintenance
//@synthesize normalizedPublicInstallCost = _normalizedPublicInstallCost;
//@synthesize normalizedPublicMaintenanceCost = _normalizedPublicMaintenanceCost;
//@synthesize normalizedPrivateInstallCost = _normalizedPrivateInstallCost;

//currently not in use because public property damages are rolled into private property damages
//@synthesize normalizedLandscapePublicPropertyDamages = _normalizedLandscapePublicPropertyDamages;

@synthesize normalizedLandscapeCostPrivatePropertyDamages = _normalizedLandscapeCostPrivatePropertyDamages;

//currently not in use
//@synthesize normalizedPrivateMaintenanceCost = _normalizedPrivateMaintenanceCost;
@synthesize normalizedGreatestDepthStandingWater = _normalizedGreatestDepthStandingWater;
@synthesize normalizedLandscapeCumulativeOutflow = _normalizedLandscapeCumulativeOutflow;
@synthesize normalizedLandscapeCumulativeSewers = _normalizedLandscapeCumulativeSewers;
@synthesize normalizedProportionCumulativeNetGIInfiltration = _normalizedProportionCumulativeNetGIInfiltration;
@synthesize landscapeCumulativeGICapacityUsed = _landscapeCumulativeGICapacityUsed;
@synthesize trialNum = _trialNum;

-(id) init: (NSString *) pageResults withTrialNum:(int)trialNum {
    NSArray * components = [pageResults componentsSeparatedByString:@"\n\n"];
    
    //NSLog(@"%@", components);
//    _normalizedPublicInstallCost = [[components objectAtIndex :0] floatValue];
//    _normalizedPrivateInstallCost = [[components objectAtIndex:1] floatValue];
//    _normalizedLandscapePublicPropertyDamages = [[components objectAtIndex:2] floatValue];
    _normalizedLandscapeCostPrivatePropertyDamages = [[components objectAtIndex:1] floatValue];
//    _normalizedPublicMaintenanceCost = [[components objectAtIndex:4] floatValue];
//    _normalizedPrivateMaintenanceCost = [[components objectAtIndex:5]floatValue];
    _normalizedGreatestDepthStandingWater = [[components objectAtIndex:2]floatValue];
    _normalizedLandscapeCumulativeOutflow = [[components objectAtIndex:3] floatValue];
    _normalizedLandscapeCumulativeSewers = [[components objectAtIndex:4] floatValue];
    _normalizedProportionCumulativeNetGIInfiltration = [[components objectAtIndex:5] floatValue];
    _landscapeCumulativeGICapacityUsed = [[components objectAtIndex:6] floatValue];
    _normalizedLandscapeCumulativeFloodingOverall = [[components objectAtIndex:8] floatValue];
    //not set by the simulation; value is initialized in the 
    _normalizedLandscapeCostInstallPlusMaintenance = 0;
    _trialNum = trialNum;
    
    //NSLog(@"%f", _infiltration);
    
    return self;
}
@end

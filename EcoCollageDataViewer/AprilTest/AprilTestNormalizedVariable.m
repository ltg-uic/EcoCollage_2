//
//  AprilTestNormalizedVariable.m
//  AprilTest
//
//  Created by Joey Shelley on 4/20/14.
//  Copyright (c) 2014 Joey Shelley. All rights reserved.
//

#import "AprilTestNormalizedVariable.h"

@implementation AprilTestNormalizedVariable
@synthesize normalizedPublicInstallCost = _normalizedPublicInstallCost;
@synthesize normalizedLandscapePublicPropertyDamages = _normalizedLandscapePublicPropertyDamages;
@synthesize normalizedLandscapeCostInstallPlusMaintenance = _normalizedLandscapeCostInstallPlusMaintenance;
@synthesize normalizedPublicMaintenanceCost = _normalizedPublicMaintenanceCost;
@synthesize normalizedPrivateInstallCost = _normalizedPrivateInstallCost;
@synthesize normalizedLandscapeCostPrivatePropertyDamages = _normalizedLandscapeCostPrivatePropertyDamages;
@synthesize normalizedPrivateMaintenanceCost = _normalizedPrivateMaintenanceCost;
@synthesize normalizedGreatestDepthStandingWater = _normalizedGreatestDepthStandingWater;
@synthesize normalizedLandscapeCumulativeOutflow = _normalizedLandscapeCumulativeOutflow;
@synthesize normalizedLandscapeCumulativeSewers = _normalizedLandscapeCumulativeSewers;
@synthesize normalizedProportionCumulativeNetGIInfiltration = _normalizedProportionCumulativeNetGIInfiltration;
@synthesize landscapeCumulativeGICapacityUsed = _landscapeCumulativeGICapacityUsed;
@synthesize trialNum = _trialNum;

-(id) init: (NSString *) pageResults withTrialNum:(int)trialNum {
    NSArray * components = [pageResults componentsSeparatedByString:@"\n\n"];
    
    //NSLog(@"%@", components);
    _normalizedPublicInstallCost = [[components objectAtIndex :0] floatValue];
    _normalizedPrivateInstallCost = [[components objectAtIndex:1] floatValue];
    _normalizedLandscapePublicPropertyDamages = [[components objectAtIndex:2] floatValue];
    _normalizedLandscapeCostPrivatePropertyDamages = [[components objectAtIndex:3] floatValue];
    _normalizedPublicMaintenanceCost = [[components objectAtIndex:4] floatValue];
    _normalizedPrivateMaintenanceCost = [[components objectAtIndex:5]floatValue];
    _normalizedGreatestDepthStandingWater = [[components objectAtIndex:6]floatValue];
    _normalizedLandscapeCumulativeOutflow = [[components objectAtIndex:7] floatValue];
    _normalizedLandscapeCumulativeSewers = [[components objectAtIndex:8] floatValue];
    _normalizedProportionCumulativeNetGIInfiltration = [[components objectAtIndex:9] floatValue];
    _landscapeCumulativeGICapacityUsed = [[components objectAtIndex:10] floatValue];
    _normalizedLandscapeCumulativeFloodingOverall = [[components objectAtIndex:12] floatValue];
    _normalizedLandscapeCostInstallPlusMaintenance == [[components objectAtIndex:13] floatValue];
    _trialNum = trialNum;
    
    //NSLog(@"%f", _infiltration);
    
    return self;
}
@end

//
//  AprilTestSimRun.m
//  AprilTest
//
//  Created by Joey Shelley on 4/14/14.
//  Copyright (c) 2014 Joey Shelley. All rights reserved.
//

#import "AprilTestSimRun.h"

@implementation AprilTestSimRun
@synthesize map = _map;
@synthesize landscapeCostTotalInstall = _landscapeCostTotalInstall;
@synthesize landscapeCostInstallPlusMaintenance = _landscapeCostInstallPlusMaintenance;

@synthesize landscapeCostPublicPropertyDamage = _landscapeCostPublicPropertyDamage;

//@synthesize landscapeCostInstallPrivateGI = _landscapeCostInstallPrivateGI;
//@synthesize landscapeCostPrivatePropertyDamage = _landscapeCostPrivatePropertyDamage;

@synthesize landscapeCostTotalMaintenance = _landscapeCostTotalMaintenance;
@synthesize landscapeCostPrivateMaintenance = _landscapeCostPrivateMaintenance;
@synthesize waterHeightList = _waterHeightList;
@synthesize normalizedLandscapeCumulativeOutflow = _normalizedLandscapeCumulativeOutflow;
@synthesize normalizedLandscapeCumulativeSewers = _normalizedLandscapeCumulativeSewers;
@synthesize proportionCumulativeNetGIInfiltration = _proportionCumulativeNetGIInfiltration;
@synthesize efficiencyList = _efficiencyList;
@synthesize maxWaterHeightList = _maxWaterHeightList;
@synthesize costPerGallonCapturedByGI = _costPerGallonCapturedByGI;


-(id) init: (NSString *) pageResults withTrialNum:(int)trialNum {
    NSArray * components = [pageResults componentsSeparatedByString:@"\n\n"];
    
    [[[components objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
    _map = [components objectAtIndex:0];
    _landscapeCostTotalInstall = [[[components objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
    _landscapeCostInstallPrivateGI = [[[components objectAtIndex:2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
    _landscapeCostPublicPropertyDamage = [[[components objectAtIndex:3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
    _landscapeCostPrivatePropertyDamage = [[[components objectAtIndex:4] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
    _landscapeCostTotalMaintenance = [[[components objectAtIndex:5] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
    _landscapeCostPrivateMaintenance = [[[components objectAtIndex:6] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
    _waterHeightList = [components objectAtIndex:7];
    _normalizedLandscapeCumulativeOutflow = [[[components objectAtIndex:8] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] floatValue];
    _normalizedLandscapeCumulativeSewers = [[[components objectAtIndex:9] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] floatValue];
    _proportionCumulativeNetGIInfiltration = [[[components objectAtIndex:10] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] floatValue];
    _efficiencyList = [[components objectAtIndex:11] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _maxWaterHeightList = [[components objectAtIndex:12] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _costPerGallonCapturedByGI = [[[components objectAtIndex:13] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] floatValue];
    _landscapeCostInstallPlusMaintenance = [[[components objectAtIndex:14] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
    _trialNum = trialNum;
    
    //NSLog(@"%f", _infiltration);
    
    return self;
}
@end

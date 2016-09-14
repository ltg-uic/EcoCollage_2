//
//  AprilTestNormalizedVariable.h
//  AprilTest
//
//  Created by Joey Shelley on 4/20/14.
//  Copyright (c) 2014 Joey Shelley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AprilTestNormalizedVariable : NSObject
@property float normalizedPublicInstallCost;
@property float normalizedPrivateInstallCost;
@property float normalizedLandscapeCostInstallPlusMaintenance;
@property float normalizedLandscapePublicPropertyDamages;
@property float normalizedLandscapeCostPrivatePropertyDamages;
@property float normalizedPublicMaintenanceCost;
@property float normalizedPrivateMaintenanceCost;
@property float normalizedGreatestDepthStandingWater;
@property float normalizedLandscapeCumulativeOutflow;
@property float normalizedLandscapeCumulativeSewers;
@property float normalizedProportionCumulativeGICaptured;
@property float landscapeCumulativeGICapacityUsed;
@property float normalizedLandscapeCumulativeFloodingOverall;
@property int trialNum;

-(id) init: (NSString *) pageResults withTrialNum: (int) trialNum;
@end

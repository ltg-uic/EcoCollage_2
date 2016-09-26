//
//  AprilTestNormalizedVariable.h
//  AprilTest
//
//  Created by Joey Shelley on 4/20/14.
//  Copyright (c) 2014 Joey Shelley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AprilTestNormalizedVariable : NSObject

//these are being superceded by normalizedLandscapeCostInstallPlusMaintenance; combines all four into
//a single variable, normalized against the budget
//@property float normalizedPublicInstallCost;
//@property float normalizedPrivateInstallCost;
//@property float normalizedPublicMaintenanceCost;
//@property float normalizedPrivateMaintenanceCost;

@property float normalizedLandscapeCostInstallPlusMaintenance;

//currently not in use because public property damages are rolled into private property damages
//@property float normalizedLandscapePublicPropertyDamages;

@property float normalizedLandscapeCostPrivatePropertyDamages;

@property float normalizedGreatestDepthStandingWater;
@property float normalizedLandscapeCumulativeOutflow;
@property float normalizedLandscapeCumulativeSewers;
@property float normalizedProportionCumulativeNetGIInfiltration;

//currently not in use: GI captured refers to water captured in GI (storage + infiltration)  adding this would be a substantial programming effort to add to UI. need to consider if it is its own outcome category or if it should be displayed alongside something else
//@property float normalizedProportionCumulativeGICaptured;

//consider: how to combine with existing outcome categories in a meaningful way for the scores, especially to avoid "double counting" against them with overall flooding
//@property normalizedLandscapeCumulativeStreetFlooding;
//@property normalizedLandscapeCumulativeBlockFlooding;

@property float landscapeCumulativeGICapacityUsed;
@property float normalizedLandscapeCumulativeFloodingOverall;
@property int trialNum;

-(id) init: (NSString *) pageResults withTrialNum: (int) trialNum;
@end

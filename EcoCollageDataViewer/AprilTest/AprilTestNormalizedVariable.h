//
//  AprilTestNormalizedVariable.h
//  AprilTest
//
//  Created by Tia on 4/20/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AprilTestNormalizedVariable : NSObject
@property float publicInstallCost;
@property float privateInstallCost;
@property float publicDamages;
@property float privateDamages;
@property float publicMaintenanceCost;
@property float privateMaintenanceCost;
@property float standingWater;
@property float impactNeighbors;
@property float sewerLoad;
@property float infiltration;
@property float efficiency;
@property float floodedStreets;
@property int trialNum;

-(id) init: (NSString *) pageResults withTrialNum: (int) trialNum;
@end

//
//  AprilTestSimRun.h
//  AprilTest
//
//  Created by Tia on 4/14/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AprilTestSimRun : NSObject
@property NSString * map;
@property int publicInstallCost;
@property int privateInstallCost;
@property int publicDamages;
@property int privateDamages;
@property int publicMaintenanceCost;
@property int privateMaintenanceCost;
@property NSString * standingWater;
@property float impactNeighbors;
@property float sewerLoad;
@property float infiltration;
@property NSString * efficiency;
@property NSString * maxWaterHeights;
@property int trialNum;
@property float dollarsGallons;

-(id) init: (NSString *) pageResults withTrialNum: (int) trialNum;
@end

//
//  AprilTestSimRun.h
//  AprilTest
//
//  Created by Joey Shelley on 4/14/14.
//  Copyright (c) 2014 Joey Shelley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AprilTestSimRun : NSObject
@property NSString * map;
@property int landscapeCostTotalInstall;
@property int landscapeCostInstallPlusMaintenance;
@property int landscapeCostInstallPrivateGI;
@property int landscapeCostPublicPropertyDamage;
@property int landscapeCostPrivatePropertyDamage;
@property int landscapeCostTotalMaintenance;
@property int landscapeCostPrivateMaintenance;
@property NSString * waterHeightList;
@property float normalizedLandscapeCumulativeOutflow;
@property float normalizedLandscapeCumulativeSewers;
@property float infiltration;
@property NSString * efficiencyList;
@property NSString * maxWaterHeightList;
@property int trialNum;
@property float costPerGallonCapturedByGI;

-(id) init: (NSString *) pageResults withTrialNum: (int) trialNum;
@end

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
//landscapeCostTotalInstall and landscapeCostTotalMaintenance are used in display
@property int landscapeCostTotalInstall;
@property int landscapeCostTotalMaintenance;
//landscapeCostTotalInstallPlusMaintenance used by normalization code in AprilTestTabBarController
@property int landscapeCostInstallPlusMaintenance;

//currently not in use: private variables; all costs are rolled in to above "total" variables
//@property int landscapeCostInstallPrivateGI;
//@property int landscapeCostPrivateMaintenance;

//currently not in use: only calculating property damage. ideally, landscapeCostPrivatePropertyDamage should be just landscapeCostPropertyDamage.
//@property int landscapeCostPublicPropertyDamage;
@property int landscapeCostPrivatePropertyDamage;

//currently not in use: GI captured refers to water captured in GI (storage + infiltration)  adding this would be a substantial programming effort to add to UI. need to consider if it is its own outcome category or if it should be displayed alongside something else
//@property float proportionCumulativeGICaptured;

@property NSString * waterHeightList;
@property float normalizedLandscapeCumulativeOutflow;
@property float normalizedLandscapeCumulativeSewers;
@property float proportionCumulativeNetGIInfiltration;
@property NSString * efficiencyList;
@property NSString * maxWaterHeightList;
@property int trialNum;
@property float costPerGallonCapturedByGI;

-(id) init: (NSString *) pageResults withTrialNum: (int) trialNum;
@end

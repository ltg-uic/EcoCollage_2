//
//  AprilTestTabBarController.h
//  AprilTest
//
//  Created by Tia on 4/10/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "FebTestWaterDisplay.h"
#import "AprilTestEfficiencyView.h"

@interface AprilTestTabBarController : UITabBarController <GKSessionDelegate>
@property NSMutableArray * currentConcernRanking;
@property NSMutableArray * trialRuns;
@property NSMutableArray * trialRunsNormalized;
@property NSMutableArray * trialRunsDynNorm;
@property NSMutableArray * profiles;
@property NSMutableArray * ownProfile;
@property NSString * url;
@property int studyNum;
@property int trialNum;
@property (nonatomic, strong) GKSession * session;
@property NSString * peerIDForMomma;
@property int showProfile;
@property int budget;
@property NSMutableArray *waterDisplaysInTab;
@property NSMutableArray *maxWaterDisplaysInTab;
@property NSMutableArray *efficiencyViewsInTab;
@property NSMutableArray *pieCharts;
@property NSMutableArray *pieChartsForScoreBarView;
@property NSMutableArray *slices;
@property int pieIndex;
@property NSMutableArray *favorites;
@property NSMutableArray *leastFavorites;
- (UIImage *)viewToImageForWaterDisplay:(FebTestWaterDisplay *)waterDisplay;
+ (void) shutdownBluetooth;
- (void) addPieChartAtIndex:(int)index forProfile:(NSArray *)profile;
- (void) updatePieChartAtIndex:(int)index forProfile:(NSArray *)profile;
- (void)reloadDataForPieChartAtIndex:(int)index;
@end

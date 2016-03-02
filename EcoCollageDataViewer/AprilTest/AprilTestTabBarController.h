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
@property NSMutableArray * waterDisplaysInTab;
@property NSMutableArray * maxWaterDisplaysInTab;
@property NSMutableArray * efficiencyViewsInTab;
@property NSMutableArray * pieCharts;
@property NSMutableArray * pieChartsForScoreBarView;
@property NSMutableArray * slices;
@property NSMutableArray * favorites;
@property NSMutableArray * leastFavorites;
@property NSMutableArray * scores;
@property NSString       * url;
@property NSString       * LogFile;
@property NSString       * ownProfileName;
@property NSString       * peerIDForMomma;
@property int   studyNum;
@property int   trialNum;
@property int   logNum;
@property int   reloadSocialView;
@property float threshVal;
@property int   showProfile;
@property int   budget;
@property BOOL  SortingEnabled;

@property int pieIndex;


@property (nonatomic, strong) GKSession * session;
- (UIImage *)viewToImageForWaterDisplay:(FebTestWaterDisplay *)waterDisplay;
+ (void) shutdownBluetooth;
- (void) addPieChartAtIndex:(int)index forProfile:(NSArray *)profile;
- (void) updatePieChartAtIndex:(int)index forProfile:(NSArray *)profile;
- (void)reloadDataForPieChartAtIndex:(int)index;
- (NSMutableArray*)getScoreBarValuesForProfile:(int)profileIndex forTrial:(int)trial isDynamicTrial:(int)dynamic;
- (float)generateOverBudgetPenalty:(NSMutableArray*)scoreVisNames withInstallCost:(int)installCost;

//log writing related methods
- (NSString*) generateLogEntryWith:(NSString*)extra;
- (void) writeToLogFileString:(NSString*)str;

- (NSMutableArray*) getTrialRuns;
@end

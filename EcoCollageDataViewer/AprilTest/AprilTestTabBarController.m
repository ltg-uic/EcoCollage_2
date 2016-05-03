//
//  AprilTestTabBarController.m
//  AprilTest
//
//  Created by Tia on 4/10/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import "AprilTestTabBarController.h"
#import "AprilTestVariable.h"
#import "AprilTestNormalizedVariable.h"
#import "AprilTestSimRun.h"
#import "XYPieChart.h"
#import "SocialViewController.h"
#import "AprilTestTabBarController.h"
#import "AprilTestSimRun.h"
#import "FebTestIntervention.h"
#import "AprilTestVariable.h"
#import "FebTestWaterDisplay.h"
#import "AprilTestEfficiencyView.h"
#import "AprilTestCostDisplay.h"
#import "AprilTestNormalizedVariable.h"
#import "XYPieChart.h"
#import <QuartzCore/QuartzCore.h>

@interface AprilTestTabBarController ()


@end


@implementation AprilTestTabBarController
@synthesize currentConcernRanking = _currentConcernRanking;
@synthesize url = _url;
@synthesize studyNum = _studyNum;
@synthesize trialNum = _trialNum;
@synthesize logNum   =_logNum;
@synthesize LogFile  =_LogFile;
@synthesize SortingEnabled = _SortingEnabled;
@synthesize session = _session;
@synthesize profiles = _profiles;
@synthesize ownProfile = _ownProfile;
@synthesize trialRuns = _trialRuns;
@synthesize trialRunsNormalized = _trialRunsNormalized;
@synthesize trialRunsDynNorm = _trialRunsDynNorm;
@synthesize budget = _budget;
@synthesize waterDisplaysInTab = _waterDisplaysInTab;
@synthesize maxWaterDisplaysInTab = _maxWaterDisplaysInTab;
@synthesize efficiencyViewsInTab = _efficiencyViewsInTab;
@synthesize pieCharts = _pieCharts;
@synthesize pieChartsForScoreBarView = _pieChartsForScoreBarView;
@synthesize slices = _slices;
@synthesize pieIndex = _pieIndex;
@synthesize favorites = _favorites;
@synthesize leastFavorites = _leastFavorites;
@synthesize threshVal = _threshVal;
@synthesize scores = _scores;
@synthesize reloadSocialView = _reloadSocialView;

static NSTimeInterval const kConnectionTimeout = 30.0;
NSMutableArray *viewsForWaterDisplays;
NSMutableArray *viewsForMaxWaterDisplays;
NSMutableArray *viewsForEfficiencyViews;
NSDictionary *dataDictionary;
NSArray *sliceColors;
NSMutableDictionary *sliceNumbers;
NSMutableArray *slicesInfo;

NSMutableDictionary         *concernColors;
NSMutableDictionary         *concernNames;
NSMutableDictionary         *scoreColors;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// make sure tab bar is same height regardless of which version of iOS is running (iOS 8 has smaller tab bar than iOS 7)
- (void)viewWillLayoutSubviews {
    CGRect tabFrame = self.tabBar.frame;
    tabFrame.size.height = 49;
    tabFrame.origin.y = self.view.frame.size.height - 49;
    self.tabBar.frame = tabFrame;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _trialNum = 0;
    
    //manually derived list of variables that are going to be implemented in this test. Eventually, should be replaced with a access to database, such that width, etc, are all documented as such.
    
    //_currentConcernRanking = [[NSMutableArray alloc] initWithObjects: [[AprilTestVariable alloc] initWith: @"publicCost" withDisplayName:@"Public Costs" withNumVar: 1 withWidth: 220 withRank:3], [[AprilTestVariable alloc] initWith: @"privateCost" withDisplayName:@"Private Costs" withNumVar: 3 withWidth: 220 withRank:1], [[AprilTestVariable alloc] initWith: @"efficiencyOfIntervention" withDisplayName:@"Efficiency of Intervention ($/Gallon)" withNumVar: 1 withWidth: 220 withRank:1], [[AprilTestVariable alloc] initWith:@"puddleTime" withDisplayName:@"Water Depth over Storm" withNumVar: 1 withWidth:220 withRank:1], [[AprilTestVariable alloc] initWith:@"impactingMyNeighbors" withDisplayName:@"Impact on my Neighbors" withNumVar: 1 withWidth: 220 withRank:1], [[AprilTestVariable alloc] initWith:@"groundwaterInfiltration" withDisplayName:@"Groundwater Infiltration" withNumVar: 1 withWidth:220 withRank:1], [[AprilTestVariable alloc] initWith:@"puddleMax" withDisplayName:@"Maximum Water Extent" withNumVar: 1 withWidth:220 withRank:1], nil];
    
    //    Public Costs	publicCost
    //    Private Costs	privateCost
    //    Efficiency of Intervention ($/Gallon)	efficiencyOfIntervention
    //    Water Depth over Storm	puddleTime
    //    Maximum Water Extent	puddleMax
    //    Groundwater Infiltration	groundwaterInfiltration
    //    Impact on my Neighbors	impactingMyNeighbors

    _currentConcernRanking = [[NSMutableArray alloc] initWithObjects: [[AprilTestVariable alloc] initWith:@"publicCost" withDisplayName:@"Investment" withNumVar:1 withWidth:220 withRank:1], [[AprilTestVariable alloc] initWith:@"privateCost" withDisplayName:@"Damage Reduction" withNumVar:1 withWidth:220 withRank:1], [[AprilTestVariable alloc] initWith:@"efficiencyOfIntervention" withDisplayName:@"Efficiency of Intervention ($/Gallon)" withNumVar:1 withWidth:220 withRank:1], [[AprilTestVariable alloc] initWith:@"capacity" withDisplayName:@"Capacity Used" withNumVar:1 withWidth:220 withRank:1], [[AprilTestVariable alloc] initWith:@"puddleTime" withDisplayName:@"Water Flow Path" withNumVar:1 withWidth:220 withRank:1], [[AprilTestVariable alloc] initWith:@"puddleMax" withDisplayName:@"Max Depth of Flooding" withNumVar:1 withWidth:220 withRank:1], [[AprilTestVariable alloc] initWith:@"groundwaterInfiltration" withDisplayName:@"Groundwater Infiltration" withNumVar:1 withWidth:220 withRank:1], [[AprilTestVariable alloc] initWith:@"impactingMyNeighbors" withDisplayName:@"Impact on my Neighbors" withNumVar:1 withWidth:220 withRank:1], nil];
    
    concernColors = [[NSMutableDictionary alloc] initWithObjects:
                     [NSArray arrayWithObjects:
                      [UIColor colorWithHue:.3 saturation:.6 brightness:.9 alpha: 0.5],
                      [UIColor colorWithHue:.31 saturation:.6 brightness:.91 alpha: 0.5],
                      [UIColor colorWithHue:.32 saturation:.6 brightness:.92 alpha: 0.5],
                      [UIColor colorWithHue:.33 saturation:.6 brightness:.93 alpha: 0.5],
                      [UIColor colorWithHue:.35 saturation:.8 brightness:.6 alpha: 0.5],
                      [UIColor colorWithHue:.36 saturation:.8 brightness:.61 alpha: 0.5],
                      [UIColor colorWithHue:.37 saturation:.8 brightness:.62 alpha: 0.5],
                      [UIColor colorWithHue:.38 saturation:.8 brightness:.63 alpha: 0.5],
                      [UIColor colorWithHue:.4 saturation:.8 brightness:.3 alpha: 0.5],
                      [UIColor colorWithHue:.65 saturation:.8 brightness:.6 alpha: 0.5],
                      [UIColor colorWithHue:.6 saturation:.8 brightness:.3 alpha: 0.5],
                      [UIColor colorWithHue:.6 saturation:.0 brightness:.3 alpha: 0.5],
                      [UIColor colorWithHue:.6 saturation:.0 brightness:.9 alpha: 0.5],
                      [UIColor colorWithHue:.55 saturation:.8 brightness:.9 alpha: 0.5], nil]  forKeys: [[NSArray alloc] initWithObjects: @"Investment", @"publicCostI", @"publicCostM", @"publicCostD", @"Damage Reduction", @"privateCostI", @"privateCostM", @"privateCostD",  @"Efficiency of Intervention ($/Gallon)", @"Water Flow Path", @"Max Depth of Flooding", @"Groundwater Infiltration", @"Impact on my Neighbors", @"Capacity Used", nil] ];
    
    concernNames = [[NSMutableDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects: @"publicCost", @"privateCost", @"efficiencyOfIntervention", @"capacity", @"puddleTime", @"puddleMax", @"groundwaterInfiltration", @"impactingMyNeighbors", nil] forKeys:[[NSArray alloc] initWithObjects:@"Investment", @"Damage Reduction", @"Efficiency of Intervention ($/Gallon)", @"Capacity Used", @"Water Flow Path", @"Max Depth of Flooding", @"Groundwater Infiltration", @"Impact on my Neighbors", nil]];
    
    scoreColors = [[NSMutableDictionary alloc] initWithObjects:
                   [NSArray arrayWithObjects:
                    [UIColor colorWithHue:.3 saturation:.6 brightness:.9 alpha: 0.5],
                    [UIColor colorWithHue:.31 saturation:.6 brightness:.91 alpha: 0.5],
                    [UIColor colorWithHue:.32 saturation:.6 brightness:.92 alpha: 0.5],
                    [UIColor colorWithHue:.33 saturation:.6 brightness:.93 alpha: 0.5],
                    [UIColor colorWithHue:.35 saturation:.8 brightness:.6 alpha: 0.5],
                    [UIColor colorWithHue:.36 saturation:.8 brightness:.61 alpha: 0.5],
                    [UIColor colorWithHue:.37 saturation:.8 brightness:.62 alpha: 0.5],
                    [UIColor colorWithHue:.38 saturation:.8 brightness:.63 alpha: 0.5],
                    [UIColor colorWithHue:.4 saturation:.8 brightness:.3 alpha: 0.5],
                    [UIColor colorWithHue:.65 saturation:.8 brightness:.6 alpha: 0.5],
                    [UIColor colorWithHue:.6 saturation:.8 brightness:.3 alpha: 0.5],
                    [UIColor colorWithHue:.6 saturation:.0 brightness:.3 alpha: 0.5],
                    [UIColor colorWithHue:.6 saturation:.0 brightness:.9 alpha: 0.5],
                    [UIColor colorWithHue:.55 saturation:.8 brightness:.9 alpha: 0.5], nil]  forKeys: [[NSArray alloc] initWithObjects: @"publicCost", @"publicCostI", @"publicCostM", @"publicCostD", @"privateCost", @"privateCostI", @"privateCostM", @"privateCostD",  @"efficiencyOfIntervention", @"puddleTime", @"puddleMax", @"groundwaterInfiltration", @"impactingMyNeighbors", @"capacity", nil] ];

    
    // Do any additional setup after loading the view.
    
    _trialRuns = [[NSMutableArray alloc]init];
    _trialRunsNormalized = [[NSMutableArray alloc]init];
    _trialRunsDynNorm = [[NSMutableArray alloc]init];
    _profiles = [[NSMutableArray alloc]init];
    _ownProfile = [[NSMutableArray alloc]init];
    _waterDisplaysInTab = [[NSMutableArray alloc]init];
    _maxWaterDisplaysInTab = [[NSMutableArray alloc]init];
    _efficiencyViewsInTab  = [[NSMutableArray alloc] init];
    viewsForWaterDisplays = [[NSMutableArray alloc]init];
    viewsForMaxWaterDisplays = [[NSMutableArray alloc]init];
    viewsForEfficiencyViews  = [[NSMutableArray alloc] init];
    _pieCharts = [[NSMutableArray alloc]init];
    _pieChartsForScoreBarView = [[NSMutableArray alloc]init];
    _favorites = [[NSMutableArray alloc]init];
    _leastFavorites = [[NSMutableArray alloc]init];
    
    // within scores are NSDictionaries
    //          @"Username"     : NSString deviceName for a user
    //          @"Profile"      : NSArray profileArray for a user
    //          @"Trial Scores" : NSMutableArray trialScores for the profile for each trial
    // add new NSDictionary each time a new user joins
    // NSDictionary at index 0 belongs to this device
    _scores = [[NSMutableArray alloc]init];
    
    NSMutableArray *trialScores = [[NSMutableArray alloc]init];
    NSDictionary *scoreDict = @{@"Device Name" : [[UIDevice currentDevice] name],
                                @"Profile"     : _ownProfile,
                                @"Scores"      : trialScores };
    [_scores addObject:scoreDict];
    
    _budget    = 150000;
    _threshVal = 150; // 150 millimeters = 6 inches
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    dataDictionary = [[NSDictionary alloc]init];
    
    _pieIndex = 0;
    
    
    
    // Register for notifications
    [defaultCenter addObserver:self
                      selector:@selector(setupSession)
                          name:UIApplicationWillEnterForegroundNotification
                        object:nil];
    
    
    [defaultCenter addObserver:self
                      selector:@selector(teardownSession)
                          name:UIApplicationDidEnterBackgroundNotification
                        object:nil];
    
    [self setupSession];
    
    /*
    [NSTimer scheduledTimerWithTimeInterval:10.0f
                                     target:self selector:@selector(checkConnection) userInfo:nil repeats:YES];
     */
    
    _slices = [[NSMutableArray alloc]init];
    
    sliceNumbers = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects: [NSNumber numberWithInt:8], [NSNumber numberWithInt:7],[NSNumber numberWithInt:6],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:3],[NSNumber numberWithInt:2],[NSNumber numberWithInt:1], nil] forKeys: [NSArray arrayWithObjects: [NSNumber numberWithInt:1], [NSNumber numberWithInt:2],[NSNumber numberWithInt:3],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:6],[NSNumber numberWithInt:7],[NSNumber numberWithInt:8], nil]];
    
    sliceColors =[NSArray arrayWithObjects:
                  [UIColor colorWithHue:.3 saturation:.6 brightness:.9 alpha: 0.5],
                  [UIColor colorWithHue:.35 saturation:.8 brightness:.6 alpha: 0.5],
                  [UIColor colorWithHue:.4 saturation:.8 brightness:.3 alpha: 0.5],
                  [UIColor colorWithHue:.55 saturation:.8 brightness:.9 alpha: 0.5],
                  [UIColor colorWithHue:.65 saturation:.8 brightness:.6 alpha: 0.5],
                  [UIColor colorWithHue:.6 saturation:.8 brightness:.6 alpha: 0.5],
                  [UIColor colorWithHue:.6 saturation:.0 brightness:.3 alpha: 0.5],
                  [UIColor colorWithHue:.65 saturation:.0 brightness:.9 alpha: 0.5],
                  [UIColor colorWithHue:.7 saturation: 0.6 brightness:.3 alpha: 0.5],
                  [UIColor colorWithHue:.75 saturation: 0.6 brightness:.6 alpha: 0.5], nil];
    
    slicesInfo = [[NSMutableArray alloc] initWithObjects:@"Investment", @"Damage Reduction", @"Efficiency of Intervention ($/Gallon)", @"Capacity Used", @"Water Flow Path", @"Max Depth of Flooding", @"Groundwater Infiltration", @"Impact on my Neighbors", nil];
    
}

#pragma mark - Memory management

/*
- (void)checkConnection {
    if ([[_session peersWithConnectionState:GKPeerStateConnected] count] == 0) {
        NSLog(@"Attempting reconnection");
        [self shutdownBluetooth];
        [self setupSession];
    }
}
*/


- (void)dealloc
{
    // Unregister for notifications on deallocation.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Nil out delegate
    _session.delegate = nil;
}


- (void) shutdownBluetooth {
    [self.session disconnectFromAllPeers];
    self.session.available = NO;
    [self.session setDataReceiveHandler:nil withContext:nil];
    self.session.delegate = nil;
    self.session = nil;
}


#pragma mark - GKSession setup and teardown

- (void)setupSession
{
    // GKSessionModePeer: a peer advertises like a server and searches like a client.
    _session = [[GKSession alloc] initWithSessionID:@"GKForEcoCollage" displayName:[NSString stringWithFormat:@"Baby%d", _studyNum] sessionMode:GKSessionModeClient];
    self.session.delegate = self;
    self.session.available = YES;
    [_session setDataReceiveHandler:self withContext:nil];
    
}

- (void)teardownSession
{
    self.session.available = NO;
    [self.session disconnectFromAllPeers];
}



#pragma mark - GKSessionDelegate protocol conformance

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    NSString *peerName = [session displayNameForPeer:peerID];
    
    switch (state)
    {
        case GKPeerStateAvailable:
        {
            NSLog(@"didChangeState: peer %@ available", peerName);
            
            BOOL shouldInvite = FALSE;
            
            if ([peerName isEqualToString:[NSString stringWithFormat:@"Momma%d", _studyNum]])
                shouldInvite = TRUE;
            
            if (shouldInvite)
            {
                NSLog(@"Inviting %@", peerID);
                [session connectToPeer:peerID withTimeout:kConnectionTimeout];
            }
            else
            {
                NSLog(@"Not inviting %@", peerID);
            }
            
            break;
        }
            
        case GKPeerStateUnavailable:
        {
            NSLog(@"didChangeState: peer %@ unavailable", peerName);
            break;
        }
            
        case GKPeerStateConnected:
        {
            NSLog(@"didChangeState: peer %@ connected", peerName);
            if ([peerName isEqualToString:[NSString stringWithFormat:@"Momma%d", _studyNum]]) {
                self.peerIDForMomma = peerID;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"sendProfile" object:self];
            }
            break;
        }
            
        case GKPeerStateDisconnected:
        {
            NSLog(@"didChangeState: peer %@ disconnected", peerName);
            
            // if momma was disconnected, allow for reconnection
            if ([peerName isEqualToString:[NSString stringWithFormat:@"Momma%d", _studyNum]]) {
                NSLog(@"Attemping reconnection");
                self.session.delegate = nil;
                self.session = nil;
                [self setupSession];
            }
            
            break;
        }
            
        case GKPeerStateConnecting:
        {
            NSLog(@"didChangeState: peer %@ connecting", peerName);
            break;
        }
    }
}


- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    NSLog(@"connectionWithPeerFailed: peer: %@, error: %@", [session displayNameForPeer:peerID], error);
    /*
    [self teardownSession];
    [self setupSession];
     */
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: error: %@", error);
    
    /*
    [session disconnectPeerFromAllPeers:session.peerID];
    [self teardownSession];
    [self setupSession];
     */
}




- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context {
    // convert NSData to NSDictionary
    dataDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if ([[dataDictionary objectForKey:@"ping"] isEqualToString:@"ping"]) {
        // received ping to keep connection alive
        //NSLog(@"Received ping");
        return;
    }
    
    // convert NSDictionary to NSArray
    NSArray *dataArray = [dataDictionary objectForKey:@"data"];
    
    if([dataArray[0] isEqualToString:@"profileToMomma"]) {
        // do nothing
    }
    else if([dataArray[0] isEqualToString:@"usernameToMomma"]) {
        // do nothing
    }
    else if([dataArray[0] isEqualToString:@"profileToBaby"]) {
        // receive individual profile when updated by another baby bird
        _reloadSocialView = 1;
        [self receiveProfileFromMomma:dataArray];
    }
    else if([dataArray[0] isEqualToString:@"usernameToBaby"]) {
        _reloadSocialView = 1;
        [self handleUsernameUpdates:dataArray];
    }
    else if([dataArray[0] isEqualToString:@"allProfilesToNewBaby"]) {
        // receive all profiles when baby bird first connects to Momma so that baby is brought up to speed
        _reloadSocialView = 1;
        [self receiveAllProfilesFromMomma:dataArray];
    }
    else if([dataArray[0] isEqualToString:@"removeProfile"]) {
        _reloadSocialView = 1;
        [self removeProfile:dataArray];
    }
    else if([dataArray[0] isEqualToString:@"singleTrialData"]) {
        [self receiveSingleTrial:dataArray];
    }
    else if([dataArray[0] isEqualToString:@"multipleTrialsData"]) {
        [self receiveMultipleTrials:dataArray];
    }
    else if([dataArray[0] isEqualToString:@"budgetChange"]) {
        _reloadSocialView = 1;
        [self updateBudget:dataArray];
    }
    else if ([dataArray[0] isEqualToString:@"trialRequestToBaby"]) {
        [self sendTrialRequestToMomma:dataArray];
    }
    else if([dataArray[0] isEqualToString:@"favoriteForBabies"] || [dataArray[0] isEqualToString:@"unselectedFavoriteForBabies"]) {
        _reloadSocialView = 1;
        [self updateFavorites:dataArray];
    }
    else if([dataArray[0] isEqualToString:@"multipleFavoritesForBaby"]) {
        _reloadSocialView = 1;
        [self updateAllFavorites:dataArray];
    }
    else if([dataArray[0] isEqualToString:@"leastFavoriteForBabies"] || [dataArray[0] isEqualToString:@"unselectedLeastFavoriteForBabies"]) {
        _reloadSocialView = 1;
        [self updateLeastFavorites:dataArray];
    }
    else if([dataArray[0] isEqualToString:@"multipleLeastFavoritesForBaby"]) {
        _reloadSocialView = 1;
        [self updateAllLeastFavorites:dataArray];
    }
    else if([dataArray[0] isEqualToString:@"thresholdUpdated"]) {
        _reloadSocialView = 1;
        [self updateThreshold:dataArray];
    }
    else {
        NSLog(@"Received unknown data");
    }
}

/* 
 Functions figures out the scores for a specific trial for a specific profile (concernRankings)
 
 Returns: Returns a mutablearray with two components. First component is another mutablearray called scoreVisVals which holds the values for each concernRanking. Second component is again another mutablearray called scoreVisNames which holds the names of each concernRanking in order.
 */
- (NSMutableArray*)getScoreBarValuesForProfile:(int)profileIndex forTrial:(int)trial isDynamicTrial:(int)dynamic{
    NSMutableArray* scores = [[NSMutableArray alloc]init];

    AprilTestSimRun *simRun = [_trialRuns objectAtIndex:trial];
    AprilTestNormalizedVariable *simRunNormal;
    
    if(dynamic) simRunNormal = [_trialRunsDynNorm objectAtIndex:trial];
    else simRunNormal = [_trialRunsNormalized objectAtIndex:trial];
    
    
    NSArray *currentProfile = [[NSArray alloc]init];
    currentProfile = [_profiles objectAtIndex:profileIndex];
    
    NSMutableArray *currentConcernRanking = [[NSMutableArray alloc]init];
    
    // get the concernRanking for the currentProfile
    for (int j = 3; j < [currentProfile count]; j++) {
        [currentConcernRanking addObject:[[AprilTestVariable alloc] initWith:[concernNames objectForKey:[currentProfile objectAtIndex:j]] withDisplayName:[currentProfile objectAtIndex: j] withNumVar:1 withWidth:220 withRank:10-j]];
    }
    
    float priorityTotal= 0;
    float scoreTotal = 0;
    for(int j = 0; j < currentConcernRanking.count; j++){
        
        priorityTotal += [(AprilTestVariable *)[currentConcernRanking objectAtIndex:j] currentConcernRanking];
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:@","];
    
    NSArray *sortedArray = [currentConcernRanking sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSInteger first = [(AprilTestVariable*)a currentConcernRanking];
        NSInteger second = [(AprilTestVariable*)b currentConcernRanking];
        if(first > second) return NSOrderedAscending;
        else return NSOrderedDescending;
    }];
    NSMutableArray *scoreVisVals = [[NSMutableArray alloc] init];
    NSMutableArray *scoreVisNames = [[NSMutableArray alloc] init];
    
    for(int j = 0 ; j < currentConcernRanking.count ; j++){
        
        AprilTestVariable * currentVar =[sortedArray objectAtIndex:j];
        
        //laziness: this is just the investment costs
        if([currentVar.name compare: @"publicCost"] == NSOrderedSame){
            float investmentInstallN = simRunNormal.publicInstallCost;
            float investmentMaintainN = simRunNormal.publicMaintenanceCost;
            
            scoreTotal += (currentVar.currentConcernRanking/priorityTotal * (1 - investmentInstallN));
            //scoreTotal += ((currentVar.currentConcernRanking/2.0)/priorityTotal * (1 - investmentMaintainN));
            //scoreTotal += ((currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRun.impactNeighbors));
            
            [scoreVisVals addObject:[NSNumber numberWithFloat:((currentVar.currentConcernRanking)/priorityTotal * (1 - investmentInstallN))]];
            //[scoreVisVals addObject:[NSNumber numberWithFloat:((currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRun.impactNeighbors))]];
            [scoreVisNames addObject: @"publicCost"];
            //[scoreVisNames addObject: @"publicCostD"];
            
            
            //just damages now
        } else if ([currentVar.name compare: @"privateCost"] == NSOrderedSame){
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.privateDamages);
            
            //add values for the score visualization
            
            [scoreVisVals addObject:[NSNumber numberWithFloat:(currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.privateDamages))]];
            //scoreTotal +=currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.privateDamages);
            //[scoreVisVals addObject: [NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.privateDamages)]];
            [scoreVisNames addObject: @"privateCostD"];
            
        } else if ([currentVar.name compare: @"impactingMyNeighbors"] == NSOrderedSame){
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.impactNeighbors);
            [scoreVisVals addObject:[NSNumber numberWithFloat: currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.impactNeighbors)]];
            [scoreVisNames addObject: currentVar.name];
            
        } else if ([currentVar.name compare: @"groundwaterInfiltration"] == NSOrderedSame){
            
            
            scoreTotal += (currentVar.currentConcernRanking/priorityTotal) * (simRunNormal.infiltration );
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * ( simRunNormal.infiltration )]];
            [scoreVisNames addObject: currentVar.name];
        } else if([currentVar.name compare:@"puddleTime"] == NSOrderedSame){
            
            
            scoreTotal += (currentVar.currentConcernRanking + 1)/priorityTotal * (1 - simRunNormal.standingWater);
            [scoreVisVals addObject:[NSNumber numberWithFloat:(currentVar.currentConcernRanking)/priorityTotal * (1- simRunNormal.standingWater)]];
            [scoreVisNames addObject: currentVar.name];
            
        } else if([currentVar.name compare:@"puddleMax"] == NSOrderedSame){
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.floodedStreets);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1- simRunNormal.floodedStreets)]];
            [scoreVisNames addObject: currentVar.name];
        } else if ([currentVar.name compare: @"capacity"] == NSOrderedSame){
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal *  (simRunNormal.efficiency);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal *  (simRunNormal.efficiency)]];
            //NSLog(@"%@", NSStringFromCGRect(ev.frame));
            [scoreVisNames addObject: currentVar.name];
            
        } else if ([currentVar.name compare: @"efficiencyOfIntervention"] == NSOrderedSame){
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1 - simRun.dollarsGallons/25.19);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1 - simRun.dollarsGallons/25.19)]];
            [scoreVisNames addObject:currentVar.name];
        }
    }
    
    float mod = [self generateOverBudgetPenalty:scoreVisNames withInstallCost:simRun.publicInstallCost];
    
    
    //computing each score with log skew due to over-investment cost
    for(int k =  0; k < scoreVisVals.count; k++){
        
        float scoreWidth = [[scoreVisVals objectAtIndex: k] floatValue];

        scoreWidth *= mod;

        if (scoreWidth < 0) scoreWidth = 0.0;
        [scoreVisVals replaceObjectAtIndex:k withObject:[NSNumber numberWithFloat:scoreWidth]];
    }
    
    
    [scores addObject:scoreVisVals];
    [scores addObject:scoreVisNames];
    return scores;
}

- (float)generateOverBudgetPenalty:(NSMutableArray*)scoreVisNames withInstallCost:(int)installCost {
    
    int investmentIndex = 0;
    for(int i = 0; i < scoreVisNames.count; i++) {
        if([[scoreVisNames objectAtIndex:i] isEqualToString:@"publicCostI"] ||
           [[scoreVisNames objectAtIndex:i] isEqualToString:@"publicCost"])
            investmentIndex = i;
    }
    
    float amountOverBudget = (installCost - _budget)/(float)_budget;
    float modifier;
    if ( amountOverBudget > 1 && investmentIndex < 7)
        modifier = (1 - cos((amountOverBudget * (7-investmentIndex)/7)* M_PI))/2;
    else modifier = 1;
    
    if(modifier > 1) modifier = 1;
    if(amountOverBudget <= 0) modifier = 1;
    
    return modifier;
}

- (void)updateThreshold:(NSArray*)dataArray {
    float threshold = [((NSNumber*)dataArray[1]) floatValue];
    _threshVal = threshold;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFloodingThreshold" object:self];
}

- (void)updateAllFavorites:(NSArray *)dataArray {
    for (int i = 1; i < [dataArray count]; i++) {
        [self updateFavorites:[dataArray objectAtIndex:i]];
    }
}

- (void)updateAllLeastFavorites:(NSArray *)dataArray {
    for (int i = 1; i < [dataArray count]; i++) {
        [self updateLeastFavorites:[dataArray objectAtIndex:i]];
    }
}


- (void)addFavorite:(NSArray *)dataArray {
    // check if this favorite is already present, if so don't add it
    BOOL isPresent = FALSE;
    for(int i = 0; i < _favorites.count; i++) {
        NSArray *favorite = [_favorites objectAtIndex:i];
        if([[dataArray objectAtIndex:1] isEqualToString:[favorite objectAtIndex:1]] && [[dataArray objectAtIndex:2] isEqualToNumber:[favorite objectAtIndex:2]])
            isPresent = TRUE;
    }
    if(!isPresent) {
        [_favorites addObject:dataArray];
    }
}

- (void)removeFavorite:(NSArray *)dataArray {
    // check if this favorite is present, if so remove it
    for(int i = 0; i < _favorites.count; i++) {
        NSArray *favorite = [_favorites objectAtIndex:i];
        if([[dataArray objectAtIndex:1] isEqualToString:[favorite objectAtIndex:1]] && [[dataArray objectAtIndex:2] isEqualToNumber:[favorite objectAtIndex:2]])
            [_favorites removeObjectAtIndex:i];
    }
}

- (void)updateFavorites:(NSArray*)dataArray {
    BOOL favoriteIsAnUpdate = NO;
    int indexOfProfile = -1;
    
    if([[dataArray objectAtIndex:0] isEqualToString:@"unselectedFavoriteForBabies"])
        [self removeFavorite:dataArray];
    else
        [self addFavorite:dataArray];
    
    for(NSArray *favorite in _favorites) {
        NSLog(@"%@", favorite);
    }
    /*
    for (int i = 0; i < _favorites.count; i++) {
        NSArray *favorite = [_favorites objectAtIndex:i];
        
        if ([[favorite objectAtIndex:1] isEqualToString:[dataArray objectAtIndex:1]]) {
            favoriteIsAnUpdate = YES;
            [_favorites replaceObjectAtIndex:i withObject:dataArray];
            NSLog(@"Replaced favorite for device %@", [dataArray objectAtIndex:1]);
            
            // send notification to social view controller that there was an update to a favorite
        }
    }
    
    NSArray *profile;
    if (favoriteIsAnUpdate) {
        for (int i = 0; i < _profiles.count; i++) {
            profile = [_profiles objectAtIndex:i];
            if ([[profile objectAtIndex:1] isEqualToString:[dataArray objectAtIndex:1]]) {
                indexOfProfile = i;
                break;
            }
        }
    }
    
    if (!favoriteIsAnUpdate) {
        [_favorites addObject:dataArray];
        NSLog(@"Added favorite for device %@", [dataArray objectAtIndex:1]);
    }
    else if(favoriteIsAnUpdate && indexOfProfile != -1) {
        NSNumber *numIndex = [NSNumber numberWithInt:indexOfProfile];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:numIndex forKey:@"data"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFavoriteOrLeast" object:self   userInfo:dict];
        [self updatePieChartAtIndex:indexOfProfile forProfile:profile];
    }
     */
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"favoritesUpdated" object:self   userInfo:nil];
}


- (void)addLeastFavorite:(NSArray *)dataArray {
    // check if this favorite is already present, if so don't add it
    BOOL isPresent = FALSE;
    for(int i = 0; i < _leastFavorites.count; i++) {
        NSArray *leastFavorite = [_leastFavorites objectAtIndex:i];
        if([[dataArray objectAtIndex:1] isEqualToString:[leastFavorite objectAtIndex:1]] && [[dataArray objectAtIndex:2] isEqualToNumber:[leastFavorite objectAtIndex:2]])
            isPresent = TRUE;
    }
    if(!isPresent) {
        [_leastFavorites addObject:dataArray];
    }
    
}

- (void)removeLeastFavorite:(NSArray *)dataArray {
    // check if this favorite is present, if so remove it
    for(int i = 0; i < _leastFavorites.count; i++) {
        NSArray *leastFavorite = [_leastFavorites objectAtIndex:i];
        if([[dataArray objectAtIndex:1] isEqualToString:[leastFavorite objectAtIndex:1]] && [[dataArray objectAtIndex:2] isEqualToNumber:[leastFavorite objectAtIndex:2]])
            [_leastFavorites removeObjectAtIndex:i];
    }
}

- (void)updateLeastFavorites:(NSArray *)dataArray {
    BOOL leastFavoriteIsAnUpdate = NO;
    int indexOfProfile = -1;
    
    if([[dataArray objectAtIndex:0] isEqualToString:@"unselectedLeastFavoriteForBabies"])
        [self removeLeastFavorite:dataArray];
    else
        [self addLeastFavorite:dataArray];
    
    for(NSArray *leastFavorite in _leastFavorites) {
        NSLog(@"%@", leastFavorite);
    }
    
    /*
    for (int i = 0; i < _leastFavorites.count; i++) {
        NSArray *leastFavorite = [_leastFavorites objectAtIndex:i];
        
        if ([[leastFavorite objectAtIndex:1] isEqualToString:[dataArray objectAtIndex:1]]) {
            leastFavoriteIsAnUpdate = YES;
            [_leastFavorites replaceObjectAtIndex:i withObject:dataArray];
            NSLog(@"Replaced least favorite for device %@", [dataArray objectAtIndex:1]);
        }
    }
    
    NSArray *profile;
    if (leastFavoriteIsAnUpdate) {
        for (int i = 0; i < _profiles.count; i++) {
            profile = [_profiles objectAtIndex:i];
            if ([[profile objectAtIndex:1] isEqualToString:[dataArray objectAtIndex:1]]) {
                indexOfProfile = i;
                break;
            }
        }
    }
    
    if (!leastFavoriteIsAnUpdate) {
        [_leastFavorites addObject:dataArray];
        NSLog(@"Added least favorite for device %@", [dataArray objectAtIndex:1]);
    }
    else if(leastFavoriteIsAnUpdate && indexOfProfile != -1) {
        NSNumber *numIndex = [NSNumber numberWithInt:indexOfProfile];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:numIndex forKey:@"data"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFavoriteOrLeast" object:self   userInfo:dict];
        [self updatePieChartAtIndex:indexOfProfile forProfile:profile];
    }
     */
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"leastFavoritesUpdated" object:self   userInfo:nil];
}

- (void)sendTrialRequestToMomma:(NSArray*)dataArray {
    int trialUpdate = [[dataArray objectAtIndex:1] integerValue];
    
    // if Momma has new trials for us, send her a request
    if (trialUpdate > _trialNum) {
        NSMutableArray *trialRequest = [[NSMutableArray alloc]init];
        // add type of data
        [trialRequest addObject:@"requestForTrial"];
        
        [trialRequest addObject:[NSNumber numberWithInt:_trialNum]];

        
        NSDictionary *trialRequestToSendToMomma = [NSDictionary dictionaryWithObject:trialRequest
                                                                         forKey:@"data"];
        
        if(trialRequestToSendToMomma != nil) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:trialRequestToSendToMomma];
            if(_peerIDForMomma != nil)
                [_session sendData:data toPeers:@[_peerIDForMomma] withDataMode:GKSendDataReliable error:nil];
        }
    }
}

- (void)removeProfile:(NSArray *)dataArray {
    // if profile belongs to us, don't do anything
    if ([[dataArray objectAtIndex:1] isEqualToString:[[UIDevice currentDevice]name]])
        return;
    
    for (int i = 0; i < _profiles.count; i++) {
        // if device names match, change username
        if([_profiles[i][1] isEqualToString:dataArray[1]]) {
            [_profiles removeObjectAtIndex:i];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"profileUpdate" object:self userInfo:nil];
}

//generates a log entry with an extra bit of information regarding the log that must be added as an argument
//only offers the username and time stamp in the method
- (NSString*) generateLogEntryWith:(NSString*)extra{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *timeStamp = [formatter stringFromDate:[NSDate date]];
    
    NSString *logEntry = [NSString stringWithFormat:@"%@\t%@ %@\n",self.ownProfileName,timeStamp, extra];
    
    //log the entry that will be written (debugging reasons)
    //NSLog(@"%@", logEntry);
    
    return logEntry;
}

//method that writes/rewrites at a log file in documents directory
- (void) writeToLogFileString:(NSString*)str{
    
    //determine if the file exists or not... if not then create it
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:_LogFile];
    if (!fileExists) {
        [[NSFileManager defaultManager] createFileAtPath:_LogFile contents:nil attributes:nil];
        [str writeToFile:_LogFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    else{
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:_LogFile];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    }

}

- (void)handleUsernameUpdates:(NSArray *)dataArray {
    // if username belongs to this device, don't do anything (name changes are stored locally already)
    if ([[dataArray objectAtIndex:1] isEqualToString:[[UIDevice currentDevice]name]])
        return;
    
    int index = -1;
    
    for (int i = 0; i < _profiles.count; i++) {
        // if device names match, change username
        if([_profiles[i][1] isEqualToString:dataArray[1]]) {
            /*
            if ([[[_profiles objectAtIndex:i] objectAtIndex:2] isEqualToString:[dataArray objectAtIndex:2]])
                return;
             */
            _profiles[i][2] = dataArray[2];
            index = i;
        }
    }
    
    if (index != -1) {
        NSNumber *numIndex = [NSNumber numberWithInt:index];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:numIndex forKey:@"data"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"usernameUpdate" object:nil userInfo:dict];
    }
    
}


- (void) receiveAllProfilesFromMomma:(NSArray *)dataArray {
    NSLog(@"AprilTestTabBar: receiveAllProfilesFromMomma: Received all profiles from Momma");
    
    // check if our profiles are the same as Momma's
    int numberOfSameProfiles = 0;
    for (NSArray *profile in _profiles) {
        for (int i = 1; i < [dataArray count]; i++) {
            if ([[dataArray objectAtIndex:i] isEqual:profile])
                numberOfSameProfiles++;
        }
    }
    
    // if all the profiles are the same, return
    if (numberOfSameProfiles == [_profiles count])
        return;
     
    if (_profiles.count != 0) {
        [_profiles removeAllObjects];
        [_pieCharts removeAllObjects];
        [_scores removeAllObjects];
        [_pieChartsForScoreBarView removeAllObjects];
        [_slices removeAllObjects];
    }
    
    int indexOffset = 0;
    indexOffset = (int)_ownProfile.count - 8;
    
    NSMutableArray *trialScores = [[NSMutableArray alloc]init];
    NSDictionary *scoreDict = @{@"Device Name" : [[UIDevice currentDevice]name],
                                @"Profile"     : [[NSArray alloc] initWithObjects:[_ownProfile objectAtIndex:indexOffset], [_ownProfile objectAtIndex:indexOffset+1], [_ownProfile objectAtIndex:indexOffset+2], [_ownProfile objectAtIndex:indexOffset+3], [_ownProfile objectAtIndex:indexOffset+4], [_ownProfile objectAtIndex:indexOffset+5], [_ownProfile objectAtIndex:indexOffset+6], [_ownProfile objectAtIndex:indexOffset+7], nil],
                                @"Scores"      : trialScores };
    [_scores addObject:scoreDict];
    
    [_profiles addObject:_ownProfile];
    [self addPieChartAtIndex:0 forProfile:_ownProfile];
    
    // add all profiles sent from momma to local profile list in baby
    for (int i = 1; i < dataArray.count; i++) {
        indexOffset = (int)[[dataArray objectAtIndex:i] count] - 8;
        // only add the profile if it is not our own
        if (![[[dataArray objectAtIndex:i]objectAtIndex:1] isEqualToString:[[UIDevice currentDevice]name] ]) {
            [_profiles addObject:[dataArray objectAtIndex:i]];
            [self addPieChartAtIndex:i forProfile:[dataArray objectAtIndex:i]];

            NSArray *profile = [dataArray objectAtIndex:i];
            
            NSMutableArray *trialScores = [[NSMutableArray alloc]init];
            NSDictionary *scoreDict = @{@"Device Name" : [[UIDevice currentDevice]name],
                                        @"Profile"     : [[NSArray alloc] initWithObjects:[profile objectAtIndex:indexOffset], [profile objectAtIndex:indexOffset+1], [profile objectAtIndex:indexOffset+2], [profile objectAtIndex:indexOffset+3], [profile objectAtIndex:indexOffset+4], [profile objectAtIndex:indexOffset+5], [profile objectAtIndex:indexOffset+6], [profile objectAtIndex:indexOffset+7], nil],
                                        @"Scores"      : trialScores };
            [_scores addObject:scoreDict];
        }
    }
    
    
    NSLog(@"AprilTestTabBar: receiveAllProfilesFromMomma: Processed all profiles from Momma");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"profileUpdate" object:self userInfo:nil];
    NSLog(@"AprilTestTabBar: receiveAllProfilesFromMomma: Sent notification for all profiles from Momma to listening channels");
}

// when a new profile is received, add the a new pie object to _pieCharts
- (void) addPieChartAtIndex:(int)index forProfile:(NSArray *)profile {
    // write code for adding pie charts
    
    // draw pie chart
    // draw profile pie charts
    XYPieChart *pie = [[XYPieChart alloc]initWithFrame:CGRectMake(-5, 5, 120, 120) Center:CGPointMake(80, 100) Radius:60.0];
    XYPieChart *pie2 = [[XYPieChart alloc]initWithFrame:CGRectMake(40, 30, 180, 180) Center:CGPointMake(80, 100) Radius:90.0];
    
    NSMutableArray *newSlices = [[NSMutableArray alloc]init];
    for (int i = 0; i < 8; i++) {
        [newSlices addObject:[NSNumber numberWithInt:1]];
    }
    
    for (int j = 0; j < 8; j++) {
        int indexS = (int)[profile indexOfObject:[slicesInfo objectAtIndex:j]] - 2;
        [newSlices replaceObjectAtIndex:j withObject:[sliceNumbers objectForKey:[NSNumber numberWithInt:indexS]]];
    }
    
    _pieIndex = [_slices count];
    [_slices addObject:newSlices];
    
    [pie setDataSource:self];
    [pie setStartPieAngle:M_PI_2];
    [pie setAnimationSpeed:1.0];
    [pie setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
    [pie setUserInteractionEnabled:NO];
    pie.showLabel = false;
    [pie setLabelShadowColor:[UIColor blackColor]];
    
    [pie reloadData];
    
    [_pieCharts addObject:pie];
    
    [pie2 setDataSource:self];
    [pie2 setStartPieAngle:M_PI_2];
    [pie2 setAnimationSpeed:1.0];
    [pie2 setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
    [pie2 setUserInteractionEnabled:YES];
    pie2.showLabel = false;
    [pie2 setLabelShadowColor:[UIColor blackColor]];
    
    [pie2 reloadData];
    
    [_pieChartsForScoreBarView addObject:pie2];
}

- (void) updatePieChartAtIndex:(int)index forProfile:(NSArray *)profile{
    XYPieChart *pie1 = [_pieCharts objectAtIndex:index];
    XYPieChart *pie2 = [_pieChartsForScoreBarView objectAtIndex:index];
    
    for (int j = 0; j < 8; j++) {
        int indexS = (int)[profile indexOfObject:[slicesInfo objectAtIndex:j]] - 2;
        [[_slices objectAtIndex:index] replaceObjectAtIndex:j withObject:[sliceNumbers objectForKey:[NSNumber numberWithInt:indexS]]];
    }
    
    _pieIndex = index;
    
    [pie1 reloadData];
    [pie2 reloadData];
    
    // make a notification to social view that a pie chart was reloaded
}

- (void)reloadDataForPieChartAtIndex:(int)index {
    _pieIndex = index;
}


- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return 8;
}

- (CGFloat) pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    return [[[_slices objectAtIndex:_pieIndex] objectAtIndex:index] intValue];
}
- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    return [sliceColors objectAtIndex:(index % sliceColors.count)];
}

// profile data setup by indexes of mutablearray
// 0 : type of data being sent (profileToBaby)
// 1 : device name
// 2 : username (defaults to devices name if no username selected)
// 3 - 10 : concerns in order of most important to least important

- (void) receiveProfileFromMomma:(NSArray *)dataArray {
    NSLog(@"AprilTestTabBar: receiveProfileFromMomma: Received single profile from Momma");
    
    // if profile belongs to us, don't do anything
    if ([[dataArray objectAtIndex:1] isEqualToString:[[UIDevice currentDevice]name]]) {
        [self addPieChartAtIndex:0 forProfile:_ownProfile];
        
        int indexOffset = (int)_ownProfile.count - 8;
        
        NSMutableArray *trialScores = [[NSMutableArray alloc]init];
        NSDictionary *scoreDict = @{@"Device Name" : [[UIDevice currentDevice]name],
                                    @"Profile"     : [[NSArray alloc]initWithObjects:[_ownProfile objectAtIndex:indexOffset], [_ownProfile objectAtIndex:indexOffset+1], [_ownProfile objectAtIndex:indexOffset+2], [_ownProfile objectAtIndex:indexOffset+3], [_ownProfile objectAtIndex:indexOffset+4], [_ownProfile objectAtIndex:indexOffset+5], [_ownProfile objectAtIndex:indexOffset+6], [_ownProfile objectAtIndex:indexOffset+7], nil],
                                    @"Scores"      : trialScores };
        [_scores replaceObjectAtIndex:0 withObject:scoreDict];
        
        return;
    }
    
    
    BOOL oldProfile = 0;
    int index = -1;
    
    // check if profile sent from baby is an update on an already existing one,
    // and if so update it and send update to babies
    for (int i = 0; i < _profiles.count; i++) {
        if([_profiles[i][1] isEqualToString:dataArray[1]]) {
            /*
            if([[_profiles objectAtIndex:i] isEqual: dataArray])
                return;
             */
            _profiles[i] = dataArray;
            oldProfile = 1;
            // grab the index of the profile changed so social view visualization can reload that profile
            index = i;
            
            int indexOffset = (int)dataArray.count - 8;
            
            NSMutableArray *trialScores = [[NSMutableArray alloc]init];
            NSDictionary *scoreDict = @{@"Device Name" : [dataArray objectAtIndex:1],
                                        @"Profile"     : [[NSArray alloc]initWithObjects:[dataArray objectAtIndex:indexOffset], [dataArray objectAtIndex:indexOffset+1], [dataArray objectAtIndex:indexOffset+2], [dataArray objectAtIndex:indexOffset+3], [dataArray objectAtIndex:indexOffset+4], [dataArray objectAtIndex:indexOffset+5], [dataArray objectAtIndex:indexOffset+6], [dataArray objectAtIndex:indexOffset+7], nil],
                                        @"Scores"      : trialScores };
            [_scores replaceObjectAtIndex:i withObject:scoreDict];
        }
    }
    
    // otherwise, the profile is new and should be added to the mutableArray 'profiles'
    // a pie chart should also be loaded for the profile
    // add NSDictionary to _scores
    if (!oldProfile) {
        [_profiles addObject:dataArray];
        [self addPieChartAtIndex:(int)[_pieCharts count] forProfile:dataArray];
        
        int indexOffset = (int)dataArray.count - 8;
        
        NSMutableArray *trialScores = [[NSMutableArray alloc]init];
        NSDictionary *scoreDict = @{@"Device Name" : [dataArray objectAtIndex:1],
                                    @"Profile"     : [[NSArray alloc]initWithObjects:[dataArray objectAtIndex:indexOffset], [dataArray objectAtIndex:indexOffset+1], [dataArray objectAtIndex:indexOffset+2], [dataArray objectAtIndex:indexOffset+3], [dataArray objectAtIndex:indexOffset+4], [dataArray objectAtIndex:indexOffset+5], [dataArray objectAtIndex:indexOffset+6], [dataArray objectAtIndex:indexOffset+7], nil],
                                    @"Scores"      : trialScores };
        [_scores addObject:scoreDict];
    }
    
    
    NSLog(@"AprilTestTabBar: receiveProfileFromMomma: Processed single profile from Momma");

    if (oldProfile) {
        NSNumber *numIndex = [NSNumber numberWithInt:index];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:numIndex forKey:@"data"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSingleProfile" object:self   userInfo:dict];
        [self updatePieChartAtIndex:index forProfile:dataArray];
    }
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:@"drawNewProfile" object:self userInfo:nil];
    
    
    NSLog(@"AprilTestTabBar: receiveProfileFromMomma: Sent notification for single profile from Momma to listening channels");
}


- (void) receiveSingleTrial:(NSArray *)dataArray {
    NSLog(@"AprilTestTabBar: receiveSingleTrial: Received single trial");
    
    AprilTestSimRun *simRun = [[AprilTestSimRun alloc] init:[dataArray objectAtIndex:1] withTrialNum:_trialNum];
    AprilTestNormalizedVariable *simRunNormal = [[AprilTestNormalizedVariable alloc] init: [dataArray objectAtIndex:2] withTrialNum:_trialNum];
    AprilTestNormalizedVariable *simRunDyn    = [[AprilTestNormalizedVariable alloc] init: [dataArray objectAtIndex:2] withTrialNum:_trialNum];
    
    [_trialRuns addObject:simRun];
    [_trialRunsNormalized addObject:simRunNormal];
    [_trialRunsDynNorm addObject:simRunDyn];
    
    
    // check if we already have this trial
    for (int i = 0; i < _trialNum; i++) {
        if ([((AprilTestSimRun*)[_trialRuns objectAtIndex:i]).map isEqualToString:simRun.map]) {
            [_trialRuns objectAtIndex:i];
            [_trialRunsNormalized objectAtIndex:i];
            [_trialRunsDynNorm objectAtIndex:i];
            return;
        }
    }
    
    //keeping track of water display views
    FebTestWaterDisplay *waterDisplay = [[FebTestWaterDisplay alloc] initWithFrame:CGRectMake(0, 0, 115, 125) andContent:simRun.standingWater];
    [_waterDisplaysInTab addObject:waterDisplay];
    UIView *viewForWaterDisplay = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 115, 125)];
    [viewsForWaterDisplays addObject:viewForWaterDisplay];
    waterDisplay.view = viewForWaterDisplay;
    
    //keeping track of max water display views
    FebTestWaterDisplay *maxWaterDisplay = [[FebTestWaterDisplay alloc] initWithFrame:CGRectMake(0, 0, 115, 125) andContent:simRun.maxWaterHeights];
    UIView *viewForMaxWaterDisplay = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 115, 125)];
    [viewsForMaxWaterDisplays addObject:viewForMaxWaterDisplay];
    maxWaterDisplay.view = [viewsForMaxWaterDisplays objectAtIndex:_trialNum];
    [_maxWaterDisplaysInTab addObject:maxWaterDisplay];
    
    //keeping track of intervention capacity views
    AprilTestEfficiencyView *ev = [[AprilTestEfficiencyView alloc] initWithFrame:CGRectMake(0, 0, 130, 150) withContent: simRun.efficiency];
    [_efficiencyViewsInTab addObject:ev];
    UIView *viewforEfficiency = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 130, 150)];
    [viewsForEfficiencyViews addObject:viewforEfficiency];
    ev.trialNum = _trialNum;
    ev.view = [viewsForEfficiencyViews objectAtIndex:_trialNum];
    
    _trialNum++;
    
    
    NSLog(@"AprilTestTabBar: receiveSingleTrial: Processed single trial");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePicker" object:self];
    if (_trialNum == 1)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"profileUpdate" object:self];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"drawSingleTrial" object:self userInfo:nil];
    
    
    NSLog(@"AprilTestTabBar: receiveSingleTrial: Sent notification to listening channels");
}


- (void) receiveMultipleTrials:(NSArray *)dataArray {
    NSLog(@"AprilTestTabBar: receiveMultipleTrials: Received multiple trials");
    
    
    // check if we already have all of the trials being sent over
    // count of objects in dataArray = (2 * number of trials being sent) + 1
    if ([dataArray count] <= _trialNum * 2 + 1) {
        NSLog(@"AprilTestTabBar: receiveMultipleTrials: Not updating all trials");
        return;
    }
    
    BOOL updateSocial = 0;
    if (_trialNum == 0)
        updateSocial = 1;
     
    
    NSMutableArray *temp = [[NSMutableArray alloc]init];
    
    // grab any new trials
    for (int i = _trialNum * 2 + 1; i < [dataArray count] - 1; i+=2) {
        [temp addObject:[dataArray objectAtIndex:i]];
        [temp addObject:[dataArray objectAtIndex:i+1]];
    }
    
    for (int i = 0; i < temp.count - 1; i += 2) {
        
        AprilTestSimRun *simRun = [[AprilTestSimRun alloc] init:[temp objectAtIndex:i] withTrialNum:_trialNum];
        AprilTestNormalizedVariable *simRunNormal = [[AprilTestNormalizedVariable alloc] init: [temp objectAtIndex:i+1] withTrialNum:_trialNum];
        AprilTestNormalizedVariable *simRunDyn    = [[AprilTestNormalizedVariable alloc] init: [temp objectAtIndex:i+1] withTrialNum:_trialNum];
        
        [_trialRuns addObject:simRun];
        [_trialRunsNormalized addObject:simRunNormal];
        [_trialRunsDynNorm addObject:simRunDyn];
        
        
        FebTestWaterDisplay *waterDisplay = [[FebTestWaterDisplay alloc] initWithFrame:CGRectMake(0, 0, 115, 125) andContent:simRun.standingWater];
        [_waterDisplaysInTab addObject:waterDisplay];
        UIView *viewForWaterDisplay = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 115, 125)];
        [viewsForWaterDisplays addObject:viewForWaterDisplay];
        waterDisplay.view = viewForWaterDisplay;
        
        FebTestWaterDisplay *maxWaterDisplay = [[FebTestWaterDisplay alloc] initWithFrame:CGRectMake(0, 0, 115, 125) andContent:simRun.maxWaterHeights];
        UIView *viewForMaxWaterDisplay = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 115, 125)];
        [viewsForMaxWaterDisplays addObject:viewForMaxWaterDisplay];
        maxWaterDisplay.view = [viewsForMaxWaterDisplays objectAtIndex:_trialNum];
        [_maxWaterDisplaysInTab addObject:maxWaterDisplay];
        
        //keeping track of intervention capacity views
        AprilTestEfficiencyView *ev = [[AprilTestEfficiencyView alloc] initWithFrame:CGRectMake(0, 0, 130, 150) withContent: simRun.efficiency];
        [_efficiencyViewsInTab addObject:ev];
        UIView *viewforEfficiency = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 130, 150)];
        [viewsForEfficiencyViews addObject:viewforEfficiency];
        ev.trialNum = _trialNum;
        ev.view = [viewsForEfficiencyViews objectAtIndex:_trialNum];
        
        _trialNum++;
    }
    
    NSLog(@"AprilTestTabBar: receiveMultipleTrials: Processed multiple trials");
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePicker" object:self];
    if (updateSocial)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"profileUpdate" object:self userInfo:nil];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"drawMultipleTrials" object:self userInfo:nil];
    
    NSLog(@"AprilTestTabBar: receiveMultipleTrials: Sent updates to listening views for multiple trials");
    
}

- (void)updateBudget:(NSArray *)dataArray {
    if (_budget == [[dataArray objectAtIndex:1]integerValue])
        return;

    _budget = [[dataArray objectAtIndex:1]integerValue];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBudget" object:self];
}


- (UIImage *)viewToImageForWaterDisplay:(FebTestWaterDisplay *)waterDisplay {
    return [waterDisplay viewToImage];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Memory Warning!" message:@"Device is running low on memory. Application may crash soon." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
}


@end




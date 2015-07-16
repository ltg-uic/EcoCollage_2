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

@interface AprilTestTabBarController ()


@end


@implementation AprilTestTabBarController
@synthesize currentConcernRanking = _currentConcernRanking;
@synthesize url = _url;
@synthesize studyNum = _studyNum;
@synthesize trialNum = _trialNum;
@synthesize session = _session;
@synthesize profiles = _profiles;
@synthesize ownProfile = _ownProfile;
@synthesize trialRuns = _trialRuns;
@synthesize trialRunsNormalized = _trialRunsNormalized;
@synthesize trialRunsDynNorm = _trialRunsDynNorm;
@synthesize budget = _budget;
@synthesize waterDisplaysInTab = _waterDisplaysInTab;
@synthesize maxWaterDisplaysInTab = _maxWaterDisplaysInTab;
@synthesize pieCharts = _pieCharts;

static NSTimeInterval const kConnectionTimeout = 30.0;
NSMutableArray *viewsForWaterDisplays;
NSMutableArray *viewsForMaxWaterDisplays;
NSDictionary *dataDictionary;



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
    
    _currentConcernRanking = [[NSMutableArray alloc] initWithObjects: [[AprilTestVariable alloc] initWith:@"publicCost" withDisplayName:@"Investment" withNumVar:1 withWidth:220 withRank:1], [[AprilTestVariable alloc] initWith:@"privateCost" withDisplayName:@"Damage Reduction" withNumVar:1 withWidth:220 withRank:1], [[AprilTestVariable alloc] initWith:@"efficiencyOfIntervention" withDisplayName:@"Efficiency of Intervention ($/Gallon)" withNumVar:1 withWidth:220 withRank:1], [[AprilTestVariable alloc] initWith:@"capacity" withDisplayName:@"Capacity Used" withNumVar:1 withWidth:220 withRank:1], [[AprilTestVariable alloc] initWith:@"puddleTime" withDisplayName:@"Water Depth Over Time" withNumVar:1 withWidth:220 withRank:1], [[AprilTestVariable alloc] initWith:@"puddleMax" withDisplayName:@"Maximum Flooded Area" withNumVar:1 withWidth:220 withRank:1], [[AprilTestVariable alloc] initWith:@"groundwaterInfiltration" withDisplayName:@"Groundwater Infiltration" withNumVar:1 withWidth:220 withRank:1], [[AprilTestVariable alloc] initWith:@"impactingMyNeighbors" withDisplayName:@"Impact on my Neighbors" withNumVar:1 withWidth:220 withRank:1], nil];
    
    // Do any additional setup after loading the view.
    
    _trialRuns = [[NSMutableArray alloc]init];
    _trialRunsNormalized = [[NSMutableArray alloc]init];
    _trialRunsDynNorm = [[NSMutableArray alloc]init];
    _profiles = [[NSMutableArray alloc]init];
    _ownProfile = [[NSMutableArray alloc]init];
    _waterDisplaysInTab = [[NSMutableArray alloc]init];
    _maxWaterDisplaysInTab = [[NSMutableArray alloc]init];
    viewsForWaterDisplays = [[NSMutableArray alloc]init];
    viewsForMaxWaterDisplays = [[NSMutableArray alloc]init];
    _pieCharts = [[NSMutableArray alloc]init];
    
    _budget = 150000;
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    dataDictionary = [[NSDictionary alloc]init];
    
    
    
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
    
    [NSTimer scheduledTimerWithTimeInterval:10.0f
                                     target:self selector:@selector(checkConnection) userInfo:nil repeats:YES];
    
}

#pragma mark - Memory management

- (void)checkConnection {
    if ([[_session peersWithConnectionState:GKPeerStateConnected] count] == 0) {
        NSLog(@"Attempting reconnection");
        [self shutdownBluetooth];
        [self setupSession];
    }
}



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
            
            BOOL shouldInvite = ([peerName isEqualToString:[NSString stringWithFormat:@"Momma%d", _studyNum]]);
            
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
            /*
            [self teardownSession];
            [self setupSession];
             */
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
        [self receiveProfileFromMomma:dataArray];
    }
    else if([dataArray[0] isEqualToString:@"usernameToBaby"]) {
        [self handleUsernameUpdates:dataArray];
    }
    else if([dataArray[0] isEqualToString:@"allProfilesToNewBaby"]) {
        // receive all profiles when baby bird first connects to Momma so that baby is brought up to speed
        [self receiveAllProfilesFromMomma:dataArray];
    }
    else if([dataArray[0] isEqualToString:@"removeProfile"]) {
        [self removeProfile:dataArray];
    }
    else if([dataArray[0] isEqualToString:@"singleTrialData"]) {
        [self receiveSingleTrial:dataArray];
    }
    else if([dataArray[0] isEqualToString:@"multipleTrialsData"]) {
        [self receiveMultipleTrials:dataArray];
    }
    else if([dataArray[0] isEqualToString:@"budgetChange"]) {
        [self updateBudget:dataArray];
    }
    else {
        NSLog(@"Received unknown data");
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
    
    // empty current profiles mutableArray if there is anything in there
    if (_profiles.count >= ([dataArray count] - 1))
        return;
    
     
    if (_profiles.count != 0) {
        [_profiles removeAllObjects];
        [_pieCharts removeAllObjects];
    }
    
    [_profiles addObject:_ownProfile];
    [self addPieChartAtIndex:0 forProfile:_ownProfile];
    
    // add all profiles sent from momma to local profile list in baby
    for (int i = 1; i < dataArray.count; i++) {
        // only add the profile if it is not our own
        if (![[[dataArray objectAtIndex:i]objectAtIndex:1] isEqualToString:[[UIDevice currentDevice]name] ]) {
            [_profiles addObject:[dataArray objectAtIndex:i]];
            [self addPieChartAtIndex:i forProfile:[dataArray objectAtIndex:i]];
        }
    }
    
    
    NSLog(@"AprilTestTabBar: receiveAllProfilesFromMomma: Processed all profiles from Momma");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"profileUpdate" object:self userInfo:nil];
    NSLog(@"AprilTestTabBar: receiveAllProfilesFromMomma: Sent notification for all profiles from Momma to listening channels");
}

- (void) addPieChartAtIndex:(int)index forProfile:(NSArray *)profile {
    // write code for adding pie charts
}

- (void) updatePieChartAtIndex:(int)index {
    
    
    // make a notification to social view that a pie chart was reloaded
}

// profile data setup by indexes of mutablearray
// 0 : type of data being sent (profileToBaby)
// 1 : device name
// 2 : username (defaults to devices name if no username selected)
// 3 - 10 : concerns in order of most important to least important

- (void) receiveProfileFromMomma:(NSArray *)dataArray {
    NSLog(@"AprilTestTabBar: receiveProfileFromMomma: Received single profile from Momma");
    
    // if profile belongs to us, don't do anything
    if ([[dataArray objectAtIndex:1] isEqualToString:[[UIDevice currentDevice]name]])
        return;
    
    
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
        }
    }
    
    // otherwise, the profile is new and should be added to the mutableArray 'profiles'
    // a pie chart should also be loaded for the profile
    if (!oldProfile) {
        [_profiles addObject:dataArray];
        [self addPieChartAtIndex:(int)[_pieCharts count] forProfile:dataArray];
    }
    
    
    NSLog(@"AprilTestTabBar: receiveProfileFromMomma: Processed single profile from Momma");

    if (oldProfile) {
        NSNumber *numIndex = [NSNumber numberWithInt:index];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:numIndex forKey:@"data"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSingleProfile" object:self   userInfo:dict];
        [self updatePieChartAtIndex:index];
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
    
    _trialNum++;
    
    
    NSLog(@"AprilTestTabBar: receiveSingleTrial: Processed single trial");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePicker" object:self];
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
        
        _trialNum++;
    }
    
    NSLog(@"AprilTestTabBar: receiveMultipleTrials: Processed multiple trials");
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePicker" object:self];
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




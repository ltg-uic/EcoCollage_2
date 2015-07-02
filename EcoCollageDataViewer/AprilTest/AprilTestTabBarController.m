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

static NSTimeInterval const kConnectionTimeout = 15.0;



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

    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    
    
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
    
}

#pragma mark - Memory management

- (void)dealloc
{
    // Unregister for notifications on deallocation.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Nil out delegate
    _session.delegate = nil;
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
            [self teardownSession];
            [self setupSession];
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
    [self teardownSession];
    [self setupSession];
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: error: %@", error);
    
    [session disconnectPeerFromAllPeers:session.peerID];
    [self teardownSession];
    [self setupSession];
}




- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context {
    // convert NSData to NSDictionary
    NSDictionary *dataDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
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
    
    for (int i = 0; i < _profiles.count; i++) {
        // if device names match, change username
        if([_profiles[i][1] isEqualToString:dataArray[1]]) {
            _profiles[i][2] = dataArray[2];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"profileUpdate" object:nil userInfo:nil];
}


- (void) receiveAllProfilesFromMomma:(NSArray *)dataArray {
    // empty current profiles mutableArray if there is anything in there
    if (_profiles.count != 0)
        [_profiles removeAllObjects];
    
    [_profiles addObject:_ownProfile];
    
    // add all profiles sent from momma to local profile list in baby
    for (int i = 1; i < dataArray.count; i++) {
        // only add the profile if it is not our own
        if (![[[dataArray objectAtIndex:i]objectAtIndex:1] isEqualToString:[[UIDevice currentDevice]name] ])
            [_profiles addObject:[dataArray objectAtIndex:i]];
    }
    
    NSLog(@"Received all profiles from Momma");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"profileUpdate" object:self userInfo:nil];
}


// profile data setup by indexes of mutablearray
// 0 : type of data being sent (profileToBaby)
// 1 : device name
// 2 : username (defaults to devices name if no username selected)
// 3 - 10 : concerns in order of most important to least important

- (void) receiveProfileFromMomma:(NSArray *)dataArray {
    // if profile belongs to us, don't do anything
    if ([[dataArray objectAtIndex:1] isEqualToString:[[UIDevice currentDevice]name]])
        return;
    
    
    BOOL oldProfile = 0;
    
    
    // check if profile sent from baby is an update on an already existing one,
    // and if so update it and send update to babies
    for (int i = 0; i < _profiles.count; i++) {
        if([_profiles[i][1] isEqualToString:dataArray[1]]) {
            _profiles[i] = dataArray;
            oldProfile = 1;
        }
    }
    
    // otherwise, the profile is new and should be added to the mutableArray 'profiles'
    if (!oldProfile) {
        [_profiles addObject:dataArray];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"profileUpdate" object:self userInfo:nil];
}


- (void) receiveSingleTrial:(NSArray *)dataArray {
    NSLog(@"Received single trial");
    
    AprilTestSimRun *simRun = [[AprilTestSimRun alloc] init:[dataArray objectAtIndex:1] withTrialNum:_trialNum];
    AprilTestNormalizedVariable *simRunNormal = [[AprilTestNormalizedVariable alloc] init: [dataArray objectAtIndex:2] withTrialNum:_trialNum];
    AprilTestNormalizedVariable *simRunDyn    = [[AprilTestNormalizedVariable alloc] init: [dataArray objectAtIndex:2] withTrialNum:_trialNum];
    
    [_trialRuns addObject:simRun];
    [_trialRunsNormalized addObject:simRunNormal];
    [_trialRunsDynNorm addObject:simRunDyn];
    
    _trialNum++;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePicker" object:self];
    
    if (_trialNum == 1)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"profileUpdate" object:self userInfo:nil];
}


- (void) receiveMultipleTrials:(NSArray *)dataArray {
    NSLog(@"Received multiple trials");
    
    // empty trials arrays to prepare to receive all from Momma
    [_trialRuns removeAllObjects];
    [_trialRunsNormalized removeAllObjects];
    [_trialRunsDynNorm removeAllObjects];
    
    _trialNum = 0;
    
    for (int i = 1; i < dataArray.count; i += 2) {
        
        AprilTestSimRun *simRun = [[AprilTestSimRun alloc] init:[dataArray objectAtIndex:i] withTrialNum:_trialNum];
        AprilTestNormalizedVariable *simRunNormal = [[AprilTestNormalizedVariable alloc] init: [dataArray objectAtIndex:i+1] withTrialNum:_trialNum];
        AprilTestNormalizedVariable *simRunDyn    = [[AprilTestNormalizedVariable alloc] init: [dataArray objectAtIndex:i+1] withTrialNum:_trialNum];
        
        [_trialRuns addObject:simRun];
        [_trialRunsNormalized addObject:simRunNormal];
        [_trialRunsDynNorm addObject:simRunDyn];
        
        _trialNum++;
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePicker" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"profileUpdate" object:self userInfo:nil];
    
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




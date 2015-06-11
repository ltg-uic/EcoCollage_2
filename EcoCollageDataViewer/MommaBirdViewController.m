//
//  MommaBirdViewController.m
//  AprilTest
//
//  Created by Ryan Fogarty on 5/26/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import "MommaBirdViewController.h"
#import <Foundation/Foundation.h>
//#import <CoreBluetooth/CoreBluetooth.h>

@interface MommaBirdViewController () // Class extension
@property (nonatomic, strong) GKSession *session;
@end

@implementation MommaBirdViewController

@synthesize url = _url;
@synthesize studyNum = _studyNum;
@synthesize textView = _textView;

static NSTimeInterval const kConnectionTimeout = 30.0;
NSMutableArray *profiles;
NSMutableArray *trials;

typedef struct UserProfiles {
    int userNumber;
    int investment;
    int damageReduction;
    int efficiencyOfIntervention;
    int capacityUsed;
    int waterDepth;
    int maxFloodedArea;
    int groundwaterInfiltration;
    int impactOnNeighbors;
    
    struct UserProfiles *next;
} UserProfiles;

#define string char**

typedef struct SimResults {
    int simID;
    int studyID;
    int trialID;
    string map;
    int publicCost;
    int privateCost;
    int publicDamages;
    int privateDamages;
    int publicMaintenanceCost;
    int privateMaintenanceCost;
    string standingWater;
    float impactNeighbors;
    float neightborsImpactMe;
    float infiltration;
    string efficiency;
    string maxWaterHeights;
    string dollarsPerGallon;
    
    struct SimResults *next;
} SimResults;

typedef struct SimNormalizedResults {
    int simID;
    int studyID;
    int trialID;
    float publicCost;
    float privateCost;
    float publicDamages;
    float privateDamages;
    float publicMaintenanceCost;
    float privateMaintenanceCost;
    float standingWater;
    float impactNeighbors;
    float neighborsImpactMe;
    float infiltration;
    float efficiency;
    float MaxWaterHeight;
    float floodedStreets;
    
    struct SimNormalizedResults *next;
} SimNormalizedResults;



#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    profiles = [[NSMutableArray alloc]init];
    trials = [[NSMutableArray alloc]init];
}



- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
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
    _session = [[GKSession alloc] initWithSessionID:@"GKForEcoCollage" displayName:@"Momma" sessionMode:GKSessionModeServer];
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

            NSLog(@"Not inviting %@", peerID);
            
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
            [self sendAllProfilesToNewBaby:peerID];
            break;
        }
            
        case GKPeerStateDisconnected:
        {
            NSLog(@"didChangeState: peer %@ disconnected", peerName);
            break;
        }
            
        case GKPeerStateConnecting:
        {
            NSLog(@"didChangeState: peer %@ connecting", peerName);
            break;
        }
    }
}


- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    NSLog(@"didReceiveConnectionRequestFromPeer: %@", [session displayNameForPeer:peerID]);
    
    NSError *error;
    
    BOOL connectionEstablished = FALSE;
    NSString *peerName = [session displayNameForPeer:peerID];
    
    if([peerName isEqualToString:@"Baby"])
        connectionEstablished = [session acceptConnectionFromPeer:peerID error:&error];
    
    if (!connectionEstablished)
    {
        NSLog(@"error = %@", error);
    }
}


- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    NSLog(@"connectionWithPeerFailed: peer: %@, error: %@", [session displayNameForPeer:peerID], error);
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: error: %@", error);
    
    [session disconnectPeerFromAllPeers:session.peerID];
}




- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context { //---
    // convert NSData to NSDictionary
    NSDictionary *dataDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    // convert NSDictionary to NSArray
    NSArray *dataArray = [dataDictionary objectForKey:@"data"];
    
    if([dataArray[0] isEqualToString:@"profileToMomma"]) {
        [self handleProfileUpdates:dataArray];
    }
    else if([dataArray[0] isEqualToString:@"usernameUpdate"]) {
        [self handleUsernameUpdates:dataArray];
    }
}


- (void)handleUsernameUpdates:(NSArray *)dataArray {
    // check if profile sent from baby is an update on an already existing one and if so update it
    for (int i = 0; i < profiles.count; i++) {
        // if device names match, change username
        if([profiles[i][1] isEqualToString:dataArray[1]]) {
            profiles[i][2] = dataArray[2];
        }
    }
    
    
    
    NSMutableArray *usernameForBaby = [[NSMutableArray alloc]init];
    [usernameForBaby addObject:@"usernameToBaby"];
    [usernameForBaby addObject:[dataArray objectAtIndex:1]];
    [usernameForBaby addObject:[dataArray objectAtIndex:2]];
    
    NSDictionary *usernameToSendToBaby = [NSDictionary dictionaryWithObject:usernameForBaby
                                                                     forKey:@"data"];
    // crashes were occuring on baby bird side, so make sure before archiving that dictionary is not nil
    if(usernameToSendToBaby != nil) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:usernameToSendToBaby];
        [_session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
    }
    
    [self updateTextView];
}




/* how data is setup in "profiles"
    profiles is a mutableArray of NSArray's, each array containing the data for a baby's profile
    to send this data, the first index of the array sent must be "allProfilesToNewBaby"
    after that, the profiles can be stored in their NSArray's and set over
*/
// when a new baby is connected, that baby receives all the user profiles to get it up to date
- (void) sendAllProfilesToNewBaby:(NSString *)peerID {
    if (profiles == nil) {
        return;
    }
    NSMutableArray *profilesForNewBaby = [[NSMutableArray alloc]init];
    [profilesForNewBaby addObject:@"allProfilesToNewBaby"];
    
    for (NSArray *individualProfile in profiles) {
        [profilesForNewBaby addObject:individualProfile];
    }
    
    NSDictionary *profilesToSendToBaby = [NSDictionary dictionaryWithObject:profilesForNewBaby
                                                                    forKey:@"data"];
    // crashes were occuring on baby bird side, so make sure before archiving that dictionary is not nil
    if(profilesToSendToBaby != nil) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:profilesToSendToBaby];
        [_session sendData:data toPeers:@[peerID] withDataMode:GKSendDataReliable error:nil];
    }
    
}


// profile data setup by indexes of mutablearray
// 0 : type of data being sent (profileToMomma)
// 1 : device name
// 2 : username (defaults to devices name if no username selected)
// 3 - 10 : concerns in order of most important to least important

- (void) handleProfileUpdates:(NSArray *)dataArray {
    BOOL oldProfile = 0;
    
    // check if profile sent from baby is an update on an already existing one and if so update it
    for (int i = 0; i < profiles.count; i++) {
        if([profiles[i][1] isEqualToString:dataArray[1]]) {
            profiles[i] = dataArray;
            oldProfile = 1;
        }
    }
    // otherwise, the profile is new and should be added to the mutableArray 'profiles'
    if (!oldProfile) {
        [profiles addObject:dataArray];
    }
    
    
    [self sendProfileUpdateToBabies:dataArray];
    
    [self updateTextView];
}



- (void) updateTextView {
    NSMutableString* allProfiles = [[NSMutableString alloc]initWithString:@""];
    
    
    // loop through all the user profiles stored in mutableArray 'profiles'
    for (NSArray *profile in profiles) {
        NSMutableArray *tempProfile = [[NSMutableArray alloc]init];
        for (int i = 1; i < profile.count; i++) {
            [tempProfile addObject:[profile objectAtIndex:i]];
        }
        NSString *profileString = [tempProfile componentsJoinedByString:@"\n"];
        
        [allProfiles appendString:profileString];
        [allProfiles appendString:@"\n\n"];
    }

    _textView.text = allProfiles;
}


// profile data setup by indexes of mutablearray
// 0 : type of data being sent (profileToBaby)
// 1 : username (defaults to devices name if no username selected)
// 2 - 9 : concerns in order of most important to least important
- (void) sendProfileUpdateToBabies:(NSArray *)dataArray {
    // convert to mutableArray so that the type of data being sent can be changed
    NSMutableArray *dataMutableArray = [dataArray mutableCopy];
    [dataMutableArray replaceObjectAtIndex:0 withObject:@"profileToBaby"];
     
     
    NSDictionary *profileToSendToBaby = [NSDictionary dictionaryWithObject:dataMutableArray
                                                                     forKey:@"data"];
    // crashes were occuring on baby bird side, so make sure before archiving that dictionary is not nil
    if(profileToSendToBaby != nil) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:profileToSendToBaby];
        [_session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
    }
}



@end
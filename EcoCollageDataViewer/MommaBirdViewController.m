//
//  MommaBirdViewController.m
//  AprilTest
//
//  Created by Ryan Fogarty on 5/26/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import "MommaBirdViewController.h"
#import "AprilTestSimRun.h"
#import "AprilTestNormalizedVariable.h"
#import <Foundation/Foundation.h>

@interface MommaBirdViewController () // Class extension
@property (nonatomic, strong) GKSession *session;
@property (strong, nonatomic) CBCentralManager      *myCentralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData         *data;
@end

@implementation MommaBirdViewController

@synthesize url = _url;
@synthesize studyNum = _studyNum;
@synthesize textView = _textView;
@synthesize macMiniTextView = _macMiniTextView;
@synthesize myCentralManager = _myCentralManager;
@synthesize discoveredPeripheral = _discoveredPeripheral;
@synthesize BudgetSlider = _BudgetSlider;

static NSTimeInterval const kConnectionTimeout = 30.0;
NSMutableArray *profiles;
NSMutableArray * trialRuns;             // array of strings, not yet analyzed as trial data, to be passed to babies
NSMutableArray * trialRunsNormalized;   // same as above, but this contains normalized raw data
NSMutableArray *dataFromMacMini;
UILabel *budgetLabel;
int trialNum;
int maxBudget = 5000000;
int currentBudget;
NSMutableArray *favorites;
NSData *ping;


#define SEPARATOR_FOR_TRIAL_DATA        @"$(TRIAL_DATA)$"


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    
    trialNum = 0;
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    
    
    // Register for notifications
    [defaultCenter addObserver:self
                      selector:@selector(setupGKSession)
                          name:UIApplicationWillEnterForegroundNotification
                        object:nil];
    
    
    [defaultCenter addObserver:self
                      selector:@selector(teardownGKSession)
                          name:UIApplicationDidEnterBackgroundNotification
                        object:nil];
    
    [self setupGKSession];
    
    profiles = [[NSMutableArray alloc]init];
    dataFromMacMini = [[NSMutableArray alloc]init];
    trialRuns = [[NSMutableArray alloc]init];
    trialRunsNormalized = [[NSMutableArray alloc]init];
    favorites = [[NSMutableArray alloc]init];
    
    self.studyNumberLabel.text = [NSString stringWithFormat:@"Study Number %d", _studyNum];
    self.trialNumberLabel.text = [NSString stringWithFormat:@"Trial Number %d", trialNum];
    
    // setup core bluetooth connection to mac mini
    self.data = [[NSMutableData alloc]init];
    //self.myCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    
    _BudgetSlider.minimumValue = 0;
    _BudgetSlider.maximumValue = maxBudget;
    _BudgetSlider.continuous = YES;
    currentBudget = 150000;
    
    [_BudgetSlider addTarget:self action:@selector(budgetChanged) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    budgetLabel = [[UILabel alloc]init];
    [self drawBudgetLabels];
    
    NSDictionary *pingDict = [NSDictionary dictionaryWithObject:@"ping" forKey:@"ping"];
    ping = [NSKeyedArchiver archivedDataWithRootObject:pingDict];
    
    
    [NSTimer scheduledTimerWithTimeInterval:20.0f
                                     target:self selector:@selector(pingPeers) userInfo:nil repeats:YES];

}

- (void)pingPeers {
    if ([[_session peersWithConnectionState:GKPeerStateConnected] count] > 0) {
        [_session sendDataToAllPeers:ping withDataMode:GKSendDataReliable error:nil];
    }
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

- (void)setupGKSession
{
    // GKSessionModePeer: a peer advertises like a server and searches like a client.
    _session = [[GKSession alloc] initWithSessionID:@"GKForEcoCollage" displayName:[NSString stringWithFormat:@"Momma%d", _studyNum] sessionMode:GKSessionModeServer];
    self.session.delegate = self;
    self.session.available = YES;
    [_session setDataReceiveHandler:self withContext:nil];
    
}

- (void)teardownGkSession
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
            
            NSLog(@"Not inviting");
            
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
            
            [self sendBudgetToSpecificBaby:peerID];
            // when a baby is connected, send it all of the profiles loaded
            if ([profiles count] != 0) {
                [self sendAllProfilesToNewBaby:peerID];
            }
            
            // when a baby is connected, send it all of the trials loaded
            if ([trialRuns count] != 0 && [trialRunsNormalized count] != 0) {
                [self sendTrialRequestToBaby:peerID];
            }
            break;
        }
            
        case GKPeerStateDisconnected:
        {
            NSLog(@"didChangeState: peer %@ disconnected", peerName);
            session.available = YES;
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
    
    if([peerName isEqualToString:[NSString stringWithFormat:@"Baby%d", _studyNum]])
        connectionEstablished = [session acceptConnectionFromPeer:peerID error:&error];
    else {
        [session denyConnectionFromPeer:peerID];
        NSLog(@"Denied connection");
    }
    
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
    else if([dataArray[0] isEqualToString:@"removeProfile"]) {
        [self removeProfile:dataArray];
    }
    else if([dataArray[0] isEqualToString:@"requestForTrial"]) {
        [self sendTrialsForRequest:dataArray toPeer:(NSString *)peer];
    }
    else if([dataArray[0] isEqualToString:@"favoriteForMomma"]) {
        [self updateFavoriteTrials:dataArray];
    }
}


- (void)updateFavoriteTrials:(NSArray *)dataArray {
    BOOL profileHasAFavorite = NO;
    
    for (NSArray *favorite in favorites) {
        if ([[dataArray objectAtIndex:1] isEqualToString:[favorite objectAtIndex:1]]) {
            profileHasAFavorite = YES;
        }
    }
    
    for (int i = 0; i < favorites.count; i++) {
        NSArray *favorite = [favorites objectAtIndex:i];
        if ([[dataArray objectAtIndex:1] isEqualToString:[favorite objectAtIndex:1]]) {
            profileHasAFavorite = YES;
            [favorites replaceObjectAtIndex:i withObject:dataArray];
        }
    }
    
    if(!profileHasAFavorite)
        [favorites addObject:dataArray];
    
    if (_session) {
        // send update to all baby birds
        NSMutableArray* favoriteUpdateForBabies = [[NSMutableArray alloc]init];
        [favoriteUpdateForBabies addObject:@"favoriteForBabies"];
        [favoriteUpdateForBabies addObject:[dataArray objectAtIndex:1]];
        [favoriteUpdateForBabies addObject:[dataArray objectAtIndex:2]];
    
        NSDictionary *favoriteToSendToBabies = [NSDictionary dictionaryWithObject:favoriteUpdateForBabies
                                                                      forKey:@"data"];
    
        if(favoriteToSendToBabies != nil) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:favoriteToSendToBabies];
            [_session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
        }
    }
}

- (void)removeProfile:(NSArray *)dataArray {
    // check if profile sent from baby is an update on an already existing one and if so update it
    for (int i = 0; i < profiles.count; i++) {
        // if device names match, change username
        if([profiles[i][1] isEqualToString:dataArray[1]]) {
            [profiles removeObjectAtIndex:i];
        }
    }
    
    [self updateTextView];
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
    
    NSDictionary *usernameToSendToBaby = [NSDictionary dictionaryWithObject:usernameForBaby forKey:@"data"];
    // crashes were occuring on baby bird side, so make sure before archiving that dictionary is not nil
    if(usernameToSendToBaby != nil) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:usernameToSendToBaby];
        [_session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
    }
    
    [self updateTextView];
}


- (void)sendTrialsForRequest:(NSArray *)dataArray toPeer:(NSString*)peerID{
    NSLog(@"Received request from Baby for trials %d - %d", [[dataArray objectAtIndex:1] integerValue], trialNum);
    
    if ([[dataArray objectAtIndex:1] integerValue] == 0) {
        [self sendAllTrialsToSpecificBaby:peerID];
        return;
    }
    
    for (int i = [[dataArray objectAtIndex:1]integerValue]; i < trialNum; i++) {
        NSLog(@"Sent baby trial %d", i);
        [self sendSingleTrialToSpecificBaby:[trialRuns objectAtIndex:i] normalizedData:[trialRunsNormalized objectAtIndex:i] peerID:peerID];
    }
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
    BOOL didChange = 0;
    
    // check if profile sent from baby is an update on an already existing one and if so update it
    for (int i = 0; i < profiles.count; i++) {
        if([profiles[i][1] isEqualToString:dataArray[1]]) {
            if (![profiles[i] isEqual:dataArray ]) didChange = 1;
            profiles[i] = dataArray;
            oldProfile = 1;
        }
    }
    // otherwise, the profile is new and should be added to the mutableArray 'profiles'
    if (!oldProfile) {
        [profiles addObject:dataArray];
        didChange = 1;
    }
    
    
    if (didChange) {
        [self sendProfileUpdateToBabies:dataArray];
        [self updateTextView];
    }
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
// 0 : type of data being sent (profileToMomma)
// 1 : device name
// 2 : username (defaults to devices name if no username selected)
// 3 - 10 : concerns in order of most important to least important

- (void) sendProfileUpdateToBabies:(NSArray *)dataArray {
    // convert to mutableArray so that the type of data being sent can be changed
    NSMutableArray *dataMutableArray = [dataArray mutableCopy];
    [dataMutableArray replaceObjectAtIndex:0 withObject:@"profileToBaby"];
     
     
    NSDictionary *profileToSendToBaby = [NSDictionary dictionaryWithObject:dataMutableArray forKey:@"data"];
    // crashes were occuring on baby bird side, so make sure before archiving that dictionary is not nil
    if(profileToSendToBaby != nil) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:profileToSendToBaby];
        [_session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
    }
}


- (void)sendTrialRequestToBaby:(NSString *)peerID {
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    
    // add the type of data that is being sent
    [dataArray addObject:@"trialRequestToBaby"];
    
    [dataArray addObject:[NSNumber numberWithInt:trialNum]];
    
    NSDictionary *trialRequestToSendToBaby = [NSDictionary dictionaryWithObject:dataArray forKey:@"data"];
    
    // crashes were occuring on baby bird side, so make sure before archiving that dictionary is not nil
    if(trialRequestToSendToBaby != nil) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:trialRequestToSendToBaby];
        [_session sendData:data toPeers:@[peerID] withDataMode:GKSendDataReliable error:nil];
        NSLog(@"Sent Trial Request to Baby");
    }
}


- (void) sendSingleTrialToBabies:(NSString *)trialContent normalizedData:(NSString *) trialContentN {
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    
    // add the type of data that is being sent
    [dataArray addObject:@"singleTrialData"];
    
    // add trial content
    [dataArray addObject:trialContent];
    
    // add normalized trial content
    [dataArray addObject:trialContentN];
    
    NSDictionary *trialToSendToBaby = [NSDictionary dictionaryWithObject:dataArray forKey:@"data"];
    
    // crashes were occuring on baby bird side, so make sure before archiving that dictionary is not nil
    if(trialToSendToBaby != nil) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:trialToSendToBaby];
        [_session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
        NSLog(@"Sent single trial to all babies");
    }
}


- (void) sendSingleTrialToSpecificBaby:(NSString *)trialContent normalizedData:(NSString *) trialContentN peerID:(NSString *)peerID {
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    
    // add the type of data that is being sent
    [dataArray addObject:@"singleTrialData"];
    
    // add trial content
    [dataArray addObject:trialContent];
    
    // add normalized trial content
    [dataArray addObject:trialContentN];
    
    NSDictionary *trialToSendToBaby = [NSDictionary dictionaryWithObject:dataArray forKey:@"data"];
    
    // crashes were occuring on baby bird side, so make sure before archiving that dictionary is not nil
    if(trialToSendToBaby != nil) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:trialToSendToBaby];
        [_session sendData:data toPeers:@[peerID] withDataMode:GKSendDataReliable error:nil];\
        NSLog(@"Sent single trial to %@", peerID);
    }
}


- (void) sendAllTrialsToSpecificBaby:(NSString *)peerID {
    // if there is only one trial loaded, send it by itself
    if ([trialRuns count] == 1 && [trialRunsNormalized count] == 1) {
        [self sendSingleTrialToSpecificBaby:[trialRuns objectAtIndex:0] normalizedData:[trialRunsNormalized objectAtIndex:0] peerID:peerID];
        return;
    }
    
    // if there are unequal numbers of trials loaded in these two arrays, there will be issues down the line, so bail out if that is the case
    if ([trialRuns count] != [trialRunsNormalized count])
        return;
    
    // if more than one trial loaded, must add them together
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    
    // add the type of data that is being sent
    [dataArray addObject:@"multipleTrialsData"];
    
    for (int i = 0; i < trialRuns.count; i++) {
        // add trial content
        [dataArray addObject:[trialRuns objectAtIndex:i]];
        
        // add normalized content
        [dataArray addObject:[trialRunsNormalized objectAtIndex:i]];
    }
    
    NSDictionary *trialsToSendToBaby = [NSDictionary dictionaryWithObject:dataArray forKey:@"data"];
    
    
    // crashes were occuring on baby bird side, so make sure before archiving that dictionary is not nil
    if(trialsToSendToBaby != nil) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:trialsToSendToBaby];
        [_session sendData:data toPeers:@[peerID] withDataMode:GKSendDataReliable error:nil];
        NSLog(@"Sent all trials to %@", peerID);
    }
}




# pragma mark CoreBluetooth Methods


- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // Determine the state of the peripheral
    if ([central state] == CBCentralManagerStatePoweredOff) {
        NSLog(@"CoreBluetooth BLE hardware is powered off");
    }
    else if ([central state] == CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
        NSLog(@"Scanning for advertising peripheral devices..");
        //Will scan for peripheral devices that are advertising
        [_myCentralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"4732CA16-1009-4E0A-AC8E-9E8CC2A68A24"]] options:nil];
    }
    else if ([central state] == CBCentralManagerStateUnauthorized) {
        NSLog(@"CoreBluetooth BLE state is unauthorized");
    }
    else if ([central state] == CBCentralManagerStateUnknown) {
        NSLog(@"CoreBluetooth BLE state is unknown");
    }
    else if ([central state] == CBCentralManagerStateUnsupported) {
        NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
    }
}

-(void)centralManager:(CBCentralManager *)central
didDiscoverPeripheral:(CBPeripheral *)peripheral
    advertisementData:(NSDictionary *)advertisementData
                 RSSI:(NSNumber *)RSSI
{
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    [_myCentralManager stopScan];
    NSLog(@"Scanning Stopped, Mac Mini was found!");
    
    if (self.discoveredPeripheral != peripheral) {
        
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        self.discoveredPeripheral = peripheral;
        
        // And connect
        NSLog(@"Connecting to peripheral %@", peripheral);
        
        
        [self.myCentralManager connectPeripheral:peripheral options:nil];
    }
    
}



// If the connection fails for whatever reason, we need to deal with it.
 
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
}

// We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:@[[CBUUID UUIDWithString:@"4732CA16-1009-4E0A-AC8E-9E8CC2A68A24"]]];
}


// The Service was discovered
 
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        return;
    }
    
    // Discover the characteristic we want...
    NSLog(@"Discovered some service");
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"E4AE0854-E6F7-46BD-99DE-51A9B9049E8B"]] forService:service];
    }
}

//The characteristic was discovered.
 // Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"Discovering characteristics");
    
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        // And check if it's the right one
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"E4AE0854-E6F7-46BD-99DE-51A9B9049E8B"]])
        {
            NSLog(@"Found a desired Characteristic!");
            // subscribe to characteristic
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    // Once this is complete, we just need to wait for the data to come in.
}



# pragma mark CoreBluetooth Update Notification Methods

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    
    if (error) {
        NSLog(@"Error changing notification state: %@",
              [error localizedDescription]);
    }
    else {
        NSLog(@"Updated notification state for characteristic %@", characteristic);
    }
    
}


// this method is called whenever a subscribed characteristic updates on the peripheral side
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    // Have we got everything we need?
    if ([stringFromData isEqualToString:@"EOM"]) {
        // We have, so show the data,
        NSString *stringForMacMiniTextView = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        
        [dataFromMacMini addObject:stringForMacMiniTextView];

        [self updateMacMiniTextView];
        
        // reset data for next transfer
        [self.data setLength:0];
        
        return;
    }
    
    // Otherwise, just add the data on to what we already have
    [self.data appendData:characteristic.value];
    
    // Log it
    NSLog(@"Received: %@", stringFromData);
}


- (void) updateMacMiniTextView {
    NSMutableString *stringForMacMiniTextView = [[NSMutableString alloc]initWithString:@""];
    
    for (int i = 0; i < dataFromMacMini.count; i++) {
        NSArray *array = [[dataFromMacMini objectAtIndex:i] componentsSeparatedByString:SEPARATOR_FOR_TRIAL_DATA];
        
        [stringForMacMiniTextView appendString:[[NSString alloc]initWithFormat:@"Trial %d\n", i]];
        [stringForMacMiniTextView appendString:[array componentsJoinedByString:@"\n"]];
        [stringForMacMiniTextView appendString:@"\n\n"];
    }
    
    _macMiniTextView.text = stringForMacMiniTextView;
}

- (IBAction)loadNextTrial:(UIButton *)sender {

    //pull content from the server that is said to be from le trial with real vals
    NSString * urlPlusFile = [NSString stringWithFormat:@"%@/%@", _url, @"simOutput.php"];
    NSString *myRequestString = [[NSString alloc] initWithFormat:@"trialID=%d&studyID=%d", trialNum, _studyNum ];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString: urlPlusFile ] ];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    
    NSString *content;
    while( !content){
        NSURLResponse *response;
        NSError *err;
        NSData *returnData = [ NSURLConnection sendSynchronousRequest: request returningResponse:&response error:&err];
        //NSLog(@"error: %@", err);
        
        if( [returnData bytes]) content = [NSString stringWithUTF8String:[returnData bytes]];
        //NSLog(@"responseData: %@", content);
    }
    
    //pull content from the server that is said to be from le trial that is said to be normalized vals (ranging from 0 to 1)
    NSString *urlPlusFileN = [NSString stringWithFormat:@"%@/%@", _url, @"simOutputN.php"];
    NSString *myRequestStringN = [[NSString alloc] initWithFormat:@"trialID=%d&studyID=%d", trialNum, _studyNum ];
    NSData *myRequestDataN = [ NSData dataWithBytes: [ myRequestStringN UTF8String ] length: [ myRequestStringN length ] ];
    NSMutableURLRequest *requestN = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString: urlPlusFileN ] ];
    [ requestN setHTTPMethod: @"POST" ];
    [ requestN setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ requestN setHTTPBody: myRequestDataN ];
    
    NSString *contentN;
    while( !contentN){
        NSURLResponse *responseN;
        NSError *err;
        NSData *returnDataN = [ NSURLConnection sendSynchronousRequest: requestN returningResponse:&responseN error:&err];
        //NSLog(@"error: %@", err);
        
        if( [returnDataN bytes]) contentN = [NSString stringWithUTF8String:[returnDataN bytes]];
        //NSLog(@"responseData: %@", contentN);
    }
    
    if(content != NULL && content.length > 100 && contentN != NULL){
        [self sendSingleTrialToBabies:content normalizedData:contentN];
        
        // store the trials so they can be sent to a new Baby if it joins late
        [trialRuns addObject: content];                  //contains trials containing real values
        [trialRunsNormalized addObject:contentN];   //contains trials containing normalized values
        
        NSLog(@"Number of trials loaded %lu", (unsigned long)trialRuns.count);
        
        trialNum++;
        self.trialNumberLabel.text = [NSString stringWithFormat:@"Trial Number %d", trialNum];
    }
}


- (IBAction)BudgetSlider:(UISlider *)sender {
    UISlider *slider = (UISlider*)sender;
    int value = slider.value;
    //-- Do further actions
    
    value = 1000.0 * floor((value/1000.0)+0.5);
    
    currentBudget = value;
    
    [self changeBudgetLabel:(int)currentBudget];
}

- (void)drawBudgetLabels {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:@","];
    
    // draw current budget label
    budgetLabel.text = [NSString stringWithFormat:@"Budget: $%@", [formatter stringFromNumber:[NSNumber numberWithInt:currentBudget]]];
    [budgetLabel sizeToFit];
    budgetLabel.frame = CGRectMake(_BudgetSlider.frame.origin.x + (_BudgetSlider.frame.size.width - budgetLabel.frame.size.width) / 2, _BudgetSlider.frame.origin.y - budgetLabel.frame.size.height - 10, budgetLabel.frame.size.width, budgetLabel.frame.size.height);
    [self.view addSubview:budgetLabel];
    
    // draw min budget label
    UILabel *minBudgetLabel = [[UILabel alloc]init];
    minBudgetLabel.text = @"Minimum budget: $0";
    [minBudgetLabel sizeToFit];
    minBudgetLabel.frame = CGRectMake(_BudgetSlider.frame.origin.x - minBudgetLabel.frame.size.width - 10, _BudgetSlider.frame.origin.y, minBudgetLabel.frame.size.width, _BudgetSlider.frame.size.height);
    [self.view addSubview:minBudgetLabel];
    
    // draw max budget label
    UILabel *maxBudgetLabel = [[UILabel alloc]init];
    maxBudgetLabel.text = [NSString stringWithFormat:@"Maximum budget: $%@", [formatter stringFromNumber:[NSNumber numberWithInt:maxBudget]]];
    [maxBudgetLabel sizeToFit];
    maxBudgetLabel.frame = CGRectMake(_BudgetSlider.frame.origin.x + _BudgetSlider.frame.size.width + 10, _BudgetSlider.frame.origin.y, maxBudgetLabel.frame.size.width, _BudgetSlider.frame.size.height);
    [self.view addSubview:maxBudgetLabel];
    
    _BudgetSlider.value = currentBudget;
}

- (void)changeBudgetLabel:(int)budget {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:@","];
    
    budgetLabel.text = [NSString stringWithFormat:@"Set Budget $%@", [formatter stringFromNumber:[NSNumber numberWithInt:budget]]];
    [budgetLabel sizeToFit];
}

- (void)budgetChanged {
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    
    // add the type of data that is being sent
    [dataArray addObject:@"budgetChange"];
    
    // add trial content
    [dataArray addObject:[NSNumber numberWithInteger:currentBudget]];
    
    
    NSDictionary *budgetToSendToBaby = [NSDictionary dictionaryWithObject:dataArray forKey:@"data"];
    
    // crashes were occuring on baby bird side, so make sure before archiving that dictionary is not nil
    if(budgetToSendToBaby != nil) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:budgetToSendToBaby];
        [_session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
    }
}

- (void)sendBudgetToSpecificBaby:(NSString *)peerID {
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    
    // add the type of data that is being sent
    [dataArray addObject:@"budgetChange"];
    
    // add trial content
    [dataArray addObject:[NSNumber numberWithInteger:currentBudget]];
    
    
    NSDictionary *budgetToSendToBaby = [NSDictionary dictionaryWithObject:dataArray forKey:@"data"];
    
    // crashes were occuring on baby bird side, so make sure before archiving that dictionary is not nil
    if(budgetToSendToBaby != nil) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:budgetToSendToBaby];
        [_session sendData:data toPeers:@[peerID] withDataMode:GKSendDataReliable error:nil];
    }
}

@end
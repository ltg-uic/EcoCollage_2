//
//  MommaBirdViewController.m
//  AprilTest
//
//  Created by Ryan Fogarty on 5/26/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import "MommaBirdViewController.h"
#import <Foundation/Foundation.h>

@interface MommaBirdViewController () // Class extension
@property (nonatomic, strong) GKSession *session;
@property (strong, nonatomic) CBCentralManager      *myCentralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@end

@implementation MommaBirdViewController

@synthesize url = _url;
@synthesize studyNum = _studyNum;
@synthesize textView = _textView;
@synthesize myCentralManager = _myCentralManager;
@synthesize discoveredPeripheral = _discoveredPeripheral;

static NSTimeInterval const kConnectionTimeout = 15.0;
NSMutableArray *profiles;
NSMutableArray *trials;
int studyNumber;

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
                      selector:@selector(setupGKSession)
                          name:UIApplicationWillEnterForegroundNotification
                        object:nil];
    
    
    [defaultCenter addObserver:self
                      selector:@selector(teardownGKSession)
                          name:UIApplicationDidEnterBackgroundNotification
                        object:nil];
    
    [self setupGKSession];
    
    profiles = [[NSMutableArray alloc]init];
    trials = [[NSMutableArray alloc]init];
    
    self.studyNumberLabel.text = [NSString stringWithFormat:@"%d", _studyNum];
    
    // setup core bluetooth connection to mac mini
    self.myCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
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
    _session = [[GKSession alloc] initWithSessionID:@"GKForEcoCollage" displayName:@"Momma" sessionMode:GKSessionModeServer];
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
// 0 : type of data being sent (profileToMomma)
// 1 : device name
// 2 : username (defaults to devices name if no username selected)
// 3 - 10 : concerns in order of most important to least important

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



/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
}

/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:@[[CBUUID UUIDWithString:@"4732CA16-1009-4E0A-AC8E-9E8CC2A68A24"]]];
}


/** The Service was discovered
 */
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

/** The characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
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
    
    NSData *data = characteristic.value;
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    NSLog(@"Received data: %@", dataString);
}


@end
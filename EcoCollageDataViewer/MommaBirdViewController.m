//
//  MommaBirdViewController.m
//  AprilTest
//
//  Created by Ryan Fogarty on 5/26/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import "MommaBirdViewController.h"
//#import <CoreBluetooth/CoreBluetooth.h>

@interface MommaBirdViewController () // Class extension
@property (nonatomic, strong) GKSession *session;
@end

@implementation MommaBirdViewController

@synthesize url = _url;
@synthesize studyNum = _studyNum;
@synthesize textView = _textView;
@synthesize textField = _textField;


static NSTimeInterval const kConnectionTimeout = 30.0;


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
            
            /* Momma never invites, only accepts invites from babies
            
            BOOL shouldInvite = ([self.session.displayName compare:peerName] == NSOrderedDescending);
            
            if (shouldInvite)
            {
                NSLog(@"Inviting %@", peerID);
                [session connectToPeer:peerID withTimeout:kConnectionTimeout];
            }
             
            */
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
            NSData *data;
            NSString *stringToSend = _textView.text;
            data = [stringToSend dataUsingEncoding:NSASCIIStringEncoding];
            [self mySendDataToPeers:data];
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



/*

- (void)applicationWillTerminate:(UIApplication *)app {
    picker.delegate = nil;
    
    // Nil out delegate
    _currentSession.delegate = nil;
    self.currentSession.available = NO;
    
    [self.currentSession disconnectFromAllPeers];
    _currentSession = nil;
}




- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *) session {
    session.available = NO;
    _currentSession = session;
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
    picker.delegate = nil;
    [picker dismiss];
    //[picker autorelease];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
    _currentSession.available = NO;
    picker.delegate = nil;
    //[picker autorelease];
    [connect setHidden:NO];
    [disconnect setHidden:YES];
}



- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    switch (state)
    {
        case GKPeerStateConnected:
            NSLog(@"connected");
            break;
        case GKPeerStateDisconnected:
            NSLog(@"disconnected");
            //[self.currentSession release];
            _currentSession = nil;
            [connect setHidden:NO];
            [disconnect setHidden:YES];
            break;
    }
}
 
 */


- (void) mySendDataToPeers:(NSData *) data {
    [self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];

}
 


- (IBAction)sendText:(UIButton *)sender {
    // close keyboard
    [_textField resignFirstResponder];
    
    if(_session) {
        NSData *data;
        NSString *stringToSend = _textView.text;
        stringToSend = [stringToSend stringByAppendingString:@"\n"];
        stringToSend = [stringToSend stringByAppendingString:_textField.text];
        _textView.text = stringToSend;
        data = [stringToSend dataUsingEncoding:NSASCIIStringEncoding];
        [self mySendDataToPeers:data];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data not sent" message:@"Not connected" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}



- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context { //---convert the NSData to NSString---
    NSString * stringReceived = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSArray *arrayFromString = [stringReceived componentsSeparatedByString:@"|"];
    NSString *stringToDisplay = [arrayFromString componentsJoinedByString:@"\n"];
    
    _textView.text = stringToDisplay;
    //[alert release];
}


/*

- (IBAction)connectToGK:(UIButton *)sender {
    picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    //don't hide connect for Momma since she wants to connect to all babies
    //[connect setHidden:YES];
    [disconnect setHidden:NO];
    [picker show];
}

- (IBAction)disconnectFromGK:(UIButton *)sender {
    picker.delegate = nil;
    
    // Nil out delegate
    _currentSession.delegate = nil;
    self.currentSession.available = NO;
    
    [self.currentSession disconnectFromAllPeers];
    _currentSession = nil;
    [connect setHidden:NO];
    [disconnect setHidden:YES];
}
 
 */

@end

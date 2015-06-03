//
//  MommaBirdViewController.m
//  AprilTest
//
//  Created by Ryan Fogarty on 5/26/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import "MommaBirdViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface MommaBirdViewController ()

@end

@implementation MommaBirdViewController

@synthesize url = _url;
@synthesize studyNum = _studyNum;
@synthesize textView = _textView;
@synthesize textField = _textField;
@synthesize currentSession = _currentSession;
@synthesize connect;
@synthesize disconnect;


GKPeerPickerController *picker;


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
    // Do any additional setup after loading the view.
}



- (void)viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
}


- (void)applicationWillTerminate:(UIApplication *)app {
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
- (void) mySendDataToPeers:(NSData *) data {
    [self.currentSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];

}

- (IBAction)sendText:(UIButton *)sender {
    // close keyboard
    [_textField resignFirstResponder];
    
    if(_currentSession) {
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

@end

//
//  SocialViewController.m
//  AprilTest
//
//  Created by Ryan Fogarty on 6/2/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import "SocialViewController.h"
#import "AprilTestTabBarController.h"

@interface SocialViewController ()

@end

@implementation SocialViewController

@synthesize textField = _textField;
@synthesize textView = _textView;
@synthesize currentSession = _currentSession;
@synthesize studyNum = _studyNum;

- (void)applicationWillTerminate:(UIApplication *)app {
    // Nil out delegate
    _currentSession.delegate = nil;
    self.currentSession.available = NO;
    
    [self.currentSession disconnectFromAllPeers];
    _currentSession = nil;
    
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    tabControl.currentSession = _currentSession;
    
}

- (void)viewDidLoad {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    _studyNum = tabControl.studyNum;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



// called everytime tab is switched to this view
// necessary in case currentSession changes, i.e. is disconnected and reconnected again
- (void)viewDidAppear:(BOOL)animated {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    _currentSession = tabControl.currentSession;
    
    // setDataReceiveHandler whenever user switches to a different view which will process the GameKit session
    [_currentSession setDataReceiveHandler:self withContext:nil];
    

    [super viewDidAppear:animated];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)sendText:(UIButton *)sender {
    // close keyboard
    [_textField resignFirstResponder];
    
    
    // reload everytime data will be sent to check if session was disconnected
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    _currentSession = tabControl.currentSession;
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


- (void) mySendDataToPeers:(NSData *) data {
    [self.currentSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];

}


- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    switch (state)
    {
        case GKPeerStateConnected:
            NSLog(@"connected");
            break;
        case GKPeerStateDisconnected:
            NSLog(@"disconnected");
            _currentSession = nil;
            AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
            tabControl.currentSession = _currentSession;
            break;
    }
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context { //---convert the NSData to NSString---
    NSString* str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    _textView.text = str;
    //[alert release];
}

/*
 AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
 tabControl.studyNum = [[[NSString alloc] initWithString:_textField.text]integerValue];
*/


@end

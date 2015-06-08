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
@synthesize studyNum = _studyNum;



- (void)viewDidLoad {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    _studyNum = tabControl.studyNum;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



// called everytime tab is switched to this view
// necessary in case currentSession changes, i.e. is disconnected and reconnected again
- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    // get data received from AprilTestTabBarController through Bluetooth with Momma
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    self.textView.text = tabControl.dataReceived;
    
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
    if(tabControl.session) {
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
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    [tabControl.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
    
}




@end

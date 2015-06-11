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

@synthesize textView = _textView;
@synthesize studyNum = _studyNum;



- (void)viewDidLoad {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    _studyNum = tabControl.studyNum;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleChatUpdate:)
                                                 name:@"chatUpdated"
                                               object:nil];
    
    
}




-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// release notification is view is unloaded for memory purposes
- (void) viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




- (void)handleChatUpdate:(NSNotification *)note {
    NSDictionary *dictData = [note userInfo];

    NSString *received = [dictData objectForKey:@"chatUpdate"];
    _textView.text = received;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end

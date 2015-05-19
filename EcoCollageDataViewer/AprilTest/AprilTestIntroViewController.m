//
//  AprilTestIntroViewController.m
//  AprilTest
//
//  Created by Tia on 4/21/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import "AprilTestIntroViewController.h"
#import "AprilTestTabBarController.h"

@interface AprilTestIntroViewController ()

@end


@implementation AprilTestIntroViewController
@synthesize server = _server;
@synthesize studyNumber = _studyNumber;
@synthesize url = _url;
@synthesize studyNum = _studyNum;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)switchUI:(id)sender {
    _url = _server.text;
    _studyNum = [_studyNumber.text intValue];

    [self performSegueWithIdentifier:@"switchFromLogin" sender:self];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    AprilTestTabBarController *tab = [segue destinationViewController];
    tab.url = _url;
    tab.studyNum = _studyNum;
}


@end

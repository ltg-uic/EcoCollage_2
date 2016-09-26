//
//  AprilTestIntroViewController.m
//  AprilTest
//
//  Created by Joey Shelley on 4/21/15.
//  Copyright (c) 2015 Joey Shelley. All rights reserved.
//

#import "AprilTestIntroViewController.h"
#import "MommaBirdViewController.h"
#import "AprilTestTabBarController.h"

@interface AprilTestIntroViewController ()

@end


#define BABY_BIRD 0
#define MOMMA_BIRD 1

@implementation AprilTestIntroViewController
@synthesize server = _server;
@synthesize studyNumber = _studyNumber;
@synthesize url = _url;
@synthesize studyNum = _studyNum;
@synthesize appType = _appType;
@synthesize logNum  = _logNum;
@synthesize LogNumber = _LogNumber;
@synthesize logFile =_logFile;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _appType = 0;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchUI:(id)sender {
    
    //grew tired of having to append http:// so i already had it appended, is that cool?? Now all you need is the IP adress 
    NSString* finalString = [NSString stringWithFormat: @"%@%@", @"http://", _server.text];
    
    _url =  finalString;
    _studyNum = [_studyNumber.text intValue];
    _logNum  =  [_LogNumber.text   intValue];
    _logFile = [self generateLogFileWithLogNum:_logNum];
    
    NSLog(@"%@", _logFile);
    if(_appType == BABY_BIRD)
        [self performSegueWithIdentifier:@"switchToBabyBird" sender:self];
    else
        [self performSegueWithIdentifier:@"switchToMommaBird" sender:self];
}

// Momma Bird or Baby Bird
- (IBAction)applicationType:(UISegmentedControl *)sender {
    _appType = (int)sender.selectedSegmentIndex;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//method that writes/rewrites at a file in documents directory
-(NSString*) generateLogFileWithLogNum:(int)logNum{
    NSString* newLogFile;
    NSDateComponents *components    = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSDateComponents *timeComponent = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
    
    //generate the file name
    newLogFile = [NSString stringWithFormat:@"%ld_%ld_%ld_%ld_%d.txt",(long)[components year], (long)[components month], (long)[components day], (long)[timeComponent hour], logNum];
    
    
    //append the file name to Documents path to create the pathway
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* logfilePath = [documentsPath stringByAppendingPathComponent:newLogFile];
    
    return logfilePath;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if(_appType == BABY_BIRD) {
        AprilTestTabBarController *tab = [segue destinationViewController];
        tab.url            = _url;
        tab.studyNum       = _studyNum;
        tab.logNum         =_logNum;   //transfer log Number
        tab.LogFile        = _logFile;  //transfer the path to the log file generated
        tab.SortingEnabled = ([self.SortingEnabled isOn]) ? YES : NO;
        tab.showProfile    = ([self.profileHidingSwitch isOn]) ? 1 : 0;
        
    }
    else {
        MommaBirdViewController *momma_data = [segue destinationViewController];
        momma_data.url = _url;
        momma_data.IPAddress = _server.text; // Needed for EcoVision
        momma_data.studyNum = _studyNum;
    }
}
@end

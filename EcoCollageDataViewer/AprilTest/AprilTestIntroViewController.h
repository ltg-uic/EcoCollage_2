//
//  AprilTestIntroViewController.h
//  AprilTest
//
//  Created by Tia on 4/21/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AprilTestIntroViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *server;
@property (strong, nonatomic) IBOutlet UITextField *studyNumber;
@property (strong, nonatomic) IBOutlet UITextField *LogNumber;
@property NSString * url;
@property NSString* logFile;
@property int logNum;
@property int studyNum;
@property int appType;
@property (strong, nonatomic) IBOutlet UISwitch *profileHidingSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *SortingEnabled;
@end

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
@property NSString * url;
@property int studyNum;
@end

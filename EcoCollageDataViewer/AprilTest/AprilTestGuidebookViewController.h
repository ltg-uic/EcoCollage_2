//
//  AprilTestGuidebookViewController.h
//  AprilTest
//
//  Created by Joey Shelley on 8/7/14.
//  Copyright (c) 2014 Joey Shelley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AprilTestGuidebookViewController : UIViewController
@property (strong, nonatomic) IBOutlet UISwitch *elevationSwitch;
@property (strong, nonatomic) IBOutlet UIImageView *aerialView;
@property (strong, nonatomic) IBOutlet UILabel *irving;
@property (strong, nonatomic) IBOutlet UILabel *washington;
@property (strong, nonatomic) IBOutlet UILabel *longwood;
@property (strong, nonatomic) IBOutlet UIView *streetView;
@property (strong, nonatomic) IBOutlet UILabel *threshLabel;

@end

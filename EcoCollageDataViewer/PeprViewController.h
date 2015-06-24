//
//  PeprTestFirstViewController.h
//  PeprTest
//
//  Created by Tia on 10/1/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPieChart.h"
#import <GameKit/GameKit.h>

@interface PeprViewController : UIViewController <XYPieChartDelegate, XYPieChartDataSource, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UISwitch *surveyType;
@property (strong, nonatomic) IBOutlet UISwitch *cpVisible;
@property (strong, nonatomic) IBOutlet UISegmentedControl *typeCP;
@property (strong, nonatomic) IBOutlet UIView *surveyView;
@property (strong, nonatomic) IBOutlet XYPieChart *pie;
@property(nonatomic, strong) NSMutableArray *slices;
@property(nonatomic, strong) NSArray        *sliceColors;
@property(nonatomic, strong) NSMutableArray *currentConcernRanking;
@property (strong, nonatomic) IBOutlet UITextView *descriptionView;
@property (strong, nonatomic) IBOutlet UITextField *usernameText;
- (IBAction)profileSharingSwitch:(UISwitch *)sender;

@end

//
//  AprilTestSecondViewController.h
//  AprilTest
//
//  Created by Tia on 4/7/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface OutcomeSalienceViewController : UIViewController <UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
@property NSMutableArray * currentConcernRanking;
@property int studyNum;
@property (strong, nonatomic) IBOutlet UIScrollView *dataWindow;
@property (strong, nonatomic) IBOutlet UIScrollView *mapWindow;

@property (strong, nonatomic) IBOutlet UIScrollView *titleWindow;
@property (strong, nonatomic) IBOutlet UIScrollView *SliderWindow;

@property NSString * url;
@property (strong, nonatomic) IBOutlet UILabel *hoursAfterStormLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) IBOutlet UIPickerView *sortingPicker;
@property (strong, nonatomic) NSMutableArray *scenarioNames;


@property (strong, nonatomic) IBOutlet UISwitch *DynamicNormalization;
- (IBAction)NormTypeSwitched:(UISwitch *)sender;


@property (strong, nonatomic) IBOutlet UILabel *currentMaxInvestment;

@property (strong, nonatomic) IBOutlet UITextField *SortPickerTextField;
@end

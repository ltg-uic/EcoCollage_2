//
//  AprilTestSecondViewController.h
//  AprilTest
//
//  Created by Tia on 4/7/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OutcomeSalienceViewController : UIViewController <UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
@property NSMutableArray * currentConcernRanking;
@property int studyNum;
@property (strong, nonatomic) IBOutlet UIScrollView *dataWindow;
@property (strong, nonatomic) IBOutlet UIScrollView *mapWindow;

@property (strong, nonatomic) IBOutlet UIScrollView *titleWindow;
@property NSString * url;
@property (strong, nonatomic) IBOutlet UISlider *hoursAfterStorm;
@property (strong, nonatomic) IBOutlet UILabel *hoursAfterStormLabel;
@property (strong, nonatomic) IBOutlet UISlider *thresholdValue;
@property (strong, nonatomic) IBOutlet UILabel *thresholdValueLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) IBOutlet UIPickerView *sortingPicker;
@property (strong, nonatomic) NSMutableArray *scenarioNames;

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD

@property (strong, nonatomic) IBOutlet UILabel *currentMaxInvestment;
=======
>>>>>>> parent of f0f7c42... Merge remote-tracking branch 'origin/master'
=======
>>>>>>> parent of f0f7c42... Merge remote-tracking branch 'origin/master'
=======
>>>>>>> parent of 3978cb6... Commit
@end

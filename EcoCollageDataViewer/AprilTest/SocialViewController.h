//
//  SocialViewController.h
//  AprilTest
//
//  Created by Ryan Fogarty on 6/2/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface SocialViewController : UIViewController <UIScrollViewDelegate>
@property int studyNum;
@property (strong, nonatomic) IBOutlet UIScrollView *profilesWindow;
@property (strong, nonatomic) IBOutlet UIScrollView *usernamesWindow;
@property (strong, nonatomic) IBOutlet UIScrollView *mapWindow;
@property (strong, nonatomic) IBOutlet UISlider *BudgetSlider;
@property (strong, nonatomic) IBOutlet UISlider *StormPlayBack;


@property (strong, nonatomic) IBOutlet UITextField *trialPickerTextField;


@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end

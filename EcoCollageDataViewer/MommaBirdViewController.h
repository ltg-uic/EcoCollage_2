//
//  MommaBirdViewController.h
//  AprilTest
//
//  Created by Ryan Fogarty on 5/26/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface MommaBirdViewController : UIViewController <GKSessionDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>
@property NSMutableArray *currentConcernRanking;
@property NSString *url;
@property int studyNum;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UITextView *macMiniTextView;

@property (strong, nonatomic) IBOutlet UITextField *budgetNumber;
@property (strong, nonatomic) IBOutlet UILabel *studyNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *trialNumberLabel;
- (IBAction)BudgetSlider:(UISlider *)sender;
@property (strong, nonatomic) IBOutlet UISlider *BudgetSlider;

@end

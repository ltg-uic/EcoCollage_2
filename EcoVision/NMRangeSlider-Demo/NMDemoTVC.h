//
//  NMDemoTVC.h
//  NMRangeSlider
//
//  Created by Murray Hughes on 04/08/2012
//  Copyright 2011 Null Monkey Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NMRangeSlider.h"

@interface NMDemoTVC : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (IBAction)segmentedControl:(UISegmentedControl *)sender;

@property (weak, nonatomic) IBOutlet NMRangeSlider *labelSlider;
@property (weak, nonatomic) IBOutlet UILabel *lowerLabel;
@property (weak, nonatomic) IBOutlet UILabel *upperLabel;
- (IBAction)labelSliderChanged:(NMRangeSlider*)sender;


@property (weak, nonatomic) IBOutlet NMRangeSlider *labelSlider2;
@property (weak, nonatomic) IBOutlet UILabel *lowerLabel2;
@property (weak, nonatomic) IBOutlet UILabel *upperLabel2;
- (IBAction)labelSliderChanged2:(NMRangeSlider*)sender;


@property (weak, nonatomic) IBOutlet NMRangeSlider *labelSlider3;
@property (weak, nonatomic) IBOutlet UILabel *lowerLabel3;
@property (weak, nonatomic) IBOutlet UILabel *upperLabel3;
- (IBAction)labelSliderChanged3:(NMRangeSlider*)sender;

@end

//
//  SecondViewController.h
//  EcoVision
//
//  Created by LTG-Guest on 4/8/15.
//  Copyright (c) 2015 EcoCollage. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NMRangeSlider.h"

@interface SecondViewController : UIViewController <UIScrollViewDelegate,UIGestureRecognizerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView* imageView;
@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;

- (IBAction)threshold_image:(UIButton *)sender;
- (IBAction)saveHSVValues:(UIButton *)sender;
- (IBAction)un_thresh_image:(UIButton *)sender;


@property (weak, nonatomic) IBOutlet UIImageView *InspectedColour;
- (IBAction)UndoTap:(UIButton *)sender;
- (IBAction)ClearSamples:(UIButton *)sender;
- (IBAction)SendHSVVals:(UIButton *)sender;

@end


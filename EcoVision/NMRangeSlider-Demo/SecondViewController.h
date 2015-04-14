//
//  SecondViewController.h
//  EcoVision
//
//  Created by LTG-Guest on 4/8/15.
//  Copyright (c) 2015 EcoCollage. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NMRangeSlider.h"

@interface SecondViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView* imageView;
@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;

- (IBAction)threshold_image:(UIButton *)sender;
- (IBAction)show_plain_image:(UIButton *)sender;

@end


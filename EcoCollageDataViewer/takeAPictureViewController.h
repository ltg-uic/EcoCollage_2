//
//  takeAPictureViewController.h
//  Trial_1
//
//  Created by Jamie Auza on 5/12/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface takeAPictureViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView* imageView; // why
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic,strong) UIImage * currentImage_TAP;
@property (nonatomic,strong) UIImage * warpedGlobal;
@property (nonatomic,strong) UIImage * userImage_TAP;


@property NSString * groupNumber;
@property NSString *IPAddress;
@property (weak, nonatomic) IBOutlet UIButton *analyzeScreen;


- (IBAction)takePhoto:(id)sender;
- (IBAction)toAnalyze:(id)sender;
- (IBAction)toLogin:(id)sender;
- (IBAction)beginProcessing:(id)sender;


// Given Methods
- (void)viewDidLoad;
- (void)didReceiveMemoryWarning;

// Throw error alert
- (void)throwErrorAlert:(NSString*) alertString;

// Used to display the picture just taken from the camera onto the main viewer
- (void)updateScrollView:(UIImage *) img;
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;

// Used to process the picture to be analyzed
- (void)beginProcessingMap;
- (void)processMap;
- (int)threshy;
- (int)contoury;
- (int)warpy;







@end

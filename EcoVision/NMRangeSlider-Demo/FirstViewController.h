//
//  FirstViewController.h
//  EcoVision
//
//  Created by LTG-Guest on 4/8/15.
//  Copyright (c) 2015 EcoCollage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, weak) IBOutlet UIImageView* imageView;
@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;


-(void)sendData;
-(void)processMap;
-(int)threshy;
-(int)contoury;
-(int)warpy;


- (IBAction)takePhoto:(id)sender;
- (IBAction)process:(UIButton *)sender;
- (IBAction)analyze:(UIButton *)sender;



@property (strong, nonatomic) IBOutlet UITextField *studyNumber;
@property (strong, nonatomic) IBOutlet UITextField *trialNumber;
@property (strong, nonatomic) IBOutlet UITextField *IPAddress;


- (IBAction)incrementStudyNum:(UIButton *)sender;
- (IBAction)incrementTrialNum:(UIButton *)sender;


@end


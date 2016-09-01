//
//  analysisViewController.h
//  Trial_1
//
//  Created by Jamie Auza on 5/20/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface analysisViewController : UIViewController <UIScrollViewDelegate, UITabBarControllerDelegate,UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UIImageView* imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic,strong) UIImage * currentImage_A;
@property (nonatomic,strong) UIImage * userImage_A;


- (IBAction)toCalibrate:(id)sender;

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;


@property (weak, nonatomic) IBOutlet UIButton *addSwaleButton;
@property (weak, nonatomic) IBOutlet UIButton *addRainBarrelButton;
@property (weak, nonatomic) IBOutlet UIButton *addGreenRoofButton;
@property (weak, nonatomic) IBOutlet UIButton *addPermeablePaverButton;
@property (weak, nonatomic) IBOutlet UIButton *dropDown;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)addGi:(id)sender;
- (IBAction)retakePicture:(id)sender;
- (IBAction)send:(id)sender;
- (IBAction)dropDownButton:(id)sender;

- (void) test;
- (void) drawIconsInArray:(NSMutableArray *)iconArray image:(UIImage*)iconImage;

@property CGFloat squareWidth;
@property CGFloat squareHeight;
@property NSMutableArray* switches;
@property NSString * groupNumber;
@property NSString * IPAddress;
@property long int clickedSegment_A;

@end

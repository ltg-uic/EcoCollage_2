//
//  SecondViewController.m
//  EcoVision
//
//  Created by LTG-Guest on 4/8/15.
//  Copyright (c) 2015 EcoCollage. All rights reserved.
//

#import "SecondViewController.h"
#import "CVWrapper.h"
#import <math.h>
#import <stdlib.h>

@interface SecondViewController ()

@end

@implementation SecondViewController

UIImage* plainImage = nil;
UIImage* threshedImage = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    plainImage = [CVWrapper getCurrentImage];
    [self updateScrollView:[CVWrapper getCurrentImage]];
}

- (void) updateScrollView:(UIImage *) img {
    //** following code presents userImage in scrollView
    UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
    
    // if there is an image in scrollView it will remove it
    [self.imageView removeFromSuperview];

    self.imageView = imageView;
    [self.scrollView addSubview:imageView];
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView.contentSize = self.imageView.bounds.size;
    self.scrollView.maximumZoomScale = 4.0;
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.contentOffset = CGPointMake(-(self.scrollView.bounds.size.width-self.imageView.bounds.size.width)/2, -(self.scrollView.bounds.size.height-self.imageView.bounds.size.height)/2);
}


- (IBAction)threshold_image:(UIButton *)sender {
    if (plainImage == nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"No image to threshold!" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        return;
    }

    threshedImage = [CVWrapper thresh:plainImage colorCase: [CVWrapper getSegmentIndex]];
    
    [self updateScrollView:threshedImage];
}

- (IBAction)show_plain_image:(UIButton *)sender {
    [self updateScrollView:plainImage];
}
@end

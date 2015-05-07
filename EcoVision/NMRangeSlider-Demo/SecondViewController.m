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
    [self setHSVValues];
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
    if(plainImage != nil)
        [self updateScrollView:[CVWrapper getCurrentImage]];
}

- (void) updateScrollView:(UIImage *) img {
    //** following code presents userImage in scrollView
    UIImageView *newView = [[UIImageView alloc] initWithImage:img];
    
    // if there is an image in scrollView it will remove it
    [self.imageView removeFromSuperview];

    self.imageView = newView;
    [self.scrollView addSubview:newView];
    self.scrollView.backgroundColor = [UIColor whiteColor];
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
    
    if(plainImage == nil) {
        [self takePhoto];
    }
}

- (void)takePhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    plainImage = info[UIImagePickerControllerOriginalImage];
    
    [CVWrapper setCurrentImage:plainImage];
    
    if (plainImage == nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Error taking photo!" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        self.scrollView.backgroundColor = [UIColor whiteColor]; // hides scrollView

    }
    else {
        [self updateScrollView:plainImage];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)saveHSVValues:(UIButton *)sender {
    int values[30];
    [CVWrapper getHSV_Values:values];
    
    NSString *str = @"";
    
    int i;
    for(i = 0; i < 30; i++) {
        str = [str stringByAppendingFormat:@"%d ", values[i]];
    }
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"hsvValues"];
    fileName = [fileName stringByAppendingPathExtension:@"txt"];
    
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    [file writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
    
}

- (void) setHSVValues {
    int hsvValues[30];
    [CVWrapper getHSV_Values:hsvValues];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"hsvValues"];
    fileName = [fileName stringByAppendingPathExtension:@"txt"];
    
    NSString* content = [NSString stringWithContentsOfFile:fileName
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    NSArray *arr = [content componentsSeparatedByString:@" "];
    
    int i;
    for(i = 0; i < 30; i++) {
        hsvValues[i] = [[arr objectAtIndex:i]integerValue];
    }
    
    [CVWrapper setHSV_Values:hsvValues];
    
}
@end

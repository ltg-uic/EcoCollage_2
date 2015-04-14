//
//  FirstViewController.m
//  EcoVision
//
//  Created by LTG-Guest on 4/8/15.
//  Copyright (c) 2015 EcoCollage. All rights reserved.
//

#import "FirstViewController.h"
#import "CVWrapper.h"
#import <math.h>
#import <stdlib.h>

@interface FirstViewController ()

@end

@implementation FirstViewController

int widthGlobal = 0;

UIImage *userImage = nil;
UIImage *savedImage;
UIImage *userImageGlobal;
UIImage *warpedGlobal;
bool studyNum;
NSString *fileContents;
NSURL *server;
NSString *IPAddress = @"131.193.79.217";

int cornersGlobal[8];
int studyNumber;
int trialNumber;

char results[5000];


int testBoy = 0;
int rowGlobal;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.IPAddress.text = IPAddress;
    
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"Results" ofType:@"txt"];
    NSError *error;
    
    //this is the url you need to set to the output of the program
    fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePhoto:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    userImage = info[UIImagePickerControllerOriginalImage];

    [CVWrapper setCurrentImage:userImage];
    
    //** following code presents userImage in scrollView
    UIImageView *imageView = [[UIImageView alloc] initWithImage:userImage];
    
    // if there is an image in scrollView it will remove it
    [self.imageView removeFromSuperview];
    
    if (userImage == nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Test image thresholding failed! Please try taking the picture again" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        self.scrollView.backgroundColor = [UIColor whiteColor]; // hides scrollView
    }
    else {
        self.imageView = imageView;
        [self.scrollView addSubview:imageView];
        self.scrollView.backgroundColor = [UIColor blackColor];
        self.scrollView.contentSize = self.imageView.bounds.size;
        self.scrollView.maximumZoomScale = 4.0;
        self.scrollView.minimumZoomScale = 0.5;
        self.scrollView.contentOffset = CGPointMake(-(self.scrollView.bounds.size.width-self.imageView.bounds.size.width)/2, -(self.scrollView.bounds.size.height-self.imageView.bounds.size.height)/2);
    }
    
    //** end code presenting userImage in scrollView
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)process:(UIButton *)sender {
    
    [self processMap];
    
}


-(void)processMap{
    int t = 0, c = 0, w = 0;
    
    t = [self threshy];
    
    if(t) {
        c = [self contoury];
    }
    if(c) {
        w = [self warpy];
    }

    if(w){
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Does this look like your map?" message:@"If so, click analyze. If not, retake the image and reprocess" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
    }
}

-(int)threshy{
    
    
    if (userImage == nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"No image to threshold! \nTake a photo of the entire board" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        return 0;
    }
    
    /* thresholds image
     ** colorCases: 0 = green
     **             1 = red
     **             2 = wood
     **             3 = blue
     **             4 = dark green (corner markers)
     */
    
    
    UIImage* threshed = nil;
    threshed = [CVWrapper thresh:userImage colorCase: 4];
    
    //** following code shows thresholded image in scrollView
    UIImageView *imageView = [[UIImageView alloc] initWithImage:threshed];
    
    // if there is an image in scrollView it will remove it
    [self.imageView removeFromSuperview];
    
    if (userImage == nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image thresholding failed! Please try taking the picture again" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        self.scrollView.backgroundColor = [UIColor whiteColor]; // hides scrollView
        return 0;
    }
    else {
        self.imageView = imageView;
        [self.scrollView addSubview:imageView];
        self.scrollView.backgroundColor = [UIColor blackColor];
        self.scrollView.contentSize = self.imageView.bounds.size;
        self.scrollView.maximumZoomScale = 4.0;
        self.scrollView.minimumZoomScale = 0.5;
        self.scrollView.contentOffset = CGPointMake(-(self.scrollView.bounds.size.width-self.imageView.bounds.size.width)/2, -(self.scrollView.bounds.size.height-self.imageView.bounds.size.height)/2);
        // save userImage image to global copy for detecting contours
        userImageGlobal = userImage;
        return 1;
    }
    
    //** end of code showing thresholded image in scrollView5000
    
}
-(int)contoury{
    if(userImageGlobal == nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image was not thresholded. Threshold your image!" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        self.scrollView.backgroundColor = [UIColor whiteColor]; // hides scrollView
        return 0;
    }
    
    int width = [CVWrapper detectContours:userImageGlobal corners:cornersGlobal];
    
    if(width != 0) {
        widthGlobal = abs(width);
    }
    else widthGlobal = 1;
    
    return 1;
    
}
-(int)warpy{
    /*
     * get userImage image
     * find triangle contours on userImage image
     * get Point2f of those triangle contours
     * plug those points into warper
     */
    
    
    
    int height = (widthGlobal * 23) / 25;
    if (userImage == nil || userImageGlobal == nil || widthGlobal == 0) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Can not warp! \nMake sure you threshold and contour first!" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        return 0;
    }
    
    // make blank image of size widthXheight
    UIImage *dst = nil;
    CGSize targetSize = CGSizeMake(widthGlobal, height);
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
    thumbnailRect.origin = CGPointMake(0.0,0.0);
    thumbnailRect.size.width  = targetSize.width;
    thumbnailRect.size.height = targetSize.height;
    
    [userImage drawInRect:thumbnailRect];
    
    
    dst = UIGraphicsGetImageFromCurrentImageContext();
    
    
    UIGraphicsEndImageContext();
    // finished making image
    
    
    // make a UIImage which will be perspectively warped from stitchedImage
    // use stitchedImageGlobal because it is the global equivalent to stitchedImage
    UIImage* destination = [CVWrapper warp:userImage destination_image:dst];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:destination];
    
    
    
    //** following code shows warped image in scrollView
    
    // if there is an image in scrollView it will remove it
    [self.imageView removeFromSuperview];
    
    
    if (destination == nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image warping failed! \nPlease take your picture again" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        self.scrollView.backgroundColor = [UIColor whiteColor]; // hides scrollView
        return 0;
    }
    else {
        [CVWrapper setCurrentImage:destination]; // set image for SecondViewController to use for thresh holding and displaying on "configuration" tab
        warpedGlobal = destination;
        self.imageView = imageView;
        [self.scrollView addSubview:imageView];
        self.scrollView.backgroundColor = [UIColor blackColor];
        self.scrollView.contentSize = self.imageView.bounds.size;
        self.scrollView.maximumZoomScale = 4.0;
        self.scrollView.minimumZoomScale = 0.5;
        self.scrollView.contentOffset = CGPointMake(-(self.scrollView.bounds.size.width-self.imageView.bounds.size.width)/2, -(self.scrollView.bounds.size.height-self.imageView.bounds.size.height)/2);
        return 1;
    }
    
    //** end of code showing warped image in scrollView
    
}




// run analysis to find marker pieces on map
- (IBAction)analyze:(UIButton *)sender {
    
    if(IPAddress == nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter the server IP address" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if(studyNum == 0) { // checks if bool studyNum is false (means studyNumber text field is empty)
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter your study number" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if(studyNumber < -1) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter your trial number" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // for testing
    UIImage* testImg = [UIImage imageNamed:@"single31.JPG"];
    
    int worked;
    if(warpedGlobal == nil) {
        worked = [CVWrapper analysis:testImg studyNumber: studyNumber trialNumber:trialNumber results: results];
    }
    else {
        worked = [CVWrapper analysis:warpedGlobal studyNumber: studyNumber trialNumber:trialNumber results: results];
    }
    
    if(worked) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"We found your pieces!" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        [self sendData];
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"We couldn't find your pieces!" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)sendData{
    int studyID = studyNumber;
    int trialID = trialNumber;
    
    server = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", IPAddress]];
    
    
    // get rid of trailing space in results string
    int i = 0;
    while(results[i] != '\0') {
        if(results[i+1] == '\0')
            results[i] = '\0';
        i++;
    }
    
    NSString *temp = [NSString stringWithCString:results encoding:NSASCIIStringEncoding];
    
    fileContents = temp;
    
    NSString *escapedFileContents = [fileContents stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSLog(@"%@", escapedFileContents);
    
    NSString *content;
    while (!content){
        NSString *stringText = [NSString stringWithFormat:@"mapInput.php?studyID=%d&trialID=%d&map=%@", studyID, trialID, escapedFileContents];
        content = [NSString stringWithContentsOfURL:[NSURL URLWithString: stringText relativeToURL:server] encoding:NSUTF8StringEncoding error:nil];
    }
    NSLog(@"%@", content);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    studyNum = ([self.studyNumber.text length] == 0) ? 0 : 1;
    studyNumber = [self.studyNumber.text integerValue];
    trialNumber = [self.trialNumber.text integerValue];
    IPAddress = self.IPAddress.text;
    if([IPAddress length] == 0) IPAddress = nil;
    [self.IPAddress resignFirstResponder];
    [self.studyNumber resignFirstResponder];
    [self.trialNumber resignFirstResponder];
    return YES;
}

- (IBAction)incrementStudyNum:(UIButton *)sender {
    studyNumber++;
    studyNum = 1; // flip bool checking if studyNumber text field is empty
    self.studyNumber.text = [NSString stringWithFormat:@"%d", studyNumber];
    
}

- (IBAction)incrementTrialNum:(UIButton *)sender {
    trialNumber++;
    self.trialNumber.text = [NSString stringWithFormat:@"%d", trialNumber];
}


@end

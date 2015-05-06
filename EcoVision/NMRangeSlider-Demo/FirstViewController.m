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
UIImage *threshedGlobal = nil;
UIImage *warpedGlobal;
bool studyNum;
NSString *fileContents;
NSURL *server;
NSString *IPAddress = @"";
//@"131.193.79.217";

int cornersGlobal[8];
int studyNumber;
int trialNumber;

char results[5000];

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setHSVValues];
    
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
    
    if (userImage == nil) {
        [self throwErrorAlert:@"Error taking photo! Please try taking the picture again"];
        self.scrollView.backgroundColor = [UIColor whiteColor]; // hides scrollView
    }
    else {
        [self updateScrollView:userImage];
    }
    
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

    /*
    if(w){
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Does this look like your map?" message:@"If so, click analyze. If not, retake the image and reprocess" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
    }
    */
}

-(int)threshy{
    if (userImage == nil) {
        UIImage* testImg = [UIImage imageNamed:@"IMG_0463.JPG"];
        userImage = testImg;
        //[self throwErrorAlert:@"No image to threshold! \nTake a photo of the entire board"];
        //return 0;
    }
    
    /* thresholds image
     ** colorCases: 0 = green
     **             1 = red
     **             2 = wood
     **             3 = blue
     **             4 = dark green (corner markers)
     */
    
    threshedGlobal = [CVWrapper thresh:userImage colorCase: 4];
    
    return (threshedGlobal == nil) ? 0 : 1;
}
-(int)contoury{
    if(threshedGlobal == nil) {
        [self throwErrorAlert:@"Image was not thresholded. Threshold your image!"];
        return 0;
    }
    
    int width = [CVWrapper detectContours:threshedGlobal corners:cornersGlobal];
    
    if(width != 0) {
        widthGlobal = abs(width);
    }
    
    return 1;
    
}
-(int)warpy{
    int height = (widthGlobal * 23) / 25;
    if (userImage == nil || threshedGlobal == nil || widthGlobal == 0) {
        [self throwErrorAlert:@"Can not warp! \nMake sure you threshold and contour first!"];
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
    
    if (destination == nil) {
        [self throwErrorAlert:@"Image warping failed! \nPlease take your picture again"];
        return 0;
    }
    else {
        warpedGlobal = destination;
        [CVWrapper setCurrentImage:destination];
        [self updateScrollView:destination];
        return 1;
    }
    
}




// run analysis to find marker pieces on map
- (IBAction)analyze:(UIButton *)sender {
    
    if(IPAddress == nil) {
        [self throwErrorAlert:@"Enter the server IP address"];
        return;
    }
    
    if(studyNum == 0) { // checks if bool studyNum is false (means studyNumber text field is empty)
        [self throwErrorAlert:@"Enter your study number"];
        return;
    }
    
    if(studyNumber < -1) {
        [self throwErrorAlert:@"Enter your trial number"];
        return;
    }
    
    // for testing
    int worked;
    UIImage* testImg = [UIImage imageNamed:@"single31.JPG"];
    if(warpedGlobal == nil) { // also for testing
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
        [self throwErrorAlert:@"No markers were found!"];
    }
}

-(void)sendData{
    int studyID = studyNumber;
    int trialID = trialNumber;
    
    server = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", IPAddress]];
    
    // get rid of trailing 'space' character in results string
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

- (void) throwErrorAlert:(NSString*) alertString {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:alertString delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    [alert show];
    self.scrollView.backgroundColor = [UIColor whiteColor]; // hides scrollView
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

//
//  takeAPictureViewController.m
//  Trial_1
//
//  Created by Jamie Auza on 5/12/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import "takeAPictureViewController.h"
#import "ViewController.h"
#import "analysisViewController.h" 
#import "loginViewController.h"
#import "CVWrapper.h"

@interface takeAPictureViewController ()

@end

@implementation takeAPictureViewController
@synthesize scrollView;
@synthesize currentImage_TAP;
@synthesize analyzeScreen;

UIImage *threshedGlobal = nil;
@synthesize userImage_TAP;
UIImage *testImg;  //test image to be warped/analyzed if no picture is taken
@synthesize warpedGlobal;
UIImage *warpedGlobalMean;
UIAlertView * progress;
UIImagePickerController *picker;

NSURL *server;
NSString *fileContents;

int widthGlobal = 0;
int cornersGlobal[8];
int studyNumber;

//char results[5000];
char results[5000]; // changed to do testing

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self performSegueWithIdentifier:@"toTips" sender:self]; MERGING
    
    [self setHSVValues];
    [analyzeScreen setEnabled:FALSE];
    testImg = [UIImage imageNamed:@"IMG_0054.JPG"];
    
    picker = [[UIImagePickerController alloc] init];
    warpedGlobal = currentImage_TAP;
}

- (void) viewDidAppear:(BOOL)animated{
    if( currentImage_TAP != nil){
        [self updateScrollView:currentImage_TAP];
        [analyzeScreen setEnabled:TRUE];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

/*
 * Can use this method after buttonizeButtonTap to instantiate anything before you segue into the next scene
 *
 * @param segue The name of the segue
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toTileDetection"])
    {
        // Set some properties of the next view controller ( for send data )
        //takeAPictureViewController *takeAPictureViewController = [segue destinationViewController];
        //analysisViewController *analysisViewController = [segue destinationViewController];
        //UIImage * test = [CVWrapper getCurrentImage]; // Doesn't work
        
        
        [self analyze];
        currentImage_TAP = warpedGlobal;
        analysisViewController *analysisViewController = [segue destinationViewController];
        analysisViewController.currentImage_A = currentImage_TAP;
        analysisViewController.groupNumber = self.groupNumber;
        analysisViewController.IPAddress = self.IPAddress;
        analysisViewController.userImage_A = userImage_TAP;
         
    }
    /*
    if ([[segue identifier] isEqualToString:@"toMommaBird"])
    {
        currentImage_TAP = warpedGlobal;
        loginViewController * login = [segue destinationViewController];
        login.grpNumber = self.groupNumber;
        login.IPAddress = self.IPAddress;
        login.currentImage_L = currentImage_TAP;
        login.originalImage_L = userImage_TAP;
    }
     */
    
    if ([[segue identifier] isEqualToString:@"toTips"])
    {
        ViewController * tips = [segue destinationViewController];
        currentImage_TAP = warpedGlobal;
        tips.currentImage_T = currentImage_TAP;
        tips.groupNumber = self.groupNumber;
        tips.IPAddress = self.IPAddress;
        tips.userImage_T = userImage_TAP;
    }
    
}


#pragma mark - IBActions

- (IBAction)toTileDetection:(id)sender {
    [self performSegueWithIdentifier:@"toTileDetection" sender:sender];
}

- (IBAction)toMommaBird:(id)sender {
    [self performSegueWithIdentifier:@"toMommaBird" sender:sender];
}

- (IBAction)toTips:(id)sender {
    [self performSegueWithIdentifier:@"toTips" sender:sender];
}


- (IBAction)takePhoto:(id)sender {
    //******To Camera App********//
    /*
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
     */
    //*******To Test Image*******//
    
    // Bypass Camera and go straight to the method that updates the scrollView
    
    userImage_TAP = [UIImage imageNamed:@"IMG_0030.jpg"];
    [CVWrapper setCurrentImage:userImage_TAP];
    //[self updateScrollView:userImage_TAP];
    [self processMap];
    [analyzeScreen setEnabled:TRUE];
    
    
}



#pragma mark - Picture
/*
 * Required to be a delegate for UIImagePickerController. This method gets called once the user finishes taking a picture.
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    userImage_TAP = info[UIImagePickerControllerOriginalImage];
    
    //[CVWrapper setCurrentImage:userImage_TAP];
    
    if (userImage_TAP == nil) {
        [self throwErrorAlert:@"Error taking photo! Please try taking the picture again"];
        self.scrollView.backgroundColor = [UIColor whiteColor]; // hides scrollView
    }
    else {
        
        //mean_image = [CVWrapper ApplyMedianFilter:userImage_TAP];
        //userImage_TAP = [UIImage imageWithCGImage:mean_image.CGImage];
        
        [CVWrapper setCurrentImage:userImage_TAP];
        //[self updateScrollView:userImage_TAP];
        [self processMap];
        [analyzeScreen setEnabled:TRUE];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

/*
 * Required to be a delegate for UIImagePickerController. This method gets called if the user cancels taking the picture.
 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Change the Screen
/*
 * The following code presents userImage_TAP in scrollView
 */
- (void) updateScrollView:(UIImage *) img {
    
    UIImageView *newView = [[UIImageView alloc] initWithImage:img];
    
    // if there is an image in scrollView it will remove it
    [self.imageView removeFromSuperview];
    
    //handle pinching in/ pinching out to zoom
    newView.userInteractionEnabled = YES;
    newView.backgroundColor = [UIColor clearColor];
    newView.contentMode =  UIViewContentModeCenter;
    
    
    self.imageView = newView;
    [self.scrollView addSubview:newView];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.contentSize = self.imageView.bounds.size;
    self.scrollView.maximumZoomScale = 6.0;
    self.scrollView.minimumZoomScale = 0.5;
    
    self.scrollView.clipsToBounds = YES;
    self.scrollView.delegate = self;
    
    //self.scrollView.contentOffset = CGPointMake(-(self.scrollView.bounds.size.width-self.imageView.bounds.size.width)/2, -(self.scrollView.bounds.size.height-self.imageView.bounds.size.height)/2);
    
    [self.scrollView addSubview:newView];
    
    //Set image on the scrollview
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageView;
}

/*
 * General method to throw an alert message
 *
 * @param the error message that goes along with the error ebing thrown
 */
- (void) throwErrorAlert:(NSString*) alertString {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:alertString delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    [alert show];
    //self.scrollView.backgroundColor = [UIColor whiteColor]; // hides scrollView ( we don't really need this cause we don't have one in this Scene
}


#pragma mark - Process
/*
 * Set the initial HSV Values before analyzing.
 */
- (void) setHSVValues {
    int hsvValues[30];
    int i;
    [CVWrapper getHSV_Values:hsvValues];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"hsvValues"];
    fileName = [fileName stringByAppendingPathExtension:@"txt"];
    
    //create file if it doesn't exist and fill with default values
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
        
        int hsvDefault[] = {10, 80, 50, 200, 50, 255,  115 ,120 ,97 ,226, 112 ,240, 90, 110, 40, 100, 120, 225, 0, 15, 30, 220, 50, 210, 15, 90, 35, 200, 35, 130};
        [CVWrapper setHSV_Values:hsvDefault];
        
        
        NSString *str = @"";
        
        for(i = 0; i < 30; i++) {
            str = [str stringByAppendingFormat:@"%d ", hsvDefault[i]];
        }
        
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
        
        [file writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        [file closeFile];
    }
    
    
    NSString* content = [NSString stringWithContentsOfFile:fileName
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    NSArray *arr = [content componentsSeparatedByString:@" "];
    
    for(i = 0; i < 30 && i < arr.count; i++) {
        NSLog(@"hsvValue %d: %d\n", i, [[arr objectAtIndex:i]integerValue]);
        hsvValues[i] = [[arr objectAtIndex:i]integerValue];
    }
    
    [CVWrapper setHSV_Values:hsvValues];
    
}
- (void) processMap{
    int t = 0, c = 0, w = 0;
    
    t = [self threshy];
    
    if(t) {
        NSLog(@"Picture was threshed");
        c = [self contoury];
    }
    if(c) {
         NSLog(@"Picture was contoured");
        w = [self warpy];
    }
    
    /*
     if(w){
     UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Does this look like your map?" message:@"If so, click analyze. If not, retake the image and reprocess" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
     [alert show];
     }
     */
}
- (int) threshy{
    if (userImage_TAP == nil) {
        userImage_TAP = testImg;
    }
    
    /* thresholds image
     ** colorCases: 0 = green
     **             1 = red
     **             2 = wood
     **             3 = blue
     **             4 = dark green (corner markers)
     */
    
    threshedGlobal = [CVWrapper thresh:userImage_TAP colorCase: 4];
    return (threshedGlobal == nil) ? 0 : 1;
}
- (int)contoury{
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
- (int) warpy{
    int height = (widthGlobal * 23) / 25;
    if (userImage_TAP == nil || threshedGlobal == nil || widthGlobal == 0) {
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
    
    [userImage_TAP drawInRect:thumbnailRect];
    
    
    dst = UIGraphicsGetImageFromCurrentImageContext();
    
    
    UIGraphicsEndImageContext();
    // finished making image
    
    // make a UIImage which will be perspectively warped from stitchedImage
    // use stitchedImageGlobal because it is the global equivalent to stitchedImage
    UIImage* destination = [CVWrapper warp:userImage_TAP destination_image:dst];
    
    if (destination == nil) {
        [self throwErrorAlert:@"Image warping failed! \nPlease take your picture again"];
        return 0;
    }
    else {
        warpedGlobal     = destination;
        warpedGlobalMean = [CVWrapper ApplyMedianFilter:destination];
        
        [CVWrapper setCurrentImage:destination];
        
        [self updateScrollView:destination];
        return 1;
    }
    
}

#pragma mark - Analyze
// Analyze the picture

- (void) analyze{
    // for testing
    int worked;
    
    worked = [CVWrapper analysis:warpedGlobal studyNumber: 0 trialNumber:0 results: results];
    // After they analyze they reset the coords
    
    if(worked) {
        /*
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"We found your pieces!" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        
        */
        // FOR TESTING PURPOSES ONLY-- Testing to see if we can actually threshold something
        
        /*
         UIImage* threshedImage = [CVWrapper thresh:warpedGlobal colorCase: [CVWrapper getSegmentIndex]];
         [self updateScrollView:threshedImage];
         */
        
        // ok why didn't this show...
        // DONT COMMENT OUT
        //[self sendData];
        
        return;
    }
    else {
        [self throwErrorAlert:@"No markers were found!"];
    }

}

@end

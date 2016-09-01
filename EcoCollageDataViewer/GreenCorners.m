//
//  GreenCorner.m
//  Trial_1
//
//  Created by Jamie Auza on 5/20/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import "GreenCorners.h"
#import "CVWrapper.h"
#import "Coordinate.h"
#import "savedLocations.h"
#import "analysisViewController.h"
#import <math.h>
#import <stdlib.h>

@implementation GreenCorners

UITapGestureRecognizer * singleTap_GC; // tap that recognizes color extraction
UITapGestureRecognizer * doubleTap_GC; // tap that recognizes removal of sample

UIImage* plainImage_GC = nil;
UIImageView * img_GC;
UIImage* threshedImage_GC = nil;

NSMutableArray * GreenCornerSamples;
NSMutableArray * sampleImages_GC;

int highHue_GC, highSaturation_GC, highVal_GC;
int lowHue_GC, lowSaturation_GC, lowVal_GC;
savedLocations* savedLocationsFromFile_GC;

@synthesize sample1;
@synthesize sample2;
@synthesize sample3;
@synthesize sample4;
@synthesize sample5;
@synthesize sample6;
@synthesize lightest_GC;
@synthesize darkest_GC;
@synthesize originalImage;
@synthesize clickedSegment_GC;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initializing the switch
    [self.threshSwitch addTarget:self
                          action:@selector(stateChanged:) forControlEvents:UIControlEventValueChanged];
    _threshSwitch.on = false;
    
    // Set Default HSV Values
    [self setHSVValues];
    
    savedLocationsFromFile_GC = [[savedLocations alloc] init];
    
    
    // Back Button
    UIBarButtonItem *buttonizeButton = [[UIBarButtonItem alloc] initWithTitle:@"Buttonize"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(buttonizeButtonTap:)];
    self.navigationItem.rightBarButtonItems = @[buttonizeButton];
    
    // To send data to save screen
    _highLowVals_GC = [[NSMutableArray alloc]init];
    
    
    
    GreenCornerSamples = [NSMutableArray array];
    sampleImages_GC = [NSMutableArray array];
    
    [self changeColorSetToIndex:clickedSegment_GC]; // changes the 6 vals
    [self updateBrightAndDark]; // gets lightest and darkest
    
    [sampleImages_GC addObject:sample1];
    [sampleImages_GC addObject:sample2];
    [sampleImages_GC addObject:sample3];
    [sampleImages_GC addObject:sample4];
    [sampleImages_GC addObject:sample5];
    [sampleImages_GC addObject:sample6];
    
    
    // Necessary to find where to put the sampled color
    sample1.backgroundColor = _brightestColor_GC;
    sample2.backgroundColor = _darkestColor_GC;
    sample3.backgroundColor = UIColor.whiteColor;
    sample4.backgroundColor = UIColor.whiteColor;
    sample5.backgroundColor = UIColor.whiteColor;
    sample6.backgroundColor = UIColor.whiteColor;
    
    [GreenCornerSamples addObject:_brightestColor_GC];
    [GreenCornerSamples addObject:_darkestColor_GC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    plainImage_GC = originalImage;
    [self updateScrollView:plainImage_GC];
    
    
    // Initializing the Tap Gestures
    singleTap_GC = [[UITapGestureRecognizer alloc]
                    initWithTarget:self
                    action:@selector(handleSingleTapFrom:)];
    singleTap_GC.numberOfTapsRequired = 1;
    [_scrollView addGestureRecognizer:singleTap_GC];
    singleTap_GC.delegate = self;
    
    
    doubleTap_GC = [[UITapGestureRecognizer alloc]
                    initWithTarget:self
                    action:@selector(handleDoubleTapFrom:)];
    doubleTap_GC.numberOfTapsRequired = 2;
    doubleTap_GC.delegate = self;
    
    //Fail to implement single tap if double tap is met
    [singleTap_GC requireGestureRecognizerToFail:doubleTap_GC];
    
    
    // Adding a Double Tap Gesture for all the Sample Views for the Ability to remove
    for( UIImageView * sampleView in sampleImages_GC ){
        UITapGestureRecognizer * doubleTap_GCTEST = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(handleDoubleTapFrom:)];
        doubleTap_GCTEST.numberOfTapsRequired = 2;
        doubleTap_GCTEST.delegate = self;
        [sampleView setUserInteractionEnabled:YES];
        [sampleView addGestureRecognizer: doubleTap_GCTEST];
    }
    
    // Creating Borders
    [self.lightest_GC.layer setBorderWidth:2.0];
    [self.lightest_GC.layer setBorderColor:[UIColor colorWithRed:0.86 green:0.85 blue:0.87 alpha:1.0].CGColor];
    
    [self.darkest_GC.layer setBorderWidth:2.0];
    [self.darkest_GC.layer setBorderColor:[UIColor colorWithRed:0.86 green:0.85 blue:0.87 alpha:1.0].CGColor];
    
    // If we segue from save profile or tile detection, we could have added a new profile
    savedLocationsFromFile_GC= [[savedLocations alloc] init];
    
    // If we segue from Tile Detection, we reset everything
    if( _seguedFromTileDetection == true){
        // Remove all swale samples
        [GreenCornerSamples removeAllObjects];
        
        // Necessary to find where to put the sampled color
        sample3.backgroundColor = UIColor.whiteColor;
        sample4.backgroundColor = UIColor.whiteColor;
        sample5.backgroundColor = UIColor.whiteColor;
        sample6.backgroundColor = UIColor.whiteColor;
        
        [self changeColorSetToIndex:clickedSegment_GC];
        
        // Update First 2 samples as lightest and darkest
        sample1.backgroundColor = _brightestColor_GC;
        sample2.backgroundColor = _darkestColor_GC;
        
        // Adds the brightest and darkest color to swale samples
        [GreenCornerSamples addObject:_brightestColor_GC];
        [GreenCornerSamples addObject:_darkestColor_GC];
        
        _seguedFromTileDetection = false;
    }
    
    [self updateBrightAndDark];
    
}

#pragma -mark Back Button

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"backToAnalysis"])
    {
        analysisViewController *analysisViewController = [segue destinationViewController];
        analysisViewController.currentImage_A = _processedImage;
        analysisViewController.userImage_A = originalImage;
        analysisViewController.clickedSegment_A = clickedSegment_GC;
    }
}
-(void)buttonizeButtonTap:(id)sender{
    [self performSegueWithIdentifier:@"backToAnalysis" sender:sender];
}

- (IBAction)backButton:(id)sender {
    // Make pop up asking if you want to do that because it will delete all of your work
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Are you sure? Going back means you will lose all palettes that were not saved." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    [alert show];
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSLog(@"user pressed Button Indexed 0");
        // Any action can be performed here
    }
    else
    {
        NSLog(@"user pressed Button Indexed 1");
        [self buttonizeButtonTap: self];
        // Any action can be performed here
    }
}

#pragma -mark Update View

/*
 * Update the scroll view
 */
- (void) updateScrollView:(UIImage *) newImg {
    CGFloat zoomScale = self.scrollView.zoomScale;
    CGPoint offset = CGPointMake(self.scrollView.contentOffset.x,self.scrollView.contentOffset.y);
    
    //MAKE SURE THAT IMAGE VIEW IS REMOVED IF IT EXISTS ON SCROLLVIEW!!
    if (img_GC != nil)
    {
        [img_GC removeFromSuperview];
        
    }
    
    img_GC = [[UIImageView alloc] initWithImage:newImg];
    
    //handle pinching in/ pinching out to zoom
    img_GC.userInteractionEnabled = YES;
    img_GC.backgroundColor = [UIColor clearColor];
    img_GC.contentMode =  UIViewContentModeCenter;
    //img.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    self.scrollView.minimumZoomScale=0.5;
    self.scrollView.maximumZoomScale=6.0;
    self.scrollView.contentSize = CGSizeMake(img_GC.frame.size.width+100, img_GC.frame.size.height+100);
    self.scrollView.clipsToBounds = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsVerticalScrollIndicator = true;
    self.scrollView.showsHorizontalScrollIndicator = true;
    
    //Set image on the scrollview
    [self.scrollView addSubview:img_GC];
    self.scrollView.zoomScale = zoomScale;
    self.scrollView.contentOffset = offset;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return img_GC;
}
#pragma -mark sending data
- (NSString*) getColorPaletteLabel{
    return self.dropDown.currentTitle;
}

- (NSMutableArray*) getHighLowVals{
    [_highLowVals_GC removeAllObjects];
    [_highLowVals_GC addObject:[NSString stringWithFormat:@"%d",lowHue_GC]];
    [_highLowVals_GC addObject:[NSString stringWithFormat:@"%d",highHue_GC]];
    [_highLowVals_GC addObject:[NSString stringWithFormat:@"%d",lowSaturation_GC]];
    [_highLowVals_GC addObject:[NSString stringWithFormat:@"%d",highSaturation_GC]];
    [_highLowVals_GC addObject:[NSString stringWithFormat:@"%d",lowVal_GC]];
    [_highLowVals_GC addObject:[NSString stringWithFormat:@"%d",highVal_GC]];
    return _highLowVals_GC;
}

#pragma -mark Handle Taps

- (void) handleSingleTapFrom: (UITapGestureRecognizer *)recognizer
{
    printf("I am single tapping...\n");
    
    CGPoint point =[singleTap_GC locationInView:self.scrollView];
    
    UIColor * color = [self GetCurrentPixelColorAtPoint:point];
    
    // Find the first view that has no color and add the color we found
    for (UIImageView * view in sampleImages_GC) {
        if( [view.backgroundColor isEqual:UIColor.whiteColor]){
            view.backgroundColor = color;
            [GreenCornerSamples addObject:color];
            break;
        }
    }
    
    [self setHighandlowVal_GCues];
    [self updateBrightAndDark];
}

- (void) handleDoubleTapFrom: (UITapGestureRecognizer *) recognizer
{
    printf("I double tapped\n");
    UIView *view = recognizer.view;
    
    Boolean removed = false;
    // Finds the color in the GreenCornerSamples array and removes it
    for (UIColor * color in GreenCornerSamples) {
        if( [color isEqual:view.backgroundColor]){
            [GreenCornerSamples removeObject:color];
            removed = true;
            break;
        }
    }
    
    // Before setting the High and Low values, change to default from picked color set
    [self resetHSV];
    [self setHighandlowVal_GCues];
    [self updateBrightAndDark];
    
    // Remove the color on the view
    view.backgroundColor = UIColor.whiteColor;
}


- (UIColor *) GetCurrentPixelColorAtPoint:(CGPoint)point
{
    // Extract Colour
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    CGContextTranslateCTM(context, -point.x, -point.y);
    [self.scrollView.layer renderInContext:context];
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    return color;
}

- (void) showSamples{
    NSLog(@"In ShowSamples: Samples has %i",GreenCornerSamples.count );
    for( UIColor * color in GreenCornerSamples){
        for (UIImageView * view in sampleImages_GC) {
            if( [view.backgroundColor isEqual:UIColor.whiteColor]){
                view.backgroundColor = color;
                break;
            }
        }
    }
}

#pragma -mark Action Buttons

- (IBAction)removeAll:(id)sender {
    [GreenCornerSamples removeAllObjects];
    for( UIImageView * sample in sampleImages_GC){
        sample.backgroundColor = UIColor.whiteColor;
    }
    if( _threshSwitch.isOn){
        [_threshSwitch setOn:false];
        [self updateScrollView:originalImage];
    }
    [self resetHSV];
    [self updateBrightAndDark];
}

#pragma mark - Threshold Switch
/*
 * This is the method that gets called when we toggle the switch.
 */
- (void)stateChanged:(UISwitch *)switchState
{
    if ([switchState isOn]) {
        [self threshold_image];
    } else {
        [self un_thresh_image];
    }
}

/*
 * Threshold
 */
- (void) threshold_image{
    if (plainImage_GC == nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"No image to threshold!" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    //thresh either the plain image or the median filtered image
    /* thresholds image
     ** colorCases: 0 = green
     **             1 = red
     **             2 = wood
     **             3 = blue
     **             4 = dark green (corner markers) <--
     */
    
    [CVWrapper setSegmentIndex:4];
    [self changeHSVVals];
    
    threshedImage_GC = [CVWrapper thresh:plainImage_GC colorCase: 4];
    //_scrollView.zoomScale = plainImage_GC.scale;
    [self updateScrollView:threshedImage_GC];
}

/*
 * UnThreshold
 */
- (void) un_thresh_image{
    if (img_GC != nil && (img_GC.image != plainImage_GC))
    {
        printf("Reseting to unthreshed image\n");
        [self updateScrollView:plainImage_GC];
    }
}

#pragma -mark HSV Values

/*
 * Gets the integers from hsvValues.txt and sends them to CVWrapper
 */
- (void) setHSVValues {
    int H_Sample;
    int S_Sample;
    int V_Sample;
    
    for( UIColor * color in GreenCornerSamples) {
        const CGFloat* components = CGColorGetComponents(color.CGColor);
        
        int red = components[0]*255.0;
        int green = components[1]*255.0;
        int blue = components[2]*255.0;
        
        [CVWrapper getHSVValuesfromRed:red Green:green Blue:blue H:&H_Sample S:&S_Sample V:&V_Sample];
        
        highHue_GC = ( highHue_GC < H_Sample ) ? H_Sample : highHue_GC ;
        highSaturation_GC = ( highSaturation_GC < S_Sample ) ? S_Sample : highSaturation_GC ;
        highVal_GC = ( highVal_GC < V_Sample ) ? V_Sample : highVal_GC ;
        
        lowHue_GC = ( lowHue_GC > H_Sample ) ? H_Sample : lowHue_GC ;
        lowSaturation_GC = ( lowSaturation_GC > S_Sample ) ? S_Sample : lowSaturation_GC ;
        lowVal_GC = ( lowVal_GC > V_Sample ) ? V_Sample : lowVal_GC;
        
    }
}

/*
 * Changes the HSV Values in CVWrapper
 * Does this change the txt file?
 */
- (void) changeHSVVals{
    /*
     ** colorCases: 0 = green
     **             1 = red
     **             2 = wood
     **             3 = blue
     **             4 = dark green (corner markers) <--
     */
    
    int caseNum = 4;
    int vals[30] = {0};
    [CVWrapper getHSV_Values:vals];
    
    
    // Find the High and Low Values from Samples
    [self setHighandlowVal_GCues];
    
    // changes the values by the CVWrapper
    vals[caseNum * 6] = lowHue_GC;
    vals[caseNum * 6 + 1] = highHue_GC;
    vals[caseNum * 6 + 2] = lowSaturation_GC;
    vals[caseNum * 6 + 3] = highSaturation_GC;
    vals[caseNum * 6 + 4] = lowVal_GC;
    vals[caseNum * 6 + 5] = highVal_GC;
    
    [CVWrapper setHSV_Values:vals];
}

#pragma change HSV Values based on samples

/*
 * Goes through the Array of Colors and sets the High and Low Values of the Hue, Saturation, and Value.
 */
- (void) setHighandlowVal_GCues{
    int H_Sample;
    int S_Sample;
    int V_Sample;
    
    for( UIColor * color in GreenCornerSamples) {
        const CGFloat* components = CGColorGetComponents(color.CGColor);
        
        int red = components[0]*255.0;
        int green = components[1]*255.0;
        int blue = components[2]*255.0;
        
        [CVWrapper getHSVValuesfromRed:red Green:green Blue:blue H:&H_Sample S:&S_Sample V:&V_Sample];
        
        highHue_GC = ( highHue_GC < H_Sample ) ? H_Sample : highHue_GC ;
        highSaturation_GC = ( highSaturation_GC < S_Sample ) ? S_Sample : highSaturation_GC ;
        highVal_GC = ( highVal_GC < V_Sample ) ? V_Sample : highVal_GC ;
        
        lowHue_GC = ( lowHue_GC > H_Sample ) ? H_Sample : lowHue_GC ;
        lowSaturation_GC = ( lowSaturation_GC > S_Sample ) ? S_Sample : lowSaturation_GC ;
        lowVal_GC = ( lowVal_GC > V_Sample ) ? V_Sample : lowVal_GC;
        
    }
}

#pragma Change HSV Values based on Location

#pragma -mark Drop Down Menu
// Number of thins shown in the drop down

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section{
    return [savedLocationsFromFile_GC count];
}


- (void) changeColorSetToIndex: (int)index{
    clickedSegment_GC = index;
    
    [self.dropDown setTitle: [savedLocationsFromFile_GC nameOfObjectAtIndex:index]  forState:UIControlStateNormal];
    
    // Icon == CaseNum
    NSMutableArray * newSetting  = [savedLocationsFromFile_GC getHSVForSavedLocationAtIndex:index Icon:4];
    
    lowHue_GC = [[newSetting objectAtIndex:0] integerValue];
    highHue_GC = [[newSetting objectAtIndex:1] integerValue];
    
    lowSaturation_GC = [[newSetting objectAtIndex:2] integerValue];
    highSaturation_GC = [[newSetting objectAtIndex:3] integerValue];
    
    lowVal_GC = [[newSetting objectAtIndex:4] integerValue];
    highVal_GC = [[newSetting objectAtIndex:5] integerValue];
    
    [self changeHSVVals];
    
    
}

// Called after we save to change the tableview
- (void) changeFromFile{
    savedLocationsFromFile_GC = [savedLocationsFromFile_GC changeFromFile];

}

- (IBAction)dropDownButton:(id)sender {
    /*
    if( self.tableView.hidden == TRUE )
        self.tableView.hidden =  FALSE;
    else
        self.tableView.hidden = TRUE;
     */
}

#pragma -mark Bright and Dark
-(void) updateBrightAndDark{
    
    if( lowHue_GC == 255 && lowSaturation_GC == 255 && lowVal_GC == 255 &&
       highHue_GC == 0 && highSaturation_GC == 0 && highVal_GC == 0){
        // choose a color first
        darkest_GC.backgroundColor = UIColor.whiteColor;
        lightest_GC.backgroundColor = UIColor.whiteColor;
        
        return;
    }
    
    
    
    double R_low;
    double G_low;
    double B_low;
    double R_high;
    double G_high;
    double B_high;
    
    [CVWrapper getRGBValuesFromH:lowHue_GC
                               S:lowSaturation_GC
                               V:lowVal_GC
                               R:&R_low
                               G:&G_low
                               B:&B_low];
    
    [CVWrapper getRGBValuesFromH:highHue_GC
                               S:highSaturation_GC
                               V:highVal_GC
                               R:&R_high
                               G:&G_high
                               B:&B_high];
    _darkestColor_GC = [[UIColor alloc] initWithRed:R_low/255.0
                                              green:G_low/255.0
                                               blue:B_low/255.0
                                              alpha:1];
    darkest_GC.backgroundColor = _darkestColor_GC;
    
    _brightestColor_GC = [[UIColor alloc] initWithRed:R_high/255.0
                                                green:G_high/255.0
                                                 blue:B_high/255.0
                                                alpha:1];
    lightest_GC.backgroundColor = _brightestColor_GC;
    
}

- (void) resetHSV{
    lowHue_GC = 255;
    highHue_GC = 0;
    
    lowSaturation_GC = 255;
    highSaturation_GC = 0;
    
    lowVal_GC = 255;
    highVal_GC = 0;
}

@end

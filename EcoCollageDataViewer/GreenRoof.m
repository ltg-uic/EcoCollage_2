//
//  PermeablePaver.m
//  Trial_1
//
//  Created by Jamie Auza on 5/20/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import "GreenRoof.h"
#import "CVWrapper.h"
#import "Coordinate.h"
#import "savedLocations.h"
#import "analysisViewController.h"
#import <math.h>
#import <stdlib.h>

@implementation GreenRoof

UITapGestureRecognizer * singleTap_GR; // tap that recognizes color extraction
UITapGestureRecognizer * doubleTap_GR; // tap that recognizes removal of sample

UIImage* plainImage_GR = nil;
UIImageView * img_GR;
UIImage* threshedImage_GR = nil;

NSMutableArray * GreenRoofSamples;
NSMutableArray * sampleImages_GR;
NSMutableArray* greenRoofCoordinatesCalibrated;

int highHue_GR, highSaturation_GR, highVal_GR;
int lowHue_GR, lowSaturation_GR, lowVal_GR;
savedLocations* savedLocationsFromFile_GR;

@synthesize sample1;
@synthesize sample2;
@synthesize sample3;
@synthesize sample4;
@synthesize sample5;
@synthesize sample6;
@synthesize lightest_GR;
@synthesize darkest_GR;
@synthesize viewIconSwitch;


UIImage* greenRoofIcon2 = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initializing the switch
    [self.threshSwitch addTarget:self
                          action:@selector(stateChanged:) forControlEvents:UIControlEventValueChanged];
    _threshSwitch.on = false;
    
    // Set Default HSV Values
    [self setHSVValues];
    
    savedLocationsFromFile_GR = [[savedLocations alloc] init];
    
    
    
    
    // Switch to see icons
    [viewIconSwitch addTarget:self
                       action:@selector(stateChangedViewIcon:) forControlEvents:UIControlEventValueChanged];
    
    greenRoofIcon2 = [UIImage imageNamed:@"greenroof_outline.png"];
    
    // Back Button
    UIBarButtonItem *buttonizeButton = [[UIBarButtonItem alloc] initWithTitle:@"Buttonize"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(buttonizeButtonTap:)];
    self.navigationItem.rightBarButtonItems = @[buttonizeButton];
    
    // To send data to save screen
    _highLowVals_GR = [[NSMutableArray alloc]init];
    
    
    
    GreenRoofSamples = [NSMutableArray array];
    sampleImages_GR = [NSMutableArray array];
    
    [self changeColorSetToIndex:_clickedSegment_GR]; // changes the 6 vals
    [self updateBrightAndDark]; // gets lightest and darkest
    
    [sampleImages_GR addObject:sample1];
    [sampleImages_GR addObject:sample2];
    [sampleImages_GR addObject:sample3];
    [sampleImages_GR addObject:sample4];
    [sampleImages_GR addObject:sample5];
    [sampleImages_GR addObject:sample6];
    
    
    // Necessary to find where to put the sampled color
    sample1.backgroundColor = _brightestColor_GR;
    sample2.backgroundColor = _darkestColor_GR;
    sample3.backgroundColor = UIColor.whiteColor;
    sample4.backgroundColor = UIColor.whiteColor;
    sample5.backgroundColor = UIColor.whiteColor;
    sample6.backgroundColor = UIColor.whiteColor;
    
    [GreenRoofSamples addObject:_brightestColor_GR];
    [GreenRoofSamples addObject:_darkestColor_GR];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    plainImage_GR = _currentImage_GR;
    
    [self updateScrollView:_currentImage_GR];
    
    
    // Initializing the Tap Gestures
    singleTap_GR = [[UITapGestureRecognizer alloc]
                   initWithTarget:self
                   action:@selector(handleSingleTapFrom:)];
    singleTap_GR.numberOfTapsRequired = 1;
    [_scrollView addGestureRecognizer:singleTap_GR];
    singleTap_GR.delegate = self;
    
    
    doubleTap_GR = [[UITapGestureRecognizer alloc]
                   initWithTarget:self
                   action:@selector(handleDoubleTapFrom:)];
    doubleTap_GR.numberOfTapsRequired = 2;
    doubleTap_GR.delegate = self;
    
    //Fail to implement single tap if double tap is met
    [singleTap_GR requireGestureRecognizerToFail:doubleTap_GR];
    
    
    // Adding a Double Tap Gesture for all the Sample Views for the Ability to remove
    for( UIImageView * sampleView in sampleImages_GR ){
        UITapGestureRecognizer * doubleTap_GRTEST = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handleDoubleTapFrom:)];
        doubleTap_GRTEST.numberOfTapsRequired = 2;
        doubleTap_GRTEST.delegate = self;
        [sampleView setUserInteractionEnabled:YES];
        [sampleView addGestureRecognizer: doubleTap_GRTEST];
    }
    
    // Creating Borders
    [self.lightest_GR.layer setBorderWidth:2.0];
    [self.lightest_GR.layer setBorderColor:[UIColor colorWithRed:0.86 green:0.85 blue:0.87 alpha:1.0].CGColor];
    
    [self.darkest_GR.layer setBorderWidth:2.0];
    [self.darkest_GR.layer setBorderColor:[UIColor colorWithRed:0.86 green:0.85 blue:0.87 alpha:1.0].CGColor];
    
    // If we segue from save profile or tile detection, we could have added a new profile
    savedLocationsFromFile_GR= [[savedLocations alloc] init];
    
    // If we segue from Tile Detection, we reset everything
    if( _seguedFromTileDetection == true){
        // Remove all swale samples
        [GreenRoofSamples removeAllObjects];
        
        // Necessary to find where to put the sampled color
        sample3.backgroundColor = UIColor.whiteColor;
        sample4.backgroundColor = UIColor.whiteColor;
        sample5.backgroundColor = UIColor.whiteColor;
        sample6.backgroundColor = UIColor.whiteColor;
        
        [self changeColorSetToIndex:_clickedSegment_GR];
        
        // Update First 2 samples as lightest and darkest
        sample1.backgroundColor = _brightestColor_GR;
        sample2.backgroundColor = _darkestColor_GR;
        
        // Adds the brightest and darkest color to swale samples
        [GreenRoofSamples addObject:_brightestColor_GR];
        [GreenRoofSamples addObject:_darkestColor_GR];
        
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
        analysisViewController.currentImage_A = _currentImage_GR;
        analysisViewController.userImage_A = _originalImage_GR;
        analysisViewController.groupNumber = self.groupNumber;
        analysisViewController.IPAddress = self.IPAddress;
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
#pragma -mark sending data
- (NSString*) getColorPaletteLabel{
    return self.dropDown.currentTitle;
}

- (NSMutableArray*) getHighLowVals{
    [_highLowVals_GR removeAllObjects];
    [_highLowVals_GR addObject:[NSString stringWithFormat:@"%d",lowHue_GR]];
    [_highLowVals_GR addObject:[NSString stringWithFormat:@"%d",highHue_GR]];
    [_highLowVals_GR addObject:[NSString stringWithFormat:@"%d",lowSaturation_GR]];
    [_highLowVals_GR addObject:[NSString stringWithFormat:@"%d",highSaturation_GR]];
    [_highLowVals_GR addObject:[NSString stringWithFormat:@"%d",lowVal_GR]];
    [_highLowVals_GR addObject:[NSString stringWithFormat:@"%d",highVal_GR]];
    return _highLowVals_GR;
}


#pragma -mark View Icons Switch
- (void)stateChangedViewIcon:(UISwitch *)switchState
{
    if( switchState.isOn ){
        if( _threshSwitch.isOn)
            [_threshSwitch setOn:false];
        
        UIGraphicsBeginImageContext(_currentImage_GR.size);
        [_currentImage_GR drawInRect:CGRectMake(0, 0, _currentImage_GR.size.width, _currentImage_GR.size.height)];
        NSLog(@"stateChangedViewIcon -- Begin");
        
        // Use the new HSV Values
        [self changeHSVVals];
        NSLog(@"stateChangedViewIcon -- AFTER WE CHANGE THE HSV VALUES");
        int HSV_values[30];
        [CVWrapper getHSV_Values:HSV_values];
        
        for( int x = 0; x < 30 ; x++)
            NSLog(@"HSV VAL -- %i", HSV_values[x]);
        NSLog(@"stateChangedViewIcon -- AFTER WE CHANGE THE HSV VALUES");
        char resultafter[5000];
        [CVWrapper analysis:_currentImage_GR studyNumber: 0 trialNumber:0 results:resultafter];
        
        
        greenRoofCoordinatesCalibrated = [CVWrapper getGreenRoofCoordinates];
        NSLog(@"There are %i permeable pavers detected" , greenRoofCoordinatesCalibrated.count);
        [self drawIconsInArray:greenRoofCoordinatesCalibrated image:greenRoofIcon2];
        
        UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self updateScrollView:result];
        NSLog(@"stateChangedViewIcon -- End ");
    } else {
        [self updateScrollView:_currentImage_GR];
    }
    
}

-(void) drawIconsInArray:(NSMutableArray *)iconArray image:(UIImage*)iconImage{
    CGFloat squareWidth = _currentImage_GR.size.width/23;
    CGFloat squareHeight = _currentImage_GR.size.height/25;
    for( Coordinate * coord in iconArray){
        [iconImage drawInRect:CGRectMake( coord.getX * squareWidth,
                                         _currentImage_GR.size.height - ( coord.getY + 1 ) * squareHeight,
                                         squareWidth, squareHeight)];
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
    if (img_GR != nil)
    {
        [img_GR removeFromSuperview];
        
    }
    
    img_GR = [[UIImageView alloc] initWithImage:newImg];
    
    
    
    //handle pinching in/ pinching out to zoom
    img_GR.userInteractionEnabled = YES;
    img_GR.backgroundColor = [UIColor clearColor];
    img_GR.contentMode =  UIViewContentModeCenter;
    //img.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    self.scrollView.minimumZoomScale=0.5;
    self.scrollView.maximumZoomScale=6.0;
    self.scrollView.contentSize = CGSizeMake(img_GR.frame.size.width+100, img_GR.frame.size.height+100);
    self.scrollView.clipsToBounds = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsVerticalScrollIndicator = true;
    self.scrollView.showsHorizontalScrollIndicator = true;
    
    
    //Set image on the scrollview
    [self.scrollView addSubview:img_GR];
    self.scrollView.zoomScale = zoomScale;
    self.scrollView.contentOffset = offset;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return img_GR;
}


#pragma -mark Handle Taps

- (void) handleSingleTapFrom: (UITapGestureRecognizer *)recognizer
{
    printf("I am single tapping...\n");
    
    CGPoint point =[singleTap_GR locationInView:self.scrollView];
    
    UIColor * color = [self GetCurrentPixelColorAtPoint:point];
    
    // Find the first view that has no color and add the color we found
    for (UIImageView * view in sampleImages_GR) {
        if( [view.backgroundColor isEqual:UIColor.whiteColor]){
            view.backgroundColor = color;
            [GreenRoofSamples addObject:color];
            break;
        }
    }
    
    [self setHighandlowVal_GRues];
    [self updateBrightAndDark];
}

- (void) handleDoubleTapFrom: (UITapGestureRecognizer *) recognizer
{
    printf("I double tapped\n");
    UIView *view = recognizer.view;
    
    Boolean removed = false;
    // Finds the color in the GreenRoofSamples array and removes it
    for (UIColor * color in GreenRoofSamples) {
        if( [color isEqual:view.backgroundColor]){
            [GreenRoofSamples removeObject:color];
            printf("Removed a color\n");
            printf("Permeable Pavers has %i things", GreenRoofSamples.count);
            removed = true;
            break;
        }
    }
    
    // Before setting the High and Low values, change to default from picked color set
    [self resetHSV];
    [self setHighandlowVal_GRues];
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
    NSLog(@"In ShowSamples: Samples has %i",GreenRoofSamples.count );
    for( UIColor * color in GreenRoofSamples){
        for (UIImageView * view in sampleImages_GR) {
            if( [view.backgroundColor isEqual:UIColor.whiteColor]){
                view.backgroundColor = color;
                break;
            }
        }
    }
}

#pragma -mark Action Buttons

- (IBAction)removeAll:(id)sender {
    [GreenRoofSamples removeAllObjects];
    for( UIImageView * sample in sampleImages_GR){
        sample.backgroundColor = UIColor.whiteColor;
    }
    if( _threshSwitch.isOn || viewIconSwitch.isOn){
        [_threshSwitch setOn:false];
        [viewIconSwitch setOn:false];
        [self updateScrollView:_currentImage_GR];
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
        if( viewIconSwitch.isOn)
            [viewIconSwitch setOn:false];
        
        [self threshold_image];
    } else {
        [self un_thresh_image];
    }
}

/*
 * Threshold
 */
- (void) threshold_image{
    if (plainImage_GR == nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"No image to threshold!" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    //thresh either the plain image or the median filtered image
    /* thresholds image
     ** colorCases: 0 = green
     **             1 = red
     **             2 = wood <--
     **             3 = blue
     **             4 = dark green (corner markers)
     */
    
    [CVWrapper setSegmentIndex:2];
    [self changeHSVVals];
    
    threshedImage_GR = [CVWrapper thresh:plainImage_GR colorCase: 2];
    [self updateScrollView:threshedImage_GR];
}

/*
 * UnThreshold
 */
- (void) un_thresh_image{
    if (img_GR != nil && (img_GR.image != plainImage_GR))
    {
        printf("Reseting to unthreshed image\n");
        [self updateScrollView:plainImage_GR];
    }
}

#pragma -mark HSV Values

/*
 * Gets the integers from hsvValues.txt and sends them to CVWrapper
 */
- (void) setHSVValues {
    int hsvValues[30];
    [CVWrapper getHSV_Values:hsvValues];
    
    NSError *error;
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"hsvValues"];
    fileName = [fileName stringByAppendingPathExtension:@"txt"];
    
    NSString* content = [NSString stringWithContentsOfFile:fileName
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    
    // if file reading creates an error, set values to default
    if(error) {
        NSLog(@"File reading error: default hsv values loaded");
        int hsvDefault[] = {10, 80, 50, 200, 50, 255,       // Green (Swale)
             120,115,182,97,240,121,         // Red (Rain Barrel
            90, 110, 40, 100, 120, 225,     // Brown (Green Roof)
            0, 15, 30, 220, 50, 210,        // Blue (Permeable Paver)
            15, 90, 35, 200, 35, 130};      // Dark Green (Corner Markers)
        [CVWrapper setHSV_Values:hsvDefault];
        return;
    }
    
    NSLog(@"Reading from hsvValues.txt from setHSVValues: %@", content);
    
    NSArray *arr = [content componentsSeparatedByString:@" "];
    
    int i;
    for(i = 0; i < 30; i++) {
        // loss of precision is fine since all numbers stored in arr will have only zeroes after the decimal
        hsvValues[i] = [[arr objectAtIndex:i]integerValue];
    }
    
    [CVWrapper setHSV_Values:hsvValues];
}

/*
 * Changes the HSV Values in CVWrapper
 * Does this change the txt file?
 */
- (void) changeHSVVals{
    /*
     ** colorCases: 0 = green
     **             1 = red
     **             2 = wood <--
     **             3 = blue
     **             4 = dark green (corner markers)
     */
    
    int caseNum = 2;
    int vals[30] = {0};
    [CVWrapper getHSV_Values:vals];
    

    
    // Find the High and Low Values from Samples
    [self setHighandlowVal_GRues];
    
    // changes the values by the CVWrapper
    vals[caseNum * 6] = lowHue_GR;
    vals[caseNum * 6 + 1] = highHue_GR;
    vals[caseNum * 6 + 2] = lowSaturation_GR;
    vals[caseNum * 6 + 3] = highSaturation_GR;
    vals[caseNum * 6 + 4] = lowVal_GR;
    vals[caseNum * 6 + 5] = highVal_GR;
    
    [CVWrapper setHSV_Values:vals];
}

#pragma change HSV Values based on samples

/*
 * Goes through the Array of Colors and sets the High and Low Values of the Hue, Saturation, and Value.
 */
- (void) setHighandlowVal_GRues{
    int H_Sample;
    int S_Sample;
    int V_Sample;
    
    for( UIColor * color in GreenRoofSamples) {
        const CGFloat* components = CGColorGetComponents(color.CGColor);
        
        int red = components[0]*255.0;
        int green = components[1]*255.0;
        int blue = components[2]*255.0;
        
        [CVWrapper getHSVValuesfromRed:red Green:green Blue:blue H:&H_Sample S:&S_Sample V:&V_Sample];
        
        highHue_GR = ( highHue_GR < H_Sample ) ? H_Sample : highHue_GR ;
        highSaturation_GR = ( highSaturation_GR < S_Sample ) ? S_Sample : highSaturation_GR ;
        highVal_GR = ( highVal_GR < V_Sample ) ? V_Sample : highVal_GR ;
        
        lowHue_GR = ( lowHue_GR > H_Sample ) ? H_Sample : lowHue_GR ;
        lowSaturation_GR = ( lowSaturation_GR > S_Sample ) ? S_Sample : lowSaturation_GR ;
        lowVal_GR = ( lowVal_GR > V_Sample ) ? V_Sample : lowVal_GR;
        
    }
}

- (void) setNoDefault{
    lowHue_GR = 225;
    highHue_GR = 0;
    
    lowSaturation_GR = 225;
    highSaturation_GR = 0;
    
    lowVal_GR = 225;
    highVal_GR = 0;
}

- (void) setDefaultHSV{
    
    lowHue_GR = 10;
    highHue_GR = 80;
    
    lowSaturation_GR = 50;
    highSaturation_GR = 200;
    
    lowVal_GR = 50;
    highVal_GR = 255;
}

#pragma Change HSV Values based on Location

- (void) changeColorSetToIndex: (int)index{
    
    [self.dropDown setTitle: [savedLocationsFromFile_GR nameOfObjectAtIndex:_clickedSegment_GR]  forState:UIControlStateNormal];
    
    // Icon == CaseNum
    NSMutableArray * newSetting  = [savedLocationsFromFile_GR getHSVForSavedLocationAtIndex:index Icon:2];
    
    lowHue_GR = [[newSetting objectAtIndex:0] integerValue];
    highHue_GR = [[newSetting objectAtIndex:1] integerValue];
    
    lowSaturation_GR = [[newSetting objectAtIndex:2] integerValue];
    highSaturation_GR = [[newSetting objectAtIndex:3] integerValue];
    
    lowVal_GR = [[newSetting objectAtIndex:4] integerValue];
    highVal_GR = [[newSetting objectAtIndex:5] integerValue];
    
    NSLog(@"lowHue_GR is %i", lowHue_GR);
    
    [self changeHSVVals];
    
}

// Called after we save to change the tableview
- (void) changeFromFile{
    savedLocationsFromFile_GR = [savedLocationsFromFile_GR changeFromFile];
}

#pragma -mark Bright and Dark
-(void) updateBrightAndDark{
    
    if( lowHue_GR == 255 && lowSaturation_GR == 255 && lowVal_GR == 255 &&
       highHue_GR == 0 && highSaturation_GR == 0 && highVal_GR == 0){
        // choose a color first
        darkest_GR.backgroundColor = UIColor.whiteColor;
        lightest_GR.backgroundColor = UIColor.whiteColor;
        
        return;
    }
    
    
    
    double R_low;
    double G_low;
    double B_low;
    double R_high;
    double G_high;
    double B_high;
    
    [CVWrapper getRGBValuesFromH:lowHue_GR
                               S:lowSaturation_GR
                               V:lowVal_GR
                               R:&R_low
                               G:&G_low
                               B:&B_low];
    
    [CVWrapper getRGBValuesFromH:highHue_GR
                               S:highSaturation_GR
                               V:highVal_GR
                               R:&R_high
                               G:&G_high
                               B:&B_high];
    _darkestColor_GR = [[UIColor alloc] initWithRed:R_low/255.0
                                             green:G_low/255.0
                                              blue:B_low/255.0
                                             alpha:1];
    darkest_GR.backgroundColor = _darkestColor_GR;
    
    _brightestColor_GR = [[UIColor alloc] initWithRed:R_high/255.0
                                               green:G_high/255.0
                                                blue:B_high/255.0
                                               alpha:1];
    lightest_GR.backgroundColor = _brightestColor_GR;
    
}

-(void) resetHSV{
    lowHue_GR = 255;
    highHue_GR = 0;
    lowSaturation_GR = 255;
    highSaturation_GR = 0;
    lowVal_GR = 255;
    highVal_GR = 0;
}

- (IBAction)dropDownButton:(id)sender {
    /*
    if( self.tableView.hidden == TRUE )
        self.tableView.hidden =  FALSE;
    else
        self.tableView.hidden = TRUE;
    */
}



@end

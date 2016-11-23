//
//  PermeablePaver.m
//  Trial_1
//
//  Created by Jamie Auza on 5/20/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import "PermeablePaver.h"
#import "CVWrapper.h"
#import "Coordinate.h"
#import "savedLocations.h"
#import "analysisViewController.h"
#import <math.h>
#import <stdlib.h>

@implementation PermeablePaver

UITapGestureRecognizer * singleTap_PP; // tap that recognizes color extraction
UITapGestureRecognizer * doubleTap_PP; // tap that recognizes removal of sample

UIImage* plainImage_PP = nil;
UIImageView * img_PP;
UIImage* threshedImage_PP = nil;

NSMutableArray * PermeablePaverSamples;
NSMutableArray * sampleImages_PP;
NSMutableArray* permeablePaverCoordinatesCalibrated;

int highHue_PP, highSaturation_PP, highVal_PP;
int lowHue_PP, lowSaturation_PP, lowVal_PP;
savedLocations* savedLocationsFromFile_PP;

@synthesize sample1;
@synthesize sample2;
@synthesize sample3;
@synthesize sample4;
@synthesize sample5;
@synthesize sample6;
@synthesize lightest_PP;
@synthesize darkest_PP;
@synthesize viewIconSwitch;
@synthesize clickedSegment_PP;

UIImage* permeablePaverIcon2 = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initializing the switch
    [self.threshSwitch addTarget:self
                          action:@selector(stateChanged:) forControlEvents:UIControlEventValueChanged];
    _threshSwitch.on = false;
    
    // Set Default HSV Values
    [self setHSVValues];
    
    savedLocationsFromFile_PP = [[savedLocations alloc] init];
    
    
    
    
    // Switch to see icons
    [viewIconSwitch addTarget:self
                       action:@selector(stateChangedViewIcon:) forControlEvents:UIControlEventValueChanged];
    
    permeablePaverIcon2 = [UIImage imageNamed:@"permeablepaver_outline.png"];
    
    // Back Button
    UIBarButtonItem *buttonizeButton = [[UIBarButtonItem alloc] initWithTitle:@"Buttonize"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(buttonizeButtonTap:)];
    self.navigationItem.rightBarButtonItems = @[buttonizeButton];
    
    // To send data to save screen
    _highLowVals_PP = [[NSMutableArray alloc]init];
    
    
    
    PermeablePaverSamples = [NSMutableArray array];
    sampleImages_PP = [NSMutableArray array];
    
    [self changeColorSetToIndex:(int)clickedSegment_PP]; // changes the 6 vals
    [self updateBrightAndDark]; // gets lightest and darkest
    
    [sampleImages_PP addObject:sample1];
    [sampleImages_PP addObject:sample2];
    [sampleImages_PP addObject:sample3];
    [sampleImages_PP addObject:sample4];
    [sampleImages_PP addObject:sample5];
    [sampleImages_PP addObject:sample6];
    
    
    // Necessary to find where to put the sampled color
    sample1.backgroundColor = _brightestColor_PP;
    sample2.backgroundColor = _darkestColor_PP;
    sample3.backgroundColor = UIColor.whiteColor;
    sample4.backgroundColor = UIColor.whiteColor;
    sample5.backgroundColor = UIColor.whiteColor;
    sample6.backgroundColor = UIColor.whiteColor;
    
    [PermeablePaverSamples addObject:_brightestColor_PP];
    [PermeablePaverSamples addObject:_darkestColor_PP];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    plainImage_PP = _currentImage_PP;
    
    [self updateScrollView:_currentImage_PP];
    
    
    // Initializing the Tap Gestures
    singleTap_PP = [[UITapGestureRecognizer alloc]
                    initWithTarget:self
                    action:@selector(handleSingleTapFrom:)];
    singleTap_PP.numberOfTapsRequired = 1;
    [_scrollView addGestureRecognizer:singleTap_PP];
    singleTap_PP.delegate = self;
    
    
    doubleTap_PP = [[UITapGestureRecognizer alloc]
                    initWithTarget:self
                    action:@selector(handleDoubleTapFrom:)];
    doubleTap_PP.numberOfTapsRequired = 2;
    doubleTap_PP.delegate = self;
    
    //Fail to implement single tap if double tap is met
    [singleTap_PP requireGestureRecognizerToFail:doubleTap_PP];
    
    
    // Adding a Double Tap Gesture for all the Sample Views for the Ability to remove
    for( UIImageView * sampleView in sampleImages_PP ){
        UITapGestureRecognizer * doubleTap_PPTEST = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(handleDoubleTapFrom:)];
        doubleTap_PPTEST.numberOfTapsRequired = 2;
        doubleTap_PPTEST.delegate = self;
        [sampleView setUserInteractionEnabled:YES];
        [sampleView addGestureRecognizer: doubleTap_PPTEST];
    }
    
    // Creating Borders
    [self.lightest_PP.layer setBorderWidth:2.0];
    [self.lightest_PP.layer setBorderColor:[UIColor colorWithRed:0.86 green:0.85 blue:0.87 alpha:1.0].CGColor];
    
    [self.darkest_PP.layer setBorderWidth:2.0];
    [self.darkest_PP.layer setBorderColor:[UIColor colorWithRed:0.86 green:0.85 blue:0.87 alpha:1.0].CGColor];
    
    // If we segue from save profile or tile detection, we could have added a new profile
    savedLocationsFromFile_PP= [[savedLocations alloc] init];
    
    // If we segue from Tile Detection, we reset everything
    if( _seguedFromTileDetection == true){
        // Remove all swale samples
        [PermeablePaverSamples removeAllObjects];
        
        // Necessary to find where to put the sampled color
        sample3.backgroundColor = UIColor.whiteColor;
        sample4.backgroundColor = UIColor.whiteColor;
        sample5.backgroundColor = UIColor.whiteColor;
        sample6.backgroundColor = UIColor.whiteColor;
        
        [self changeColorSetToIndex:clickedSegment_PP];
        
        // Update First 2 samples as lightest and darkest
        sample1.backgroundColor = _brightestColor_PP;
        sample2.backgroundColor = _darkestColor_PP;
        
        // Adds the brightest and darkest color to swale samples
        [PermeablePaverSamples addObject:_brightestColor_PP];
        [PermeablePaverSamples addObject:_darkestColor_PP];
        
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
        analysisViewController.currentImage_A = _currentImage_PP;
        analysisViewController.userImage_A = _originalImage_PP;
        analysisViewController.clickedSegment_A = clickedSegment_PP;
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

#pragma -mark View Icons Switch
- (void)stateChangedViewIcon:(UISwitch *)switchState
{
    if( switchState.isOn ){
        if( _threshSwitch.isOn)
            [_threshSwitch setOn:false];
        
        UIGraphicsBeginImageContext(_currentImage_PP.size);
        [_currentImage_PP drawInRect:CGRectMake(0, 0, _currentImage_PP.size.width, _currentImage_PP.size.height)];
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
        [CVWrapper analysis:_currentImage_PP studyNumber: 0 trialNumber:0 results:resultafter];
        
        
        permeablePaverCoordinatesCalibrated = [CVWrapper getPermeablePaverCoordinates];
        NSLog(@"There are %lu permeable pavers detected" , (unsigned long)permeablePaverCoordinatesCalibrated.count);
        [self drawIconsInArray:permeablePaverCoordinatesCalibrated image:permeablePaverIcon2];
        
        UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self updateScrollView:result];
        NSLog(@"stateChangedViewIcon -- End ");
    } else {
        [self updateScrollView:_currentImage_PP];
    }
    
}

-(void) drawIconsInArray:(NSMutableArray *)iconArray image:(UIImage*)iconImage{
    CGFloat squareWidth = _currentImage_PP.size.width/23;
    CGFloat squareHeight = _currentImage_PP.size.height/25;
    for( Coordinate * coord in iconArray){
        [iconImage drawInRect:CGRectMake( coord.getX * squareWidth,
                                         _currentImage_PP.size.height - ( coord.getY + 1 ) * squareHeight,
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
    if (img_PP != nil)
    {
        [img_PP removeFromSuperview];
        
    }
    
    img_PP = [[UIImageView alloc] initWithImage:newImg];
    
    //handle pinching in/ pinching out to zoom
    img_PP.userInteractionEnabled = YES;
    img_PP.backgroundColor = [UIColor clearColor];
    img_PP.contentMode =  UIViewContentModeCenter;
    //img.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    self.scrollView.minimumZoomScale=0.5;
    self.scrollView.maximumZoomScale=6.0;
    self.scrollView.contentSize = CGSizeMake(img_PP.frame.size.width+100, img_PP.frame.size.height+100);
    self.scrollView.clipsToBounds = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsVerticalScrollIndicator = true;
    self.scrollView.showsHorizontalScrollIndicator = true;
    
    
    //Set image on the scrollview
    [self.scrollView addSubview:img_PP];
    self.scrollView.zoomScale = zoomScale;
    self.scrollView.contentOffset = offset;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return img_PP;
}
#pragma -mark sending data
- (NSString*) getColorPaletteLabel{
    return self.dropDown.currentTitle;
}

- (NSMutableArray*) getHighLowVals{
    [_highLowVals_PP removeAllObjects];
    [_highLowVals_PP addObject:[NSString stringWithFormat:@"%d",lowHue_PP]];
    [_highLowVals_PP addObject:[NSString stringWithFormat:@"%d",highHue_PP]];
    [_highLowVals_PP addObject:[NSString stringWithFormat:@"%d",lowSaturation_PP]];
    [_highLowVals_PP addObject:[NSString stringWithFormat:@"%d",highSaturation_PP]];
    [_highLowVals_PP addObject:[NSString stringWithFormat:@"%d",lowVal_PP]];
    [_highLowVals_PP addObject:[NSString stringWithFormat:@"%d",highVal_PP]];
    return _highLowVals_PP;
}

#pragma -mark Handle Taps

- (void) handleSingleTapFrom: (UITapGestureRecognizer *)recognizer
{
    printf("I am single tapping...\n");
    
    CGPoint point =[singleTap_PP locationInView:self.scrollView];
    
    UIColor * color = [self GetCurrentPixelColorAtPoint:point];
    
    // Find the first view that has no color and add the color we found
    for (UIImageView * view in sampleImages_PP) {
        if( [view.backgroundColor isEqual:UIColor.whiteColor]){
            view.backgroundColor = color;
            [PermeablePaverSamples addObject:color];
            break;
        }
    }
    
    [self setHighandlowVal_PPues];
    [self updateBrightAndDark];
}

- (void) handleDoubleTapFrom: (UITapGestureRecognizer *) recognizer
{
    printf("I double tapped\n");
    UIView *view = recognizer.view;
    
    Boolean removed = false;
    // Finds the color in the PermeablePaverSamples array and removes it
    for (UIColor * color in PermeablePaverSamples) {
        if( [color isEqual:view.backgroundColor]){
            [PermeablePaverSamples removeObject:color];
            printf("Removed a color\n");
            printf("Permeable Pavers has %lu things", (unsigned long)PermeablePaverSamples.count);
            removed = true;
            break;
        }
    }
    
    // Before setting the High and Low values, change to default from picked color set
    [self resetHSV];
    [self setHighandlowVal_PPues];
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
    NSLog(@"In ShowSamples: Samples has %lu",(unsigned long)PermeablePaverSamples.count );
    for( UIColor * color in PermeablePaverSamples){
        for (UIImageView * view in sampleImages_PP) {
            if( [view.backgroundColor isEqual:UIColor.whiteColor]){
                view.backgroundColor = color;
                break;
            }
        }
    }
}

#pragma -mark Action Buttons

- (IBAction)removeAll:(id)sender {
    [PermeablePaverSamples removeAllObjects];
    for( UIImageView * sample in sampleImages_PP){
        sample.backgroundColor = UIColor.whiteColor;
    }
    if( _threshSwitch.isOn || viewIconSwitch.isOn){
        [_threshSwitch setOn:false];
        [viewIconSwitch setOn:false];
        [self updateScrollView:_currentImage_PP];
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
    if (plainImage_PP == nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"No image to threshold!" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    //thresh either the plain image or the median filtered image
    /* thresholds image
     ** colorCases: 0 = green
     **             1 = red
     **             2 = wood
     **             3 = blue <--
     **             4 = dark green (corner markers)
     */
    
    [CVWrapper setSegmentIndex:3];
    [self changeHSVVals];
    
    threshedImage_PP = [CVWrapper thresh:plainImage_PP colorCase: 3];
    //_scrollView.zoomScale = plainImage_PP.scale;
    [self updateScrollView:threshedImage_PP];
}

/*
 * UnThreshold
 */
- (void) un_thresh_image{
    if (img_PP != nil && (img_PP.image != plainImage_PP))
    {
        printf("Reseting to unthreshed image\n");
        [self updateScrollView:plainImage_PP];
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
        hsvValues[i] = (int)[[arr objectAtIndex:i] integerValue];
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
     **             2 = wood
     **             3 = blue <--
     **             4 = dark green (corner markers)
     */
    
    int caseNum = 3;
    int vals[30] = {0};
    [CVWrapper getHSV_Values:vals];
    
    
    // Find the High and Low Values from Samples
    [self setHighandlowVal_PPues];
    
    // changes the values by the CVWrapper
    vals[caseNum * 6] = lowHue_PP;
    vals[caseNum * 6 + 1] = highHue_PP;
    vals[caseNum * 6 + 2] = lowSaturation_PP;
    vals[caseNum * 6 + 3] = highSaturation_PP;
    vals[caseNum * 6 + 4] = lowVal_PP;
    vals[caseNum * 6 + 5] = highVal_PP;
    
    [CVWrapper setHSV_Values:vals];
}

#pragma change HSV Values based on samples

/*
 * Goes through the Array of Colors and sets the High and Low Values of the Hue, Saturation, and Value.
 */
- (void) setHighandlowVal_PPues{
    int H_Sample;
    int S_Sample;
    int V_Sample;
    
    for( UIColor * color in PermeablePaverSamples) {
        const CGFloat* components = CGColorGetComponents(color.CGColor);
        
        int red = components[0]*255.0;
        int green = components[1]*255.0;
        int blue = components[2]*255.0;
        
        [CVWrapper getHSVValuesfromRed:red Green:green Blue:blue H:&H_Sample S:&S_Sample V:&V_Sample];
        
        highHue_PP = ( highHue_PP < H_Sample ) ? H_Sample : highHue_PP ;
        highSaturation_PP = ( highSaturation_PP < S_Sample ) ? S_Sample : highSaturation_PP ;
        highVal_PP = ( highVal_PP < V_Sample ) ? V_Sample : highVal_PP ;
        
        lowHue_PP = ( lowHue_PP > H_Sample ) ? H_Sample : lowHue_PP ;
        lowSaturation_PP = ( lowSaturation_PP > S_Sample ) ? S_Sample : lowSaturation_PP ;
        lowVal_PP = ( lowVal_PP > V_Sample ) ? V_Sample : lowVal_PP;
        
    }
}

- (void) resetHSV{
    lowHue_PP = 255;
    highHue_PP = 0;
    
    lowSaturation_PP = 255;
    highSaturation_PP = 0;
    
    lowVal_PP = 255;
    highVal_PP = 0;
}

#pragma Change HSV Values based on Location

#pragma -mark Drop Down Menu

- (void) changeColorSetToIndex: (int)index{
    clickedSegment_PP = index;
    
    [self.dropDown setTitle: [savedLocationsFromFile_PP nameOfObjectAtIndex:index]  forState:UIControlStateNormal];
    
    // Icon == CaseNum
    NSMutableArray * newSetting  = [savedLocationsFromFile_PP getHSVForSavedLocationAtIndex:index Icon:3];
    
    lowHue_PP = (int)[[newSetting objectAtIndex:0] integerValue];
    highHue_PP = (int)[[newSetting objectAtIndex:1] integerValue];
    
    lowSaturation_PP = (int)[[newSetting objectAtIndex:2] integerValue];
    highSaturation_PP = (int)[[newSetting objectAtIndex:3] integerValue];
    
    lowVal_PP = (int)[[newSetting objectAtIndex:4] integerValue];
    highVal_PP = (int)[[newSetting objectAtIndex:5] integerValue];
    
    [self changeHSVVals];
    
    
}

// Called after we save to change the tableview
- (void) changeFromFile{
    savedLocationsFromFile_PP = [savedLocationsFromFile_PP changeFromFile];
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
    
    if( lowHue_PP == 255 && lowSaturation_PP == 255 && lowVal_PP == 255 &&
       highHue_PP == 0 && highSaturation_PP == 0 && highVal_PP == 0){
        // choose a color first
        darkest_PP.backgroundColor = UIColor.whiteColor;
        lightest_PP.backgroundColor = UIColor.whiteColor;
        
        return;
    }
    
    
    
    double R_low;
    double G_low;
    double B_low;
    double R_high;
    double G_high;
    double B_high;
    
    [CVWrapper getRGBValuesFromH:lowHue_PP
                               S:lowSaturation_PP
                               V:lowVal_PP
                               R:&R_low
                               G:&G_low
                               B:&B_low];
    
    [CVWrapper getRGBValuesFromH:highHue_PP
                               S:highSaturation_PP
                               V:highVal_PP
                               R:&R_high
                               G:&G_high
                               B:&B_high];
    _darkestColor_PP = [[UIColor alloc] initWithRed:R_low/255.0
                                              green:G_low/255.0
                                               blue:B_low/255.0
                                              alpha:1];
    darkest_PP.backgroundColor = _darkestColor_PP;
    
    _brightestColor_PP = [[UIColor alloc] initWithRed:R_high/255.0
                                                green:G_high/255.0
                                                 blue:B_high/255.0
                                                alpha:1];
    lightest_PP.backgroundColor = _brightestColor_PP;
    
}



@end

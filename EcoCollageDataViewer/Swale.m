//
//  Swale.m
//  Trial_1
//
//  Created by Jamie Auza on 5/20/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import "Swale.h"
#import "CVWrapper.h"
#import "Coordinate.h"
#import "savedLocations.h"
#import "saveColors.h"
#import "analysisViewController.h"
#import <math.h>
#import <stdlib.h>

@implementation Swale

UITapGestureRecognizer * singleTap_S; // tap that recognizes color extraction
UITapGestureRecognizer * doubleTap_S; // tap that recognizes removal of sample

UIImage* plainImage_S = nil;
UIImageView * img_S;
UIImage* threshedImage_S = nil;

NSMutableArray * SwaleSamples;
NSMutableArray * sampleImages_S;
NSMutableArray* swaleCoordinatesCalibrated;

int highHue_S, highSaturation_S, highVal_S;
int lowHue_S, lowSaturation_S, lowVal_S;
int hasNoDefaultValues;

@synthesize savedLocationsFromFile_S;
@synthesize sample1;
@synthesize sample2;
@synthesize sample3;
@synthesize sample4;
@synthesize sample5;
@synthesize sample6;
@synthesize lightest_S;
@synthesize darkest_S;
@synthesize viewIconSwitch;

@synthesize clickedSegment_S;
@synthesize seguedFromTileDetection;

UIImage* swaleIcon2 = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initializing the switch
    [self.threshSwitch addTarget:self
                          action:@selector(stateChanged:) forControlEvents:UIControlEventValueChanged];
    _threshSwitch.on = false;
    
    // Set Default HSV Values
    [self setHSVValues];
    
    savedLocationsFromFile_S = [[savedLocations alloc] init];


    
    
    // Switch to see icons
    [viewIconSwitch addTarget:self
                       action:@selector(stateChangedViewIcon:) forControlEvents:UIControlEventValueChanged];
    
    swaleIcon2 = [UIImage imageNamed:@"swale_outline.png"];
    
    // Back Button
    UIBarButtonItem *buttonizeButton = [[UIBarButtonItem alloc] initWithTitle:@"Buttonize"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(buttonizeButtonTap:)];
    self.navigationItem.rightBarButtonItems = @[buttonizeButton];
    
    // To send data to save screen
    _highLowVals_S = [[NSMutableArray alloc]init];
    

  
    SwaleSamples = [NSMutableArray array];
    sampleImages_S = [NSMutableArray array];
        
    [self changeColorSetToIndex:clickedSegment_S]; // changes the 6 vals
    [self updateBrightAndDark]; // gets lightest and darkest
        
    [sampleImages_S addObject:sample1];
    [sampleImages_S addObject:sample2];
    [sampleImages_S addObject:sample3];
    [sampleImages_S addObject:sample4];
    [sampleImages_S addObject:sample5];
    [sampleImages_S addObject:sample6];
        
        
        // Necessary to find where to put the sampled color
    sample1.backgroundColor = _brightestColor_S;
    sample2.backgroundColor = _darkestColor_S;
    sample3.backgroundColor = UIColor.whiteColor;
    sample4.backgroundColor = UIColor.whiteColor;
    sample5.backgroundColor = UIColor.whiteColor;
    sample6.backgroundColor = UIColor.whiteColor;
        
    [SwaleSamples addObject:_brightestColor_S];
    [SwaleSamples addObject:_darkestColor_S];
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    plainImage_S = _currentImage_S;
    
    [self updateScrollView:_currentImage_S];
    
    
    // Initializing the Tap Gestures
    singleTap_S = [[UITapGestureRecognizer alloc]
                   initWithTarget:self
                   action:@selector(handleSingleTapFrom:)];
    singleTap_S.numberOfTapsRequired = 1;
    [_scrollView addGestureRecognizer:singleTap_S];
    singleTap_S.delegate = self;
    
    
    doubleTap_S = [[UITapGestureRecognizer alloc]
                   initWithTarget:self
                   action:@selector(handleDoubleTapFrom:)];
    doubleTap_S.numberOfTapsRequired = 2;
    doubleTap_S.delegate = self;
    
    //Fail to implement single tap if double tap is met
    [singleTap_S requireGestureRecognizerToFail:doubleTap_S];
    
    
    // Adding a Double Tap Gesture for all the Sample Views for the Ability to remove
    for( UIImageView * sampleView in sampleImages_S ){
        UITapGestureRecognizer * doubleTap_STEST = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handleDoubleTapFrom:)];
        doubleTap_STEST.numberOfTapsRequired = 2;
        doubleTap_STEST.delegate = self;
        [sampleView setUserInteractionEnabled:YES];
        [sampleView addGestureRecognizer: doubleTap_STEST];
    }
    
    // Creating Borders
    [self.lightest_S.layer setBorderWidth:2.0];
    [self.lightest_S.layer setBorderColor:[UIColor colorWithRed:0.86 green:0.85 blue:0.87 alpha:1.0].CGColor];
    
    [self.darkest_S.layer setBorderWidth:2.0];
    [self.darkest_S.layer setBorderColor:[UIColor colorWithRed:0.86 green:0.85 blue:0.87 alpha:1.0].CGColor];
        
    // If we segue from save profile or tile detection, we could have added a new profile
    savedLocationsFromFile_S = [[savedLocations alloc] init];
    
    // If we segue from Tile Detection, we reset everything
    if( seguedFromTileDetection == true){
        // Remove all swale samples
        [SwaleSamples removeAllObjects];
            
        // Necessary to find where to put the sampled color
        sample3.backgroundColor = UIColor.whiteColor;
        sample4.backgroundColor = UIColor.whiteColor;
        sample5.backgroundColor = UIColor.whiteColor;
        sample6.backgroundColor = UIColor.whiteColor;
        
        [self changeColorSetToIndex:clickedSegment_S];
        
        // Update First 2 samples as lightest and darkest
        sample1.backgroundColor = _brightestColor_S;
        sample2.backgroundColor = _darkestColor_S;
        
        // Adds the brightest and darkest color to swale samples
        [SwaleSamples addObject:_brightestColor_S];
        [SwaleSamples addObject:_darkestColor_S];
        
        seguedFromTileDetection = false;
    }
    
    [self updateBrightAndDark];
    
}
#pragma -mark Sending high and low values to save screen

- (NSString*) getColorPaletteLabel{
    return self.dropDown.currentTitle;
}

- (NSMutableArray*) getHighLowVals{
    [_highLowVals_S removeAllObjects];
    [_highLowVals_S addObject:[NSString stringWithFormat:@"%d",lowHue_S]];
    [_highLowVals_S addObject:[NSString stringWithFormat:@"%d",highHue_S]];
    [_highLowVals_S addObject:[NSString stringWithFormat:@"%d",lowSaturation_S]];
    [_highLowVals_S addObject:[NSString stringWithFormat:@"%d",highSaturation_S]];
    [_highLowVals_S addObject:[NSString stringWithFormat:@"%d",lowVal_S]];
    [_highLowVals_S addObject:[NSString stringWithFormat:@"%d",highVal_S]];
    return _highLowVals_S;
}

#pragma -mark Back Button

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"backToAnalysis"])
    {
        analysisViewController *analysisViewController = [segue destinationViewController];
        analysisViewController.currentImage_A = _currentImage_S;
        analysisViewController.userImage_A = _originalImage_S;
        analysisViewController.clickedSegment_A = clickedSegment_S;
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
        
        UIGraphicsBeginImageContext(_currentImage_S.size);
        [_currentImage_S drawInRect:CGRectMake(0, 0, _currentImage_S.size.width, _currentImage_S.size.height)];
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
        [CVWrapper analysis:_currentImage_S studyNumber: 0 trialNumber:0 results:resultafter];
        
        
        swaleCoordinatesCalibrated = [CVWrapper getSwaleCoordinates];
        NSLog(@"There are %i swales detected" , swaleCoordinatesCalibrated.count);
        [self drawIconsInArray:swaleCoordinatesCalibrated image:swaleIcon2];
        
        UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self updateScrollView:result];
        NSLog(@"stateChangedViewIcon -- End ");
    } else {
        [self updateScrollView:_currentImage_S];
    }
    
}

-(void) drawIconsInArray:(NSMutableArray *)iconArray image:(UIImage*)iconImage{
    CGFloat squareWidth = _currentImage_S.size.width/23;
    CGFloat squareHeight = _currentImage_S.size.height/25;
    for( Coordinate * coord in iconArray){
        [iconImage drawInRect:CGRectMake( coord.getX * squareWidth,
                                         _currentImage_S.size.height - ( coord.getY + 1 ) * squareHeight,
                                         squareWidth, squareHeight)];
    }
}


#pragma -mark Update View

/*
 * Update the scroll view
 */
- (void) updateScrollView:(UIImage *) newImg {
    //MAKE SURE THAT IMAGE VIEW IS REMOVED IF IT EXISTS ON SCROLLVIEW!!
    CGFloat zoomScale = self.scrollView.zoomScale;
    CGPoint offset = CGPointMake(self.scrollView.contentOffset.x,self.scrollView.contentOffset.y);
    
    if (img_S != nil)
    {
        [img_S removeFromSuperview];
        
    }
    
    img_S = [[UIImageView alloc] initWithImage:newImg];
    
    
    
    //handle pinching in/ pinching out to zoom
    img_S.userInteractionEnabled = YES;
    img_S.backgroundColor = [UIColor clearColor];
    img_S.contentMode =  UIViewContentModeCenter;
    //img.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    self.scrollView.minimumZoomScale=0.5;
    self.scrollView.maximumZoomScale=6.0;
    self.scrollView.contentSize = CGSizeMake(img_S.frame.size.width+100, img_S.frame.size.height+100);
    self.scrollView.clipsToBounds = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsVerticalScrollIndicator = true;
    self.scrollView.showsHorizontalScrollIndicator = true;
    
    
    
    //Set image on the scrollview
    [self.scrollView addSubview:img_S];
    self.scrollView.zoomScale = zoomScale;
    self.scrollView.contentOffset = offset;
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return img_S;
}


#pragma -mark Handle Taps

- (void) handleSingleTapFrom: (UITapGestureRecognizer *)recognizer
{
    printf("I am single tapping...\n");
    
    CGPoint point =[singleTap_S locationInView:self.scrollView];
    
    UIColor * color = [self GetCurrentPixelColorAtPoint:point];
    
    // Find the first view that has no color and add the color we found
    for (UIImageView * view in sampleImages_S) {
        if( [view.backgroundColor isEqual:UIColor.whiteColor]){
            view.backgroundColor = color;
            [SwaleSamples addObject:color];
            break;
        }
    }
    
    [self setHighandlowVal_Sues];
    [self updateBrightAndDark];
    

}

- (void) handleDoubleTapFrom: (UITapGestureRecognizer *) recognizer
{
    printf("I double tapped\n");
    UIView *view = recognizer.view;
    
    Boolean removed = false;
    // Finds the color in the SwaleSamples array and removes it
    for (UIColor * color in SwaleSamples) {
        if( [color isEqual:view.backgroundColor]){
            [SwaleSamples removeObject:color];
            printf("Removed a color\n");
            printf("Permeable Pavers has %i things", SwaleSamples.count);
            removed = true;
            break;
        }
    }
    
    // Before setting the High and Low values, change to default from picked color set
    [self resetHSV];
    [self setHighandlowVal_Sues];
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
    NSLog(@"Red %d --- %f",pixel[0], pixel[0]/255.0 );
    NSLog(@"Green %d --- %f",pixel[1], pixel[1]/255.0 );
    NSLog(@"Blue %d --- %f",pixel[2], pixel[2]/255.0 );
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    return color;
}

- (void) showSamples{
    NSLog(@"In ShowSamples: Samples has %i",SwaleSamples.count );
    for( UIColor * color in SwaleSamples){
        for (UIImageView * view in sampleImages_S) {
            if( [view.backgroundColor isEqual:UIColor.whiteColor]){
                view.backgroundColor = color;
                break;
            }
        }
    }
}

#pragma -mark Action Buttons

- (IBAction)removeAll:(id)sender {
    [SwaleSamples removeAllObjects];
    for( UIImageView * sample in sampleImages_S){
        sample.backgroundColor = UIColor.whiteColor;
    }
    
    if( _threshSwitch.isOn || viewIconSwitch.isOn){
        [_threshSwitch setOn:false];
        [viewIconSwitch setOn:false];
        [self updateScrollView:_currentImage_S];
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
    if (plainImage_S == nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"No image to threshold!" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        return;
    }

    
    //thresh either the plain image or the median filtered image
    /* thresholds image
     ** colorCases: 0 = green <--
     **             1 = red
     **             2 = wood
     **             3 = blue
     **             4 = dark green (corner markers)
     */
    
    [CVWrapper setSegmentIndex:0];
    [self changeHSVVals];
    
    threshedImage_S = [CVWrapper thresh:plainImage_S colorCase: 0];
    //_scrollView.zoomScale = plainImage_S.scale;
    [self updateScrollView:threshedImage_S];
}

/*
 * UnThreshold
 */
- (void) un_thresh_image{
    if (img_S != nil && (img_S.image != plainImage_S))
    {
        printf("Reseting to unthreshed image\n");
        [self updateScrollView:plainImage_S];
    }
}

#pragma -mark HSV Values

/*
 * Gets the integers from hsvValues.txt and sends them to CVWrapper
 */
- (void) setHSVValues {

    int hsvValues[] = {255, 0, 255, 0, 255, 0,
        255, 0, 255, 0, 255, 0,
        255, 0, 255, 0, 255, 0,
        255, 0, 255, 0, 255, 0,
        255, 0, 255, 0, 255, 0};
    [CVWrapper setHSV_Values:hsvValues];
}

/*
 * Changes the HSV Values in CVWrapper
 * Does this change the txt file?
 */
- (void) changeHSVVals{
    /*
     ** colorCases: 0 = green <--
     **             1 = red
     **             2 = wood
     **             3 = blue
     **             4 = dark green (corner markers)
     */
    
    int caseNum = 0;
    int vals[30] = {0};
    [CVWrapper getHSV_Values:vals];
    
    // Find the High and Low Values from Samples
    if( SwaleSamples.count != 0)
        [self setHighandlowVal_Sues];
    
    // changes the values by the CVWrapper
    vals[caseNum * 6] = lowHue_S;
    vals[caseNum * 6 + 1] = highHue_S;
    vals[caseNum * 6 + 2] = lowSaturation_S;
    vals[caseNum * 6 + 3] = highSaturation_S;
    vals[caseNum * 6 + 4] = lowVal_S;
    vals[caseNum * 6 + 5] = highVal_S;
    
    [CVWrapper setHSV_Values:vals];
}

#pragma change HSV Values based on samples

/*
 * Goes through the Array of Colors ( compares it to the current 6 values ) and sets the High and Low Values of the Hue, Saturation, and Value.
 */
- (void) setHighandlowVal_Sues{
    
    int H_Sample;
    int S_Sample;
    int V_Sample;
    
    for( UIColor * color in SwaleSamples) {
        const CGFloat* components = CGColorGetComponents(color.CGColor);
        
        int red = components[0]*255.0;
        int green = components[1]*255.0;
        int blue = components[2]*255.0;
        
        [CVWrapper getHSVValuesfromRed:red Green:green Blue:blue H:&H_Sample S:&S_Sample V:&V_Sample];
        
        highHue_S = ( highHue_S < H_Sample ) ? H_Sample : highHue_S ;
        highSaturation_S = ( highSaturation_S < S_Sample ) ? S_Sample : highSaturation_S ;
        highVal_S = ( highVal_S < V_Sample ) ? V_Sample : highVal_S ;
        
        lowHue_S = ( lowHue_S > H_Sample ) ? H_Sample : lowHue_S ;
        lowSaturation_S = ( lowSaturation_S > S_Sample ) ? S_Sample : lowSaturation_S ;
        lowVal_S = ( lowVal_S > V_Sample ) ? V_Sample : lowVal_S;
        
        
    }
}

#pragma Change HSV Values based on Location

#pragma -mark Drop Down Menu

// should only be called in the beginning
- (void) changeColorSetToIndex: (int)index{
    
    clickedSegment_S = index;
    
    [self.dropDown setTitle: [savedLocationsFromFile_S nameOfObjectAtIndex:index]  forState:UIControlStateNormal];
    
    NSMutableArray * newSetting  = [savedLocationsFromFile_S getHSVForSavedLocationAtIndex:index Icon:0];
    
    lowHue_S = [[newSetting objectAtIndex:0] integerValue];
    highHue_S = [[newSetting objectAtIndex:1] integerValue];
    
    lowSaturation_S = [[newSetting objectAtIndex:2] integerValue];
    highSaturation_S = [[newSetting objectAtIndex:3] integerValue];
    
    lowVal_S = [[newSetting objectAtIndex:4] integerValue];
    highVal_S = [[newSetting objectAtIndex:5] integerValue];
    
    NSLog(@"LowHue_S is %i", lowHue_S);
    
    [self changeHSVVals];
    
    //self.tableView.hidden =  TRUE;
    
}

// Called after we save to change the tableview
- (void) changeFromFile{
    savedLocationsFromFile_S = [savedLocationsFromFile_S changeFromFile];
   // [self.tableView reloadData];
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
    NSLog(@"Changing the dark and brightest to these values");
    NSLog(@" LH:%d LS:%d LV:%d", lowHue_S, lowSaturation_S, lowVal_S);
    NSLog(@" HH:%d HS:%d HV:%d", highHue_S, highSaturation_S, highVal_S);

    if( lowHue_S == 255 && lowSaturation_S == 255 && lowVal_S == 255 &&
       highHue_S == 0 && highSaturation_S == 0 && highVal_S == 0){
        // choose a color first
        darkest_S.backgroundColor = UIColor.whiteColor;
        lightest_S.backgroundColor = UIColor.whiteColor;
        
        return;
    }
    
    double R_low;
    double G_low;
    double B_low;
    double R_high;
    double G_high;
    double B_high;
    
    [CVWrapper getRGBValuesFromH:lowHue_S
                               S:lowSaturation_S
                               V:lowVal_S
                               R:&R_low
                               G:&G_low
                               B:&B_low];
    
    [CVWrapper getRGBValuesFromH:highHue_S
                               S:highSaturation_S
                               V:highVal_S
                               R:&R_high
                               G:&G_high
                               B:&B_high];
    _darkestColor_S = [[UIColor alloc] initWithRed:R_low/255.0
                                             green:G_low/255.0
                                              blue:B_low/255.0
                                             alpha:1];
    darkest_S.backgroundColor = _darkestColor_S;
    
    _brightestColor_S = [[UIColor alloc] initWithRed:R_high/255.0
                                               green:G_high/255.0
                                                blue:B_high/255.0
                                               alpha:1];
    lightest_S.backgroundColor = _brightestColor_S;

}

-(void) resetHSV{
    lowHue_S = 255;
    highHue_S = 0;
    lowSaturation_S = 255;
    highSaturation_S = 0;
    lowVal_S = 255;
    highVal_S = 0;
}

@end
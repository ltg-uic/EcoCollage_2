//
//  PermeablePaver.m
//  Trial_1
//
//  Created by Jamie Auza on 5/20/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import "saveColors.h"
#import "RainBarrel.h"
#import "CVWrapper.h"
#import "Coordinate.h"
#import "savedLocations.h"
#import "analysisViewController.h"
#import <math.h>
#import <stdlib.h>

@implementation RainBarrel

UITapGestureRecognizer * singleTap_RB; // tap that recognizes color extraction
UITapGestureRecognizer * doubleTap_RB; // tap that recognizes removal of sample

UIImage* plainImage_RB = nil;
UIImageView * img_RB;
UIImage* threshedImage_RB = nil;

NSMutableArray * RainBarrelSamples;
NSMutableArray * sampleImages_RB;
NSMutableArray* rainBarrelCoordinatesCalibrated;

int highHue_RB, highSaturation_RB, highVal_RB;
int lowHue_RB, lowSaturation_RB, lowVal_RB;
savedLocations* savedLocationsFromFile_RB;

@synthesize sample1;
@synthesize sample2;
@synthesize sample3;
@synthesize sample4;
@synthesize sample5;
@synthesize sample6;
@synthesize lightest_RB;
@synthesize darkest_RB;
@synthesize viewIconSwitch;
@synthesize clickedSegment_RB;

UIImage* rainBarrelIcon2 = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initializing the switch
    [self.threshSwitch addTarget:self
                          action:@selector(stateChanged:) forControlEvents:UIControlEventValueChanged];
    _threshSwitch.on = false;
    
    // Set Default HSV Values
    [self setHSVValues];
    
    savedLocationsFromFile_RB = [[savedLocations alloc] init];
    
    
    
    
    // Switch to see icons
    [viewIconSwitch addTarget:self
                       action:@selector(stateChangedViewIcon:) forControlEvents:UIControlEventValueChanged];
    
    rainBarrelIcon2 = [UIImage imageNamed:@"rainbarrel_outline.png"];
    
    // Back Button
    UIBarButtonItem *buttonizeButton = [[UIBarButtonItem alloc] initWithTitle:@"Buttonize"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(buttonizeButtonTap:)];
    self.navigationItem.rightBarButtonItems = @[buttonizeButton];
    
    // To send data to save screen
    _highLowVals_RB = [[NSMutableArray alloc]init];
    
    
    
    RainBarrelSamples = [NSMutableArray array];
    sampleImages_RB = [NSMutableArray array];
    
    [self changeColorSetToIndex:clickedSegment_RB]; // changes the 6 vals
    [self updateBrightAndDark]; // gets lightest and darkest
    
    [sampleImages_RB addObject:sample1];
    [sampleImages_RB addObject:sample2];
    [sampleImages_RB addObject:sample3];
    [sampleImages_RB addObject:sample4];
    [sampleImages_RB addObject:sample5];
    [sampleImages_RB addObject:sample6];
    
    
    // Necessary to find where to put the sampled color
    sample1.backgroundColor = _brightestColor_RB;
    sample2.backgroundColor = _darkestColor_RB;
    sample3.backgroundColor = UIColor.whiteColor;
    sample4.backgroundColor = UIColor.whiteColor;
    sample5.backgroundColor = UIColor.whiteColor;
    sample6.backgroundColor = UIColor.whiteColor;
    
    [RainBarrelSamples addObject:_brightestColor_RB];
    [RainBarrelSamples addObject:_darkestColor_RB];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    plainImage_RB = _currentImage_RB;
    
    [self updateScrollView:_currentImage_RB];
    
    
    // Initializing the Tap Gestures
    singleTap_RB = [[UITapGestureRecognizer alloc]
                    initWithTarget:self
                    action:@selector(handleSingleTapFrom:)];
    singleTap_RB.numberOfTapsRequired = 1;
    [_scrollView addGestureRecognizer:singleTap_RB];
    singleTap_RB.delegate = self;
    
    
    doubleTap_RB = [[UITapGestureRecognizer alloc]
                    initWithTarget:self
                    action:@selector(handleDoubleTapFrom:)];
    doubleTap_RB.numberOfTapsRequired = 2;
    doubleTap_RB.delegate = self;
    
    //Fail to implement single tap if double tap is met
    [singleTap_RB requireGestureRecognizerToFail:doubleTap_RB];
    
    
    // Adding a Double Tap Gesture for all the Sample Views for the Ability to remove
    for( UIImageView * sampleView in sampleImages_RB ){
        UITapGestureRecognizer * doubleTap_RBTEST = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(handleDoubleTapFrom:)];
        doubleTap_RBTEST.numberOfTapsRequired = 2;
        doubleTap_RBTEST.delegate = self;
        [sampleView setUserInteractionEnabled:YES];
        [sampleView addGestureRecognizer: doubleTap_RBTEST];
    }
    
    // Creating Borders
    [self.lightest_RB.layer setBorderWidth:2.0];
    [self.lightest_RB.layer setBorderColor:[UIColor colorWithRed:0.86 green:0.85 blue:0.87 alpha:1.0].CGColor];
    
    [self.darkest_RB.layer setBorderWidth:2.0];
    [self.darkest_RB.layer setBorderColor:[UIColor colorWithRed:0.86 green:0.85 blue:0.87 alpha:1.0].CGColor];
    
    // If we segue from save profile or tile detection, we could have added a new profile
    savedLocationsFromFile_RB= [[savedLocations alloc] init];
    
    // If we segue from Tile Detection, we reset everything
    if( _seguedFromTileDetection == true){
        // Remove all swale samples
        [RainBarrelSamples removeAllObjects];
        
        // Necessary to find where to put the sampled color
        sample3.backgroundColor = UIColor.whiteColor;
        sample4.backgroundColor = UIColor.whiteColor;
        sample5.backgroundColor = UIColor.whiteColor;
        sample6.backgroundColor = UIColor.whiteColor;
        
        [self changeColorSetToIndex:clickedSegment_RB];
        
        // Update First 2 samples as lightest and darkest
        sample1.backgroundColor = _brightestColor_RB;
        sample2.backgroundColor = _darkestColor_RB;
        
        // Adds the brightest and darkest color to swale samples
        [RainBarrelSamples addObject:_brightestColor_RB];
        [RainBarrelSamples addObject:_darkestColor_RB];
        
        _seguedFromTileDetection = false;
    }
    
    [self updateBrightAndDark];
    
}
#pragma -mark sending data
- (NSString*) getColorPaletteLabel{
    return self.dropDown.currentTitle;
}

- (NSMutableArray*) getHighLowVals{
    [_highLowVals_RB removeAllObjects];
    [_highLowVals_RB addObject:[NSString stringWithFormat:@"%d",lowHue_RB]];
    [_highLowVals_RB addObject:[NSString stringWithFormat:@"%d",highHue_RB]];
    [_highLowVals_RB addObject:[NSString stringWithFormat:@"%d",lowSaturation_RB]];
    [_highLowVals_RB addObject:[NSString stringWithFormat:@"%d",highSaturation_RB]];
    [_highLowVals_RB addObject:[NSString stringWithFormat:@"%d",lowVal_RB]];
    [_highLowVals_RB addObject:[NSString stringWithFormat:@"%d",highVal_RB]];
    return _highLowVals_RB;
}

#pragma -mark Back Button

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"backToAnalysis"])
    {
        analysisViewController *analysisViewController = [segue destinationViewController];
        analysisViewController.currentImage_A = _currentImage_RB;
        analysisViewController.userImage_A = _originalImage_RB;
        analysisViewController.clickedSegment_A = clickedSegment_RB;
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
        
        UIGraphicsBeginImageContext(_currentImage_RB.size);
        [_currentImage_RB drawInRect:CGRectMake(0, 0, _currentImage_RB.size.width, _currentImage_RB.size.height)];
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
        [CVWrapper analysis:_currentImage_RB studyNumber: 0 trialNumber:0 results:resultafter];
        
        
        rainBarrelCoordinatesCalibrated = [CVWrapper getRainBarrelCoordinates];
        NSLog(@"There are %i permeable pavers detected" , rainBarrelCoordinatesCalibrated.count);
        [self drawIconsInArray:rainBarrelCoordinatesCalibrated image:rainBarrelIcon2];
        
        UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self updateScrollView:result];
        NSLog(@"stateChangedViewIcon -- End ");
    } else {
        [self updateScrollView:_currentImage_RB];
    }
    
}

-(void) drawIconsInArray:(NSMutableArray *)iconArray image:(UIImage*)iconImage{
    CGFloat squareWidth = _currentImage_RB.size.width/23;
    CGFloat squareHeight = _currentImage_RB.size.height/25;
    for( Coordinate * coord in iconArray){
        [iconImage drawInRect:CGRectMake( coord.getX * squareWidth,
                                         _currentImage_RB.size.height - ( coord.getY + 1 ) * squareHeight,
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
    if (img_RB != nil)
    {
        [img_RB removeFromSuperview];
        
    }
    
    img_RB = [[UIImageView alloc] initWithImage:newImg];
    
    //handle pinching in/ pinching out to zoom
    img_RB.userInteractionEnabled = YES;
    img_RB.backgroundColor = [UIColor clearColor];
    img_RB.contentMode =  UIViewContentModeCenter;
    //img.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    self.scrollView.minimumZoomScale=0.5;
    self.scrollView.maximumZoomScale=6.0;
    self.scrollView.contentSize = CGSizeMake(img_RB.frame.size.width+100, img_RB.frame.size.height+100);
    self.scrollView.clipsToBounds = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsVerticalScrollIndicator = true;
    self.scrollView.showsHorizontalScrollIndicator = true;
    
    //Set image on the scrollview
    [self.scrollView addSubview:img_RB];
    self.scrollView.zoomScale = zoomScale;
    self.scrollView.contentOffset = offset;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return img_RB;
}


#pragma -mark Handle Taps

- (void) handleSingleTapFrom: (UITapGestureRecognizer *)recognizer
{
    printf("I am single tapping...\n");
    
    CGPoint point =[singleTap_RB locationInView:self.scrollView];
    
    UIColor * color = [self GetCurrentPixelColorAtPoint:point];
    
    // Find the first view that has no color and add the color we found
    for (UIImageView * view in sampleImages_RB) {
        if( [view.backgroundColor isEqual:UIColor.whiteColor]){
            view.backgroundColor = color;
            [RainBarrelSamples addObject:color];
            break;
        }
    }
    
    [self setHighandlowVal_RBues];
    [self updateBrightAndDark];
}

- (void) handleDoubleTapFrom: (UITapGestureRecognizer *) recognizer
{
    printf("I double tapped\n");
    UIView *view = recognizer.view;
    
    Boolean removed = false;
    // Finds the color in the RainBarrelSamples array and removes it
    for (UIColor * color in RainBarrelSamples) {
        if( [color isEqual:view.backgroundColor]){
            [RainBarrelSamples removeObject:color];
            printf("Removed a color\n");
            printf("Permeable Pavers has %i things", RainBarrelSamples.count);
            removed = true;
            break;
        }
    }
    
    // Before setting the High and Low values, change to default from picked color set
    [self resetHSV];
    [self setHighandlowVal_RBues];
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
    NSLog(@"In ShowSamples: Samples has %i",RainBarrelSamples.count );
    for( UIColor * color in RainBarrelSamples){
        for (UIImageView * view in sampleImages_RB) {
            if( [view.backgroundColor isEqual:UIColor.whiteColor]){
                view.backgroundColor = color;
                break;
            }
        }
    }
}

#pragma -mark Action Buttons

- (IBAction)removeAll:(id)sender {
    [RainBarrelSamples removeAllObjects];
    for( UIImageView * sample in sampleImages_RB){
        sample.backgroundColor = UIColor.whiteColor;
    }
    
    if( _threshSwitch.isOn || viewIconSwitch.isOn){
        [_threshSwitch setOn:false];
        [viewIconSwitch setOn:false];
        [self updateScrollView:_currentImage_RB];
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
    if (plainImage_RB == nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"No image to threshold!" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    //thresh either the plain image or the median filtered image
    /* thresholds image
     ** colorCases: 0 = green
     **             1 = red  <--
     **             2 = wood
     **             3 = blue
     **             4 = dark green (corner markers)
     */
    
    [CVWrapper setSegmentIndex:1];
    [self changeHSVVals];
    
    threshedImage_RB = [CVWrapper thresh:plainImage_RB colorCase: 1];
    //_RBcrollView.zoomScale = plainImage_RB.scale;
    [self updateScrollView:threshedImage_RB];
}

/*
 * UnThreshold
 */
- (void) un_thresh_image{
    if (img_RB != nil && (img_RB.image != plainImage_RB))
    {
        printf("Reseting to unthreshed image\n");
        [self updateScrollView:plainImage_RB];
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
     **             1 = red  <--
     **             2 = wood
     **             3 = blue
     **             4 = dark green (corner markers)
     */
    
    int caseNum = 1;
    int vals[30] = {0};
    [CVWrapper getHSV_Values:vals];
    
    
    // Find the High and Low Values from Samples
    [self setHighandlowVal_RBues];
    
    // changes the values by the CVWrapper
    vals[caseNum * 6] = lowHue_RB;
    vals[caseNum * 6 + 1] = highHue_RB;
    vals[caseNum * 6 + 2] = lowSaturation_RB;
    vals[caseNum * 6 + 3] = highSaturation_RB;
    vals[caseNum * 6 + 4] = lowVal_RB;
    vals[caseNum * 6 + 5] = highVal_RB;
    
    [CVWrapper setHSV_Values:vals];
}

#pragma change HSV Values based on samples

/*
 * Goes through the Array of Colors and sets the High and Low Values of the Hue, Saturation, and Value.
 */
- (void) setHighandlowVal_RBues{
    int H_RBample;
    int S_RBample;
    int V_RBample;
    
    for( UIColor * color in RainBarrelSamples) {
        const CGFloat* components = CGColorGetComponents(color.CGColor);
        
        int red = components[0]*255.0;
        int green = components[1]*255.0;
        int blue = components[2]*255.0;
        
        [CVWrapper getHSVValuesfromRed:red Green:green Blue:blue H:&H_RBample S:&S_RBample V:&V_RBample];
        
        highHue_RB = ( highHue_RB < H_RBample ) ? H_RBample : highHue_RB ;
        highSaturation_RB = ( highSaturation_RB < S_RBample ) ? S_RBample : highSaturation_RB ;
        highVal_RB = ( highVal_RB < V_RBample ) ? V_RBample : highVal_RB ;
        
        lowHue_RB = ( lowHue_RB > H_RBample ) ? H_RBample : lowHue_RB ;
        lowSaturation_RB = ( lowSaturation_RB > S_RBample ) ? S_RBample : lowSaturation_RB ;
        lowVal_RB = ( lowVal_RB > V_RBample ) ? V_RBample : lowVal_RB;
        
    }
}


#pragma -mark Drop Down Menu


- (void) changeColorSetToIndex: (int)index{
    clickedSegment_RB = index;
    
    [self.dropDown setTitle: [savedLocationsFromFile_RB nameOfObjectAtIndex:index]  forState:UIControlStateNormal];
    
    // Icon == CaseNum
    /*
    ** colorCases: 0 = green
    **             1 = red  <--
    **             2 = wood
    **             3 = blue
    **             4 = dark green (corner markers)
    */
    NSMutableArray * newSetting  = [savedLocationsFromFile_RB getHSVForSavedLocationAtIndex:index Icon:1];
    
    lowHue_RB = [[newSetting objectAtIndex:0] integerValue];
    highHue_RB = [[newSetting objectAtIndex:1] integerValue];
    
    lowSaturation_RB = [[newSetting objectAtIndex:2] integerValue];
    highSaturation_RB = [[newSetting objectAtIndex:3] integerValue];
    
    lowVal_RB = [[newSetting objectAtIndex:4] integerValue];
    highVal_RB = [[newSetting objectAtIndex:5] integerValue];
    
    NSLog(@"lowHue_RB is %i", lowHue_RB);
    
    [self changeHSVVals];
    
}

// Called after we save to change the tableview
- (void) changeFromFile{
    savedLocationsFromFile_RB = [savedLocationsFromFile_RB changeFromFile];
}


- (IBAction)dropDownButton:(id)sender {
    /*
    if( self.tableView.hidden == TRUE )
        self.tableView.hidden =  FALSE;
    else
        self.tableView.hidden = TRUE;
     */
}
-(void) resetHSV{
    lowHue_RB = 255;
    highHue_RB = 0;
    lowSaturation_RB = 255;
    highSaturation_RB = 0;
    lowVal_RB = 255;
    highVal_RB = 0;
}
#pragma -mark Bright and Dark
-(void) updateBrightAndDark{
    
    if( lowHue_RB == 255 && lowSaturation_RB == 255 && lowVal_RB == 255 &&
       highHue_RB == 0 && highSaturation_RB == 0 && highVal_RB == 0){
        // choose a color first
        darkest_RB.backgroundColor = UIColor.whiteColor;
        lightest_RB.backgroundColor = UIColor.whiteColor;
        
        return;
    }
    
    
    
    double R_low;
    double G_low;
    double B_low;
    double R_high;
    double G_high;
    double B_high;
    
    [CVWrapper getRGBValuesFromH:lowHue_RB
                               S:lowSaturation_RB
                               V:lowVal_RB
                               R:&R_low
                               G:&G_low
                               B:&B_low];
    
    [CVWrapper getRGBValuesFromH:highHue_RB
                               S:highSaturation_RB
                               V:highVal_RB
                               R:&R_high
                               G:&G_high
                               B:&B_high];
    _darkestColor_RB = [[UIColor alloc] initWithRed:R_low/255.0
                                              green:G_low/255.0
                                               blue:B_low/255.0
                                              alpha:1];
    darkest_RB.backgroundColor = _darkestColor_RB;
    
    _brightestColor_RB = [[UIColor alloc] initWithRed:R_high/255.0
                                                green:G_high/255.0
                                                 blue:B_high/255.0
                                                alpha:1];
    lightest_RB.backgroundColor = _brightestColor_RB;
    
}


@end

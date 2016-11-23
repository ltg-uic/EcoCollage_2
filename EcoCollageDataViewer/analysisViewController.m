//
//  analysisViewController.m
//  Trial_1
//
//  Created by Jamie Auza on 5/20/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import "analysisViewController.h"
#import "TakeAPictureViewController.h"
#import "savedLocations.h"
#import "Swale.h"
#import "GreenRoof.h"
#import "PermeablePaver.h"
#import "RainBarrel.h"
#import "saveColors.h"
#import "GreenCorners.h"
#import "CVWrapper.h"
#import "Coordinate.h"

@implementation analysisViewController
UITapGestureRecognizer * singleTap_A; // tap that recognizes color extraction
UITapGestureRecognizer * doubleTap_A; // tap that recognizes removal of sample

UIImage* plainImage2 = nil;

UIImage* watermarkImage = nil;
UIImage* swaleIcon = nil;
UIImage* rainBarrelIcon = nil;
UIImage* greenRoofIcon = nil;
UIImage* permeablePaverIcon = nil;

NSMutableArray* swaleCoordinates;
NSMutableArray* rainBarrelCoordinates;
NSMutableArray* permeablePaverCoordinates;
NSMutableArray* greenRoofCoordinates;
NSMutableArray* arrayOfCoordinateArrays;
NSMutableArray* addButtons;
NSMutableArray * profileSetting;
savedLocations* savedLocationsFromFile_A;

int pressedButton = -1;
NSMutableArray * map;
NSString* trialID;
NSArray* trialNumbers;

@synthesize currentImage_A;

@synthesize squareWidth;
@synthesize squareHeight;

@synthesize addSwaleButton;
@synthesize addRainBarrelButton;
@synthesize addGreenRoofButton;
@synthesize addPermeablePaverButton;
@synthesize IPAddress;

@synthesize clickedSegment_A;

- (void) viewDidLoad{
    // Get Coordinates
    swaleCoordinates = [CVWrapper getSwaleCoordinates];
    rainBarrelCoordinates = [CVWrapper getRainBarrelCoordinates];
    permeablePaverCoordinates = [CVWrapper getPermeablePaverCoordinates];
    greenRoofCoordinates = [CVWrapper getGreenRoofCoordinates];
    
    // Initilializing
    arrayOfCoordinateArrays = [[NSMutableArray alloc] init];
    
    [arrayOfCoordinateArrays addObject: swaleCoordinates];
    [arrayOfCoordinateArrays addObject: rainBarrelCoordinates];
    [arrayOfCoordinateArrays addObject: permeablePaverCoordinates];
    [arrayOfCoordinateArrays addObject: greenRoofCoordinates];

    [self initArray];
    trialID = @"";
    
    // For Drop Down
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    savedLocationsFromFile_A = [[savedLocations alloc] init];
    
    profileSetting = [[NSMutableArray alloc] init];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Set up the picture on Scroll View
    plainImage2 = currentImage_A;
    [self updateScrollView:plainImage2];
    
    // Getting Icon Images
    swaleIcon = [UIImage imageNamed:@"swale_outline.png"];
    rainBarrelIcon = [UIImage imageNamed:@"rainbarrel_outline.png"];
    greenRoofIcon = [UIImage imageNamed:@"greenroof_outline.png"];
    permeablePaverIcon = [UIImage imageNamed:@"permeablepaver_outline.png"];
    
    
    NSLog(@"Width: %f", currentImage_A.size.width);
    NSLog(@"Height: %f", currentImage_A.size.height);
    
    squareWidth = currentImage_A.size.width/23;
    squareHeight = currentImage_A.size.height/25;

    
    // Add Buttons
    addButtons = [[NSMutableArray alloc] init];

    [addButtons addObject: addSwaleButton];
    [addButtons addObject: addGreenRoofButton];
    [addButtons addObject: addRainBarrelButton];
    [addButtons addObject: addPermeablePaverButton];
    
    // Tap Gestures
    // Initializing the Tap Gestures
    singleTap_A = [[UITapGestureRecognizer alloc]
                    initWithTarget:self
                    action:@selector(handleSingleTapFrom:)];
    singleTap_A.numberOfTapsRequired = 1;
    [_scrollView addGestureRecognizer:singleTap_A];
    singleTap_A.delegate = self;
    
    
    doubleTap_A = [[UITapGestureRecognizer alloc]
                    initWithTarget:self
                    action:@selector(handleDoubleTapFrom:)];
    doubleTap_A.numberOfTapsRequired = 2;
    doubleTap_A.delegate = self;
    [_scrollView addGestureRecognizer:doubleTap_A];
    
    [self setHSVValues];
    
    [self updateViewedIcons];
    [self.dropDown setTitle: [savedLocationsFromFile_A nameOfObjectAtIndex:clickedSegment_A]  forState:UIControlStateNormal];
}

#pragma -mark Map Text file

- (void) initArray{
    // get a reference to our file
    NSString *myPath = [[NSBundle mainBundle]pathForResource:@"DuPageMap" ofType:@"txt"];
    
    // read the contents into a string
    NSString *myFile = [[NSString alloc]initWithContentsOfFile:myPath encoding:NSUTF8StringEncoding error:nil];
    
    // display our file
    NSLog(@"Our file contains this: %@", myFile);
    myFile = [myFile stringByReplacingOccurrencesOfString:@"[" withString:@"" ];
    myFile = [myFile stringByReplacingOccurrencesOfString:@"]" withString:@"" ];
    myFile = [myFile stringByReplacingOccurrencesOfString:@"\"" withString:@"" ];
    myFile = [myFile stringByReplacingOccurrencesOfString:@"\r" withString:@"" ]; // carriage return

    myFile = [myFile stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSLog(@"Our file contains this: \n%@", myFile);
    
    NSArray * arrayOfRows = [myFile componentsSeparatedByString:@"\n"];
    int height = [arrayOfRows count];
    //NSLog(@"We have %d rows", height);
    NSArray * oneRow = [[arrayOfRows objectAtIndex:0] componentsSeparatedByString:@"\t"];
    int width = [oneRow count];
    //NSLog(@"We have %d columns", width);
    
    /*
     * --- Map Guide ---
     * Num | char |   Name     | GI that can be added
     *  0    "r"    Road         None
     *  1    "p"    Permeable    Swale
     *  2    "b"    Building     Green Roof, Rain Barrel
     *  3    "i"    Impermeable  Swale, Permeable Paver
     */
    map = [[NSMutableArray alloc] init];
    for( int y = height-1; y >= 0 ;y--){
        NSArray * rowTemp = [[arrayOfRows objectAtIndex:y] componentsSeparatedByString:@"\t"];
        [map addObject:rowTemp];
    }
    
}

#pragma mark - Tap Handlers

- (void) handleSingleTapFrom: (UITapGestureRecognizer *)recognizer
{
    printf("I am single tapping...\n");
    
    CGPoint point =[singleTap_A locationInView:self.imageView];
    
    // Covert Point to Coordinate Object
    Coordinate * addCoord;
    addCoord = [[Coordinate alloc] initWithXCoord:(point.x / squareWidth) YCoord: 25 -(point.y / squareHeight)];
    
    
    // Fixing Bug that can add more than one thing to a certain Coordinate
    for( Coordinate * coord in swaleCoordinates){
        if( [coord isEqualToOther:addCoord] )
            return;
    }
    for( Coordinate * coord in greenRoofCoordinates){
        if( [coord isEqualToOther:addCoord] )
            return;
    }
    for( Coordinate * coord in rainBarrelCoordinates){
        if( [coord isEqualToOther:addCoord] )
            return;
    }
    for( Coordinate * coord in permeablePaverCoordinates){
        if( [coord isEqualToOther:addCoord] )
            return;
    }
    // We should have error messages if that Icon isn't allowed on that location
    
    
    NSLog(@"Coordinate found X Value: %i", addCoord.getX);
    NSLog(@"Coordinate found y Value: %i", addCoord.getY);
    
    NSString * locationType = [[map objectAtIndex:addCoord.getY] objectAtIndex:addCoord.getX];
    
    if([ locationType isEqualToString:@"r"]  ){
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Icons can be added on Roads (Grey) " delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        alert.tag = 2;
        [alert show];
        return;
    }
    
    Boolean didAdd = false;
    switch(pressedButton){
        case -1:
            // No add button was pressed
            // Add pop-up error message
            break;
        case 0:
            if( [ locationType isEqualToString:@"p"] || [ locationType isEqualToString:@"i"] ){
                [swaleCoordinates addObject:addCoord];
                didAdd = true;
            }
            else{
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Swales can only be added to Green Areas (Green) or Paved Non-Streets (Blue Green)" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                alert.tag = 2;
                [alert show];
            }
            break;
        case 1:
            if( [ locationType isEqualToString:@"b"] ){
                [rainBarrelCoordinates addObject:addCoord];
                didAdd = true;
            }
            else{
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Rain Barrels can only be added to Buildings (Brown) " delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                alert.tag = 2;
                [alert show];
            }
            break;
        case 2:
            if( [ locationType isEqualToString:@"b"] ){
                [greenRoofCoordinates addObject:addCoord];
                didAdd = true;
            }
            else{
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Green Roofs can only be added to Buildings (Brown)" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                alert.tag = 2;
                [alert show];
            }
            break;
        case 3:
            if( [ locationType isEqualToString:@"i"] ){
                [permeablePaverCoordinates addObject:addCoord];
                didAdd = true;
            }
            else{
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Permeable Pavers can only be added to Paved Non-Streets (Blue Green)" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                alert.tag = 2;
                [alert show];
            }
            break;
    }

    if( pressedButton != -1 && didAdd == true)
        [self updateViewedIcons];
}

- (void) handleDoubleTapFrom: (UITapGestureRecognizer *) recognizer
{
    printf("I double tapped\n");
    
    CGPoint point =[doubleTap_A locationInView:self.imageView];
    
    // Covert Point to Coordinate Object
    Coordinate * removeCoord;
    removeCoord = [[Coordinate alloc] initWithXCoord:(point.x / squareWidth) YCoord: 25 - (point.y / squareHeight) ];
    
    NSLog(@"Coordinate found X Value -- remove: %i", removeCoord.getX);
    NSLog(@"Coordinate found y Value -- remove: %i", removeCoord.getY);
    
    Coordinate * removeMe =[[Coordinate alloc] initWithXCoord:-1 YCoord: -1 ]; // Cannot remove while looping
    
    for( NSMutableArray * coordinateArray in arrayOfCoordinateArrays){
        for( Coordinate * coord in coordinateArray ){
            if( coord.getX == removeCoord.getX &&  coord.getY == removeCoord.getY )
                removeMe = coord;
        }
        
        if( removeMe.getY != -1 ){
            [coordinateArray removeObject:removeMe];
        }
    }
    
    [self updateViewedIcons];
}


#pragma mark - updateviewedicons


-(void) updateViewedIcons{
    UIGraphicsBeginImageContext(currentImage_A.size);
    [currentImage_A drawInRect:CGRectMake(0, 0, currentImage_A.size.width, currentImage_A.size.height)];
     NSLog(@"Updating what's shown");

    [self drawIconsInArray:swaleCoordinates image:swaleIcon];
    [self drawIconsInArray:rainBarrelCoordinates image:rainBarrelIcon];
    [self drawIconsInArray:greenRoofCoordinates image:greenRoofIcon];
    [self drawIconsInArray:permeablePaverCoordinates image:permeablePaverIcon];
 
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self updateScrollView:result];
    NSLog(@"Done Updating what's shown");
}

-(void) drawIconsInArray:(NSMutableArray *)iconArray image:(UIImage*)iconImage{
    for( Coordinate * coord in iconArray){
        [iconImage drawInRect:CGRectMake( coord.getX * squareWidth,
                                         currentImage_A.size.height - ( coord.getY + 1 ) * squareHeight,
                                         squareWidth, squareHeight)];
    }
}

#pragma mark - Navigations

/*
 * Can use this method after buttonizeButtonTap to instantiate anything before you segue into the next scene
 *
 * @param segue The name of the segue
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toGI"])
    {
        UINavigationController *navController = [segue destinationViewController];
        
        Swale *swale = navController.viewControllers[0];
        swale.clickedSegment_S = clickedSegment_A;
        swale.currentImage_S = plainImage2;
        swale.originalImage_S = _userImage_A;
        swale.seguedFromTileDetection = true;
        swale.groupNumber = self.groupNumber;
        swale.IPAddress = self.IPAddress;
        
        
        PermeablePaver * permeablepaver = navController.viewControllers[1];
        permeablepaver.clickedSegment_PP = clickedSegment_A;
        permeablepaver.currentImage_PP = plainImage2;
        permeablepaver.originalImage_PP = _userImage_A;
        permeablepaver.seguedFromTileDetection = true;
        permeablepaver.title = @"Permeable Paver";
        permeablepaver.groupNumber = self.groupNumber;
        permeablepaver.IPAddress = self.IPAddress;
        
        
        GreenRoof *greenRoof = navController.viewControllers[2];
        greenRoof.clickedSegment_GR = clickedSegment_A;
        greenRoof.currentImage_GR  = plainImage2;
        greenRoof.originalImage_GR  = _userImage_A;
        greenRoof.seguedFromTileDetection = true;
        greenRoof.groupNumber = self.groupNumber;
        greenRoof.IPAddress = self.IPAddress;
        
        
        RainBarrel *rainBarrel = navController.viewControllers[3];
        rainBarrel.clickedSegment_RB = clickedSegment_A;
        rainBarrel.currentImage_RB = plainImage2;
        rainBarrel.originalImage_RB = _userImage_A;
        rainBarrel.seguedFromTileDetection = true;
        rainBarrel.groupNumber = self.groupNumber;
        rainBarrel.IPAddress = self.IPAddress;
        
        
        GreenCorners * greenCorners =navController.viewControllers[4];
        greenCorners.title = @"Green Corners";
        greenCorners.clickedSegment_GC = clickedSegment_A;
        greenCorners.originalImage = _userImage_A;
        greenCorners.processedImage = plainImage2;
        greenCorners.seguedFromTileDetection = true;
        greenCorners.groupNumber = self.groupNumber;
        greenCorners.IPAddress = self.IPAddress;
        
        saveColors *saveColors = navController.viewControllers[5];
        saveColors.clickedSegment_SC = clickedSegment_A;
        saveColors.seguedFromTileDetection = true;
        saveColors.originalImage_SC = _userImage_A;
        saveColors.currentImage_SC = plainImage2;
        saveColors.title = @"Save Profile";
        saveColors.groupNumber = self.groupNumber;
        saveColors.IPAddress = self.IPAddress;
        
        
     }
    
    if( [[segue identifier] isEqualToString:@"toBack"]){
        TakeAPictureViewController *takeAPictureViewController = [segue destinationViewController];
        takeAPictureViewController.warpedGlobal = currentImage_A;
        takeAPictureViewController.groupNumber= _groupNumber;
        takeAPictureViewController.IPAddress = IPAddress;
        takeAPictureViewController.currentImage_TAP = currentImage_A;
        takeAPictureViewController.userImage_TAP = _userImage_A;
    }

    
}

/*
 * This is the method we call when we want to segue to the Take a Picture Scene
 */
-(void)buttonizeButtonTap:(id)sender{
    [self performSegueWithIdentifier:@"toGI" sender:sender];
}

/*
 * The following code presents userImage in scrollView
 */
- (void) updateScrollView:(UIImage *) img {
    
    UIImageView *newView = [[UIImageView alloc] initWithImage:img];

    CGFloat zoomScale = self.scrollView.zoomScale;
    CGPoint offset = CGPointMake(self.scrollView.contentOffset.x,self.scrollView.contentOffset.y);
    
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
    [self.scrollView addSubview:newView];
    self.scrollView.zoomScale = zoomScale;
    self.scrollView.contentOffset = offset;

    //Set image on the scrollview
}

- (IBAction)toCalibrate:(id)sender {
    [self performSegueWithIdentifier:@"toGI" sender:sender];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageView;
}

#pragma mark - IBAction

- (void) setHSVValues {
    
    int hsvDefault[] = {10, 80, 50, 200, 50, 255,  115 ,120, 97 ,226 ,112 ,240, 90, 110, 40, 100, 120, 225, 0, 15, 30, 220, 50, 210, 15, 90, 35, 200, 35, 130};
    
    [CVWrapper setHSV_Values:hsvDefault];
    
}
- (IBAction)addGi:(id)sender {
    UIButton * clickedButton = (UIButton*)sender;
    
    for( UIButton * button in addButtons){
        if( button.tag == clickedButton.tag ){
            button.selected = !button.selected;
            if( button.selected == true )
                pressedButton = button.tag;
            else
                pressedButton = -1;
        }else{
            button.selected = false;
        }
    }
    
    NSLog(@"Pressed button is %i", pressedButton);
}

- ( void )getTrialNumbers{
    NSURL *server;
    server = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http://" ,IPAddress]];
    
    NSString *content;
    NSString *stringText = [NSString stringWithFormat:@"getNextTrial.php?studyID=%@", _groupNumber];
    NSError *errorMessage;
    content = [NSString stringWithContentsOfURL:[NSURL URLWithString: stringText relativeToURL:server]                                              encoding:NSUTF8StringEncoding error:&errorMessage];
    NSLog(@"ERROR MESSAGE -- %@\n", errorMessage);
    
    if( errorMessage != NULL){ // Error Happened
        [self failedToSend];
    }else{
        content = [content stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        trialNumbers = [content componentsSeparatedByString:@"\n"];
    }
}

-( void) overwrite: (NSString*)trialToOverwritre{
    NSURL *server;
    server = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http://" ,IPAddress]];
    
    
    NSString * resultNEW=@"";
    for( Coordinate * coord in swaleCoordinates){
        resultNEW = [resultNEW stringByAppendingFormat:@"0 %d %d ", [coord getX], [coord getY]];
    }
    
    for( Coordinate * coord in rainBarrelCoordinates){
        resultNEW = [resultNEW stringByAppendingFormat:@"1 %d %d ", [coord getX], [coord getY]];
    }
    for( Coordinate * coord in greenRoofCoordinates){
        resultNEW = [resultNEW stringByAppendingFormat:@"2 %d %d ", [coord getX], [coord getY]];
    }
    for( Coordinate * coord in permeablePaverCoordinates){
        resultNEW = [resultNEW stringByAppendingFormat:@"3 %d %d ", [coord getX], [coord getY]];
    }

    NSString *escapedFileContents2 = [resultNEW stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSLog(@"ESCAPED FILE CONTENTS -- CHANGED %@", escapedFileContents2);

    
    NSString *content;
    //while content doesn't have anything assigned to it
    //while( !content ){

    NSString *stringText = [NSString stringWithFormat:@"overwriteTrial.php?studyID=%@&trialID=%@&map=%@", _groupNumber, trialID, escapedFileContents2];
    NSError *errorMessage;
    content = [NSString stringWithContentsOfURL:[NSURL URLWithString: stringText relativeToURL:server]                                              encoding:NSUTF8StringEncoding error:&errorMessage];
    NSLog(@"ERROR MESSAGE -- %@\n", errorMessage);
    NSLog(@"CONTENT -- %@\n", content);
    if( errorMessage != NULL){ // Error Happened
        [self failedToSend];
    }else{
        [self succeededToSend];
    }
    
}

#pragma -mark Back Button
- (IBAction)retakePicture:(id)sender {
    [self buttonizeButtonTap2:self];
}

#pragma -mark Sending Data
- (IBAction)send:(id)sender {
    // Make sure IP address is able to connect and get the NSArray of the trial numbers of that Group Number / Study ID
    [self getTrialNumbers];
    
    
    if(!trialNumbers){ //unaable to send
        [self failedToSend];
        return;
    }
    
    
    NSString* suggestedTrailNumber = @"";
    if( [[trialNumbers objectAtIndex:0]isEqualToString:@""]){ // This is the first trial of this Group Number /  Study ID
        suggestedTrailNumber = @"0";
    }else{
        for(NSString* num in trialNumbers)
            NSLog(@"%@",num);
        
        suggestedTrailNumber = [suggestedTrailNumber stringByAppendingFormat:@"%ld",(long)[[trialNumbers objectAtIndex:0] integerValue]+1];
        // Check this before the demo it should return 1 more than the
    }

    // Make Pop Up with all the stuff
    NSString * info = [NSString stringWithFormat: @"Server IP: %@\nGroup Number: %@\nPlease Enter Trial Number Below:", IPAddress, _groupNumber ];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Sending Icon Coordinates" message: info delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 0;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeNumberPad;
    NSString * placeholder = @"We suggest trail number: ";
    alertTextField.placeholder = [placeholder stringByAppendingString:suggestedTrailNumber];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if( [alertView tag] == 0 && buttonIndex == 1){
        trialID = [[alertView textFieldAtIndex:0] text];
        
        Boolean overwrite = false;
        for( NSString * trialId in trialNumbers){
            if( [trialId isEqualToString:trialID]){ // They want to overwrite
                overwrite = true;
            }
        }
        
        if( overwrite ){
            NSString* overwriteMessage = [@"" stringByAppendingFormat:@"There is aleady a trial %@ in the server, would you like to overwrite it?" , trialID];
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Overwriting Trial" message:overwriteMessage delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
            alert.tag = 2;
            [alert show];
        }else{
            trialID = [[alertView textFieldAtIndex:0] text];
            [self sendData];
            NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
        }
        
        
        // TODO
        //      Check if entered trail number has already been used in the server
        //          if so, another alert view to ask if they want to overwrite
    }
    
    if([alertView tag] == 2 && buttonIndex == 1) {
        [self overwrite:trialID];
    }
}

-(void)sendData{
    
    
    NSLog(@"%@",IPAddress);
    NSURL *server;
    server = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http://" ,IPAddress]];
    
    
    // OH Results becomes different since we changed it... make dummy one
    /*
    char results[5000];
    [CVWrapper analysis:currentImage_A studyNumber: [_groupNumber integerValue] trialNumber:[trialID integerValue] results: &results];
    */
    /*
     results[0] = '0';
     results[1] = ' ';
     results[2] = '8';
     results[1] = ' ';
     */
    
    // get rid of trailing 'space' character in results string
    /*
    int i = 0;
    while(results[i] != '\0') {
        if(results[i+1] == '\0')
            results[i] = '\0';
        i++;
    }
    */
    
    // Making the result
    
    NSString * resultNEW=@"";
    for( Coordinate * coord in swaleCoordinates){
        resultNEW = [resultNEW stringByAppendingFormat:@"0 %d %d ", [coord getX], [coord getY]];
    }
    for( Coordinate * coord in rainBarrelCoordinates){
        resultNEW = [resultNEW stringByAppendingFormat:@"1 %d %d ", [coord getX], [coord getY]];
    }
    for( Coordinate * coord in greenRoofCoordinates){
        resultNEW = [resultNEW stringByAppendingFormat:@"2 %d %d ", [coord getX], [coord getY]];
    }
    for( Coordinate * coord in permeablePaverCoordinates){
        resultNEW = [resultNEW stringByAppendingFormat:@"3 %d %d ", [coord getX], [coord getY]];
    }
    NSLog(@"Result from arrays: %@", resultNEW);
    

    /*
    NSString * resultOriginal=@"";
    for(int y = 0 ; y < i ; y++)
        resultOriginal = [resultOriginal stringByAppendingFormat:@"%c",results[y]];
    
    NSLog(@"the results in char form: %@", resultOriginal);
     */
    // Takes the shortened char[] into a string
    //NSString *temp = [NSString stringWithCString:results encoding:NSASCIIStringEncoding];
    //NSLog(@"the results in char form into a string: %@", resultOriginal);
    
    // Assigns fileContents to the said string ( even though we already have it in temp)
    //NSString *fileContents;
    //fileContents = temp;
    
    // Takes the 'fileContents' ( shortened char result string ) and puts '%' if unrecognized character
    //NSString *escapedFileContents = [fileContents stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    // prints it
    //NSLog(@"ESCAPED FILE CONTENTS -- CV %@", escapedFileContents);
    NSString *escapedFileContents2 = [resultNEW stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
     NSLog(@"ESCAPED FILE CONTENTS -- CHANGED %@", escapedFileContents2);
    
    
    NSString *content;
    //while content doesn't have anything assigned to it
    //while( !content ){
        NSString *stringText = [NSString stringWithFormat:@"mapInput.php?studyID=%@&trialID=%@&map=%@", _groupNumber, trialID, escapedFileContents2];
        NSError *errorMessage;
        content = [NSString stringWithContentsOfURL:[NSURL URLWithString: stringText relativeToURL:server]                                              encoding:NSUTF8StringEncoding error:&errorMessage];
        NSLog(@"ERROR MESSAGE -- %@\n", errorMessage);
        NSLog(@"CONTENT -- %@\n", content);
    if( errorMessage != NULL){ // Error Happened
        [self failedToSend];
    }else{
        [self succeededToSend];
    }
    
}

- ( void ) failedToSend{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Sending Icon Coordinates" message:@"Unable to Send Data to Server, try again. Check if server is on" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    alert.tag = 1;
    [alert show];
}
- ( void ) succeededToSend{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Sucessfully Sent Icons" message:@"New record was created successfully" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    alert.tag = 3;
    [alert show];
}

-(void)buttonizeButtonTap2:(id)sender{
    [self performSegueWithIdentifier:@"toBack" sender:sender];
}

#pragma -mark Drop Down Menu
// Number of thins shown in the drop down

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section{
    return [savedLocationsFromFile_A count];
}

/*
 * Returns the table cell at the specified index path.
 *
 * Return Value
 * An object representing a cell of the table, or nil if the cell is not visible or indexPath is out of range.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    // cell.textLabel.text = @"";
    // indexPath.row -- I'm guessing this gets called multiple times to initialize all the cells
    
    cell.textLabel.text = [savedLocationsFromFile_A nameOfObjectAtIndex:indexPath.row];
    
    return cell;
}

/*
 * Tells the delegate that the specified row is now selected.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    clickedSegment_A = index;
    [self changeColorSetToIndex:indexPath.row];
    
    [self analyze];
    [self changeCoordsFromDropDown];
    [self updateViewedIcons];

}

- (void) changeColorSetToIndex: (int)index{
    clickedSegment_A = index;
    
    [self.dropDown setTitle: [savedLocationsFromFile_A nameOfObjectAtIndex:index]  forState:UIControlStateNormal];

    profileSetting  = [savedLocationsFromFile_A getAllHSVForSavedLocationAtIndex:index]; //-- looking for bugs
    
    [self changeAllHSVVals];
    
    self.tableView.hidden =  TRUE;
}

/*
 * Changes the HSV Values in CVWrapper
 * Does this change the txt file?
 */
- (void) changeAllHSVVals {
    
    int caseNum = 0;
    int vals[30] = {0};

    for( int i = 0 ; i < 30; i++){
        vals[i] = [[profileSetting objectAtIndex:i] integerValue];
    }
    
    [CVWrapper setHSV_Values:vals];
}

- (void) changeFromFile{
    savedLocationsFromFile_A = [savedLocationsFromFile_A changeFromFile];
    [self.tableView reloadData];
}


- (IBAction)dropDownButton:(id)sender {
    if( self.tableView.hidden == TRUE )
        self.tableView.hidden =  FALSE;
    else
        self.tableView.hidden = TRUE;
}
#pragma analyze

- (void) analyze{
    // for testing
    int worked;
    char results[5000];
    worked = [CVWrapper analysis:currentImage_A studyNumber: 0 trialNumber:0 results: results];
    // After they analyze they reset the coords
    
    if(worked) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"We found your pieces!" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        
        
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

- (void) changeCoordsFromDropDown{
    
    swaleCoordinates = [CVWrapper getSwaleCoordinates];
    rainBarrelCoordinates = [CVWrapper getRainBarrelCoordinates];
    permeablePaverCoordinates = [CVWrapper getPermeablePaverCoordinates];
    greenRoofCoordinates = [CVWrapper getGreenRoofCoordinates];

}

- (void) throwErrorAlert:(NSString*) alertString {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:alertString delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    [alert show];
    //self.scrollView.backgroundColor = [UIColor whiteColor]; // hides scrollView ( we don't really need this cause we don't have one in this Scene
}

#pragma -mark Initializing Rules

@end

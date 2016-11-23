//
//  AprilTestSecondViewController.m
//  AprilTest
//
//  Created by Joey Shelley on 4/7/14.
//  Modified by Salvador Ariza
//  Copyright (c) 2014 Joey Shelley. All rights reserved.
//

#import "OutcomeSalienceViewController.h"
#import "AprilTestTabBarController.h"
#import "AprilTestSimRun.h"
#import "AprilTestVariable.h"
#import "FebTestIntervention.h"
#import "FebTestWaterDisplay.h"
#import "AprilTestEfficiencyView.h"
#import "AprilTestNormalizedVariable.h"
#import "AprilTestCostDisplay.h"
#import "FavoriteView.h"
#import "LeastFavoriteView.h"

@interface OutcomeSalienceViewController ()

@end

@implementation OutcomeSalienceViewController
@synthesize studyNum = _studyNum;
@synthesize url = _url;
@synthesize dataWindow = _dataWindow;
@synthesize mapWindow = _mapWindow;
@synthesize titleWindow = _titleWindow;
@synthesize SliderWindow = _SliderWindow;
@synthesize loadingIndicator = _loadingIndicator;
@synthesize scenarioNames = _scenarioNames;
@synthesize maxBudget = _maxBudget;

//structs that will keep track of the highest and lowest costs of Installation and maintenance (for convenience)
typedef struct Value
{
    float highestCost;
    float lowestCost;
}Value;

Value  *installationCost  = NULL;
Value  *maintenanceCost   = NULL;
Value  *privateDamages    = NULL;
Value  *impactNeighbors   = NULL;
Value  *gw_infiltration   = NULL;
Value  *floodedStreets    = NULL;
Value  *standingWater     = NULL;
Value  *efficiency_val    = NULL;

NSArray *sortedArray;
NSArray *lastSortedArray;

NSMutableArray * trialRunSubViews;      //contains all subviews/visualizations added to UIview per trial
NSMutableArray * waterDisplays;
NSMutableArray * maxWaterDisplays;
NSMutableArray * efficiency;
NSMutableArray * lastKnownConcernProfile;
NSMutableArray * bgCols;
NSMutableArray * publicCostDisplays;
NSMutableArray * OverBudgetLabels;
NSMutableArray * favoriteLabels;
NSMutableArray * favoriteViews;
NSMutableArray * leastFavoriteViews;
NSMutableArray * interventionViews;
NSMutableArray * concernRankingTitles;

UILabel *redThreshold;
NSArray *arrStatus;
NSMutableDictionary *scoreColors;
int sortChosen = 0;
int lastMoved = 0;
int trialNum = 0;
int trialOffset = 0;
int numberOfTrialsLoaded = 0;
bool passFirstThree = FALSE;
float kOFFSET_FOR_KEYBOARD = 425.0;
float offsetForMoving = 0.0;
float originalOffset = 0.0;
int maxDamagesReduced = 33000;
UITextField *edittingTX;
UITextField *SortPickerTextField;
NSTimer *scrollingTimer = nil;
UILabel  *investmentBudget;
UILabel  *interventionCap;
UILabel  *WaterDepthOverStorm;
UISlider *BudgetSlider;
UISlider *StormPlaybackWater;
UISlider *StormPlaybackInterv;
UIPickerView *SortType;
UITapGestureRecognizer *tapGestureRecognizer;

//Important values that change elements of objects
float thresh;
int hours = 0;
int hoursAfterStorm;


//budget limits set by the application
NSString *minBudgetLabel;
NSString *maxBudgetLabel;
float setBudget   = 150000;          //max budget set by user
float min_budget_limit = 0;
float max_budget_limit = 17000000;


//length of the budget bars set by the change in the budget slider
int dynamic_cd_width;
float maxPublicInstallNorm;

@synthesize currentConcernRanking = _currentConcernRanking;

#pragma mark View Lifecycle Functions

// called everytime tab is switched to this view
// necessary in case currentSession changes, i.e. is disconnected and reconnected again
- (void)viewDidAppear:(BOOL)animated {
    
    //log switch in screens to log file
    AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
    thresh = tabControl.threshVal;  //obtain thresh value from parentview controller
    
    NSString *logEntry = [tabControl generateLogEntryWith:@"\tSwitched To \tOutcome Salience View Screen"];
    [tabControl writeToLogFileString:logEntry];
    
    [super viewDidAppear:animated];
    
    if (lastSortedArray == nil || [sortedArray isEqualToArray:lastSortedArray] == NO || numberOfTrialsLoaded < tabControl.trialNum){
        [self drawMultipleTrials];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    _studyNum = tabControl.studyNum;
    _url = tabControl.url;
    
    
    trialRunSubViews        = [[NSMutableArray alloc] init];
    waterDisplays           = [[NSMutableArray alloc] init];
    maxWaterDisplays        = [[NSMutableArray alloc] init];
    efficiency              = [[NSMutableArray alloc] init];
    _scenarioNames          = [[NSMutableArray alloc] init];
    publicCostDisplays      = [[NSMutableArray alloc] init];
    OverBudgetLabels        = [[NSMutableArray alloc] init];
    favoriteLabels          = [[NSMutableArray alloc] init];
    favoriteViews           = [[NSMutableArray alloc] init];
    leastFavoriteViews      = [[NSMutableArray alloc] init];
    interventionViews       = [[NSMutableArray alloc] init];
    concernRankingTitles    = [[NSMutableArray alloc] init];
    
    _mapWindow.delegate = self;
    _dataWindow.delegate = self;
    _titleWindow.delegate = self;
    _SliderWindow.delegate = self;
    bgCols = [[NSMutableArray alloc] init];
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _loadingIndicator.center = CGPointMake(512, 300);
    _loadingIndicator.color = [UIColor blueColor];
    [self.view addSubview:_loadingIndicator];

     arrStatus = [[NSArray alloc] initWithObjects:@"Trial Number", @"My Score", @"Investment", @"Damage Reduction",@"Intervention Capacity", @"Water Flow", @"Max Flooded Area", @"Impact on my Neighbors", @"Efficiency of Intervention", @"Groundwater Infiltration", nil];
    

    if (tabControl.SortingEnabled == YES){
        //if sorting is enabled, add "Sort By" UILabel
        UILabel *sortByLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 95, 58, 21)];
        sortByLabel.text = @"Sort by";
        [self.view addSubview:sortByLabel];
        
        //if sorting is enable, add it to subview
        SortPickerTextField = [[UITextField alloc] initWithFrame:CGRectMake(76, 92, 199, 30)];
        SortPickerTextField.text = [NSString stringWithFormat:@" %@", arrStatus[sortChosen]];
        
        UIColor *borderColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        SortPickerTextField.layer.borderColor = borderColor.CGColor;
        SortPickerTextField.layer.borderWidth = 1.0;
        SortPickerTextField.layer.cornerRadius = 5.0;
        SortPickerTextField.delegate = self;
        [self.view addSubview:SortPickerTextField];
        
        if (SortType == nil){
            SortType = [[UIPickerView alloc] initWithFrame:CGRectMake(80, 120, 300, 100)];
            SortType.backgroundColor = [UIColor whiteColor];
            SortType.layer.borderWidth = 1;
            [SortType setDataSource:self];
            [SortType setDelegate:self];
            [SortType setShowsSelectionIndicator:YES];
            
        }
    }
    
    
    scoreColors = [[NSMutableDictionary alloc] initWithObjects:
                   [NSArray arrayWithObjects:
                     [UIColor colorWithHue:.3 saturation:.6 brightness:.9 alpha: 0.5],
                     [UIColor colorWithHue:.31 saturation:.6 brightness:.91 alpha: 0.5],
                     [UIColor colorWithHue:.32 saturation:.6 brightness:.92 alpha: 0.5],
                     [UIColor colorWithHue:.33 saturation:.6 brightness:.93 alpha: 0.5],
                     [UIColor colorWithHue:.35 saturation:.8 brightness:.6 alpha: 0.5],
                    [UIColor colorWithHue:.36 saturation:.8 brightness:.61 alpha: 0.5],
                    [UIColor colorWithHue:.37 saturation:.8 brightness:.62 alpha: 0.5],
                    [UIColor colorWithHue:.38 saturation:.8 brightness:.63 alpha: 0.5],
                     [UIColor colorWithHue:.4 saturation:.8 brightness:.3 alpha: 0.5],
                     [UIColor colorWithHue:.65 saturation:.8 brightness:.6 alpha: 0.5],
                     [UIColor colorWithHue:.6 saturation:.8 brightness:.3 alpha: 0.5],
                     [UIColor colorWithHue:.6 saturation:.0 brightness:.3 alpha: 0.5],
                     [UIColor colorWithHue:.6 saturation:.0 brightness:.9 alpha: 0.5],
                    [UIColor colorWithHue:.55 saturation:.8 brightness:.9 alpha: 0.5], nil]  forKeys: [[NSArray alloc] initWithObjects: @"installCost", @"publicCostI", @"publicCostM", @"publicCostD", @"damageReduction", @"privateCostI", @"privateCostM", @"privateCostD",  @"efficiencyOfIntervention", @"animatedWaterViewer", @"totalAreaFlooded", @"groundwaterInfiltration", @"impactingMyNeighbors", @"capacity", nil] ];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [self budgetUpdated];

    // automatically send Momma the favorited trial when connection begins
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendFavorite)
                                                 name:@"sendFavorite"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendLeastFavorite)
                                                 name:@"sendLeastFavorite"
                                               object:nil];
    
}


- (void) viewWillAppear:(BOOL)animated{
    AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
    _currentConcernRanking = tabControl.currentConcernRanking;
    sortedArray = [_currentConcernRanking sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSInteger first = [(AprilTestVariable*)a currentConcernRanking];
        NSInteger second = [(AprilTestVariable*)b currentConcernRanking];
        if(first > second) return NSOrderedAscending;
        else return NSOrderedDescending;
    }];
    
    //determine whether or not changes were made to the concern profile
    //also make sure same number of trials loaded before are the number of trials currently on device
    if (lastSortedArray != nil && [sortedArray isEqualToArray:lastSortedArray] && numberOfTrialsLoaded ==tabControl.trialNum) {
        //NSLog(@"No changes made on concern profile\n");
        
        //make sure all the views are in the proper offsets they were in before leaving the view
        CGPoint offset = _mapWindow.contentOffset;
        offset.y = _dataWindow.contentOffset.y;
        CGPoint titleOffset = _titleWindow.contentOffset;
        titleOffset.x = _dataWindow.contentOffset.x;
        [_titleWindow setContentOffset:titleOffset];
        [_SliderWindow setContentOffset:titleOffset];
        [_mapWindow setContentOffset:offset];
        
        
    }
    else{
        
        for (UIView *view in [_titleWindow subviews]){
            [view removeFromSuperview];
        }
        for( UIView *view in [_dataWindow subviews]){
            [view removeFromSuperview];
        }
        for (UIView *view in [_mapWindow subviews]){
            [view removeFromSuperview];
        }
        for (UIView *view in [_SliderWindow subviews]){
            [view removeFromSuperview];
        }
        
        [concernRankingTitles removeAllObjects];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(drawSingleTrial)
                                                 name:@"drawSingleTrial"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(drawMultipleTrials)
                                                 name:@"drawMultipleTrials"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(budgetUpdated)
                                                 name:@"updateBudget"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFloodingThreshold)
                                                 name:@"updateFloodingThreshold"
                                               object:nil];
    
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"drawSingleTrial" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"drawMultipleTrials" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"budgetChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateFloodingThreshold" object:nil];
    
    
    AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
    
    //keep a copy of concern profile prior to leaving view
    lastSortedArray = [[NSArray alloc] initWithArray:sortedArray];
    numberOfTrialsLoaded = tabControl.trialNum;
    
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextField Functions

/*
    Description: Handles keyboard input from Texfields and determines when textfield displaying
                 Sort categories is touched in order to reveal UIPickerView of possible sort types
 
    Input:       Touch-inside a UITexfield
    Output:      If SortTypePickerView, instead of animating keyboard animates the UIPickerView
 
*/

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textView
{
    if (textView == SortPickerTextField){
        SortType.frame = CGRectMake(80, 120, 300, SortType.frame.size.height);
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.50];
        [UIView setAnimationDelegate:self];
        SortType.frame = CGRectMake(80, 120, 300, SortType.frame.size.height);
        [self.view addSubview:SortType];
        [UIView commitAnimations];
        return NO;
    }
    else{
        return YES;
    }
}


- (void) textFieldDidEndEditing:(UITextField *)textField{
    if (textField != SortPickerTextField){
        NSNumber *trialNumEditted = [self getTrialNumFrom:textField];
        
        if (trialNumEditted == [NSNumber numberWithInt:-1]) {
            //NSLog(@"Editted a TextField that's neither a Trial Number Text Box nor the Sort Picker Text Field\n");
        }
        else{
            //log the change of trial name for trial number
            AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
            NSString *logEntry = [tabControl generateLogEntryWith:[NSString stringWithFormat:@"\tTrial %@ Name Changed to \"%@\"",trialNumEditted, textField.text]];
            [tabControl writeToLogFileString:logEntry];
        }
    }
}


-(void)keyboardWillShow {
    // Animate the current view out of the way
    NSMutableString *content = [[NSMutableString alloc] init];
    [content appendString: @"Before new naming:\n"];
    for(int i =0; i < _scenarioNames.count; i++){
        UITextField *tx =[_scenarioNames objectAtIndex:i];
        
        [content appendString: tx.text];
        [content appendString:@"\n"];
    }
    
    [content appendString:@"\n"];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"logfile_simResults.txt"];
    
    //create file if it doesn't exist
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileName])
        [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    [file seekToEndOfFile];
    [file writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
    
    
    for (int i = 0; i < _scenarioNames.count; i++){
        UITextField *tx = [_scenarioNames objectAtIndex:i];
        if ( [tx isEditing]){
            if ((tx.frame.origin.y - _mapWindow.contentOffset.y) > (self.view.frame.size.height - 450)){
                lastMoved = 1;
                edittingTX = tx;
                [self setViewMovedUp:YES];
            }
        }
    }
    
}

-(void)keyboardWillHide {
    NSMutableString *content = [[NSMutableString alloc] init];
    [content appendString: @"After naming:\n"];
    for(int i =0; i < _scenarioNames.count; i++){
        UITextField *tx =[_scenarioNames objectAtIndex:i];
        
        [content appendString: tx.text];
        [content appendString:@"\n"];
    }
    [content appendString:@"\n"];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"logfile_simResults.txt"];
    
    //create file if it doesn't exist
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileName])
        [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    [file seekToEndOfFile];
    [file writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
    if(lastMoved == 1) [self setViewMovedUp:NO];
    lastMoved = 0;
    
    
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGPoint rect = self.mapWindow.contentOffset;
    CGPoint rect2 = self.dataWindow.contentOffset;
    
    if (movedUp){
        originalOffset = rect.y;
        rect.y += (edittingTX.frame.origin.y + _mapWindow.contentOffset.y) - 225;
        rect2.y = rect.y;
    }
    else{
        // revert back to the normal state.
        rect.y = originalOffset;
        rect2.y = originalOffset;
    }
    self.mapWindow.contentOffset = rect;
    self.dataWindow.contentOffset = rect2;
    
    [UIView commitAnimations];
}


#pragma mark Getter Functions


/*
    Description: Returns the index position in a NSMutableArray of NSDictionaries that holds
                 a particular UIview. This is used to quickly reference where the UIView is drawn 
                 on the OutcomeSalienceView Controller.
 
    Input:       A UIView
    Output:      NSNumber -  referring to the position the UIView is drawn on
                 -1 - if the UIView isn't contained in any dictionary (not a part of the trial UIViews)
 
 */
- (NSNumber*) getTrialNumFrom:(id) view{
    NSNumber* trialFound = [NSNumber numberWithInt:-1];
    
    //attempting to find a textfield (trial text box names)
    if ([view isKindOfClass:[UITextField class]]){
        UITextField* txt = (UITextField*)view;
        UITextField *currTxT;
        
        for (int i = 0; i < trialRunSubViews.count; i++){
            currTxT   = [[trialRunSubViews objectAtIndex:i] objectForKey:@"TrialTxTBox"];
            
            //return trialNumber of view if it is found
            if ([currTxT isEqual:txt]){
                trialFound = [[trialRunSubViews objectAtIndex:i] valueForKey:@"TrialNum"];
                break;
            }
        }
        
    }
    
    return trialFound;
}

/*
 Description: Returns NSDictionary object with the contents of a particular trial number
 
 Input:       NSNumber - A trial number
 Output:      NSDictionary -  the object itself
              nil - if the particular trial doesnt exist
 */

- (NSDictionary*) getDictionaryFromTrial: (NSNumber*) trial{
    NSDictionary *dict = nil;
    NSNumber *dictTrial;
    for (int i = 0; i < trialRunSubViews.count; i++) {
        dictTrial = [[trialRunSubViews objectAtIndex:i] valueForKey:@"TrialNum"];
        
        if ([dictTrial isEqualToValue:trial]){
            dict = [trialRunSubViews objectAtIndex:i];
            break;
        }
    }
    
    return dict;
}


/*
 Description: Modifies a CGRect object to include in its 4 parameters, the end points of its
              frame. Esentially, where the frame begins and where it ends. The origin remains the same
              but the width and height components include the offset of the origin points as well.
 
 Input:       (CGRect) - a frame
 Output:      (CGRect) - a modified frame
 */

- (CGRect) getRectPositionsFrom:(CGRect) viewRect{
    CGRect visibleRect = CGRectMake(viewRect.origin.x, viewRect.origin.y, viewRect.origin.x + viewRect.size.width, viewRect.origin.y + viewRect.size.height);
    return visibleRect;
}

#pragma mark Logging Functions

/*
 Description: Logs the visible trials and variables after a successful scroll
 
 Input:       A scroll
 Output:      NSString write to a log file
 */
- (void) logVisibleTrialsandVariables{
    AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
    
    NSString *logEntry = @"\tTrials Visible Are\t";
    
    CGRect mapWindow = [self getRectPositionsFrom:_mapWindow.bounds];
    //determine which trials are visible by viewing if intervention views are visible within the bounds of the scrollview
    for (int i = 0; i < trialRunSubViews.count; i++){
        UIImageView *intervImgView = [[trialRunSubViews objectAtIndex:i] objectForKey:@"InterventionImgView"];
        CGRect imgViewRect = [self getRectPositionsFrom:intervImgView.frame];
        
        
        //if map is completely visible in the scrollview
        if ((mapWindow.origin.x    <= imgViewRect.origin.x)     &&
            (mapWindow.origin.y    <= imgViewRect.origin.y)     &&
            (mapWindow.size.width  >= imgViewRect.size.width)   &&
            (mapWindow.size.height >= imgViewRect.size.height))  {
            
            NSNumber *trialNum = [[trialRunSubViews objectAtIndex:i] objectForKey:@"TrialNum"];
            
            logEntry = [logEntry stringByAppendingString:[NSString stringWithFormat:@"%d,", [trialNum intValue]]];
        }
        
    }
    
    logEntry = [tabControl generateLogEntryWith:logEntry];
    
    [tabControl writeToLogFileString:logEntry];
    
    NSString *logEntry2 = @"\tVisible Concern Rankings\t";
    
    CGRect dataWindowRect = [self getRectPositionsFrom:_dataWindow.bounds];
    //determine which concern rankings are visible
    for (int i = 0; i < concernRankingTitles.count; i++){
        UILabel *currLabel   = [concernRankingTitles objectAtIndex:i];
        CGRect currLabelRect = [self getRectPositionsFrom:currLabel.frame];
        
        if ((dataWindowRect.origin.x    <= currLabelRect.origin.x)     &&
            (dataWindowRect.size.width  >= currLabelRect.size.width)   &&
            (dataWindowRect.size.height >= currLabelRect.size.height))  {
            
            logEntry2 = [logEntry2 stringByAppendingString:[NSString stringWithFormat:@"%@,", currLabel.text]];
        }

    }
    
    logEntry2 = [tabControl generateLogEntryWith:logEntry2];
    
    [tabControl writeToLogFileString:logEntry2];
}

#pragma mark Gesture Recognizers

- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
    //Code to handle the gesture
    if ([SortType isHidden]){
        //NSLog(@"View Doesn't Exist");
    }
    else{
        [SortType removeFromSuperview];
    }
}



- (void)doneTouched:(UIBarButtonItem *)sender
{
    // hide the picker view
    UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Hey!!" message:@"Its Dynamic" delegate:self cancelButtonTitle:@"Just Leave" otherButtonTitles:nil, nil];
    [alert show];
    [SortType resignFirstResponder];
    
    // perform some action
    //Handle the sort afterwards
    [_loadingIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];
    [self handleSort:(int)sortChosen];
    [_loadingIndicator stopAnimating];
}

/*
- (IBAction)pullNextRun:(id)sender {
    [_loadingIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];
    [self loadNextSimulationRun];
}*/


#pragma mark Budget Updates

/*
 Description: Removes "Over Budget: " labels found underneath Installation Cost (iff installation cost is greater than set budget)
 
 Input:       none
 Output:      removed UILabels
 */
-(void) removeBudgetLabels{
    for (int i = 0; i < OverBudgetLabels.count; i++){
        UILabel *label = [OverBudgetLabels objectAtIndex:i];
        [label removeFromSuperview];
    }
    [OverBudgetLabels removeAllObjects];
}

/*
 Description: Updates "Over Budget: " labels to reflect new/updated set budget or
 
 Input:       none
 Output:      updated UILabels
 */
- (void) updateBudgetLabels{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:@","];
    
    //remove all old labels
    [self removeBudgetLabels];
    
    
    int width = 0;
    for (int i = 0; i < _currentConcernRanking.count; i++){
        AprilTestVariable * currentVar =[sortedArray objectAtIndex:i];
        if ([currentVar.name compare: @"installCost"] == NSOrderedSame)
            break;
        else
            width += currentVar.widthOfVisualization;
    }
    
    //create a new label for any trials that are over the budget
    for (int i = 0; i < trialRunSubViews.count; i++){
        //AprilTestSimRun *simRun = [trialRuns objectAtIndex:i];
        AprilTestSimRun *simRun= [[trialRunSubViews objectAtIndex:i] valueForKey:@"TrialRun"];
        
        if (simRun.landscapeCostTotalInstall > setBudget){
            UILabel *valueLabel;
            [self drawTextBasedVar:[NSString stringWithFormat: @"Over budget by $%@", [formatter stringFromNumber: [NSNumber numberWithInt: (int) (simRun.landscapeCostTotalInstall-setBudget)]] ] withConcernPosition:width+25 andyValue:i *175 + 80 andColor:[UIColor redColor] to:&valueLabel];
            
            [OverBudgetLabels addObject:valueLabel];
        }
    }
}

/*
 Description: Updates the set budget on local Budget Slider to that of a value
 passed by Momma Bird. Also takes care of all the necessary updates
 and function calls due to the change in set budget (new over budget labels, etc..)
 
 Input:       none
 Output:      Updated ViewController configuration
 (float) newSetBudget
 */

- (void)budgetUpdated {
    // method called when budget is updated from Momma
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    [self updateBudgetSliderTo:tabControl.budget];
    
    //update the width of the public install cost bars (make sure it isn't 0)
    dynamic_cd_width = [self getWidthFromSlider:BudgetSlider toValue:setBudget];
    
    //only update all labels/bars if Static normalization is switched on
    if (!_DynamicNormalization.isOn){
        [self normalizaAllandUpdateStatically];
    }
}

//selector method that handles a change in value when budget changes (slider under titles)
-(void)BudgetChanged:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    int value = slider.value;
    //-- Do further actions
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:@","];
    
    value = 1000.0 * floor((value/1000.0)+0.5);
    
    investmentBudget.text = [NSString stringWithFormat:@"Set Budget: $%@", [formatter stringFromNumber:[NSNumber numberWithInt:value]]];
    setBudget = value;
    
    //update the width of the public install cost bars (make sure it isn't 0)
    dynamic_cd_width = [self getWidthFromSlider:BudgetSlider toValue:setBudget];
    
    //only update all labels/bars if Static normalization is switched on
    if (!_DynamicNormalization.isOn){
        [self normalizaAllandUpdateStatically];
    }
}

//method that updates Budget slider with animation and writes the new value to a label WITHOUT making a change to the max set by the User
-(void) updateBudgetSliderTo: (float) newValue
{
    [BudgetSlider setValue:newValue animated:YES];
    setBudget = newValue;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:@","];
    
    investmentBudget.text = [NSString stringWithFormat:@"Set Budget: $%@", [formatter stringFromNumber:[NSNumber numberWithInt:newValue]]];
}

#pragma mark Storm Hour Updates

-(void)StormHoursChangedOutcome:(id)sender{
    UISlider *slider = (UISlider*)sender;
    hours= slider.value;
    StormPlaybackWater.value = hours;
    StormPlaybackInterv.value = hours;
    //-- Do further actions
    
    hoursAfterStorm = floorf(hours);
    if (hoursAfterStorm % 2 != 0) hoursAfterStorm--;
    
    interventionCap.text = [NSString stringWithFormat:@"Storm Playback: %@ hours", [NSNumber numberWithInt:hours]];
    WaterDepthOverStorm.text = [NSString stringWithFormat:@"Storm Playback: %@ hours", [NSNumber numberWithInt:hours]];
}

- (void)StormHoursChosenOutcome:(NSNotification *)notification {
    
    [_loadingIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];
    NSMutableString * content = [NSMutableString alloc];
    
    AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
    
    //log the change of storm hours
    NSString *logEntry = [tabControl generateLogEntryWith:[NSString stringWithFormat:@"\tExamined hours after storm for hour:\t%@", [NSNumber numberWithInt:StormPlaybackInterv.value]]];
    [tabControl writeToLogFileString:logEntry];
    
    for (int i = 0; i < [trialRunSubViews count]; i++){
        AprilTestSimRun *simRun = [[trialRunSubViews objectAtIndex:i] valueForKey:@"TrialRun"];
        
        /* Update Intervention Capacity */
        [[tabControl.efficiencyViewsInTab objectAtIndex:simRun.trialNum] updateViewForHour:hoursAfterStorm];
        UIImageView *EfficiencyView = [[trialRunSubViews objectAtIndex:i] valueForKey:@"EfficiencyView"];
        UIImage *newEfficiencyViewImage  = [[tabControl.efficiencyViewsInTab objectAtIndex:simRun.trialNum] viewforEfficiencyToImage];
        [EfficiencyView setImage:newEfficiencyViewImage];
        
        /* update water display */
        //Access the map from the tab controller and update with the newest hours on water depth
        ((FebTestWaterDisplay*)[tabControl.waterDisplaysInTab objectAtIndex:simRun.trialNum]).thresholdValue = thresh;
        [[tabControl.waterDisplaysInTab objectAtIndex:simRun.trialNum] fastUpdateView:hoursAfterStorm];
        
        //Update water depth image from the current trial
        UIImageView *waterDepthView = [[trialRunSubViews objectAtIndex:i] valueForKey:@"WaterDepthView"];
        UIImage *newWaterDepth = [tabControl viewToImageForWaterDisplay:[tabControl.waterDisplaysInTab objectAtIndex:simRun.trialNum]];
        [waterDepthView setImage:newWaterDepth];
    }
    
    [_mapWindow setScrollEnabled:TRUE];
    [_dataWindow setScrollEnabled:TRUE];
    [_titleWindow setScrollEnabled:TRUE];
    [_loadingIndicator stopAnimating];
    
    
    NSDate *myDate = [[NSDate alloc] init];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    NSString *prettyVersion = [dateFormat stringFromDate:myDate];
    
    //if(notification == UIControlEventTouchUpInside || notification == UIControlEventTouchUpOutside){
    content = [content initWithFormat:@"%@\tHours after storm set to: %d",prettyVersion, hoursAfterStorm];
    
    //    NSLog(content);
    [content appendString:@"\n\n"];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"logfile_simResults.txt"];
    
    //create file if it doesn't exist
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileName])
        [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    [file seekToEndOfFile];
    [file writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];;
    //}
}


#pragma mark UISlider Functions

//will draw sliders on a scrollview right below the titles of concern rankings for Water Flow map and Intervention Capacity
-(void) drawSliders{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:@","];
    
    int width = 0;
    int visibleIndex = 0;
    for(int i = 0 ; i <_currentConcernRanking.count ; i++){
        
        AprilTestVariable * currentVar =[sortedArray objectAtIndex:i];
        UILabel * currentVarLabel = [[UILabel alloc] init];
        currentVarLabel.backgroundColor = [scoreColors objectForKey:currentVar.name];
        currentVarLabel.frame = CGRectMake(width, 2, currentVar.widthOfVisualization, 70);
        currentVarLabel.font = [UIFont boldSystemFontOfSize:15.3];
        
        
        if([currentVar.name compare: @"installCost"] == NSOrderedSame){
            CGRect frame  = CGRectMake(width + 25, 16, 160, 40);
            BudgetSlider = [[UISlider alloc] initWithFrame:frame];
            [BudgetSlider addTarget:self action:@selector(BudgetChanged:) forControlEvents:UIControlEventValueChanged];
            [BudgetSlider setBackgroundColor:[UIColor clearColor]];
            BudgetSlider.minimumValue = min_budget_limit;
            BudgetSlider.maximumValue = max_budget_limit;
            BudgetSlider.continuous = YES;
            [BudgetSlider setValue:setBudget animated:YES];
            //[_SliderWindow addSubview:BudgetSlider];
            
            //draw min/max cost labels under slider
            CGRect minCostFrame = CGRectMake(width + 5, 5, currentVar.widthOfVisualization/3, 15);
            UILabel *minCostLabel = [[UILabel alloc] initWithFrame:minCostFrame];
            minCostLabel.font =  [UIFont boldSystemFontOfSize:14.0];
            minCostLabel.text =  minBudgetLabel;
            
            CGRect maxCostFrame = CGRectMake(width + 160, 5, currentVar.widthOfVisualization/3, 15);
            UILabel *maxCostLabel = [[UILabel alloc] initWithFrame:maxCostFrame];
            maxCostLabel.font = [UIFont boldSystemFontOfSize:14.0];
            maxCostLabel.text = maxBudgetLabel;
            
            CGRect currCostFrame = CGRectMake(width + 25, 50, currentVar.widthOfVisualization, 15);
            investmentBudget = [[UILabel alloc] initWithFrame:currCostFrame];
            investmentBudget.font = [UIFont boldSystemFontOfSize:14.0];
            investmentBudget.text = [NSString stringWithFormat:@"Current Budget: $%@", [formatter stringFromNumber:[NSNumber numberWithInt:setBudget]]];
            
            [_SliderWindow addSubview:minCostLabel];
            [_SliderWindow addSubview:maxCostLabel];
            [_SliderWindow addSubview:investmentBudget];
            
        }
        else if ([currentVar.name compare:@"animatedWaterViewer"] == NSOrderedSame){
            CGRect frame = CGRectMake(width, 16, currentVar.widthOfVisualization, 40);
            StormPlaybackWater = [[UISlider alloc] initWithFrame:frame];
            [StormPlaybackWater addTarget:self
                                   action:@selector(StormHoursChangedOutcome:)
                         forControlEvents:UIControlEventValueChanged];
            
            [StormPlaybackWater addTarget:self
                                   action:@selector(StormHoursChosenOutcome:)
                         forControlEvents:UIControlEventTouchUpInside];
            
            [StormPlaybackWater addTarget:self
                                   action:@selector(StormHoursChosenOutcome:)
                         forControlEvents:UIControlEventTouchUpOutside];
            [StormPlaybackWater addTarget:self
                                   action:@selector(StormHoursChosenOutcome:)
                         forControlEvents:UIControlEventTouchCancel];
            
            [StormPlaybackWater setBackgroundColor:[UIColor clearColor]];
            StormPlaybackWater.minimumValue = 0.0;
            StormPlaybackWater.maximumValue = 48;
            StormPlaybackWater.continuous = YES;
            StormPlaybackWater.value = hours;
            
            [_SliderWindow addSubview:StormPlaybackWater];
            
            //draw labels for range of hours
            CGRect minCostFrame = CGRectMake(width + 5, 5, currentVar.widthOfVisualization/5, 15);
            UILabel *minHoursLabel = [[UILabel alloc] initWithFrame:minCostFrame];
            minHoursLabel.font = [UIFont boldSystemFontOfSize:14];
            minHoursLabel.text = [NSString stringWithFormat:@" 0 hrs"];
            
            CGRect maxCostFrame = CGRectMake((width + currentVar.widthOfVisualization) -53, 5, currentVar.widthOfVisualization/4, 15);
            UILabel *maxHoursLabel = [[UILabel alloc] initWithFrame:maxCostFrame];
            maxHoursLabel.font = [UIFont boldSystemFontOfSize:14];
            maxHoursLabel.text = [NSString stringWithFormat:@"48 hrs"];
            
            CGRect currCostFrame = CGRectMake(width + 25, 50, currentVar.widthOfVisualization, 15);
            WaterDepthOverStorm = [[UILabel alloc] initWithFrame:currCostFrame];
            WaterDepthOverStorm.font = [UIFont boldSystemFontOfSize:14.0];
            WaterDepthOverStorm.text = [NSString stringWithFormat:@"Storm Playback: %@ hours", [NSNumber numberWithInt:hours]];
            
            [_SliderWindow addSubview:minHoursLabel];
            [_SliderWindow addSubview:maxHoursLabel];
            [_SliderWindow addSubview:WaterDepthOverStorm];
        }
        else if( [currentVar.name compare:@"capacity"] == NSOrderedSame){
            CGRect frame = CGRectMake(width, 16, currentVar.widthOfVisualization, 40);
            StormPlaybackInterv = [[UISlider alloc] initWithFrame:frame];
            StormPlaybackInterv.minimumValue = 0.0;
            StormPlaybackInterv.maximumValue = 48;
            StormPlaybackInterv.continuous = YES;
            StormPlaybackInterv.value = hours;
            [StormPlaybackInterv setBackgroundColor:[UIColor clearColor]];
            [StormPlaybackInterv addTarget:self
                                    action:@selector(StormHoursChangedOutcome:)
                          forControlEvents:UIControlEventValueChanged];
            
            [StormPlaybackInterv addTarget:self
                                    action:@selector(StormHoursChosenOutcome:)
                          forControlEvents:UIControlEventTouchUpInside];
            
            [StormPlaybackInterv addTarget:self
                                    action:@selector(StormHoursChosenOutcome:)
                          forControlEvents:UIControlEventTouchUpOutside];
            
            [StormPlaybackInterv addTarget:self
                                    action:@selector(StormHoursChosenOutcome:)
                          forControlEvents:UIControlEventTouchCancel];
            
            [_SliderWindow addSubview:StormPlaybackInterv];
            
            //draw labels for range of hours
            CGRect minCostFrame = CGRectMake(width + 5, 5, currentVar.widthOfVisualization/5, 15);
            UILabel *minHoursLabel = [[UILabel alloc] initWithFrame:minCostFrame];
            minHoursLabel.font = [UIFont boldSystemFontOfSize:14];
            minHoursLabel.text = [NSString stringWithFormat:@" 0 hrs"];
            
            CGRect maxCostFrame = CGRectMake((width + currentVar.widthOfVisualization) -53, 5, currentVar.widthOfVisualization/4, 15);
            UILabel *maxHoursLabel = [[UILabel alloc] initWithFrame:maxCostFrame];
            maxHoursLabel.font = [UIFont boldSystemFontOfSize:14];
            maxHoursLabel.text = [NSString stringWithFormat:@"48 hrs"];
            
            CGRect currCostFrame = CGRectMake(width + 25, 50, currentVar.widthOfVisualization, 15);
            interventionCap = [[UILabel alloc] initWithFrame:currCostFrame];
            interventionCap.font = [UIFont boldSystemFontOfSize:14.0];
            interventionCap.text = [NSString stringWithFormat:@"Storm Playback: %@ hours", [NSNumber numberWithInt:hours]];
            
            [_SliderWindow addSubview:minHoursLabel];
            [_SliderWindow addSubview:maxHoursLabel];
            [_SliderWindow addSubview:interventionCap];
        }
        
        else if ([currentVar.name compare: @"damageReduction"] == NSOrderedSame){
            
        } else if ([currentVar.name compare: @"impactingMyNeighbors"] == NSOrderedSame){
            
        } else if ([currentVar.name compare: @"efficiencyOfIntervention"] == NSOrderedSame){
            
        } else if( [currentVar.name compare:@"groundwaterInfiltration"] == NSOrderedSame){
            
        } else if( [currentVar.name compare:@"totalAreaFlooded"] == NSOrderedSame){
            
            
        }
        else {
            currentVarLabel = NULL;
        }
        if(currentVar.widthOfVisualization != 0) visibleIndex++;
        
        if(currentVarLabel != NULL){
            [_SliderWindow addSubview:currentVarLabel];
        }
        width+= currentVar.widthOfVisualization;
    }
    
}


/*
 Description: Gets width (pt) relative to the start of a UISlider and a particular value
              found along the UISlider within its range. Used to draw the budget bars right under 
              the Budget Slider.
 
 Input:       (UISlider*) a Slider
 Output:      (int) the width
              (int) maxWidth of UISlider if value not in range
 */


- (int)getWidthFromSlider:(UISlider *)aSlider toValue:(float) value;
{
    if (value < aSlider.minimumValue){
        return 0;
    }
    
    float sliderRange = aSlider.frame.size.width - aSlider.currentThumbImage.size.width;
    float sliderOrigin = aSlider.frame.origin.x + (aSlider.currentThumbImage.size.width / 2.0);
    
    float sliderValueToPixels = (((value-aSlider.minimumValue)/(aSlider.maximumValue-aSlider.minimumValue)) * sliderRange) + sliderOrigin;
    float sliderValforZero    = ((0/(aSlider.maximumValue-aSlider.minimumValue)) * sliderRange) + sliderOrigin;
    
    int returnLocation = (int)sliderValueToPixels - (int)sliderValforZero;
    if (returnLocation == 0){
        return 1;
    }
    else if(returnLocation > 160){
        return 160;
    }
    else
        return returnLocation;
}


#pragma mark Normalization Functions

/*
 Description: Handles switching from viewing static and dynamic normalized data
 
 Input:       Touch on UISwitch
 Output:      Refreshed data on ViewController
 */
- (IBAction)NormTypeSwitched:(UISwitch *)sender {
    /**
     * Make Sure to update all displays/labels to reflect the change
     */
    
    if ([sender isOn]){
        //alert= [[UIAlertView alloc] initWithTitle:@"Hey!!" message:@"Its Dynamic" delegate:self cancelButtonTitle:@"Just Leave" otherButtonTitles:nil, nil];
        [self removeBudgetLabels];
        [self normalizeAllandUpdateDynamically];
        [self handleSort:sortChosen];
    }
    else{
        //alert= [[UIAlertView alloc] initWithTitle:@"Hey!!" message:@"Its Static" delegate:self cancelButtonTitle:@"Just Leave" otherButtonTitles:nil, nil];
        [self removeBudgetLabels];
        [self normalizaAllandUpdateStatically];
        [self handleSort:sortChosen];
    }
    
}

/*
 Description: Normalizes all trial data and updates view controller to reflect updated
              static normalized data (Absolue)
 
 Input:       none
 Output:      Updated View displaying static normalized data
 */
-(void) normalizaAllandUpdateStatically{
    trialNum = (int)[trialRunSubViews count];
    [self normalizeStatically];
    
    dynamic_cd_width = [self getWidthFromSlider:BudgetSlider toValue:setBudget];
    [self updatePublicCostDisplays: trialNum];
    [self updateBudgetLabels];
    
    //updates the component scores
    for (int i = 0; i < trialNum; i++)
        [self updateComponentScore:i];
}

/*
 Description: Normalizes all trial data and updates view controller to reflect updated
              dynamic normalized data (Best So Far)
 
 Input:       none
 Output:      Updated View displaying static normalized data
 */
-(void) normalizeAllandUpdateDynamically{
    trialNum = (int)[trialRunSubViews count];
    [self normalizeDynamically];
    
    dynamic_cd_width = [self getWidthFromSlider:BudgetSlider toValue:installationCost->highestCost];
    [self updatePublicCostDisplays: trialNum];
    [self updateBudgetLabels];
    
    //updates the component scores
    for (int i = 0; i < trialNum; i++)
        [self updateComponentScore:i];
}

/*
 Description: Normalizes all statically normalized data. Called after newly fetched data is found.
 
 Input:       none
 Output:      none
 */
-(void) normalizeStatically
{
    for (int i = 0; i < trialRunSubViews.count; i++)
    {
        //AprilTestSimRun *someTrial = [trialRuns objectAtIndex:i];
        //AprilTestNormalizedVariable *someTrialNorm = [trialRunsNormalized objectAtIndex:i];
        AprilTestSimRun *someTrial = [[trialRunSubViews objectAtIndex:i] valueForKey:@"TrialRun"];
        AprilTestNormalizedVariable *someTrialNorm = [[trialRunSubViews objectAtIndex:i] valueForKey:@"TrialStatic"];
        
        if (setBudget == 0){ setBudget = .01; }
        
        //public cost
        someTrialNorm.normalizedLandscapeCostInstallPlusMaintenance = ((float)someTrial.landscapeCostInstallPlusMaintenance/(setBudget));
        

    }
    
}
/*
 Description: Normalizes all dynamically normalized data. Called after newly fetched data is found.
 
 Input:       none
 Output:      none
*/
- (void)normalizeDynamically
{
    if (installationCost  == NULL) { installationCost = (Value*)malloc(sizeof(Value));  }
    if (maintenanceCost   == NULL) { maintenanceCost = (Value*) malloc(sizeof(Value));  }
    if (privateDamages    == NULL) { privateDamages = (Value*)malloc(sizeof(Value));    }
    if (impactNeighbors   == NULL) { impactNeighbors = (Value*)malloc(sizeof(Value));   }
    if (gw_infiltration   == NULL) { gw_infiltration = (Value*) malloc(sizeof(Value));  }
    if (floodedStreets    == NULL) { floodedStreets = (Value*) malloc(sizeof(Value));   }
    if (standingWater     == NULL) { standingWater = (Value*) malloc(sizeof(Value));    }
    if (efficiency_val    == NULL) { efficiency_val = (Value*) malloc(sizeof(Value));   }
    
    //Obtain the min and max of the data elements found in a trial
    int i;
    for (i = 0; i < trialRunSubViews.count; i++)
    {
        //AprilTestSimRun  *someTrial     = [trialRuns objectAtIndex:i];
        //AprilTestNormalizedVariable *someTrialNorm = [trialRunsNormalized objectAtIndex:i];
        AprilTestSimRun *someTrial = [[trialRunSubViews objectAtIndex:i] valueForKey:@"TrialRun"];
        AprilTestNormalizedVariable *someTrialNorm = [[trialRunSubViews objectAtIndex:i] valueForKey:@"TrialStatic"];
        
        if (i == 0){
            installationCost->highestCost  =  someTrial.landscapeCostTotalInstall;
            installationCost->lowestCost   =  someTrial.landscapeCostTotalInstall;
            
            maintenanceCost->highestCost   =  someTrial.landscapeCostTotalMaintenance;
            maintenanceCost->lowestCost    =  someTrial.landscapeCostTotalMaintenance;
            
            privateDamages->highestCost    = someTrial.landscapeCostPrivatePropertyDamage;
            privateDamages->lowestCost     = someTrial.landscapeCostPrivatePropertyDamage;
            
            impactNeighbors->highestCost   = someTrial.normalizedLandscapeCumulativeOutflow;
            impactNeighbors->lowestCost    = someTrial.normalizedLandscapeCumulativeOutflow;
            
            gw_infiltration->highestCost   = someTrial.proportionCumulativeNetGIInfiltration;
            gw_infiltration->lowestCost    = someTrial.proportionCumulativeNetGIInfiltration;
            
            floodedStreets->highestCost    = someTrialNorm.normalizedLandscapeCumulativeFloodingOverall;
            floodedStreets->lowestCost     = someTrialNorm.normalizedLandscapeCumulativeFloodingOverall;
            
            standingWater->highestCost     = someTrialNorm.normalizedGreatestDepthStandingWater;
            standingWater->lowestCost      = someTrialNorm.normalizedGreatestDepthStandingWater;
            
            efficiency_val->highestCost    = someTrialNorm.landscapeCumulativeGICapacityUsed;
            efficiency_val->lowestCost     = someTrialNorm.landscapeCumulativeGICapacityUsed;
        }
        
        //public cost
        if (someTrial.landscapeCostTotalMaintenance <= maintenanceCost->lowestCost) { maintenanceCost->lowestCost = someTrial.landscapeCostTotalMaintenance; }
        if (someTrial.landscapeCostTotalMaintenance >= maintenanceCost->highestCost){ maintenanceCost->highestCost = someTrial.landscapeCostTotalMaintenance; }
        
        if (someTrial.landscapeCostTotalInstall <= installationCost->lowestCost){ installationCost->lowestCost = someTrial.landscapeCostTotalInstall; }
        if (someTrial.landscapeCostTotalInstall >= installationCost->highestCost) { installationCost->highestCost = someTrial.landscapeCostTotalInstall; }
        
        
        //private cost
        if (someTrial.landscapeCostPrivatePropertyDamage <= privateDamages->lowestCost){  privateDamages->lowestCost = someTrial.landscapeCostPrivatePropertyDamage; }
        if (someTrial.landscapeCostPrivatePropertyDamage >= privateDamages->highestCost){ privateDamages->highestCost = someTrial.landscapeCostPrivatePropertyDamage; }
        
        //neighbors
        if (someTrial.normalizedLandscapeCumulativeOutflow <= impactNeighbors->lowestCost){  impactNeighbors->lowestCost = someTrial.normalizedLandscapeCumulativeOutflow; }
        if (someTrial.normalizedLandscapeCumulativeOutflow >= impactNeighbors->highestCost){ impactNeighbors->highestCost = someTrial.normalizedLandscapeCumulativeOutflow; }
        
        //infiltration
        if (someTrial.proportionCumulativeNetGIInfiltration <= gw_infiltration->lowestCost){ gw_infiltration->lowestCost = someTrial.proportionCumulativeNetGIInfiltration; }
        if (someTrial.proportionCumulativeNetGIInfiltration >= gw_infiltration->highestCost){ gw_infiltration->highestCost = someTrial.proportionCumulativeNetGIInfiltration; }
        
        //flooded streets
        if (someTrialNorm.normalizedLandscapeCumulativeFloodingOverall <= floodedStreets->lowestCost){ floodedStreets->lowestCost = someTrialNorm.normalizedLandscapeCumulativeFloodingOverall; }
        if (someTrialNorm.normalizedLandscapeCumulativeFloodingOverall >= floodedStreets->highestCost){ floodedStreets->highestCost = someTrialNorm.normalizedLandscapeCumulativeFloodingOverall; }
        
        //standing water
        if (someTrialNorm.normalizedGreatestDepthStandingWater <= standingWater->lowestCost) { standingWater->lowestCost = someTrialNorm.normalizedGreatestDepthStandingWater; }
        if (someTrialNorm.normalizedGreatestDepthStandingWater >= standingWater->highestCost){ standingWater->highestCost = someTrialNorm.normalizedGreatestDepthStandingWater;}
        
        //efficiency
        if (someTrialNorm.landscapeCumulativeGICapacityUsed <= efficiency_val->lowestCost){ efficiency_val->lowestCost = someTrialNorm.landscapeCumulativeGICapacityUsed; }
        if (someTrialNorm.landscapeCumulativeGICapacityUsed >= efficiency_val->highestCost){ efficiency_val->highestCost = someTrialNorm.landscapeCumulativeGICapacityUsed; }
        
    }

    printf("\n");
    
    /**
     * Avoid Division by 0 or any other issues that may cause errors during normalizations
     *
     */
    
    if (maintenanceCost->highestCost == 0){
        maintenanceCost->highestCost = 0.01;
    }
    else if (maintenanceCost->lowestCost == 0){
        maintenanceCost->lowestCost = 0.01;
    }
    
    if (installationCost->highestCost == 0){
        installationCost->highestCost = 0.01;
    }
    else if (installationCost->lowestCost == 0){
        installationCost->lowestCost = 0.01;
    }
    
    if (privateDamages->highestCost == 0){
        privateDamages->highestCost = 0.01;
    }
    else if (privateDamages->lowestCost == 0){
        privateDamages->lowestCost = 0.01;
    }
    
    if (impactNeighbors->highestCost > 1) {
        impactNeighbors->highestCost = 1;
    }
    else if( impactNeighbors->lowestCost <= 0){
        impactNeighbors->lowestCost = 0.01;
    }
    
    if (gw_infiltration->highestCost == 0){
        gw_infiltration->highestCost = 0.01;
    }
    else if (gw_infiltration->lowestCost == 0){
        gw_infiltration->lowestCost = 0.01;
    }
    
    if (floodedStreets->highestCost == 0){
        floodedStreets->highestCost = 0.01;
    }
    else if (floodedStreets->lowestCost == 0){
        floodedStreets->lowestCost =0.01;
    }
    
    if (standingWater->highestCost == 0){
        standingWater->highestCost = 0.01;
    }
    else if (standingWater->lowestCost == 0){
        standingWater->lowestCost = 0.01;
    }
    
    if (efficiency_val->highestCost == 0){
        efficiency_val->highestCost = 0.01;
    }
    else if (efficiency_val->lowestCost == 0){
        efficiency_val->lowestCost = 0.01;
    }
    
    
    //normalize all the variables in accordance to the max value of all current trials
    for (i = 0; i < trialRunSubViews.count; i++)
    {
        //AprilTestSimRun  *someTrial     = [trialRuns objectAtIndex:i];
        //AprilTestNormalizedVariable  *someTrialNorm = [trialRunsNormalized objectAtIndex:i];
        //AprilTestNormalizedVariable  *someTrialDyn  = [trialRunsDynNorm  objectAtIndex:i];
        
        AprilTestSimRun *someTrial = [[trialRunSubViews objectAtIndex:i] valueForKey:@"TrialRun"];
        AprilTestNormalizedVariable *someTrialNorm = [[trialRunSubViews objectAtIndex:i] valueForKey:@"TrialStatic"];
        AprilTestNormalizedVariable *someTrialDyn  = [[trialRunSubViews objectAtIndex:i] valueForKey:@"TrialDynamic"];
        
        someTrialDyn.normalizedLandscapeCostInstallPlusMaintenance     = (float)someTrial.landscapeCostInstallPlusMaintenance/installationCost->highestCost;
        someTrialDyn.normalizedLandscapeCostPrivatePropertyDamages        = (float)someTrial.landscapeCostPrivatePropertyDamage/privateDamages->highestCost;
        
        if (impactNeighbors->highestCost == impactNeighbors->lowestCost){ someTrialDyn.normalizedLandscapeCumulativeOutflow = .5; }
        else
            someTrialDyn.normalizedLandscapeCumulativeOutflow = ((someTrial.normalizedLandscapeCumulativeOutflow - impactNeighbors->lowestCost)/ (impactNeighbors->highestCost - impactNeighbors->lowestCost));
        
        if (gw_infiltration->highestCost == gw_infiltration->lowestCost){ someTrialDyn.normalizedProportionCumulativeNetGIInfiltration = .5; }
        else
            someTrialDyn.normalizedProportionCumulativeNetGIInfiltration = ((someTrial.proportionCumulativeNetGIInfiltration - gw_infiltration->lowestCost)/ (gw_infiltration->highestCost - gw_infiltration->lowestCost));
        
        if (floodedStreets->highestCost == floodedStreets->lowestCost) { someTrialDyn.normalizedLandscapeCumulativeFloodingOverall = .5; }
        else
            someTrialDyn.normalizedLandscapeCumulativeFloodingOverall = ((someTrialNorm.normalizedLandscapeCumulativeFloodingOverall - floodedStreets->lowestCost) / (floodedStreets->highestCost - floodedStreets->lowestCost));
        
        if (standingWater->highestCost == standingWater->lowestCost) { someTrialDyn.normalizedGreatestDepthStandingWater = .5; }
        else
            someTrialDyn.normalizedGreatestDepthStandingWater = ((someTrialNorm.normalizedGreatestDepthStandingWater - standingWater->lowestCost) / (standingWater->highestCost - standingWater->lowestCost));
        
        if (efficiency_val->highestCost == efficiency_val->lowestCost) { someTrialDyn.landscapeCumulativeGICapacityUsed = .5; }
        else
            someTrialDyn.landscapeCumulativeGICapacityUsed = ((someTrialNorm.landscapeCumulativeGICapacityUsed - efficiency_val->lowestCost) / (efficiency_val->highestCost - efficiency_val->lowestCost));
        
    }
}

#pragma mark Update Displays

- (void)updateFloodingThreshold {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    
    float newThreshold = tabControl.threshVal;
    thresh = newThreshold;
    
    for (FebTestWaterDisplay *display in tabControl.waterDisplaysInTab) {
        display.thresholdValue = newThreshold;
        [display fastUpdateView:display.hours];
    }
    
    for (FebTestWaterDisplay *display in tabControl.maxWaterDisplaysInTab) {
        display.thresholdValue = newThreshold;
        [display fastUpdateView:display.hours];
    }
    
    
    for (int i = 0; i < [trialRunSubViews count]; i++){
        AprilTestSimRun *simRun = [[trialRunSubViews objectAtIndex:i] valueForKey:@"TrialRun"];
        
        /* Update Intervention Capacity */
        [[tabControl.efficiencyViewsInTab objectAtIndex:simRun.trialNum] updateViewForHour:hoursAfterStorm];
        UIImageView *EfficiencyView = [[trialRunSubViews objectAtIndex:i] valueForKey:@"EfficiencyView"];
        UIImage *newEfficiencyViewImage  = [[tabControl.efficiencyViewsInTab objectAtIndex:simRun.trialNum] viewforEfficiencyToImage];
        [EfficiencyView setImage:newEfficiencyViewImage];
        
        /* update water display */
        //Access the map from the tab controller and update with the newest hours on water depth
        ((FebTestWaterDisplay*)[tabControl.waterDisplaysInTab objectAtIndex:simRun.trialNum]).thresholdValue = thresh;
        [[tabControl.waterDisplaysInTab objectAtIndex:simRun.trialNum] fastUpdateView:hoursAfterStorm];
        
        //Update water depth image from the current trial
        UIImageView *waterDepthView = [[trialRunSubViews objectAtIndex:i] valueForKey:@"WaterDepthView"];
        UIImage *newWaterDepth = [tabControl viewToImageForWaterDisplay:[tabControl.waterDisplaysInTab objectAtIndex:simRun.trialNum]];
        [waterDepthView setImage:newWaterDepth];
        
        /* update water display */
        //Access the map from the tab controller and update with the newest hours on water depth
        ((FebTestWaterDisplay*)[tabControl.maxWaterDisplaysInTab objectAtIndex:simRun.trialNum]).thresholdValue = thresh;
        FebTestWaterDisplay *mwd = [tabControl.maxWaterDisplaysInTab objectAtIndex:simRun.trialNum];
        [mwd fastUpdateView:mwd.hours];
        
        //Update water depth image from the current trial
        UIImageView *maxWaterDepthView = [[trialRunSubViews objectAtIndex:i] valueForKey:@"MWaterDepthView"];
        UIImage *newMaxWaterDepth = [tabControl viewToImageForWaterDisplay:[tabControl.maxWaterDisplaysInTab objectAtIndex:simRun.trialNum]];
        [maxWaterDepthView setImage:newMaxWaterDepth];
    }
}

//Updates the text of a UILabel (used to update labels after new trials are fetched)
- (NSMutableAttributedString *)myLabelAttributes:(NSString *)input{
    NSMutableAttributedString *labelAttributes = [[NSMutableAttributedString alloc] initWithString:input];
    return labelAttributes;
}

/*
 Description: Updates the public cost bars under the Investment column
 
 Input:       (int) - number of trials so far
 Output:      Updated public Cost Bars
 */
- (void) updatePublicCostDisplays:(int) trial
{
    AprilTestCostDisplay        *newCD;
    AprilTestNormalizedVariable *normVar;
    AprilTestSimRun             *var;
    CGRect                      frame;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:@","];
    
    float maxBudgetWidth = [self getWidthFromSlider:BudgetSlider toValue:setBudget];
    
    for (int i = 0; i < trial; i++){
        newCD = [publicCostDisplays objectAtIndex:i];
        [newCD.budgetUsed removeFromSuperview];
        [newCD.budget removeFromSuperview];
        [newCD.budgetOver removeFromSuperview];
        [newCD.valueLabel removeFromSuperview];
        
        //var     = [trialRuns objectAtIndex:i];
        //normVar = (_DynamicNormalization.isOn) ? ([trialRunsDynNorm objectAtIndex:i]) : ([trialRunsNormalized objectAtIndex:i]);
        var = [[trialRunSubViews objectAtIndex:i] valueForKey:@"TrialRun"];
        normVar = (_DynamicNormalization.isOn) ? ([[trialRunSubViews objectAtIndex:i] valueForKey:@"TrialDynamic"]) : ([[trialRunSubViews objectAtIndex:i] valueForKey:@"TrialStatic"]);
        
        frame   = CGRectMake(25, i*175 + 40, dynamic_cd_width, 30);
        float costWidth = [self getWidthFromSlider:BudgetSlider toValue:var.landscapeCostTotalInstall];
        [newCD updateWithCost:var.landscapeCostInstallPlusMaintenance normScore: normVar.normalizedLandscapeCostInstallPlusMaintenance costWidth:costWidth maxBudgetWidth:maxBudgetWidth andFrame:frame];
    }
    
}

/*
 Description: Updates the component (performance) score bar that is found on the _mapWindow scrollview.
 
 Input:       (int) - trial to be updated
 Output:      Updated public cost bar for the trial
 */

- (void) updateComponentScore: (int) trial{
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    AprilTestNormalizedVariable *simRunNormal;
    
    if (_DynamicNormalization.isOn){
        simRunNormal = [[trialRunSubViews objectAtIndex:trial] valueForKey:@"TrialDynamic"];
    }
    else{
        simRunNormal = [[trialRunSubViews objectAtIndex:trial] valueForKey:@"TrialStatic"];
    }
    
    float priorityTotal= 0;
    float scoreTotal = 0;
    
    for(int i = 0; i < _currentConcernRanking.count; i++){
        
        priorityTotal += [(AprilTestVariable *)[_currentConcernRanking objectAtIndex:i] currentConcernRanking];
    }
    
    int width = 0;
    int investmentWidth = 0;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:@","];
    
    NSMutableArray *scoreVisVals = [[NSMutableArray alloc] init];
    NSMutableArray *scoreVisNames = [[NSMutableArray alloc] init];
    
    int visibleIndex = 0;
    
    for(int i = 0 ; i <_currentConcernRanking.count ; i++){
        AprilTestVariable * currentVar =[sortedArray objectAtIndex:i];
        AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
        AprilTestSimRun *simRun = (trial < trialRunSubViews.count) ? ([[trialRunSubViews objectAtIndex:trial] valueForKey:@"TrialRun"])  : ([tabControl.trialRuns objectAtIndex:trial]);
        
        if([currentVar.name compare: @"installCost"] == NSOrderedSame){
            float investmentInstallN = simRunNormal.normalizedLandscapeCostInstallPlusMaintenance;
            //float investmentMaintainN = simRunNormal.publicMaintenanceCost;
            
            scoreTotal += ((currentVar.currentConcernRanking)/priorityTotal * (1 - investmentInstallN));
            //scoreTotal += ((currentVar.currentConcernRanking/2.0)/priorityTotal * (1 - investmentMaintainN));
            
            [scoreVisVals addObject:[NSNumber numberWithFloat:((currentVar.currentConcernRanking)/priorityTotal * (1 - investmentInstallN))]];
            //[scoreVisVals addObject:[NSNumber numberWithFloat:((currentVar.currentConcernRanking/2.0)/priorityTotal * (1 - investmentMaintainN))]];
            
            investmentWidth = width;
            [scoreVisNames addObject: @"publicCostI"];
            //[scoreVisNames addObject: @"publicCostM"];
        }
        else if ([currentVar.name compare: @"damageReduction"] == NSOrderedSame){
            
            scoreTotal += (currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.normalizedLandscapeCostPrivatePropertyDamages) + currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.normalizedLandscapeCumulativeSewers)) /2;
            
            [scoreVisVals addObject:[NSNumber numberWithFloat:(currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.normalizedLandscapeCostPrivatePropertyDamages))]];
            
            [scoreVisNames addObject: @"privateCostD"];
            
        }
        else if ([currentVar.name compare: @"impactingMyNeighbors"] == NSOrderedSame){
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.normalizedLandscapeCumulativeOutflow);
            [scoreVisVals addObject:[NSNumber numberWithFloat: currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.normalizedLandscapeCumulativeOutflow)]];
            [scoreVisNames addObject: currentVar.name];
        }
        else if ([currentVar.name compare: @"groundwaterInfiltration"] == NSOrderedSame){
            
            scoreTotal += (currentVar.currentConcernRanking/priorityTotal) * (simRunNormal.normalizedProportionCumulativeNetGIInfiltration );
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * ( simRunNormal.normalizedProportionCumulativeNetGIInfiltration )]];
            [scoreVisNames addObject: currentVar.name];
        }
        else if([currentVar.name compare:@"totalAreaFlooded"] == NSOrderedSame){
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.normalizedLandscapeCumulativeFloodingOverall);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1- simRunNormal.normalizedLandscapeCumulativeFloodingOverall)]];
            [scoreVisNames addObject: currentVar.name];
            
        }
        else if([currentVar.name compare:@"animatedWaterViewer"] == NSOrderedSame){
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.normalizedGreatestDepthStandingWater);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1- simRunNormal.normalizedGreatestDepthStandingWater)]];
            //NSLog(@"standing water: %f", currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.standingWater));
            [scoreVisNames addObject: currentVar.name];
            
        }
        else if ([currentVar.name compare: @"capacity"] == NSOrderedSame){
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal *simRunNormal.landscapeCumulativeGICapacityUsed;
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal *  simRunNormal.landscapeCumulativeGICapacityUsed]];
            [scoreVisNames addObject: currentVar.name];
            
            
        }
        else if ([currentVar.name compare: @"efficiencyOfIntervention"] == NSOrderedSame){
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1 - simRun.costPerGallonCapturedByGI/25.19);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1 - simRun.costPerGallonCapturedByGI/25.19)]];
            [scoreVisNames addObject:currentVar.name];
        }
        
        width+= currentVar.widthOfVisualization;
        if (currentVar.widthOfVisualization > 0) visibleIndex++;
    }

    
    //border around component score
    UILabel *fullValueBorder = [[UILabel alloc] initWithFrame:CGRectMake(148, (trial)*175 + 73,  114, 26)];
    fullValueBorder.backgroundColor = [UIColor grayColor];
    UILabel *fullValue = [[UILabel alloc] initWithFrame:CGRectMake(150, (trial)*175 + 75,  110, 22)];
    fullValue.backgroundColor = [UIColor whiteColor];
    [_mapWindow addSubview:fullValueBorder];
    [_mapWindow addSubview:fullValue];
    //NSLog(@" %@", scoreVisVals);
    float maxX = 150;
    float totalScore = 0;
    
    AprilTestSimRun *simRun = (trial < trialRunSubViews.count) ? ([[trialRunSubViews objectAtIndex:trial] valueForKey:@"TrialRun"])  : ([tabControl.trialRuns objectAtIndex:trial]);
    
    int investmentIndex = 0;
    for(int i = 0; i < scoreVisNames.count; i++) {
        if([[scoreVisNames objectAtIndex:i] isEqualToString:@"publicCostI"])
            investmentIndex = i;
    }
    [[[trialRunSubViews objectAtIndex:trial] objectForKey:@"ScorePenalty"] removeFromSuperview];
    UILabel *scorePenalty;
    UILabel * componentScore;
    
    float mod = [tabControl generateOverBudgetPenalty:scoreVisNames withInstallCost:simRun.landscapeCostTotalInstall];
    
    // calculate amount of budget for use in resizing each score
    float amountOverBudget = (simRun.landscapeCostTotalInstall - setBudget)/(float)setBudget;

    //computing and drawing the final component score
    for(int i =  0; i < scoreVisVals.count; i++){
        
        float scoreWidth = [[scoreVisVals objectAtIndex: i] floatValue] * 100;
        scoreWidth *= mod;
        if (scoreWidth < 0) scoreWidth = 0.0;
        
        totalScore += scoreWidth;
        componentScore = [[UILabel alloc] initWithFrame:CGRectMake(maxX, (trial)*175 + 75, floor(scoreWidth), 22)];
        componentScore.backgroundColor = [scoreColors objectForKey:[scoreVisNames objectAtIndex:i]];
        [_mapWindow addSubview:componentScore];
        maxX+=floor(scoreWidth);
    }
    if(amountOverBudget > 0) {
        [self drawTextBasedVar: [NSString stringWithFormat:@"Score penalized by %.2f%%", (1 - mod) * 100] withConcernPosition:investmentWidth + 25 andyValue: (trial * 175) +120 andColor:[UIColor redColor] to:&scorePenalty];
    }
    else {
        [self drawTextBasedVar: @"" withConcernPosition:investmentWidth + 25 andyValue: (trial * 175) +120 andColor:[UIColor redColor] to:&scorePenalty];
    }
    
    NSDictionary *oldDict = [trialRunSubViews objectAtIndex:trial];
    
    NSDictionary *trialRunInfo = @{@"TrialNum"            : [oldDict objectForKey:@"TrialNum"],
                                   @"TrialRun"            : [oldDict objectForKey:@"TrialRun"],
                                   @"TrialStatic"         : [oldDict objectForKey:@"TrialStatic"],
                                   @"TrialDynamic"        : [oldDict objectForKey:@"TrialDynamic"],
                                   @"TrialTxTBox"         : [oldDict objectForKey:@"TrialTxTBox"],
                                   @"PerformanceScore"    : [oldDict objectForKey:@"PerformanceScore"],
                                   //@"WaterDisplay"      : wd,
                                   //@"MWaterDisplay"     : mwd,
                                   //@"EfficiencyView"      : ev,
                                   @"Maintenance"         : [oldDict objectForKey:@"Maintenance"],
                                   @"ScorePenalty"        : scorePenalty,
                                   @"InterventionImgView" : [oldDict objectForKey:@"InterventionImgView"],
                                   @"WaterDepthView"      : [oldDict objectForKey:@"WaterDepthView"],
                                   @"MWaterDepthView"     : [oldDict objectForKey:@"MWaterDepthView"],
                                   @"EfficiencyView"      : [oldDict objectForKey:@"EfficiencyView"],
                                   @"Damage"              : [oldDict objectForKey:@"Damage"],
                                   @"DamageReduced"       : [oldDict objectForKey:@"DamageReduced"],
                                   @"SewerLoad"           : [oldDict objectForKey:@"SewerLoad"],
                                   @"WaterInfiltration"   : [oldDict objectForKey:@"WaterInfiltration"],
                                   @"Efficiency_Interv"   : [oldDict objectForKey:@"Efficiency_Interv"],
                                   @"ImpactNeighbor"      : [oldDict objectForKey:@"ImpactNeighbor"],
                                   @"CostDisplay"         : [oldDict objectForKey:@"CostDisplay"],
                                   @"FavoriteLabel"       : [oldDict objectForKey:@"FavoriteLabel"],
                                   @"FavoriteView"        : [oldDict objectForKey:@"FavoriteView"],
                                   @"LeastFavoriteView"   : [oldDict objectForKey:@"LeastFavoriteView"],
                                   @"StormsForCost"       : [oldDict objectForKey:@"StormsForCost"]
                                   };
    
    [trialRunSubViews replaceObjectAtIndex:trial withObject:trialRunInfo];
    
    //update the length of the component (performance) score in order to be able to sort by best score
    NSNumber *newPerformanceScore = [NSNumber numberWithFloat:totalScore];
    NSDictionary *oldDictionary   = [trialRunSubViews objectAtIndex:trial];
    NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
    [newDict addEntriesFromDictionary:oldDictionary];
    [newDict setObject:newPerformanceScore forKey:@"PerformanceScore"];
    [trialRunSubViews replaceObjectAtIndex:trial withObject:newDict];
}

#pragma mark Favorite and Least Favorite Functions

- (void)sendFavorite {
    int favorite = -1;
    
    for (NSDictionary *trialRunInfo in trialRunSubViews) {
        if([[trialRunInfo objectForKey:@"FavoriteView"] isActive])
            favorite = (int)(((FavoriteView *)[trialRunInfo objectForKey:@"FavoriteView"]).trialNum);
    }
    
    if (favorite != -1) {
        AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
        
        if(tabControl.session) {
            NSMutableArray *favoriteTrial = [[NSMutableArray alloc]init];
            
            [favoriteTrial addObject:@"favoriteForMomma"];
            [favoriteTrial addObject:[[UIDevice currentDevice]name]];
            
            [favoriteTrial addObject:[NSNumber numberWithInt:favorite]];
            
            NSDictionary *favoriteToSendToMomma = [NSDictionary dictionaryWithObject:favoriteTrial
                                                                              forKey:@"data"];
            
            if(favoriteToSendToMomma != nil) {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:favoriteToSendToMomma];
                if(tabControl.peerIDForMomma != nil)
                    [tabControl.session sendData:data toPeers:@[tabControl.peerIDForMomma] withDataMode:GKSendDataReliable error:nil];
            }
        }

    }
}

- (void)sendLeastFavorite {
    int leastFavorite = -1;

    for (NSDictionary *trialRunInfo in trialRunSubViews) {
        if([[trialRunInfo objectForKey:@"LeastFavoriteView"] isActive])
            leastFavorite = (int)(((LeastFavoriteView *)[trialRunInfo objectForKey:@"LeastFavoriteView"]).trialNum);
    }
    
    if (leastFavorite != -1) {
        AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
        
        if(tabControl.session) {
            NSMutableArray *leastFavoriteTrial = [[NSMutableArray alloc]init];
            
            [leastFavoriteTrial addObject:@"leastFavoriteForMomma"];
            [leastFavoriteTrial addObject:[[UIDevice currentDevice]name]];
            
            [leastFavoriteTrial addObject:[NSNumber numberWithInt:leastFavorite]];
            
            NSDictionary *leastFavoriteToSendToMomma = [NSDictionary dictionaryWithObject:leastFavoriteTrial
                                                                              forKey:@"data"];
            
            if(leastFavoriteToSendToMomma != nil) {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:leastFavoriteToSendToMomma];
                if(tabControl.peerIDForMomma != nil)
                    [tabControl.session sendData:data toPeers:@[tabControl.peerIDForMomma] withDataMode:GKSendDataReliable error:nil];
            }
        }
        
    }
}

- (void)favoriteTapped:(UITapGestureRecognizer *)gestureRecognizer {
    //NSLog(@"Tapped favorite");
    
    FavoriteView *favoriteView = (FavoriteView *)gestureRecognizer.view;
    BOOL isUnfavorited = [favoriteView isActive];
    
    [favoriteView isTouched];
    
    int trial = favoriteView.trialNum;
    
    //get the name (if it exists) for the trial chosen as favorite
    NSDictionary *dictforTrial = [self getDictionaryFromTrial:[NSNumber numberWithInt:trial]];
    UITextField *TxTforTrial   = [dictforTrial objectForKey:@"TrialTxTBox"];
    
    //NSString *trialName = ([TxTforTrial.text isEqualToString:[NSString stringWithFormat:@"Trial %d",trial]]) ?  (@"") : [NSString stringWithFormat:@"(%@)", TxTforTrial.text];
    
    //log the trial tapped as favorite
    AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
    NSString *logEntry = [tabControl generateLogEntryWith:[NSString stringWithFormat:@"\tTapped as favorite\t%d", trial]];
    [tabControl writeToLogFileString:logEntry];
    
    // if the least favorite is selected for this trial, unselect it
    for(NSDictionary *trialRunInfo in trialRunSubViews) {
        if([[trialRunInfo objectForKey:@"LeastFavoriteView"]trialNum] == favoriteView.trialNum) {
            [[trialRunInfo objectForKey:@"LeastFavoriteView"]setActive:NO];
            if(tabControl.session) {
                NSMutableArray *favorite = [[NSMutableArray alloc]init];
                
               
                [favorite addObject:@"unselectedLeastFavoriteForMomma"];
                [favorite addObject:[[UIDevice currentDevice]name]];
                
                [favorite addObject:[NSNumber numberWithInt:trial]];
                
                NSDictionary *favoriteToSendToMomma = [NSDictionary dictionaryWithObject:favorite
                                                                                  forKey:@"data"];
                
                if(favoriteToSendToMomma != nil) {
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:favoriteToSendToMomma];
                    if(tabControl.peerIDForMomma != nil)
                        [tabControl.session sendData:data toPeers:@[tabControl.peerIDForMomma] withDataMode:GKSendDataReliable error:nil];
                }
            }
        }
    }
    
    
    if(tabControl.session) {
        NSMutableArray *favorite = [[NSMutableArray alloc]init];
        
        if(isUnfavorited)
            [favorite addObject:@"unselectedFavoriteForMomma"];
        else
            [favorite addObject:@"favoriteForMomma"];
        [favorite addObject:[[UIDevice currentDevice]name]];
        
        [favorite addObject:[NSNumber numberWithInt:trial]];
        
        NSDictionary *favoriteToSendToMomma = [NSDictionary dictionaryWithObject:favorite
                                                                          forKey:@"data"];
        
        if(favoriteToSendToMomma != nil) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:favoriteToSendToMomma];
            if(tabControl.peerIDForMomma != nil)
                [tabControl.session sendData:data toPeers:@[tabControl.peerIDForMomma] withDataMode:GKSendDataReliable error:nil];
        }
    }
}

- (void)leastFavoriteTapped:(UITapGestureRecognizer *)gestureRecognizer {
    //NSLog(@"Tapped least favorite");
    
    LeastFavoriteView *leastFavoriteView = (LeastFavoriteView *)gestureRecognizer.view;
    
    BOOL isUnfavorited = [leastFavoriteView isActive];
    
    [leastFavoriteView isTouched];
    
    int trial = leastFavoriteView.trialNum;
    //get the name (if a unique one exists) for the trial chosen as favorite
    NSDictionary *dictforTrial = [self getDictionaryFromTrial:[NSNumber numberWithInt:trial]];
    UITextField *TxTforTrial   = [dictforTrial objectForKey:@"TrialTxTBox"];
    
    //NSString *trialName = ([TxTforTrial.text isEqualToString:[NSString stringWithFormat:@"Trial %d",trial]]) ?  (@"") : [NSString stringWithFormat:@"(%@)", TxTforTrial.text];
    
    //log the trial tapped as least favorite
    AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
    NSString *logEntry = [tabControl generateLogEntryWith:[NSString stringWithFormat:@"\tTapped as least favorite\t%d", trial]];
    [tabControl writeToLogFileString:logEntry];
    
    // if the least favorite is selected for this trial, unselect it
    for(NSDictionary *trialRunInfo in trialRunSubViews) {
        if([[trialRunInfo objectForKey:@"FavoriteView"]trialNum] == leastFavoriteView.trialNum) {
            [[trialRunInfo objectForKey:@"FavoriteView"]setActive:NO];
            if(tabControl.session) {
                NSMutableArray *favorite = [[NSMutableArray alloc]init];
                
                
                [favorite addObject:@"unselectedFavoriteForMomma"];
                [favorite addObject:[[UIDevice currentDevice]name]];
                
                [favorite addObject:[NSNumber numberWithInt:trial]];
                
                NSDictionary *favoriteToSendToMomma = [NSDictionary dictionaryWithObject:favorite
                                                                                  forKey:@"data"];
                
                if(favoriteToSendToMomma != nil) {
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:favoriteToSendToMomma];
                    if(tabControl.peerIDForMomma != nil)
                        [tabControl.session sendData:data toPeers:@[tabControl.peerIDForMomma] withDataMode:GKSendDataReliable error:nil];
                }
            }
        }
    }
    
    if(tabControl.session) {
        NSMutableArray *leastFavorite = [[NSMutableArray alloc]init];
        
        if(isUnfavorited)
            [leastFavorite addObject:@"unselectedLeastFavoriteForMomma"];
        else
            [leastFavorite addObject:@"leastFavoriteForMomma"];
        [leastFavorite addObject:[[UIDevice currentDevice]name]];
        
        [leastFavorite addObject:[NSNumber numberWithInt:trial]];
        
        NSDictionary *leastFavoriteToSendToMomma = [NSDictionary dictionaryWithObject:leastFavorite
                                                                          forKey:@"data"];
        
        if(leastFavoriteToSendToMomma != nil) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:leastFavoriteToSendToMomma];
            if(tabControl.peerIDForMomma != nil)
                [tabControl.session sendData:data toPeers:@[tabControl.peerIDForMomma] withDataMode:GKSendDataReliable error:nil];
        }
    }
}

#pragma mark Trial Drawing Functions

-(void)resizeImage:(UITapGestureRecognizer*)sender {
    
    float resizeAmount = 1.3;
    float moveX = (115 * resizeAmount - 115) / 2;
    float moveY = (125 * resizeAmount - 125) / 2;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    if (sender.view.frame.size.width <= 120 ) { //grow
        [sender.view setFrame:CGRectMake(sender.view.frame.origin.x - moveX, sender.view.frame.origin.y - moveY, sender.view.frame.size.width * resizeAmount, sender.view.frame.size.height * resizeAmount)];
        [[sender.view superview] addSubview:sender.view];
    }
    else{ //shrink
        [sender.view setFrame:CGRectMake(sender.view.frame.origin.x + moveX, sender.view.frame.origin.y + moveY, sender.view.frame.size.width / resizeAmount, sender.view.frame.size.height / resizeAmount)];
        [[sender.view superview] addSubview:sender.view];
    }
    [UIView commitAnimations];
}




-(void) drawTrial: (int) trial{
    UILabel *maintenance;
    UILabel *scorePenalty;
    UILabel *damage;
    UILabel *damageReduced;
    UILabel *stormsToMakeUpCost;
    UILabel *sewerLoad;
    UILabel *impactNeighbor;
    UILabel *gw_infiltration;
    UILabel *efficiencyOfIntervention;
    
    
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    AprilTestSimRun *simRun = (trial < trialRunSubViews.count) ? ([[trialRunSubViews objectAtIndex:trial] valueForKey:@"TrialRun"])  : ([tabControl.trialRuns objectAtIndex:trial]);
    
    float priorityTotal= 0;
    float scoreTotal = 0;
    
    NSMutableArray *scoreVisVals = [[NSMutableArray alloc] init];
    NSMutableArray *scoreVisNames = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < _currentConcernRanking.count; i++){
        priorityTotal += [(AprilTestVariable *)[_currentConcernRanking objectAtIndex:i] currentConcernRanking];
    }
    
    AprilTestNormalizedVariable *simRunNormal;
    //determines via UIswitch what type of normalization is being drawn
    if (_DynamicNormalization.isOn){
        simRunNormal = (trial < trialRunSubViews.count) ? ([[trialRunSubViews objectAtIndex:trial] valueForKey:@"TrialDynamic"])  : ([tabControl.trialRunsDynNorm objectAtIndex:trial]);
    }
    else{
        simRunNormal = (trial < trialRunSubViews.count) ? ([[trialRunSubViews objectAtIndex:trial] valueForKey:@"TrialStatic"]) :([tabControl.trialRunsNormalized objectAtIndex:trial]);
    }
    
    //creates a UIImageview of the intervention map OR finds it in the stored trials already loaded
    UIImageView *interventionImageView;
    if (trial >= [trialRunSubViews count]){
        UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 115, 125)];
        FebTestIntervention *interventionView = [[FebTestIntervention alloc] initWithPositionArray:simRun.map andFrame:tempView.frame];
        interventionView.view = tempView;
        [interventionView updateView];
        
        interventionImageView = [[UIImageView alloc] initWithFrame:(CGRectMake(20, 175 * (trial) + 40, 115, 125))];
        interventionImageView.image = [interventionView viewToImage];
        [interventionImageView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resizeImage:)];
        tap.numberOfTapsRequired = 1;
        [interventionImageView addGestureRecognizer:tap];
        
        [interventionViews addObject:interventionImageView];
        [_mapWindow addSubview:interventionImageView];
    }
    else{
        interventionImageView = [interventionViews objectAtIndex:simRun.trialNum];
        interventionImageView.frame = CGRectMake(20, 175 * (trial) + 40, 115, 125);
        [_mapWindow addSubview:interventionImageView];
    }
    [_mapWindow setContentSize: CGSizeMake(_mapWindow.contentSize.width, (trial+1)*175 +30)];
    
    //int scoreBar=0;
    
    UITextField *tx;
    if(trial >= [trialRunSubViews count]){
        tx = [[UITextField alloc] initWithFrame:CGRectMake(20, 175*(trial)+5, 245, 30)];
        tx.borderStyle = UITextBorderStyleRoundedRect;
        tx.font = [UIFont systemFontOfSize:15];
        tx.placeholder = @"enter text";
        tx.autocorrectionType = UITextAutocorrectionTypeNo;
        tx.keyboardType = UIKeyboardTypeDefault;
        tx.returnKeyType = UIReturnKeyDone;
        tx.clearButtonMode = UITextFieldViewModeWhileEditing;
        tx.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        tx.delegate = self;
        tx.text = [NSString stringWithFormat:  @"Trial %d", simRunNormal.trialNum + 1];
        [_mapWindow addSubview:tx];
        [_scenarioNames addObject:tx];
    } else {
        tx = [_scenarioNames objectAtIndex:simRun.trialNum];
        tx.frame = CGRectMake(20, 175*(trial)+5, 245, 30);
        [_mapWindow addSubview:tx];
    }
    
    int width = 0;
    int investmentWidth = 0;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:@","];
    AprilTestCostDisplay *cd;
    //FebTestWaterDisplay * wd;
    //FebTestWaterDisplay * mwd;
    //AprilTestEfficiencyView *ev;
    UIImageView *waterDepthView;
    UIImageView *MaxWaterDepthView;
    UIImageView *efficiencyImageView;
    int visibleIndex = 0;
    
    for(int i = 0 ; i <_currentConcernRanking.count ; i++){
        
        AprilTestVariable * currentVar =[sortedArray objectAtIndex:i];
        if(trial == 0 && visibleIndex %2 == 0 && currentVar.widthOfVisualization > 0){
            UILabel *bgCol = [[UILabel alloc] initWithFrame:CGRectMake(width, -2, currentVar.widthOfVisualization+1, _dataWindow.contentSize.height + 100)];
            bgCol.backgroundColor = [UIColor whiteColor];
            bgCol.layer.borderColor = [UIColor lightGrayColor].CGColor;
            bgCol.layer.borderWidth = 2.0;
            [_dataWindow addSubview:bgCol];
            [bgCols addObject:bgCol];
        }
        
        
        //laziness: this is just the investment costs
        if([currentVar.name compare: @"installCost"] == NSOrderedSame){
            float investmentInstall = simRun.landscapeCostTotalInstall;
            float investmentMaintain = simRun.landscapeCostTotalMaintenance;
            float investmentInstallN = simRunNormal.normalizedLandscapeCostInstallPlusMaintenance;
            //float investmentMaintainN = simRunNormal.publicMaintenanceCost;
            CGRect frame = CGRectMake(width + 25, trial*175 + 40, dynamic_cd_width, 30);
            
            investmentWidth = width;
            
            if(publicCostDisplays.count <= trial){
                float costWidth = [self getWidthFromSlider:BudgetSlider toValue:simRun.landscapeCostTotalInstall];
                float maxBudgetWidth = [self getWidthFromSlider:BudgetSlider toValue:setBudget];
                
                
                cd = [[AprilTestCostDisplay alloc] initWithCost:investmentInstall normScore:investmentInstallN costWidth:costWidth maxBudgetWidth:maxBudgetWidth andFrame:frame];
                [_dataWindow addSubview: cd];
                [publicCostDisplays addObject:cd];
                
            } else {
                cd = [publicCostDisplays objectAtIndex:trial];
                cd.frame = CGRectMake(width + 25, trial*175 + 40, dynamic_cd_width, 30);
                [_dataWindow addSubview:cd];
            }
            
            
            //checks if over budget, if so, prints warning message
            if ((simRun.landscapeCostTotalInstall > setBudget) && (!_DynamicNormalization.isOn)){
                //store update labels for further use (updating over budget when using absolute val)
                
                UILabel *valueLabel;
                [self drawTextBasedVar:[NSString stringWithFormat: @"Over budget by $%@", [formatter stringFromNumber: [NSNumber numberWithInt: (int) (investmentInstall-setBudget)]] ] withConcernPosition:width+25 andyValue:trial *175 + 80 andColor:[UIColor redColor] to:&valueLabel];
                
                [OverBudgetLabels addObject:valueLabel];
            }
            
            
            [self drawTextBasedVar: [NSString stringWithFormat:@"Maintenance Cost: $%@", [formatter stringFromNumber: [NSNumber numberWithInt:investmentMaintain ]]] withConcernPosition:width + 25 andyValue: (trial * 175) +100 andColor:[UIColor blackColor] to:&maintenance];
            
            scoreTotal += ((currentVar.currentConcernRanking)/priorityTotal * (1 - investmentInstallN));
            //scoreTotal += ((currentVar.currentConcernRanking/2.0)/priorityTotal * (1 - investmentMaintainN));
            
            [scoreVisVals addObject:[NSNumber numberWithFloat:((currentVar.currentConcernRanking)/priorityTotal * (1 - investmentInstallN))]];
            //NSLog(@"Investment cost: %f Investment score: %f", investmentInstall, investmentInstallN);
            // [scoreVisVals addObject:[NSNumber numberWithFloat:((currentVar.currentConcernRanking/2.0)/priorityTotal * (1 - investmentMaintainN))]];
            
            [scoreVisNames addObject: @"publicCostI"];
            // [scoreVisNames addObject: @"publicCostM"];
            

            
            //just damages now
        } else if ([currentVar.name compare: @"damageReduction"] == NSOrderedSame){
            
            
            [self drawTextBasedVar: [NSString stringWithFormat:@"Rain Damage: $%@", [formatter stringFromNumber: [NSNumber numberWithInt:simRun.landscapeCostPrivatePropertyDamage]]] withConcernPosition:width + 20 andyValue: (trial*175) +20 andColor:[UIColor blackColor] to:&damage];
            [self drawTextBasedVar: [NSString stringWithFormat:@"Damaged Reduced by: %@%%", [formatter stringFromNumber: [NSNumber numberWithInt: 100 -(int)(100*simRunNormal.normalizedLandscapeCostPrivatePropertyDamages)]]] withConcernPosition:width + 20 andyValue: (trial*175) +50 andColor:[UIColor blackColor] to:&damageReduced];
            //temporarily removed sewer load because it doesn't seem meaningful to combine
            //[self drawTextBasedVar: [NSString stringWithFormat:@"Sewer Load: %.2f%%", 100*simRun.normalizedLandscapeCumulativeSewers] withConcernPosition:width + 20 andyValue: (trial ) * 175 + 80 andColor:[UIColor blackColor] to:&sewerLoad];
            
            [self drawTextBasedVar: [NSString stringWithFormat:@"Storms like this one to"] withConcernPosition:width + 20 andyValue: (trial ) * 175 + 80 andColor:[UIColor blackColor] to:nil];
            
            if(simRun.landscapeCostPrivatePropertyDamage != 0){
                [self drawTextBasedVar: [NSString stringWithFormat:@"recoup investment cost: %d", (int)((simRun.landscapeCostTotalInstall)/(simRun.landscapeCostPrivatePropertyDamage))] withConcernPosition:width + 20 andyValue: (trial ) * 175 + 110 andColor:[UIColor blackColor] to:&stormsToMakeUpCost];
            }else {
                [self drawTextBasedVar: [NSString stringWithFormat:@"recoup investment cost: %d", (int)((simRun.landscapeCostTotalInstall)/maxDamagesReduced)] withConcernPosition:width + 20 andyValue: (trial ) * 175 + 110 andColor:[UIColor blackColor] to:&stormsToMakeUpCost];
            }
            
            scoreTotal += (currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.normalizedLandscapeCostPrivatePropertyDamages));
            
            //add values for the score visualization
            
            [scoreVisVals addObject:[NSNumber numberWithFloat:(currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.normalizedLandscapeCostPrivatePropertyDamages) )]];
            //scoreTotal +=currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.privateDamages);
            //[scoreVisVals addObject: [NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.privateDamages)]];
            [scoreVisNames addObject: @"privateCostD"];
            
        } else if ([currentVar.name compare: @"impactingMyNeighbors"] == NSOrderedSame){
            
            [self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%% of rainwater", 100*simRun.normalizedLandscapeCumulativeOutflow] withConcernPosition:width + 30 andyValue: (trial ) * 175 + 40 andColor:[UIColor blackColor] to:&impactNeighbor];
            [self drawTextBasedVar: [NSString stringWithFormat:@" flowed to neighbors"] withConcernPosition:width + 30 andyValue: (trial ) * 175 + 55 andColor:[UIColor blackColor] to:nil];
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.normalizedLandscapeCumulativeOutflow);
            [scoreVisVals addObject:[NSNumber numberWithFloat: currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.normalizedLandscapeCumulativeOutflow)]];
            [scoreVisNames addObject: currentVar.name];

        } else if ([currentVar.name compare: @"neighborImpactingMe"] == NSOrderedSame){
            
            [self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%%", 100*simRun.normalizedLandscapeCumulativeSewers] withConcernPosition:width + 50 andyValue: (trial)*175 + 40 andColor:[UIColor blackColor] to:nil];
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * ( simRunNormal.normalizedLandscapeCumulativeSewers);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * ( simRunNormal.normalizedLandscapeCumulativeSewers)]];
            [scoreVisNames addObject: currentVar.name];
 
        } else if ([currentVar.name compare: @"groundwaterInfiltration"] == NSOrderedSame){
            
            [self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%% of possible", 100*simRun.proportionCumulativeNetGIInfiltration] withConcernPosition:width + 30 andyValue: (trial)* 175 + 40 andColor:[UIColor blackColor] to:&gw_infiltration];
            [self drawTextBasedVar: [NSString stringWithFormat:@" groundwater infiltration"] withConcernPosition:width + 30 andyValue: (trial)* 175 + 55  andColor:[UIColor blackColor] to:nil];
            
            scoreTotal += (currentVar.currentConcernRanking/priorityTotal) * (simRunNormal.normalizedProportionCumulativeNetGIInfiltration );
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * ( simRunNormal.normalizedProportionCumulativeNetGIInfiltration )]];
            //NSLog(@"Groundwater Infiltration: %d", currentVar.currentConcernRanking);
            [scoreVisNames addObject: currentVar.name];

        } else if([currentVar.name compare:@"totalAreaFlooded"] == NSOrderedSame){
            
            AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
            ((FebTestWaterDisplay*)[tabControl.maxWaterDisplaysInTab objectAtIndex:trial]).thresholdValue = thresh;
            [[tabControl.maxWaterDisplaysInTab objectAtIndex:trial] updateView:48];
            
            MaxWaterDepthView = [[UIImageView alloc]initWithFrame:CGRectMake(width + 52, trial * 175 + 40, 115, 125)];
            MaxWaterDepthView.image = [tabControl viewToImageForWaterDisplay:[tabControl.maxWaterDisplaysInTab objectAtIndex:simRun.trialNum]];
            [MaxWaterDepthView setUserInteractionEnabled:YES];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resizeImage:)];
            tap.numberOfTapsRequired = 1;
            [MaxWaterDepthView addGestureRecognizer:tap];
            [_dataWindow addSubview:MaxWaterDepthView];
            
            /*
             //NSLog(@"%d, %d", waterDisplays.count, i);
             if(waterDisplays.count <= trial){
             //NSLog(@"Drawing water display for first time");
             wd = [[FebTestWaterDisplay alloc] initWithFrame:CGRectMake(width + 10, (trial)*175 + 40, 115, 125) andContent:simRun.standingWater];
             wd.view = _dataWindow;
             [waterDisplays addObject:wd];
             } else {
             wd = [waterDisplays objectAtIndex:simRun.trialNum];
             wd.frame = CGRectMake(width + 10, (trial)*175 + 40, 115, 125);
             }
             wd.thresholdValue = thresh;
             [wd fastUpdateView: StormPlaybackWater.value];*/
            
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.normalizedLandscapeCumulativeFloodingOverall);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1- simRunNormal.normalizedLandscapeCumulativeFloodingOverall)]];
            //NSLog(@"%d, %f, %@", currentVar.currentConcernRanking, simRunNormal.floodedStreets, [NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1- simRunNormal.floodedStreets)]);
            [scoreVisNames addObject: currentVar.name];

            
        } else if([currentVar.name compare:@"animatedWaterViewer"] == NSOrderedSame){
            
            AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
            
            //Moved to creating UIImageViews... to minimize lag in scrolling
            ((FebTestWaterDisplay*)[tabControl.waterDisplaysInTab objectAtIndex:simRun.trialNum]).thresholdValue = thresh;
            [[tabControl.waterDisplaysInTab objectAtIndex:trial] fastUpdateView:hoursAfterStorm];

            waterDepthView = [[UIImageView alloc]initWithFrame:CGRectMake(width + 52, (trial)*175 + 40, 115, 125)];
            waterDepthView.image = [tabControl viewToImageForWaterDisplay:[tabControl.waterDisplaysInTab objectAtIndex:simRun.trialNum]];
            [waterDepthView setUserInteractionEnabled:YES];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resizeImage:)];
            tap.numberOfTapsRequired = 1;
            [waterDepthView addGestureRecognizer:tap];
            [_dataWindow addSubview:waterDepthView];
            
            
            /*
             //display window for maxHeights
             if(maxWaterDisplays.count <= trial){
             mwd  = [[FebTestWaterDisplay alloc] initWithFrame:CGRectMake(width + 10, (trial)*175 + 40, 115, 125) andContent:simRun.maxWaterHeights];
             mwd.view = _dataWindow;
             [maxWaterDisplays addObject:mwd];
             } else {
             mwd = [maxWaterDisplays objectAtIndex:simRun.trialNum];
             mwd.frame = CGRectMake(width + 10, (trial)*175 + 40, 115, 125);
             }
             mwd.thresholdValue = thresh;
             [mwd updateView:48];*/
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.normalizedGreatestDepthStandingWater);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.normalizedGreatestDepthStandingWater)]];
            [scoreVisNames addObject: currentVar.name];
            //NSLog(@"%d, %f, %@", currentVar.currentConcernRanking, simRunNormal.standingWater , [NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.standingWater)]);


            
        } else if ([currentVar.name compare: @"capacity"] == NSOrderedSame){

            /*
             if( efficiency.count <= trial){
             //NSLog(@"Drawing efficiency display for first time");
             ev = [[AprilTestEfficiencyView alloc] initWithFrame:CGRectMake(width, (trial )*175 + 40, 130, 150) withContent: simRun.efficiency];
             ev.trialNum = i;
             ev.view = _dataWindow;
             [efficiency addObject:ev];
             } else {
             //NSLog(@"Repositioning efficiency display");
             ev = [efficiency objectAtIndex:simRun.trialNum];
             ev.frame = CGRectMake(width, (trial )*175 + 40, 130, 150);
             }
             [ev updateViewForHour: StormPlaybackInterv.value];*/
            
            if (trial >= [trialRunSubViews count]){
                AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
                ((AprilTestEfficiencyView*)[tabControl.efficiencyViewsInTab objectAtIndex:simRun.trialNum]).trialNum = i;
                [[tabControl.efficiencyViewsInTab objectAtIndex:simRun.trialNum] updateViewForHour:StormPlaybackInterv.value];
                
                efficiencyImageView         = [[UIImageView alloc] initWithFrame:CGRectMake(width, (trial )*175 + 40, 180, 150)];
                efficiencyImageView.image   = [[tabControl.efficiencyViewsInTab objectAtIndex:simRun.trialNum] viewforEfficiencyToImage];
                [_dataWindow addSubview:efficiencyImageView];
            }
            else{
                efficiencyImageView         = [[UIImageView alloc] initWithFrame:CGRectMake(width, (trial )*175 + 40, 180, 150)];
                efficiencyImageView.image   = [[tabControl.efficiencyViewsInTab objectAtIndex:simRun.trialNum] viewforEfficiencyToImage];
                [_dataWindow addSubview:efficiencyImageView];
            }
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal *  simRunNormal.landscapeCumulativeGICapacityUsed;
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal *  simRunNormal.landscapeCumulativeGICapacityUsed]];
            //NSLog(@"%@", NSStringFromCGRect(ev.frame));
            [scoreVisNames addObject: currentVar.name];


            
        } else if ([currentVar.name compare: @"efficiencyOfIntervention"] == NSOrderedSame){
            [self drawTextBasedVar: [NSString stringWithFormat:@"$/Gallon Spent: $%.2f", simRun.costPerGallonCapturedByGI  ] withConcernPosition:width + 25 andyValue: (trial * 175) + 40 andColor: [UIColor blackColor] to:&efficiencyOfIntervention];
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1 - simRun.costPerGallonCapturedByGI/25.19);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1 - simRun.costPerGallonCapturedByGI/25.19)]];
            [scoreVisNames addObject:currentVar.name];
        }
        
        width+= currentVar.widthOfVisualization;
        if (currentVar.widthOfVisualization > 0) visibleIndex++;
    }
    
    /*
    
    NSMutableArray* scores;
    if(_DynamicNormalization.isOn) scores = [tabControl getScoreBarValuesForProfile:0 forTrial:trial isDynamicTrial:1];
    else scores = [tabControl getScoreBarValuesForProfile:0 forTrial:trial isDynamicTrial:0];
    
    NSMutableArray* scoreVisVals = [scores objectAtIndex:0];
    NSMutableArray* scoreVisNames = [scores objectAtIndex:1];
     
     */
    
    //border around component score
    UILabel *fullValueBorder = [[UILabel alloc] initWithFrame:CGRectMake(148, (trial)*175 + 73,  114, 26)];
    fullValueBorder.backgroundColor = [UIColor grayColor];
    UILabel *fullValue = [[UILabel alloc] initWithFrame:CGRectMake(150, (trial)*175 + 75,  110, 22)];
    fullValue.backgroundColor = [UIColor whiteColor];
    [_mapWindow addSubview:fullValueBorder];
    [_mapWindow addSubview:fullValue];
    //NSLog(@" %@", scoreVisVals);
    float maxX = 150;
    float totalScore = 0;
    UILabel *componentScore;
    
    int investmentIndex = 0;
    for(int i = 0; i < scoreVisNames.count; i++) {
        if([[scoreVisNames objectAtIndex:i] isEqualToString:@"publicCostI"])
            investmentIndex = i;
    }
    
    float mod = [tabControl generateOverBudgetPenalty:scoreVisNames withInstallCost:simRun.landscapeCostTotalInstall];
    
    // calculate amount of budget for use in resizing each score
    float amountOverBudget = (simRun.landscapeCostTotalInstall - setBudget)/(float)setBudget;

    //computing and drawing the final component score
    for(int i =  0; i < scoreVisVals.count; i++){
        
        float scoreWidth = [[scoreVisVals objectAtIndex: i] floatValue] * 100;
        scoreWidth *= mod;

        if (scoreWidth < 0) scoreWidth = 0.0;
        totalScore += scoreWidth;
        componentScore = [[UILabel alloc] initWithFrame:CGRectMake(maxX, (trial)*175 + 75, floor(scoreWidth), 22)];
        componentScore.backgroundColor = [scoreColors objectForKey:[scoreVisNames objectAtIndex:i]];
        [_mapWindow addSubview:componentScore];
        maxX+=floor(scoreWidth);
    }
    
    if(amountOverBudget > 0) {
        [self drawTextBasedVar: [NSString stringWithFormat:@"Score penalized by %.2f%%", (1 - mod) * 100] withConcernPosition:investmentWidth + 25 andyValue: (trial * 175) +120 andColor:[UIColor redColor] to:&scorePenalty];
    }
    else {
        [self drawTextBasedVar: @"" withConcernPosition:investmentWidth + 25 andyValue: (trial * 175) +120 andColor:[UIColor redColor] to:&scorePenalty];
    }
    
    //NSLog(@"\n");
    
    [_dataWindow setContentSize:CGSizeMake(width+=100, (trial+1)*175 +30)];
    for(UILabel * bgCol in bgCols){
        if(_dataWindow.contentSize.height > _dataWindow.frame.size.height){
            [bgCol setFrame: CGRectMake(bgCol.frame.origin.x, bgCol.frame.origin.y, bgCol.frame.size.width, _dataWindow.contentSize.height + 1)];
        }else {
            [bgCol setFrame: CGRectMake(bgCol.frame.origin.x, bgCol.frame.origin.y, bgCol.frame.size.width, _dataWindow.frame.size.height + 1)];
        }
    }
    
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 175*(trial) + 40, 0, 0)];
    scoreLabel.text = @"Performance:";
    scoreLabel.font = [UIFont systemFontOfSize:14.0];
    [scoreLabel sizeToFit];
    scoreLabel.textColor = [UIColor blackColor];
    [_mapWindow addSubview:scoreLabel];
    UILabel *scoreLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(150, 175*(trial) + 60, 0, 0)];
    scoreLabel2.text = [NSString stringWithFormat:  @"Broken down by source:"];
    scoreLabel2.font = [UIFont systemFontOfSize:10.0];
    [scoreLabel2 sizeToFit];
    scoreLabel2.textColor = [UIColor blackColor];
    [_mapWindow addSubview:scoreLabel2];
    
    
    FavoriteView *favoriteView;
    UITapGestureRecognizer *tappedFavorite = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(favoriteTapped:)];
    tappedFavorite.numberOfTapsRequired = 1;
    tappedFavorite.numberOfTouchesRequired = 1;
    
    LeastFavoriteView *leastFavoriteView;
    UITapGestureRecognizer *tappedLeastFavorite = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leastFavoriteTapped:)];
    tappedLeastFavorite.numberOfTapsRequired = 1;
    tappedLeastFavorite.numberOfTouchesRequired = 1;
    
    UILabel *favoriteLabel;
    
    //if its a new trial... draw new favorite and least favorite views
    //else retrieve it from the current views kept track of
    if (trial >= [trialRunSubViews count]) {
        favoriteView = [[FavoriteView alloc]initWithFrame:CGRectMake(154, trial * 175 + 125, 40, 40) andTrialNumber:simRun.trialNum];
        [favoriteView addGestureRecognizer:tappedFavorite];
        [favoriteView setUserInteractionEnabled:YES];
        [favoriteViews addObject:favoriteView];
        [_mapWindow addSubview:favoriteView];
        
        leastFavoriteView = [[LeastFavoriteView alloc]initWithFrame:CGRectMake(212, trial * 175 + 125, 40, 40) andTrialNumber:simRun.trialNum];
        [leastFavoriteView addGestureRecognizer:tappedLeastFavorite];
        [leastFavoriteView setUserInteractionEnabled:YES];
        [leastFavoriteViews addObject:leastFavoriteView];
        [_mapWindow addSubview:leastFavoriteView];
        
        favoriteLabel = [[UILabel alloc]initWithFrame:CGRectMake(90, trial * 175 + 112, 0, 0)];
        favoriteLabel.text = @"Best for me    Worst for me";
        favoriteLabel.font = [UIFont systemFontOfSize:9.0];
        [favoriteLabel sizeToFit];
        //[favoriteLabel setTextAlignment:NSTextAlignmentLeft];
        [favoriteLabels addObject:favoriteLabel];
        [_mapWindow addSubview:favoriteLabel];
    }
    else{
        favoriteView = [favoriteViews objectAtIndex:simRun.trialNum];
        favoriteView.trialNum = trial;
        [favoriteView addGestureRecognizer:tappedFavorite];
        [favoriteView setUserInteractionEnabled:YES];
        [favoriteView setFrame:CGRectMake(154, trial * 175 + 125, 40, 40) andTrialNumber:simRun.trialNum];
        [_mapWindow addSubview:favoriteView];
        
        leastFavoriteView = [leastFavoriteViews objectAtIndex:simRun.trialNum];
        leastFavoriteView.trialNum = trial;
        [leastFavoriteView addGestureRecognizer:tappedLeastFavorite];
        [leastFavoriteView setUserInteractionEnabled:YES];
        [leastFavoriteView setFrame:CGRectMake(212, trial * 175 + 125, 40, 40) andTrialNumber:simRun.trialNum];
        [_mapWindow addSubview:leastFavoriteView];
        
        
        favoriteLabel = [favoriteLabels objectAtIndex:simRun.trialNum];
        favoriteLabel.frame = CGRectMake(90, trial * 175 + 112, 0, 0);
        [favoriteLabel sizeToFit];
        [_mapWindow addSubview:favoriteLabel];
    }
    
    
    //NSLog(@"Trial: %d\nScore: %@ / 100\n\n", simRun.trialNum, [NSNumber numberWithInt: totalScore]);
    
    NSDictionary *trialRunInfo = @{@"TrialNum"            : [NSNumber numberWithInt:simRun.trialNum],
                                   @"TrialRun"            : [tabControl.trialRuns objectAtIndex:simRun.trialNum],
                                   @"TrialStatic"         : [tabControl.trialRunsNormalized objectAtIndex:simRun.trialNum],
                                   @"TrialDynamic"        : [tabControl.trialRunsDynNorm objectAtIndex:simRun.trialNum],
                                   @"TrialTxTBox"         : tx,
                                   @"PerformanceScore"    : [NSNumber numberWithInt: totalScore],
                                   //@"WaterDisplay"      : wd,
                                   //@"MWaterDisplay"     : mwd,
                                   //@"EfficiencyView"      : ev,
                                   @"Maintenance"         : maintenance,
                                   @"ScorePenalty"        : scorePenalty,
                                   @"InterventionImgView" : interventionImageView,
                                   @"WaterDepthView"      : waterDepthView,
                                   @"MWaterDepthView"     : MaxWaterDepthView,
                                   @"EfficiencyView"      : efficiencyImageView,
                                   @"Damage"              : damage,
                                   @"DamageReduced"       : damageReduced,
                                   @"SewerLoad"           : sewerLoad,
                                   @"WaterInfiltration"   : gw_infiltration,
                                   @"Efficiency_Interv"   : efficiencyOfIntervention,
                                   @"ImpactNeighbor"      : impactNeighbor,
                                   @"CostDisplay"         : cd,
                                   @"FavoriteLabel"       : favoriteLabel,
                                   @"FavoriteView"        : favoriteView,
                                   @"LeastFavoriteView"   : leastFavoriteView,
                                   @"StormsForCost"       : stormsToMakeUpCost
                                   };
    
    //Right now contains the contents of the map window scrollview
    if (trial < trialRunSubViews.count){
        [trialRunSubViews replaceObjectAtIndex:trial withObject:trialRunInfo];
    }
    else
        [trialRunSubViews addObject:trialRunInfo];
    
    //NSLog(@"Just drew trial %d\n", simRun.trialNum);
    
    [_dataWindow flashScrollIndicators];          
    
}


- (void)drawSingleTrial {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    if ([tabControl.trialRuns count] > trialNum) {
        [_loadingIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];

        [self drawTrial:tabControl.trialNum-1];
        
        //chooses between static/dynamic normalization of trial data
        if (_DynamicNormalization.isOn)
            [self normalizeAllandUpdateDynamically];
        else
            [self normalizeStatically];
        
        //update with the current sort chosen after a new trial is drawn
        [self handleSort: sortChosen];
        
        
        //find the index (offset of trial drawn) of the recently drawn trial
        NSInteger index = [trialRunSubViews indexOfObjectPassingTest:
                            ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop)
                            {
                                return [[dict objectForKey:@"TrialNum"] isEqual:[NSNumber numberWithInt:tabControl.trialNum-1]];
                            }
                            ];
        
        if (index == NSNotFound){
            index = trialNum;
        }
        scrollingTimer = [NSTimer scheduledTimerWithTimeInterval:(0.10)
                                                              target:self selector:@selector(autoscrollTimerFired:) userInfo:[NSNumber numberWithInt:index+1] repeats:NO];
        
        [_loadingIndicator stopAnimating];
    }
    else
        NSLog(@"Trial %d not yet loaded", trialNum + 1);
}

- (void)drawMultipleTrials {
    [_loadingIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];
    
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    
    for(UIView *subview in [_SliderWindow subviews])
        [subview removeFromSuperview];
    
    for(UIView *subview in [_titleWindow subviews])
        [subview removeFromSuperview];
    
    
    for (int i =0; i < tabControl.trialNum; i++){
        [self drawTrial:i];
    }
    
    [self handleSort:sortChosen];
    
    //determine depending on min and max budget limits what is to be drawn on UILabels under le BudgetSlider
    minBudgetLabel = [NSString stringWithFormat:@"$%.1f%c", ((min_budget_limit/1000000 < 1) ? (min_budget_limit/1000) : (min_budget_limit/1000000)), (min_budget_limit/1000000 < 1) ? 'K' : 'M'];
    maxBudgetLabel = [NSString stringWithFormat:@"$%.1f%c", ((max_budget_limit/1000000 < 1) ? (max_budget_limit/1000) : (max_budget_limit/1000000)), (max_budget_limit/1000000 < 1) ? 'K' : 'M'];
    
    [self drawTitles];
    [self drawSliders];
    
    dynamic_cd_width = [self getWidthFromSlider:BudgetSlider toValue:setBudget];
    
    [_dataWindow setContentOffset:CGPointMake(0, 0)];
    [_mapWindow setContentOffset:CGPointMake(0,0 )];
    [_dataWindow flashScrollIndicators];
    
    [_loadingIndicator stopAnimating];
}


#pragma mark Other Drawing Functions


//Draws Labels to set on the dataWindow Scrollview but also returns object to be added into a MutableArray (used for updating labels)
-(void) drawTextBasedVar: (NSString *) outputValue withConcernPosition: (int) concernPos andyValue: (int) yValue andColor: (UIColor*) color to:(UILabel**) label{
    if (label != nil){
        *label = [[UILabel alloc] init];
        (*label).text = outputValue;
        (*label).frame =CGRectMake(concernPos, yValue, 0, 0);
        [*label sizeToFit ];
        (*label).font = [UIFont systemFontOfSize:14.0];
        (*label).textColor = color;
        [_dataWindow addSubview:*label];
    }else
    {
        UILabel *valueLabel = [[UILabel alloc] init];
        valueLabel.text = outputValue;
        valueLabel.frame =CGRectMake(concernPos, yValue, 0, 0);
        [valueLabel sizeToFit ];
        valueLabel.font = [UIFont systemFontOfSize:14.0];
        valueLabel.textColor = color;
        [_dataWindow addSubview:valueLabel];
    }
}

-(void) drawTitles{
    
    int width = 0;
    int visibleIndex = 0;
    for(int i = 0 ; i <_currentConcernRanking.count ; i++){

        AprilTestVariable * currentVar =[sortedArray objectAtIndex:i];
        UILabel * currentVarLabel = [[UILabel alloc] init];
        currentVarLabel.backgroundColor = [scoreColors objectForKey:currentVar.name];
        currentVarLabel.frame = CGRectMake(width, 2, currentVar.widthOfVisualization, 40);
        currentVarLabel.font = [UIFont boldSystemFontOfSize:15.3];
        if([currentVar.name compare: @"installCost"] == NSOrderedSame){
            currentVarLabel.text = @"  Investment";
        } else if ([currentVar.name compare: @"damageReduction"] == NSOrderedSame){
            currentVarLabel.text =@"  Damage Reduction";
        } else if ([currentVar.name compare: @"impactingMyNeighbors"] == NSOrderedSame){
            currentVarLabel.text =@"  Impact on my Neighbors";
        } else if ([currentVar.name compare: @"efficiencyOfIntervention"] == NSOrderedSame){
            currentVarLabel.text =@"  Efficiency of Intervention";
        } else if ([currentVar.name compare:@"animatedWaterViewer"] == NSOrderedSame){
            currentVarLabel.text = @"  Water Flow";
        } else if( [currentVar.name compare:@"groundwaterInfiltration"] == NSOrderedSame){
            currentVarLabel.text = @"  Groundwater Infiltration";
        } else if( [currentVar.name compare:@"totalAreaFlooded"] == NSOrderedSame){
            currentVarLabel.text = @"  Max Depth of Flooding";
        } else if( [currentVar.name compare:@"capacity"] == NSOrderedSame){
            currentVarLabel.text = @"  Intervention Capacity";
        }
        else {
            currentVarLabel = NULL;
        }
        if(currentVar.widthOfVisualization != 0) visibleIndex++;
        
        if(currentVarLabel != NULL){
            [_titleWindow addSubview:currentVarLabel];
            [concernRankingTitles addObject:currentVarLabel];
        }
        width+= currentVar.widthOfVisualization;
    }
    
    [_dataWindow setContentSize: CGSizeMake(width + 10, _dataWindow.contentSize.height)];
}

#pragma mark Scroll View Functions




//autoscroll to the bottom of the mapwindow (trial and component score) scrollview
- (void) autoscrollTimerFired: (NSTimer*)Timer
{
    NSNumber *trial = ((NSNumber*)[Timer userInfo]);
    int trialInt = (int)[trial integerValue];
    
    trialOffset = (trialInt - 3 < 0) ? 0 : (175 * (trialInt-3) + 35);
    
    //CGPoint bottomOffset = CGPointMake(0, _mapWindow.contentSize.height - _mapWindow.bounds.size.height);
    CGPoint bottomOffset = CGPointMake(0, trialOffset);
    [_mapWindow setContentOffset:bottomOffset animated:YES];
    
}

-(void) OffsetView: (UIView*) view toX:(int)x andY:(int)y{
    ///GENERAL FORMULA FOR TRANSLATING A FRAME
    CGRect frame = view.frame;
    frame.origin.x = x;
    frame.origin.y = y;
    [view setFrame: frame];
    /*
     CGRect frame = CGRectMake(x, y, view.frame.size.width, view.frame.size.height);
     [view setFrame: frame];*/
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if([scrollView isEqual:_dataWindow]) {
        CGPoint offset = _mapWindow.contentOffset;
        offset.y = _dataWindow.contentOffset.y;
        CGPoint titleOffset = _titleWindow.contentOffset;
        titleOffset.x = _dataWindow.contentOffset.x;
        [_titleWindow setContentOffset:titleOffset];
        [_SliderWindow setContentOffset:titleOffset];
        [_mapWindow setContentOffset:offset];
    } else {
        CGPoint offset = _dataWindow.contentOffset;
        offset.y = _mapWindow.contentOffset.y;
        [_dataWindow setContentOffset:offset];
    }
    
    NSDate *myDate = [[NSDate alloc] init];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    NSString *prettyVersion = [dateFormat stringFromDate:myDate];
    
    //NSLog(@"content offset: %f",  _dataWindow.contentOffset.x);
    if(!passFirstThree && _dataWindow.contentOffset.x > 50){
        NSMutableString * content = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@\tScrolled past three most important variables", prettyVersion]];
        
        [content appendString:@"\n\n"];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"logfile_simResults.txt"];
        
        //create file if it doesn't exist
        if(![[NSFileManager defaultManager] fileExistsAtPath:fileName])
            [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
        
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
        [file seekToEndOfFile];
        [file writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        [file closeFile];
        passFirstThree = TRUE;
    }
    if(passFirstThree &&  _dataWindow.contentOffset.x <= 50 ){
        NSMutableString * content = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@\tReturned to three most important variables", prettyVersion]];
        
        [content appendString:@"\n\n"];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"logfile_simResults.txt"];
        
        //create file if it doesn't exist
        if(![[NSFileManager defaultManager] fileExistsAtPath:fileName])
            [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
        
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
        [file seekToEndOfFile];
        [file writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        [file closeFile];
        passFirstThree = FALSE;
    }
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //log the visible views and trials
    [self logVisibleTrialsandVariables];
}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate == NO){
        [self logVisibleTrialsandVariables];
    }
}

#pragma mark Sorting Functions

- (void) handleSort:(int) row{
    
    //depending on what the type of sort it is, sort the mutable array of dictionaries
    if ([arrStatus[row] isEqual: @"Trial Number"]){
        [trialRunSubViews sortUsingDescriptors:@[ [[NSSortDescriptor alloc] initWithKey:@"TrialNum" ascending:YES]]];
    }
    else if ([arrStatus[row] isEqual: @"My Score"]){
        [trialRunSubViews sortUsingDescriptors:@[ [[NSSortDescriptor alloc] initWithKey:@"PerformanceScore" ascending:NO]]];
    }
    
    else if ([arrStatus[row] isEqual: @"Investment"]){
        [trialRunSubViews sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            AprilTestSimRun *first  = (AprilTestSimRun*)[obj1 valueForKey:@"TrialRun"];
            AprilTestSimRun *second = (AprilTestSimRun*)[obj2 valueForKey:@"TrialRun"];
            
        
                if (first.landscapeCostTotalInstall < second.landscapeCostTotalInstall)
                    return NSOrderedAscending;
                else if (second.landscapeCostTotalInstall < first.landscapeCostTotalInstall)
                    return NSOrderedDescending;
                return NSOrderedSame;
                
        }];
    }
    else if ([arrStatus[row] isEqual: @"Damage Reduction"]){
        [trialRunSubViews sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            AprilTestSimRun *first  = (AprilTestSimRun*)[obj1 valueForKey:@"TrialRun"];
            AprilTestSimRun *second = (AprilTestSimRun*)[obj2 valueForKey:@"TrialRun"];
            

                if (first.landscapeCostPrivatePropertyDamage < second.landscapeCostPrivatePropertyDamage)
                    return NSOrderedAscending;
                else if (second.landscapeCostPrivatePropertyDamage < first.landscapeCostPrivatePropertyDamage)
                    return NSOrderedDescending;
                return NSOrderedSame;
            
        }];
    }
        
    else if ([arrStatus[row] isEqual: @"Impact on my Neighbors"]){
        [trialRunSubViews sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            AprilTestSimRun *first  = (AprilTestSimRun*)[obj1 valueForKey:@"TrialRun"];
            AprilTestSimRun *second = (AprilTestSimRun*)[obj2 valueForKey:@"TrialRun"];
            

                if (first.normalizedLandscapeCumulativeOutflow < second.normalizedLandscapeCumulativeOutflow)
                    return NSOrderedAscending;
                else if (second.normalizedLandscapeCumulativeOutflow < first.normalizedLandscapeCumulativeOutflow)
                    return NSOrderedDescending;
                return NSOrderedSame;
            
            
        }];
    }
    
    else if ([arrStatus[row] isEqual: @"Intevention Capacity"]){
        [trialRunSubViews sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *key = (_DynamicNormalization.isOn) ? @"TrialDynamic" : @"TrialStatic";
            
            AprilTestNormalizedVariable *first  = (AprilTestNormalizedVariable*)[obj1 valueForKey: key];
            AprilTestNormalizedVariable *second = (AprilTestNormalizedVariable*)[obj2 valueForKey: key];
            

                if (first.landscapeCumulativeGICapacityUsed < second.landscapeCumulativeGICapacityUsed)
                    return NSOrderedAscending;
                else if (second.landscapeCumulativeGICapacityUsed < first.landscapeCumulativeGICapacityUsed)
                    return NSOrderedDescending;
                return NSOrderedSame;
            
        }];
    }
    
    else if ([arrStatus[row] isEqual: @"Max Flooded Area"]){
        [trialRunSubViews sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *key = (_DynamicNormalization.isOn) ? @"TrialDynamic" : @"TrialStatic";
            
            AprilTestNormalizedVariable *first  = (AprilTestNormalizedVariable*)[obj1 valueForKey: key];
            AprilTestNormalizedVariable *second = (AprilTestNormalizedVariable*)[obj2 valueForKey: key];
            
            
                if (first.normalizedLandscapeCumulativeFloodingOverall < second.normalizedLandscapeCumulativeFloodingOverall)
                    return NSOrderedAscending;
                else if (second.normalizedLandscapeCumulativeFloodingOverall < first.normalizedLandscapeCumulativeFloodingOverall)
                    return NSOrderedDescending;
                return NSOrderedSame;
            
        }];
    }
    
    else if ([arrStatus[row] isEqual: @"Water Flow"]){
        [trialRunSubViews sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *key = (_DynamicNormalization.isOn) ? @"TrialDynamic" : @"TrialStatic";
            
            AprilTestNormalizedVariable *first  = (AprilTestNormalizedVariable*)[obj1 valueForKey: key];
            AprilTestNormalizedVariable *second = (AprilTestNormalizedVariable*)[obj2 valueForKey: key];
            

                if (first.normalizedGreatestDepthStandingWater < second.normalizedGreatestDepthStandingWater)
                    return NSOrderedAscending;
                else if (second.normalizedGreatestDepthStandingWater < first.normalizedGreatestDepthStandingWater)
                    return NSOrderedDescending;
                return NSOrderedSame;
            
        }];
    }
    
    else if ([arrStatus[row] isEqual: @"Efficiency of Intervention"]){
        [trialRunSubViews sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            AprilTestSimRun *first  = (AprilTestSimRun*)[obj1 valueForKey:@"TrialRun"];
            AprilTestSimRun *second = (AprilTestSimRun*)[obj2 valueForKey:@"TrialRun"];
            
            
                if (first.costPerGallonCapturedByGI < second.costPerGallonCapturedByGI)
                    return NSOrderedAscending;
                else if (second.costPerGallonCapturedByGI < first.costPerGallonCapturedByGI)
                    return NSOrderedDescending;
                return NSOrderedSame;
            
        }];
    }
        
    else if ([arrStatus[row] isEqual: @"Groundwater Infiltration"]){
        [trialRunSubViews sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            AprilTestSimRun *first  = (AprilTestSimRun*)[obj1 valueForKey:@"TrialRun"];
            AprilTestSimRun *second = (AprilTestSimRun*)[obj2 valueForKey:@"TrialRun"];
            
            
                if (first.proportionCumulativeNetGIInfiltration > second.proportionCumulativeNetGIInfiltration)
                    return NSOrderedAscending;
                else if (second.proportionCumulativeNetGIInfiltration > first.proportionCumulativeNetGIInfiltration)
                    return NSOrderedDescending;
                return NSOrderedSame;
            
        }];
    }
    
    
    //loop through all entries (in sorted order) and update its frame to its new position
    for (int i = 0; i < trialRunSubViews.count; i++) {
        //FebTestWaterDisplay *wd               = [[trialRunSubViews objectAtIndex:i] valueForKey:@"WaterDisplay"];
        //FebTestWaterDisplay *mwd              = [[trialRunSubViews objectAtIndex:i] valueForKey:@"MWaterDisplay"];
        //AprilTestEfficiencyView *ev           = [[trialRunSubViews objectAtIndex:i] objectForKey:@"EfficiencyView"];
        UILabel *maintenance                  = [[trialRunSubViews objectAtIndex:i] valueForKey:@"Maintenance"];
        UITextField *newTxt                   = [[trialRunSubViews objectAtIndex:i] valueForKey:@"TrialTxTBox"];
        UILabel *Damage                       = [[trialRunSubViews objectAtIndex:i] valueForKey:@"Damage"];
        UILabel *DamageReduced                = [[trialRunSubViews objectAtIndex:i] valueForKey:@"DamageReduced"];
        UILabel *SewerLoad                    = [[trialRunSubViews objectAtIndex:i] valueForKey:@"SewerLoad"];
        UILabel *StormsForCost                = [[trialRunSubViews objectAtIndex:i] valueForKey:@"StormsForCost"];
        UILabel *gw_infiltration              = [[trialRunSubViews objectAtIndex:i] valueForKey:@"WaterInfiltration"];
        UILabel *EfficiencyOfIntervention     = [[trialRunSubViews objectAtIndex:i] valueForKey:@"Efficiency_Interv"];
        UILabel *impactNeighbor               = [[trialRunSubViews objectAtIndex:i] valueForKey:@"ImpactNeighbor"];
        UIImageView *wd                       = [[trialRunSubViews objectAtIndex:i] valueForKey:@"WaterDepthView"];
        UIImageView *mwd                      = [[trialRunSubViews objectAtIndex:i] valueForKey:@"MWaterDepthView"];
        UIImageView *ev                       = [[trialRunSubViews objectAtIndex:i] valueForKey:@"EfficiencyView"];
        UIImageView *InterventionImageView    = [[trialRunSubViews objectAtIndex:i] valueForKey:@"InterventionImgView"];
        UILabel *favoriteLabel                = [[trialRunSubViews objectAtIndex:i] objectForKey:@"FavoriteLabel"];
        FavoriteView *favoriteView            = [[trialRunSubViews objectAtIndex:i] objectForKey:@"FavoriteView"];
        LeastFavoriteView *leastFavoriteView  = [[trialRunSubViews objectAtIndex:i] objectForKey:@"LeastFavoriteView"];
        
        [favoriteView setFrame:CGRectMake(154, i * 175 + 125, 40, 40) andTrialNumber:favoriteView.trialNum];
        
        [leastFavoriteView setFrame:CGRectMake(212, i * 175 + 125, 40, 40) andTrialNumber:leastFavoriteView.trialNum];
        
        [favoriteLabel setFrame:CGRectMake(148, 175 * i + 105, 114, 20)];
        
        
        if(InterventionImageView.frame.size.width < 120)
            [self OffsetView:InterventionImageView toX:InterventionImageView.frame.origin.x andY:175 * (i) + 40];
        else
            [self OffsetView:InterventionImageView toX:InterventionImageView.frame.origin.x andY:175 * (i) + ((int)InterventionImageView.frame.origin.y % 175)];
        
        
        [self OffsetView:ev toX:ev.frame.origin.x andY:175*i + 40];
        //[ev updateViewForHour: StormPlaybackInterv.value];
        
        if(wd.frame.size.width < 120)
            [self OffsetView:wd toX:wd.frame.origin.x andY:175*i + 40];
        else
            [self OffsetView:wd toX:wd.frame.origin.x andY:175*i + ((int)wd.frame.origin.y % 175)];
        //[wd fastUpdateView: StormPlaybackWater.value];
        
        if(mwd.frame.size.width < 120)
            [self OffsetView:mwd toX:mwd.frame.origin.x andY:175*i + 40];
        else
            [self OffsetView:mwd toX:mwd.frame.origin.x andY:175*i + ((int)mwd.frame.origin.y % 175)];
        //[mwd updateView:48];
        
        //move over the private damage labels
        [self OffsetView:Damage toX:Damage.frame.origin.x andY:(i*175) +20 ];
        [self OffsetView:DamageReduced toX:DamageReduced.frame.origin.x andY:(i*175) +50];
        [self OffsetView:SewerLoad toX:SewerLoad.frame.origin.x andY:(i*175) + 80];
        [self OffsetView:StormsForCost toX:StormsForCost.frame.origin.x andY:(i*175) + 125];
        
        //move over impact on Neighbors
        [self OffsetView:impactNeighbor toX:impactNeighbor.frame.origin.x andY:(i*175) + 40];
        
        //move over groundwater infiltration
        [self OffsetView:gw_infiltration toX:gw_infiltration.frame.origin.x andY:(i*175) + 40];
        
        //move over efficiency of intervention
        [self OffsetView:EfficiencyOfIntervention toX:EfficiencyOfIntervention.frame.origin.x andY:(i*175) + 40];
        
        
        //move over maintenance
        [self OffsetView:maintenance toX:maintenance.frame.origin.x andY:(i*175) + 100];
        
        
        //Offset the "Trial #" label
        [self OffsetView:newTxt      toX:newTxt.frame.origin.x     andY:175*(i)+5];
    }

    (_DynamicNormalization.isOn) ? ([self normalizeAllandUpdateDynamically]) : ([self normalizaAllandUpdateStatically]);
}

#pragma mark UIPickerView Functions

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    SortPickerTextField.text = [NSString stringWithFormat:@" %@", arrStatus[row]];
    sortChosen = (int)row;
    [SortType removeFromSuperview];
    
    //highlight the textfield to reflect the concern ranking chosen
    if ([[arrStatus objectAtIndex:row] isEqualToString:@"Investment"]){
        SortPickerTextField.backgroundColor = [scoreColors objectForKey:@"installCost"];
    }
    else if ([[arrStatus objectAtIndex:row] isEqualToString:@"Damage Reduction"]){
        SortPickerTextField.backgroundColor = [scoreColors objectForKey:@"damageReduction"];
    }
    else if ([[arrStatus objectAtIndex:row] isEqualToString:@"Efficiency of Intervention"]){
        SortPickerTextField.backgroundColor = [scoreColors objectForKey:@"efficiencyOfIntervention"];
    }
    else if ([[arrStatus objectAtIndex:row] isEqualToString:@"Intervention Capacity"]){
        SortPickerTextField.backgroundColor = [scoreColors objectForKey:@"capacity"];
    }
    else if ([[arrStatus objectAtIndex:row] isEqualToString:@"Water Flow"]){
        SortPickerTextField.backgroundColor = [scoreColors objectForKey:@"animatedWaterViewer"];
    }
    else if ([[arrStatus objectAtIndex:row] isEqualToString:@"Max Flooded Area"]){
        SortPickerTextField.backgroundColor = [scoreColors objectForKey:@"totalAreaFlooded"];
    }
    else if ([[arrStatus objectAtIndex:row] isEqualToString:@"Groundwater Infiltration"]){
        SortPickerTextField.backgroundColor = [scoreColors objectForKey:@"groundwaterInfiltration"];
    }
    else if ([[arrStatus objectAtIndex:row] isEqualToString:@"Impact on my Neighbors"]){
        SortPickerTextField.backgroundColor = [scoreColors objectForKey:@"impactingMyNeighbors"];
    }
    else if ([[arrStatus objectAtIndex:row] isEqualToString:@"My Score"]){
        SortPickerTextField.backgroundColor = [UIColor orangeColor];
    }
    else if ([[arrStatus objectAtIndex:row] isEqualToString:@"Trial Number"]){
        SortPickerTextField.backgroundColor = [UIColor clearColor];
    }
    
    //Log the type of sort chosen
    AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
    NSString *logEntry = [tabControl generateLogEntryWith:[NSString stringWithFormat:@"\tTrial Sort Set To Sort By  \t%@", arrStatus[row]]];
    [tabControl writeToLogFileString:logEntry];
    
    //Handle the sort afterwards
    [_loadingIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];
    [self handleSort:(int)row];
    [_loadingIndicator stopAnimating];
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger numRows = [arrStatus count];
    
    return numRows;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    //create an individual frame for each element in the UIPicker and add its text
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        tView.frame = CGRectMake(0, 0, 250, 20);
    }
    tView.text = [arrStatus objectAtIndex:row];
    
    //set the background color to be its respective concern ranking color
    if ([tView.text isEqualToString:@"Investment"]){
        tView.backgroundColor = [scoreColors objectForKey:@"installCost"];
    }
    else if ([tView.text isEqualToString:@"Damage Reduction"]){
        tView.backgroundColor = [scoreColors objectForKey:@"damageReduction"];
    }
    else if ([tView.text isEqualToString:@"Efficiency of Intervention"]){
        tView.backgroundColor = [scoreColors objectForKey:@"efficiencyOfIntervention"];
    }
    else if ([tView.text isEqualToString:@"Intervention Capacity"]){
        tView.backgroundColor = [scoreColors objectForKey:@"capacity"];
    }
    else if ([tView.text isEqualToString:@"Water Flow"]){
        tView.backgroundColor = [scoreColors objectForKey:@"animatedWaterViewer"];
    }
    else if ([tView.text isEqualToString:@"Max Flooded Area"]){
        tView.backgroundColor = [scoreColors objectForKey:@"totalAreaFlooded"];
    }
    else if ([tView.text isEqualToString:@"Groundwater Infiltration"]){
        tView.backgroundColor = [scoreColors objectForKey:@"groundwaterInfiltration"];
    }
    else if ([tView.text isEqualToString:@"Impact on my Neighbors"]){
        tView.backgroundColor = [scoreColors objectForKey:@"impactingMyNeighbors"];
    }
    else if ([tView.text isEqualToString:@"My Score"]){
        tView.backgroundColor = [UIColor orangeColor];
    }
    else if ([tView.text isEqualToString:@"Trial Number"]){
        tView.backgroundColor = [UIColor clearColor];
    }
        return tView;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [arrStatus objectAtIndex:row];
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 150;
    
    return sectionWidth;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    int rowHeight = 20;
    return rowHeight;
}


@end

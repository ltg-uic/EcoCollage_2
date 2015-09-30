//
//  SocialViewController.m
//  AprilTest
//
//  Created by Ryan Fogarty on 6/2/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import "SocialViewController.h"
#import "AprilTestTabBarController.h"
#import "AprilTestSimRun.h"
#import "FebTestIntervention.h"
#import "AprilTestVariable.h"
#import "FebTestWaterDisplay.h"
#import "AprilTestEfficiencyView.h"
#import "AprilTestCostDisplay.h"
#import "AprilTestNormalizedVariable.h"
#import "XYPieChart.h"
#import <QuartzCore/QuartzCore.h>

@interface SocialViewController ()
@end

@implementation SocialViewController

@synthesize studyNum = _studyNum;
@synthesize profilesWindow = _profilesWindow;
@synthesize usernamesWindow = _usernamesWindow;
@synthesize BudgetSlider = _BudgetSlider;
@synthesize StormPlayBack = _StormPlayBack;
@synthesize loadingIndicator = _loadingIndicator;
@synthesize mapWindow = _mapWindow;
@synthesize trialPickerTextField = _trialPickerTextField;
@synthesize viewSegmentController = _viewSegmentController;

NSMutableDictionary         *concernColors;
NSMutableDictionary         *concernNames;
NSMutableDictionary         *scoreColors;

NSMutableArray              *arrStatus_social;
NSMutableArray              *efficiencySocial;
NSMutableArray              *imageViewsToRemove;
NSMutableArray              *scoreBars;

NSArray                     *sliceColors;

FebTestWaterDisplay         *waterDisplay;
FebTestWaterDisplay         *maxWaterDisplay;

UIView                      *viewForWaterDisplay;
UIView                      *viewForMaxWateDisplay;

UIImage                     *waterDisplayImage;
UIImage                     *maxWaterDisplayImage;

UITapGestureRecognizer      *tapGestureRecognizer_social;

UIScrollView                *corePlotView;
UIScrollView                *scoreBarView;
UIScrollView                *bottomOfMapWindow;

UIView                      *topOfMapWindow;

UILabel                     *budgetLabel;
UILabel                     *hoursAfterStormLabel;
UILabel                     *mapWindowStatusLabel;
UILabel                     *lastLabelTapped;
UILabel                     *maxLabelStorm;

UIPickerView                *SortType_social;


float                       thresh_social;
float                       hours_social = 0;

int                         hoursAfterStorm_social = 0;
int                         trialChosen= 0;
int                         smallSizeOfMapWindow = 50;
int                         largeSizeOfMapWindow = 220;
int                         widthOfUsernamesWindowWhenOpen;
int                         widthOfTitleVisualization = 220;
int                         heightOfVisualization = 200;
int                         dynamic_cd_width = 0;

#pragma mark View Lifecycle Functions


- (void)viewDidLoad {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    _studyNum = tabControl.studyNum;
    
    
    //AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
    NSString *logEntry = [tabControl generateLogEntryWith:@"\tSwitched To \tSocial View"];
    [tabControl writeToLogFileString:logEntry];
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // make scorebar visualization
    scoreBarView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 108, 283 + 769, 540)];
    [self.view addSubview:scoreBarView];

    
    corePlotView = [[UIScrollView alloc] initWithFrame:CGRectMake(1100, 108, 1052, 540)];
    [corePlotView setContentSize:CGSizeMake(879, 540)];
    UIImageView* plotView= [[UIImageView alloc]initWithFrame:CGRectMake(72, 0, 879, 540)];
    plotView.image = [UIImage imageNamed:@"pedvpolStudy.png"];
    [corePlotView addSubview:plotView];
    
    [self.view addSubview:corePlotView];
    
    [_viewSegmentController setSelectedSegmentIndex:1];
    
    /* visual representation of layout 3 screens
       ---------------------------------------------------
       | profiles view   | scorebar view | coreplot view |
       |                 |               |               |
       |                 |               |               |
       ---------------------------------------------------
    
    */
    
    // move profile visualization over
    _usernamesWindow.frame = CGRectMake(_usernamesWindow.frame.origin.x - 1100, _usernamesWindow.frame.origin.y, _usernamesWindow.frame.size.width, _usernamesWindow.frame.size.height);
    _profilesWindow.frame = CGRectMake(_profilesWindow.frame.origin.x - 1100, _usernamesWindow.frame.origin.y, _profilesWindow.frame.size.width, _usernamesWindow.frame.size.height);
    //[self.view viewWithTag:9002].frame = CGRectMake([self.view viewWithTag:9002].frame.origin.x - 1100, _usernamesWindow.frame.origin.y, 1, _usernamesWindow.frame.size.height);
    
    scoreBars = [[NSMutableArray alloc]init];
    
    
    
    
    concernColors = [[NSMutableDictionary alloc] initWithObjects:
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
                      [UIColor colorWithHue:.55 saturation:.8 brightness:.9 alpha: 0.5], nil]  forKeys: [[NSArray alloc] initWithObjects: @"Investment", @"publicCostI", @"publicCostM", @"publicCostD", @"Damage Reduction", @"privateCostI", @"privateCostM", @"privateCostD",  @"Efficiency of Intervention ($/Gallon)", @"Water Flow Path", @"Maximum Flooded Area", @"Groundwater Infiltration", @"Impact on my Neighbors", @"Capacity Used", nil] ];
    
    concernNames = [[NSMutableDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects: @"publicCost", @"privateCost", @"efficiencyOfIntervention", @"capacity", @"puddleTime", @"puddleMax", @"groundwaterInfiltration", @"impactingMyNeighbors", nil] forKeys:[[NSArray alloc] initWithObjects:@"Investment", @"Damage Reduction", @"Efficiency of Intervention ($/Gallon)", @"Capacity Used", @"Water Flow Path", @"Maximum Flooded Area", @"Groundwater Infiltration", @"Impact on my Neighbors", nil]];
    
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
                    [UIColor colorWithHue:.55 saturation:.8 brightness:.9 alpha: 0.5], nil]  forKeys: [[NSArray alloc] initWithObjects: @"publicCost", @"publicCostI", @"publicCostM", @"publicCostD", @"privateCost", @"privateCostI", @"privateCostM", @"privateCostD",  @"efficiencyOfIntervention", @"puddleTime", @"puddleMax", @"groundwaterInfiltration", @"impactingMyNeighbors", @"capacity", nil] ];
    
    
    sliceColors =[NSArray arrayWithObjects:
                  [UIColor colorWithHue:.3 saturation:.6 brightness:.9 alpha: 0.5],
                  [UIColor colorWithHue:.35 saturation:.8 brightness:.6 alpha: 0.5],
                  [UIColor colorWithHue:.4 saturation:.8 brightness:.3 alpha: 0.5],
                  [UIColor colorWithHue:.55 saturation:.8 brightness:.9 alpha: 0.5],
                  [UIColor colorWithHue:.65 saturation:.8 brightness:.6 alpha: 0.5],
                  [UIColor colorWithHue:.6 saturation:.8 brightness:.6 alpha: 0.5],
                  [UIColor colorWithHue:.6 saturation:.0 brightness:.3 alpha: 0.5],
                  [UIColor colorWithHue:.65 saturation:.0 brightness:.9 alpha: 0.5],
                  [UIColor colorWithHue:.7 saturation: 0.6 brightness:.3 alpha: 0.5],
                  [UIColor colorWithHue:.75 saturation: 0.6 brightness:.6 alpha: 0.5], nil];
    
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _loadingIndicator.center = CGPointMake(512, 300);
    _loadingIndicator.color = [UIColor blueColor];
    [self.view addSubview:_loadingIndicator];
    [_loadingIndicator stopAnimating];
    
    
    arrStatus_social = [[NSMutableArray alloc] initWithObjects:@"Trial 0", @"Favorite trials", @"Least Favorite Trials", nil];
    
    if (tabControl.trialNum != 0)
        _trialPickerTextField.text = [NSString stringWithFormat:@"%@", arrStatus_social[trialChosen]];
    else
        _trialPickerTextField.text = @"No Trials Loaded";
    _trialPickerTextField.delegate = self;
    
    if (SortType_social == nil){
        SortType_social = [[UIPickerView alloc] initWithFrame:CGRectMake(_trialPickerTextField.frame.origin.x - 250, _trialPickerTextField.frame.origin.y + _trialPickerTextField.frame.size.height, 250, 100)];
        SortType_social.backgroundColor = [UIColor whiteColor];
        SortType_social.layer.borderWidth = 1;
        [SortType_social setDataSource:self];
        [SortType_social setDelegate:self];
        [SortType_social setShowsSelectionIndicator:YES];
    }
    
    tapGestureRecognizer_social = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    tapGestureRecognizer_social.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer_social];
    
    efficiencySocial = [[NSMutableArray alloc]init];
    imageViewsToRemove = [[NSMutableArray alloc]init];
    
    
    
    _BudgetSlider = [[UISlider alloc]init];
    _BudgetSlider.maximumValue = 10000000;
    _BudgetSlider.value = tabControl.budget;
    [self drawMinMaxSliderLabels];
    
    _StormPlayBack.minimumValue = 0;
    _StormPlayBack.maximumValue = 48;

    [_StormPlayBack addTarget:self
                       action:@selector(StormHoursChanged:)
             forControlEvents:UIControlEventValueChanged];
    [_StormPlayBack addTarget:self
                       action:@selector(StormHoursChosen:)
             forControlEvents:UIControlEventTouchUpInside];
    [_StormPlayBack addTarget:self
                       action:@selector(StormHoursChosen:)
             forControlEvents:UIControlEventTouchCancel];
    [_StormPlayBack addTarget:self
                       action:@selector(StormHoursChosen:)
             forControlEvents:UIControlEventTouchUpOutside];
    
    
    [_StormPlayBack addTarget:self
                       action:@selector(changeHoursLabel)
             forControlEvents:(UIControlEventValueChanged)];

    _StormPlayBack.continuous = YES;
    _StormPlayBack.value = hours_social;
    
    _profilesWindow.delegate = self;
    _usernamesWindow.delegate = self;
    _mapWindow.delegate = self;
    
    
    _mapWindow.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _mapWindow.layer.borderWidth = 1.0;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnMapWindowRecognized)];
    [_mapWindow addGestureRecognizer:singleTap];
    
    topOfMapWindow = [[UIView alloc]init];
    topOfMapWindow.frame = CGRectMake(0, 0, _mapWindow.frame.size.width, smallSizeOfMapWindow);
    [_mapWindow addSubview:topOfMapWindow];
    
    bottomOfMapWindow = [[UIScrollView alloc]init];
    bottomOfMapWindow.frame = CGRectMake(0, smallSizeOfMapWindow, _mapWindow.frame.size.width, largeSizeOfMapWindow - smallSizeOfMapWindow);
    [_mapWindow addSubview:bottomOfMapWindow];
    
    
    // top of mapWindow label
    mapWindowStatusLabel = [[UILabel alloc]init];
    mapWindowStatusLabel.text = @"Tap to view map(s)";
    mapWindowStatusLabel.font = [UIFont systemFontOfSize:15.0];
    [mapWindowStatusLabel sizeToFit];
    mapWindowStatusLabel.frame = CGRectMake((topOfMapWindow.frame.size.width - mapWindowStatusLabel.frame.size.width) / 2, (smallSizeOfMapWindow - mapWindowStatusLabel.frame.size.height) / 2, mapWindowStatusLabel.frame.size.width, mapWindowStatusLabel.frame.size.height);
    [_mapWindow addSubview:mapWindowStatusLabel];
    
    waterDisplayImage = [[UIImage alloc]init];
    maxWaterDisplayImage = [[UIImage alloc]init];
    
    viewForWaterDisplay = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 115, 125)];
    viewForMaxWateDisplay = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 115, 125)];
    
    // line below profilesWindow and usernamesWindow
    UIView *lineBelowData = [[UIView alloc]init];
    lineBelowData.frame = CGRectMake(0, _usernamesWindow.frame.origin.y + _usernamesWindow.frame.size.height - 1, 1100, 1);
    lineBelowData.layer.borderColor = [UIColor lightGrayColor].CGColor;
    lineBelowData.layer.borderWidth = 0.5;
    lineBelowData.tag = 9001;
    [self.view addSubview:lineBelowData];
    
    // line inbetween usernamesWindow and profilesWindow
    UIView *lineBetweenViews = [[UIView alloc]init];
    lineBetweenViews.frame = CGRectMake(_usernamesWindow.frame.origin.x + _usernamesWindow.frame.size.width, _usernamesWindow.frame.origin.y - 1, 1, _usernamesWindow.frame.size.height + 1);
    lineBetweenViews.layer.borderColor = [UIColor lightGrayColor].CGColor;
    lineBetweenViews.layer.borderWidth = 1.0;
    lineBetweenViews.tag = 9002;
    [self.view addSubview:lineBetweenViews];
    
    widthOfUsernamesWindowWhenOpen = _usernamesWindow.frame.size.width;
    
    // draws horizontal line across scoreBarView to seperate users score bars
    UIView *lineAcrossScoreBarView = [[UIView alloc]init];
    lineAcrossScoreBarView.frame = CGRectMake(0, scoreBarView.frame.size.height / 2, scoreBarView.frame.size.width, 1);
    lineAcrossScoreBarView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    lineAcrossScoreBarView.layer.borderWidth = 1.0;
    lineAcrossScoreBarView.tag = 9003;
    [scoreBarView addSubview:lineAcrossScoreBarView];
    
    // draw vertical lines between concerns
    for (int i = 1; i < 8; i++) {
        [self drawLineInView:_profilesWindow withXVal:i * widthOfTitleVisualization];
    }
    
}


-(void) dealloc {
    NSLog(@"Deallocing...");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// release notification if view is unloaded for memory purposes
- (void) viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


/*
 Method Description: Called whenever the social view will appear. Sets up notifications.
 Inputs: None
 Outputs: None
 */
- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(profileUpdateHelper)
                                                 name:@"profileUpdate"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePicker)
                                                 name:@"updatePicker"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(usernameUpdateHelper:)
                                                 name:@"usernameUpdate"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateSingleProfileHelper:)
                                                 name:@"updateSingleProfile"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFavoriteOrLeastFavoriteChosenForProfile:)
                                                 name:@"updateFavoriteOrLeast"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(drawNewProfileHelper)
                                                 name:@"drawNewProfile"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(BudgetChanged)
                                                 name:@"updateBudget"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(investmentTapped)
                                                 name:@"slice0tapped"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(damageReducTapped)
                                                 name:@"slice1tapped"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(efficiencyTapped)
                                                 name:@"slice2tapped"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(interventionCapTapped)
                                                 name:@"slice3tapped"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(waterDepthTapped)
                                                 name:@"slice4tapped"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(maxFloodTapped)
                                                 name:@"slice5tapped"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(groundwaterTapped)
                                                 name:@"slice6tapped"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(impactTapped)
                                                 name:@"slice7tapped"
                                               object:nil];
    
    
    
    [self updatePicker];
}

/*
 Method Description: Once the social view appears, draws the profiles and score bars
 Inputs: Animation boolean
 Outputs: None
 */
- (void)viewDidAppear:(BOOL)animated {
    //log switch in screens to log file
    AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
    
    thresh_social = tabControl.threshVal;
    
    NSString *logEntry = [tabControl generateLogEntryWith:@"\tSwitched To Social View Screen"];
    [tabControl writeToLogFileString:logEntry];

    if(tabControl.reloadSocialView == 0) return;
    
    [self profileUpdate];
    [self drawScoreBarVisualizationHelper];
    
    [self drawCorePlot];
}

/*
 Method Description: Called when user switches from social view to another view. Removes notification observers. Clears the following three views: _usernamesWindow, _profilesWindow (except for vertical lines drawn in viewDidLoad), bottomOfMapWindow.
 Inputs: Animation boolean
 Outputs: None
 */
- (void)viewWillDisappear:(BOOL)animated {
    // remove notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"profileUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updatePicker" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"usernameUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateFavoriteOrLeast" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateSingleProfile" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"drawNewProfile" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateBudget" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"slice0tapped" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"slice1tapped" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"slice2tapped" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"slice3tapped" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"slice4tapped" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"slice5tapped" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"slice6tapped" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"slice7tapped" object:nil];
    
    AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
    tabControl.reloadSocialView = 0;
    
    [super viewWillDisappear:animated];
}


#pragma mark Animation Functions

/*
 Method Description: Switches between score bar visualization, profiles visualization, and graphing visualization with animation.
 Inputs: UISegmentedControl*
 Outputs: None
 */
- (IBAction)switchView:(UISegmentedControl*)sender {
    /*          6 move choices
     1 : from scoreBarView to profilesView
     2 : from scoreBarView to corePlotView
     3 : from profilesView to scoreBarView
     4 : from profilesView to corePlotView
     5 : from corePlotView to profilesView
     6 : from corePlotView to scoreBarView
     
     sender.selectedSegmentIndex == 0 -> go to profiles view
     sender.selectedSegmentIndex == 1 -> go to score bar view
     sender.selectedSegmentIndex == 2 -> go to graph view
     */
    
    int moveChoice = 0;
    if (sender.selectedSegmentIndex == 0 && scoreBarView.frame.origin.x == 0) moveChoice = 1;
    else if (sender.selectedSegmentIndex == 2 && scoreBarView.frame.origin.x == 0) moveChoice = 2;
    else if (sender.selectedSegmentIndex == 1 && _usernamesWindow.frame.origin.x == 0) moveChoice = 3;
    else if (sender.selectedSegmentIndex == 2 && _usernamesWindow.frame.origin.x == 0) moveChoice = 4;
    else if (sender.selectedSegmentIndex == 0 && corePlotView.frame.origin.x == 0) moveChoice = 5;
    else if (sender.selectedSegmentIndex == 1 && corePlotView.frame.origin.x == 0) moveChoice = 6;
    else return;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    // move scoreBarView out and move profilesView in
    if (moveChoice == 1) {
        // show profile visualization
        _usernamesWindow.frame = CGRectMake(0, _usernamesWindow.frame.origin.y, _usernamesWindow.frame.size.width, _usernamesWindow.frame.size.height);
        _profilesWindow.frame = CGRectMake(283, _profilesWindow.frame.origin.y, _profilesWindow.frame.size.width, _profilesWindow.frame.size.height);
        [self.view viewWithTag:9002].frame = CGRectMake(_usernamesWindow.frame.origin.x + _usernamesWindow.frame.size.width, _usernamesWindow.frame.origin.y - 1, 1, _usernamesWindow.frame.size.height + 1);
        
        // hide scorebar visualization
        scoreBarView.frame = CGRectMake(1100, scoreBarView.frame.origin.y, scoreBarView.frame.size.width, scoreBarView.frame.size.height);
        //[_viewSwitchButton sizeToFit];
    }
    // move scoreBarView out and move corePlotView in
    else if(moveChoice == 2) {
        // show corePlotView visualization
        corePlotView.frame = CGRectMake(0, corePlotView.frame.origin.y, corePlotView.frame.size.width, corePlotView.frame.size.height);
        
        // hide scoreBarView
        scoreBarView.frame = CGRectMake(-1100, scoreBarView.frame.origin.y, scoreBarView.frame.size.width, scoreBarView.frame.size.height);
    }
    // move profilesView out and move scoreBarView in
    else if(moveChoice == 3) {
        // hide profile visualization
        _usernamesWindow.frame = CGRectMake(_usernamesWindow.frame.origin.x - 1100, _usernamesWindow.frame.origin.y, _usernamesWindow.frame.size.width, _usernamesWindow.frame.size.height);
        _profilesWindow.frame = CGRectMake(_profilesWindow.frame.origin.x - 1100, _usernamesWindow.frame.origin.y, _profilesWindow.frame.size.width, _usernamesWindow.frame.size.height);
        [self.view viewWithTag:9002].frame = CGRectMake([self.view viewWithTag:9002].frame.origin.x - 1100, _usernamesWindow.frame.origin.y, 1, _usernamesWindow.frame.size.height);
        
        // show scorebar visualization
        scoreBarView.frame = CGRectMake(0, scoreBarView.frame.origin.y, scoreBarView.frame.size.width, scoreBarView.frame.size.height);
    }
    // move profilesView out and move corePlotView in
    else if(moveChoice == 4) {
        // hide profile visualization
        _usernamesWindow.frame = CGRectMake(_usernamesWindow.frame.origin.x - 1100, _usernamesWindow.frame.origin.y, _usernamesWindow.frame.size.width, _usernamesWindow.frame.size.height);
        _profilesWindow.frame = CGRectMake(_profilesWindow.frame.origin.x - 1100, _usernamesWindow.frame.origin.y, _profilesWindow.frame.size.width, _usernamesWindow.frame.size.height);
        [self.view viewWithTag:9002].frame = CGRectMake([self.view viewWithTag:9002].frame.origin.x - 1100, _usernamesWindow.frame.origin.y, 1, _usernamesWindow.frame.size.height);
        
        // show corePlotView visualization
        corePlotView.frame = CGRectMake(0, corePlotView.frame.origin.y, corePlotView.frame.size.width, corePlotView.frame.size.height);

    }
    // move corePlotView out and move profilesView in
    else if(moveChoice == 5) {
        // hide corePlotView visualization
        corePlotView.frame = CGRectMake(1100, corePlotView.frame.origin.y, corePlotView.frame.size.width, corePlotView.frame.size.height);
        
        // show profile visualization
        _usernamesWindow.frame = CGRectMake(0, _usernamesWindow.frame.origin.y, _usernamesWindow.frame.size.width, _usernamesWindow.frame.size.height);
        _profilesWindow.frame = CGRectMake(283, _profilesWindow.frame.origin.y, _profilesWindow.frame.size.width, _profilesWindow.frame.size.height);
        [self.view viewWithTag:9002].frame = CGRectMake(_usernamesWindow.frame.origin.x + _usernamesWindow.frame.size.width, _usernamesWindow.frame.origin.y - 1, 1, _usernamesWindow.frame.size.height + 1);
    }
    // move corePlotView out and move scoreBarView in
    else if(moveChoice == 6) {
        // hide corePlotView visualization
        corePlotView.frame = CGRectMake(1100, corePlotView.frame.origin.y, corePlotView.frame.size.width, corePlotView.frame.size.height);
        
        // show scorebar visualization
        scoreBarView.frame = CGRectMake(0, scoreBarView.frame.origin.y, scoreBarView.frame.size.width, scoreBarView.frame.size.height);
    }
    
    
    [UIView commitAnimations];
    
    if(moveChoice == 4)
        [scoreBarView setFrame:CGRectMake(-1100, scoreBarView.frame.origin.y, scoreBarView.frame.size.width, scoreBarView.frame.size.height)];
    else if(moveChoice == 5)
        [scoreBarView setFrame:CGRectMake(1100, scoreBarView.frame.origin.y, scoreBarView.frame.size.width, scoreBarView.frame.size.height)];
}

/*
 Method Description: When user taps on _mapWindow, it should slide open or closed with an animation depending on its current state.
 Inputs: None
 Outputs: None
 */
- (void)tapOnMapWindowRecognized {
    int sizeOfChange = largeSizeOfMapWindow - smallSizeOfMapWindow;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    if (_mapWindow.frame.size.height < largeSizeOfMapWindow) {
        AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
        NSString *logEntry = [tabControl generateLogEntryWith:@"\tShowed maps in social view"];
        [tabControl writeToLogFileString:logEntry];
        mapWindowStatusLabel.text = @"Tap to hide map(s)";
        _usernamesWindow.frame = CGRectMake(_usernamesWindow.frame.origin.x, _usernamesWindow.frame.origin.y + sizeOfChange, _usernamesWindow.frame.size.width, _usernamesWindow.frame.size.height - sizeOfChange);
        _profilesWindow.frame = CGRectMake(_profilesWindow.frame.origin.x, _profilesWindow.frame.origin.y + sizeOfChange, _profilesWindow.frame.size.width, _profilesWindow.frame.size.height - sizeOfChange);
        _mapWindow.frame = CGRectMake(_mapWindow.frame.origin.x, _mapWindow.frame.origin.y, _mapWindow.frame.size.width, largeSizeOfMapWindow);
        UIView *lineView = [self.view viewWithTag:9002];
        lineView.frame = CGRectMake(_usernamesWindow.frame.origin.x + _usernamesWindow.frame.size.width, _usernamesWindow.frame.origin.y - 1, 1, _usernamesWindow.frame.size.height + 1);
        
        
        scoreBarView.frame = CGRectMake(scoreBarView.frame.origin.x, scoreBarView.frame.origin.y + sizeOfChange, scoreBarView.frame.size.width, scoreBarView.frame.size.height - sizeOfChange);
        
        corePlotView.frame = CGRectMake(corePlotView.frame.origin.x, corePlotView.frame.origin.y + sizeOfChange, corePlotView.frame.size.width, corePlotView.frame.size.height - sizeOfChange);
    }
    else {
        AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
        NSString *logEntry = [tabControl generateLogEntryWith:@"\tHid maps in social view"];
        [tabControl writeToLogFileString:logEntry];
        mapWindowStatusLabel.text = @"Tap to view map(s)";
        _usernamesWindow.frame = CGRectMake(_usernamesWindow.frame.origin.x, _usernamesWindow.frame.origin.y - sizeOfChange, _usernamesWindow.frame.size.width, _usernamesWindow.frame.size.height + sizeOfChange);
        _profilesWindow.frame = CGRectMake(_profilesWindow.frame.origin.x, _profilesWindow.frame.origin.y - sizeOfChange, _profilesWindow.frame.size.width, _profilesWindow.frame.size.height + sizeOfChange);
        _mapWindow.frame = CGRectMake(_mapWindow.frame.origin.x, _mapWindow.frame.origin.y, _mapWindow.frame.size.width, smallSizeOfMapWindow);
        UIView *lineView = [self.view viewWithTag:9002];
        lineView.frame = CGRectMake(_usernamesWindow.frame.origin.x + _usernamesWindow.frame.size.width, _usernamesWindow.frame.origin.y - 1, 1, _usernamesWindow.frame.size.height + 1);
        
        scoreBarView.frame = CGRectMake(scoreBarView.frame.origin.x, scoreBarView.frame.origin.y - sizeOfChange, scoreBarView.frame.size.width, scoreBarView.frame.size.height + sizeOfChange);
        
        corePlotView.frame = CGRectMake(corePlotView.frame.origin.x, corePlotView.frame.origin.y - sizeOfChange, corePlotView.frame.size.width, corePlotView.frame.size.height + sizeOfChange);
    }
    [UIView commitAnimations];
}

#pragma mark Non-Animation Tap Recognizer Functions


/*
 Method Description: Called when user taps on a UITextField (in this case, the textField is for the trial choosing. Opens up UIPicker for trial choosing.
 Inputs: UITextField*
 Outputs: BOOL
 */
- (BOOL) textFieldShouldBeginEditing:(UITextField *)textView
{
    if (textView == _trialPickerTextField){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.50];
        [UIView setAnimationDelegate:self];
        [self.view addSubview:SortType_social];
        [UIView commitAnimations];
        return NO;
    }
    else{
        return YES;
    }
}

/*
 Method Description: Called when user taps outside of SortType_Social UIPicker. Closes Picker if it is open.
 Inputs: UITapGestureRecognizer*
 Outputs: None
 */
- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
    //Code to handle the gesture
    if ([SortType_social isHidden]){
        NSLog(@"View Doesn't Exist");
    }
    else{
        [SortType_social removeFromSuperview];
    }
}


/*
 Method Description: Called when user taps on the "Impact On My Neighbors" portion of the pie chart or score section in Score Bar Visualization. Displays score for this section and the name of the section.
 Inputs: None
 Outputs: None
 */
- (void)impactTapped {
    UILabel *scoreNumber;
    UILabel *labelForScore;
    UILabel *scoreName;
    
    for (int i = 0; i < [scoreBars count]; i++) {
        scoreNumber = [[scoreBars objectAtIndex:i] objectForKey:@"scoreNumber"];
        scoreName = [[scoreBars objectAtIndex:i] objectForKey:@"scoreName"];
        labelForScore = [[scoreBars objectAtIndex:i] objectForKey:@"impactingMyNeighbors"];
        
        scoreNumber.text = [NSString stringWithFormat:@"%d", (int)(labelForScore.frame.size.width /2.56)];
        [scoreNumber sizeToFit];
        
        scoreName.text = @"Impact on my Neighbors";
        scoreName.numberOfLines = 2;
        [scoreName sizeToFit];
        scoreName.frame = CGRectMake(scoreName.frame.origin.x, scoreName.frame.origin.y, 14 * 7, scoreName.frame.size.height);
        
        scoreNumber.center = CGPointMake(labelForScore.center.x, labelForScore.center.y);
        scoreNumber.frame = CGRectMake(scoreNumber.frame.origin.x, labelForScore.frame.origin.y - scoreNumber.frame.size.height, scoreNumber.frame.size.width, scoreNumber.frame.size.height);
        
        scoreName.center = CGPointMake(labelForScore.center.x, labelForScore.center.y);
        scoreName.frame = CGRectMake(scoreName.frame.origin.x, labelForScore.frame.origin.y + labelForScore.frame.size.height +1, scoreName.frame.size.width, scoreName.frame.size.height);
    }
    
    lastLabelTapped = [[scoreBars objectAtIndex:0] objectForKey:@"impactingMyNeighbors"];
    AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
    NSString *logEntry = [tabControl generateLogEntryWith:@"\tImpact on Neighbors score inspected"];
    [tabControl writeToLogFileString:logEntry];
}


/*
 Method Description: Called when user taps on the "Groundwater Infiltration" portion of the pie chart or score section in Score Bar Visualization. Displays score for this section and the name of the section.
 Inputs: None
 Outputs: None
 */
- (void)groundwaterTapped {
    UILabel *scoreNumber;
    UILabel *labelForScore;
    UILabel *scoreName;
    
    for (int i = 0; i < [scoreBars count]; i++) {
        scoreNumber = [[scoreBars objectAtIndex:i] objectForKey:@"scoreNumber"];
        scoreName = [[scoreBars objectAtIndex:i] objectForKey:@"scoreName"];
        labelForScore = [[scoreBars objectAtIndex:i] objectForKey:@"groundwaterInfiltration"];
        
        scoreNumber.text = [NSString stringWithFormat:@"%d", (int)(labelForScore.frame.size.width/2.56)];
        [scoreNumber sizeToFit];
        
        scoreName.text = @"Groundwater Infiltration";
        scoreName.numberOfLines = 2;
        [scoreName sizeToFit];
        scoreName.frame = CGRectMake(scoreName.frame.origin.x, scoreName.frame.origin.y, 14 * 7, scoreName.frame.size.height);
        
        scoreNumber.center = CGPointMake(labelForScore.center.x, labelForScore.center.y);
        scoreNumber.frame = CGRectMake(scoreNumber.frame.origin.x, labelForScore.frame.origin.y - scoreNumber.frame.size.height, scoreNumber.frame.size.width, scoreNumber.frame.size.height);
        
        scoreName.center = CGPointMake(labelForScore.center.x, labelForScore.center.y);
        scoreName.frame = CGRectMake(scoreName.frame.origin.x, labelForScore.frame.origin.y + labelForScore.frame.size.height +1, scoreName.frame.size.width, scoreName.frame.size.height);
        
    }
    
    lastLabelTapped = [[scoreBars objectAtIndex:0] objectForKey:@"groundwaterInfiltration"];
    AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
    NSString *logEntry = [tabControl generateLogEntryWith:@"\tGroundwater Infiltration score inspected"];
    [tabControl writeToLogFileString:logEntry];
}

/*
 Method Description: Called when user taps on the "Maximum Flooded Area" portion of the pie chart or score section in Score Bar Visualization. Displays score for this section and the name of the section.
 Inputs: None
 Outputs: None
 */
- (void)maxFloodTapped {
    UILabel *scoreNumber;
    UILabel *labelForScore;
    UILabel *scoreName;
    
    for (int i = 0; i < [scoreBars count]; i++) {
        scoreNumber = [[scoreBars objectAtIndex:i] objectForKey:@"scoreNumber"];
        scoreName = [[scoreBars objectAtIndex:i] objectForKey:@"scoreName"];
        labelForScore = [[scoreBars objectAtIndex:i] objectForKey:@"puddleMax"];
        
        scoreNumber.text = [NSString stringWithFormat:@"%d", (int)(labelForScore.frame.size.width/2.56)];
        [scoreNumber sizeToFit];
        
        scoreName.text = @"Maximum Flooded Area";
        scoreName.numberOfLines = 2;
        [scoreName sizeToFit];
        scoreName.frame = CGRectMake(scoreName.frame.origin.x, scoreName.frame.origin.y, 14 * 7, scoreName.frame.size.height);
        
        scoreNumber.center = CGPointMake(labelForScore.center.x, labelForScore.center.y);
        scoreNumber.frame = CGRectMake(scoreNumber.frame.origin.x, labelForScore.frame.origin.y - scoreNumber.frame.size.height, scoreNumber.frame.size.width, scoreNumber.frame.size.height);
        
        
        scoreName.center = CGPointMake(labelForScore.center.x, labelForScore.center.y);
        scoreName.frame = CGRectMake(scoreName.frame.origin.x, labelForScore.frame.origin.y + labelForScore.frame.size.height +1, scoreName.frame.size.width, scoreName.frame.size.height);
    }
    
    lastLabelTapped = [[scoreBars objectAtIndex:0] objectForKey:@"puddleMax"];
    AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
    NSString *logEntry = [tabControl generateLogEntryWith:@"\tMaximum Flooded Area score inspected"];
    [tabControl writeToLogFileString:logEntry];
}

/*
 Method Description: Called when user taps on the "Water Depth Over Storm" portion of the pie chart or score section in Score Bar Visualization. Displays score for this section and the name of the section.
 Inputs: None
 Outputs: None
 */
- (void)waterDepthTapped {
    UILabel *scoreNumber;
    UILabel *labelForScore;
    UILabel *scoreName;
    
    for (int i = 0; i < [scoreBars count]; i++) {
        scoreNumber = [[scoreBars objectAtIndex:i] objectForKey:@"scoreNumber"];
        scoreName = [[scoreBars objectAtIndex:i] objectForKey:@"scoreName"];
        labelForScore = [[scoreBars objectAtIndex:i] objectForKey:@"puddleTime"];
        
        scoreNumber.text = [NSString stringWithFormat:@"%d", (int)(labelForScore.frame.size.width/2.56)];
        [scoreNumber sizeToFit];
        
        scoreName.text = @"Water Flow";
        scoreName.numberOfLines = 2;
        [scoreName sizeToFit];
        scoreName.frame = CGRectMake(scoreName.frame.origin.x, scoreName.frame.origin.y, 14 * 7, scoreName.frame.size.height);
        
        scoreNumber.center = CGPointMake(labelForScore.center.x, labelForScore.center.y);
        scoreNumber.frame = CGRectMake(scoreNumber.frame.origin.x, labelForScore.frame.origin.y - scoreNumber.frame.size.height, scoreNumber.frame.size.width, scoreNumber.frame.size.height);
        
        
        scoreName.center = CGPointMake(labelForScore.center.x, labelForScore.center.y);
        scoreName.frame = CGRectMake(scoreName.frame.origin.x, labelForScore.frame.origin.y + labelForScore.frame.size.height +1, scoreName.frame.size.width, scoreName.frame.size.height);
    }
    
    lastLabelTapped = [[scoreBars objectAtIndex:0] objectForKey:@"puddleTime"];
    
    AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
    NSString *logEntry = [tabControl generateLogEntryWith:@"\tWater Flow score inspected"];
    [tabControl writeToLogFileString:logEntry];
}

/*
 Method Description: Called when user taps on the "Intervention Capacity" portion of the pie chart or score section in Score Bar Visualization. Displays score for this section and the name of the section.
 Inputs: None
 Outputs: None
 */
- (void)interventionCapTapped {
    UILabel *scoreNumber;
    UILabel *labelForScore;
    UILabel *scoreName;
    
    for (int i = 0; i < [scoreBars count]; i++) {
        scoreNumber = [[scoreBars objectAtIndex:i] objectForKey:@"scoreNumber"];
        scoreName = [[scoreBars objectAtIndex:i] objectForKey:@"scoreName"];
        labelForScore = [[scoreBars objectAtIndex:i] objectForKey:@"capacity"];
        
        scoreNumber.text = [NSString stringWithFormat:@"%d", (int)(labelForScore.frame.size.width/2.56)];
        [scoreNumber sizeToFit];
        
        scoreName.text = @"Intervention Capacity";
        scoreName.numberOfLines = 2;
        [scoreName sizeToFit];
        scoreName.frame = CGRectMake(scoreName.frame.origin.x, scoreName.frame.origin.y, 14 * 7, scoreName.frame.size.height);
        
        scoreNumber.center = CGPointMake(labelForScore.center.x, labelForScore.center.y);
        scoreNumber.frame = CGRectMake(scoreNumber.frame.origin.x, labelForScore.frame.origin.y - scoreNumber.frame.size.height, scoreNumber.frame.size.width, scoreNumber.frame.size.height);
        
        
        scoreName.center = CGPointMake(labelForScore.center.x, labelForScore.center.y);
        scoreName.frame = CGRectMake(scoreName.frame.origin.x, labelForScore.frame.origin.y + labelForScore.frame.size.height +1, scoreName.frame.size.width, scoreName.frame.size.height);
    }
    
    lastLabelTapped = [[scoreBars objectAtIndex:0] objectForKey:@"capacity"];
    AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
    NSString *logEntry = [tabControl generateLogEntryWith:@"\tCapacity score inspected"];
    [tabControl writeToLogFileString:logEntry];
}

/*
 Method Description: Called when user taps on the "Efficiency of Intervention" portion of the pie chart or score section in Score Bar Visualization. Displays score for this section and the name of the section.
 Inputs: None
 Outputs: None
 */
- (void)efficiencyTapped {
    UILabel *scoreNumber;
    UILabel *labelForScore;
    UILabel *scoreName;
    
    for (int i = 0; i < [scoreBars count]; i++) {
        scoreNumber = [[scoreBars objectAtIndex:i] objectForKey:@"scoreNumber"];
        scoreName = [[scoreBars objectAtIndex:i] objectForKey:@"scoreName"];
        labelForScore = [[scoreBars objectAtIndex:i] objectForKey:@"efficiencyOfIntervention"];
        
        scoreNumber.text = [NSString stringWithFormat:@"%d", (int)(labelForScore.frame.size.width/2.56)];
        [scoreNumber sizeToFit];
        
        scoreName.text = @"Efficiency of Intervention";
        scoreName.numberOfLines = 2;
        [scoreName sizeToFit];
        scoreName.frame = CGRectMake(scoreName.frame.origin.x, scoreName.frame.origin.y, 14 * 7, scoreName.frame.size.height);
        
        scoreNumber.center = CGPointMake(labelForScore.center.x, labelForScore.center.y);
        scoreNumber.frame = CGRectMake(scoreNumber.frame.origin.x, labelForScore.frame.origin.y - scoreNumber.frame.size.height, scoreNumber.frame.size.width, scoreNumber.frame.size.height);
        
        
        scoreName.center = CGPointMake(labelForScore.center.x, labelForScore.center.y);
        scoreName.frame = CGRectMake(scoreName.frame.origin.x, labelForScore.frame.origin.y + labelForScore.frame.size.height +1, scoreName.frame.size.width, scoreName.frame.size.height);
    }
    
    lastLabelTapped = [[scoreBars objectAtIndex:0] objectForKey:@"efficiencyOfIntervention"];
    AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
    NSString *logEntry = [tabControl generateLogEntryWith:@"\tDollars per Gallon score Inspected"];
    [tabControl writeToLogFileString:logEntry];
}

/*
 Method Description: Called when user taps on the "Damage Reduction" portion of the pie chart or score section in Score Bar Visualization. Displays score for this section and the name of the section.
 Inputs: None
 Outputs: None
 */
- (void)damageReducTapped {
    UILabel *scoreNumber;
    UILabel *labelForScore;
    UILabel *scoreName;
    
    for (int i = 0; i < [scoreBars count]; i++) {
        scoreNumber = [[scoreBars objectAtIndex:i] objectForKey:@"scoreNumber"];
        scoreName = [[scoreBars objectAtIndex:i] objectForKey:@"scoreName"];
        labelForScore = [[scoreBars objectAtIndex:i] objectForKey:@"privateCostD"];
        
        scoreNumber.text = [NSString stringWithFormat:@"%d", (int)(labelForScore.frame.size.width/2.56)];
        [scoreNumber sizeToFit];
        
        
        scoreName.text = @"Damage Reduction";
        scoreName.numberOfLines = 2;
        [scoreName sizeToFit];
        scoreName.frame = CGRectMake(scoreName.frame.origin.x, scoreName.frame.origin.y, 14 * 7, scoreName.frame.size.height);
        
        scoreNumber.center = CGPointMake(labelForScore.center.x, labelForScore.center.y);
        scoreNumber.frame = CGRectMake(scoreNumber.frame.origin.x, labelForScore.frame.origin.y - scoreNumber.frame.size.height, scoreNumber.frame.size.width, scoreNumber.frame.size.height);
        
        
        scoreName.center = CGPointMake(labelForScore.center.x, labelForScore.center.y);
        scoreName.frame = CGRectMake(scoreName.frame.origin.x, labelForScore.frame.origin.y + labelForScore.frame.size.height +1, scoreName.frame.size.width, scoreName.frame.size.height);
    }
    
    AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
    NSString *logEntry = [tabControl generateLogEntryWith:@"\tDamage Reduction Score inspected"];
    [tabControl writeToLogFileString:logEntry];
    lastLabelTapped = [[scoreBars objectAtIndex:0] objectForKey:@"privateCostD"];
}

/*
 Method Description: Called when user taps on the "Investment" portion of the pie chart or score section in Score Bar Visualization. Displays score for this section and the name of the section.
 Inputs: None
 Outputs: None
 */
- (void)investmentTapped {
    UILabel *scoreNumber;
    UILabel *labelForScore;
    UILabel *scoreName;
    
    for (int i = 0; i < [scoreBars count]; i++) {
        scoreNumber = [[scoreBars objectAtIndex:i] objectForKey:@"scoreNumber"];
        scoreName = [[scoreBars objectAtIndex:i] objectForKey:@"scoreName"];
        labelForScore = [[scoreBars objectAtIndex:i] objectForKey:@"publicCost"];
        
        scoreNumber.text = [NSString stringWithFormat:@"%d", (int)(labelForScore.frame.size.width/2.56)];
        [scoreNumber sizeToFit];
        
        scoreName.text = @"Investment";
        scoreName.numberOfLines = 1;
        [scoreName sizeToFit];
        
        scoreNumber.center = CGPointMake(labelForScore.center.x, labelForScore.center.y);
        scoreNumber.frame = CGRectMake(scoreNumber.frame.origin.x, labelForScore.frame.origin.y - scoreNumber.frame.size.height, scoreNumber.frame.size.width, scoreNumber.frame.size.height);
        
        
        scoreName.center = CGPointMake(labelForScore.center.x, labelForScore.center.y);
        scoreName.frame = CGRectMake(scoreName.frame.origin.x, labelForScore.frame.origin.y + labelForScore.frame.size.height +1, scoreName.frame.size.width, scoreName.frame.size.height);
    }
    
    lastLabelTapped = [[scoreBars objectAtIndex:0] objectForKey:@"publicCost"];
    
    AprilTestTabBarController *tabControl = (AprilTestTabBarController*)[self parentViewController];
    NSString *logEntry = [tabControl generateLogEntryWith:@"\tInvestment cost inspected"];
    [tabControl writeToLogFileString:logEntry];
    
}

#pragma mark Helper Functions

/*
 Method Description: Helper function called from notification to update profile and update Score Bars
 Inputs: None
 Outputs: None
 */
- (void)profileUpdateHelper {
    [self profileUpdate];
    [self drawScoreBarVisualizationHelper];
}

/*
 Method Description: Helper function called from notification to update username and update Score Bars
 Inputs: None
 Outputs: None
 */
- (void)usernameUpdateHelper:(NSNotification*)note {
    [self usernameUpdate:note];
    [self drawScoreBarVisualizationHelper];
}

/*
 Method Description: Helper function called from notification to update a single profile and update Score Bars
 Inputs: None
 Outputs: None
 */
- (void)updateSingleProfileHelper:(NSNotification*)note {
    [self updateSingleProfile:note];
    [self drawScoreBarVisualizationHelper];
}

/*
 Method Description: Helper function called from notification to draw a new profile and update Score Bars
 Inputs: None
 Outputs: None
 */
- (void)drawNewProfileHelper {
    [self drawNewProfile];
    [self drawScoreBarVisualizationHelper];
}

/*
 Method Description: Helper function called from notification to update Score Bars
 Inputs: None
 Outputs: None
 */
- (void)drawScoreBarVisualizationHelper {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    
    if (tabControl.trialNum == 0) return;
    
    if (tabControl.trialNum > trialChosen) {
        for (UIView *subview in [scoreBarView subviews]) {
            if(subview.tag != 9003)
                [subview removeFromSuperview];
        }
        for(int i = 0; i < tabControl.profiles.count; i++) {
            //if ( scoreBars.count > i && [[[scoreBars objectAtIndex:i] objectForKey:@"scoreBar"]isHidden] == NO)
            // [[[scoreBars objectAtIndex:i] objectForKey:@"scoreBar"] removeFromSuperview];
            
            [self drawScoreBarVisualizationWithProfileIndex:i andScoreIndex:i andTrial:trialChosen];
            if (scoreBars.count > i)
                [scoreBarView addSubview:[[scoreBars objectAtIndex:i] objectForKey:@"scoreBar"]];
        }
        
    }
    else if(tabControl.trialNum == trialChosen) {
        int scoreNum = 0;
        
        for (UIView *subview in [scoreBarView subviews]) {
            if(subview.tag != 9003)
                [subview removeFromSuperview];
        }
        for(int i = 0; i < tabControl.profiles.count; i++) {
            //if ( scoreBars.count > i && [[[scoreBars objectAtIndex:i] objectForKey:@"scoreBar"]isHidden] == NO)
            // [[[scoreBars objectAtIndex:i] objectForKey:@"scoreBar"] removeFromSuperview];
            
            // gotta find the favorite for this profile and get the trial number for that favorite
            int trial = -1;
            for (int j = 0; j < tabControl.favorites.count; j++) {
                if ([[[tabControl.favorites objectAtIndex:j] objectAtIndex:1] isEqualToString:[[tabControl.profiles objectAtIndex:i] objectAtIndex:1]])
                    trial = [[[tabControl.favorites objectAtIndex:j]objectAtIndex:2] integerValue];
            }
            
            if(trial != -1) {
                [self drawScoreBarVisualizationWithProfileIndex:i andScoreIndex:scoreNum andTrial:trial];
                if(scoreBars.count > i)
                    [scoreBarView addSubview:[[scoreBars objectAtIndex:scoreNum] objectForKey:@"scoreBar"]];
                scoreNum++;
            }
        }
        
        // draw maps in _mapWindow
        // loop through tabControl.favorites and see which maps we need to draw
        // loop through all the favorites and add any trial number not yet added to the "uniqueTrialNumbers" array
        for (UIView *subview in [bottomOfMapWindow subviews]) {
            [subview removeFromSuperview];
        }
        
        NSMutableArray *uniqueTrialNumbers = [[NSMutableArray alloc]init];
        
        for (NSArray *favorite in tabControl.favorites) {
            NSNumber *trialOfCurrentProfile = [favorite objectAtIndex:2];
            
            BOOL isARepeat = NO;
            for (NSNumber *trialNum in uniqueTrialNumbers) {
                if ([trialNum isEqualToNumber:trialOfCurrentProfile])
                    isARepeat = YES;
            }
            
            if (!isARepeat)
                [uniqueTrialNumbers addObject:trialOfCurrentProfile];
        }
        
        // sort uniqueTrialNumbers in ascending order
        for (int i = 0; i < uniqueTrialNumbers.count - 1 && uniqueTrialNumbers.count != 0; i++) {
            if ([[uniqueTrialNumbers objectAtIndex:i] integerValue] > [[uniqueTrialNumbers objectAtIndex:i+1] integerValue]) {
                int temp = [[uniqueTrialNumbers objectAtIndex:i] integerValue];
                [uniqueTrialNumbers replaceObjectAtIndex:i withObject:[uniqueTrialNumbers objectAtIndex:i+1]];
                [uniqueTrialNumbers replaceObjectAtIndex:i+1 withObject:[NSNumber numberWithInt:temp]];
            }
        }
        
        // load the maps for the trial numbers in uniqueTrialNumbers
        for (int i = 0; i < [uniqueTrialNumbers count]; i++) {
            int trialNum = [[uniqueTrialNumbers objectAtIndex:i] integerValue];
            
            UILabel *mapWindowLabel = [[UILabel alloc]init];
            mapWindowLabel.text = [NSString stringWithFormat:@"             Trial %d", trialNum + 1];
            mapWindowLabel.font = [UIFont systemFontOfSize:15.3];
            [mapWindowLabel sizeToFit];
            mapWindowLabel.frame = CGRectMake(200 * i, 2, mapWindowLabel.frame.size.width, mapWindowLabel.frame.size.height);
            [bottomOfMapWindow addSubview:mapWindowLabel];
            
            [bottomOfMapWindow setContentSize:CGSizeMake(mapWindowLabel.frame.origin.x + 250, bottomOfMapWindow.frame.size.height)];
            
            if (trialNum >= tabControl.trialNum) return;
            AprilTestSimRun *simRun = [tabControl.trialRuns objectAtIndex:trialNum];
            
            FebTestIntervention *interventionView = [[FebTestIntervention alloc] initWithPositionArray:simRun.map andFrame:(CGRectMake(20, mapWindowLabel.frame.size.height + 5, 115, 125))];
            interventionView.view = mapWindowLabel;
            [interventionView updateView];
        }
    }
    else if(tabControl.trialNum + 1 == trialChosen) {
        if(tabControl.trialNum == 0) return;
        
        int scoreNum = 0;
        
        for (UIView *subview in [scoreBarView subviews]) {
            if(subview.tag != 9003)
                [subview removeFromSuperview];
        }
        for(int i = 0; i < tabControl.profiles.count; i++) {
            
            // gotta find the favorite for this profile and get the trial number for that favorite
            int trial = -1;
            for (int j = 0; j < tabControl.leastFavorites.count; j++) {
                if ([[[tabControl.leastFavorites objectAtIndex:j] objectAtIndex:1] isEqualToString:[[tabControl.profiles objectAtIndex:i] objectAtIndex:1]])
                    trial = [[[tabControl.leastFavorites objectAtIndex:j]objectAtIndex:2] integerValue];
            }
            
            if(trial != -1) {
                [self drawScoreBarVisualizationWithProfileIndex:i andScoreIndex:scoreNum andTrial:trial];
                if(scoreBars.count > i)
                    [scoreBarView addSubview:[[scoreBars objectAtIndex:scoreNum] objectForKey:@"scoreBar"]];
                scoreNum++;
            }
        }
        
        // draw maps in _mapWindow
        // loop through tabControl.favorites and see which maps we need to draw
        // loop through all the favorites and add any trial number not yet added to the "uniqueTrialNumbers" array
        for (UIView *subview in [bottomOfMapWindow subviews]) {
            [subview removeFromSuperview];
        }
        
        NSMutableArray *uniqueTrialNumbers = [[NSMutableArray alloc]init];
        
        for (NSArray *leastFavorite in tabControl.leastFavorites) {
            NSNumber *trialOfCurrentProfile = [leastFavorite objectAtIndex:2];
            
            BOOL isARepeat = NO;
            for (NSNumber *trialNum in uniqueTrialNumbers) {
                if ([trialNum isEqualToNumber:trialOfCurrentProfile])
                    isARepeat = YES;
            }
            
            if (!isARepeat)
                [uniqueTrialNumbers addObject:trialOfCurrentProfile];
        }
        
        // sort uniqueTrialNumbers in ascending order
        for (int i = 0; i < uniqueTrialNumbers.count - 1 && uniqueTrialNumbers.count != 0; i++) {
            if ([[uniqueTrialNumbers objectAtIndex:i] integerValue] > [[uniqueTrialNumbers objectAtIndex:i+1] integerValue]) {
                int temp = [[uniqueTrialNumbers objectAtIndex:i] integerValue];
                [uniqueTrialNumbers replaceObjectAtIndex:i withObject:[uniqueTrialNumbers objectAtIndex:i+1]];
                [uniqueTrialNumbers replaceObjectAtIndex:i+1 withObject:[NSNumber numberWithInt:temp]];
            }
        }
        
        // load the maps for the trial numbers in uniqueTrialNumbers
        for (int i = 0; i < [uniqueTrialNumbers count]; i++) {
            int trialNum = [[uniqueTrialNumbers objectAtIndex:i] integerValue];
            
            UILabel *mapWindowLabel = [[UILabel alloc]init];
            mapWindowLabel.text = [NSString stringWithFormat:@"             Trial %d", trialNum + 1];
            mapWindowLabel.font = [UIFont systemFontOfSize:15.3];
            [mapWindowLabel sizeToFit];
            mapWindowLabel.frame = CGRectMake(200 * i, 2, mapWindowLabel.frame.size.width, mapWindowLabel.frame.size.height);
            [bottomOfMapWindow addSubview:mapWindowLabel];
            
            [bottomOfMapWindow setContentSize:CGSizeMake(mapWindowLabel.frame.origin.x + 250, bottomOfMapWindow.frame.size.height)];
            
            if (trialNum >= tabControl.trialNum) return;
            AprilTestSimRun *simRun = [tabControl.trialRuns objectAtIndex:trialNum];
            
            FebTestIntervention *interventionView = [[FebTestIntervention alloc] initWithPositionArray:simRun.map andFrame:(CGRectMake(20, mapWindowLabel.frame.size.height + 5, 115, 125))];
            interventionView.view = mapWindowLabel;
            [interventionView updateView];
        }
    }
    
    [scoreBarView setContentSize:CGSizeMake((scoreBars.count + 1) / 2 * 500, 540)];
    
    UIView *lineAcrossScoreBarView = [self.view viewWithTag:9003];
    lineAcrossScoreBarView.frame = CGRectMake(0, lineAcrossScoreBarView.frame.origin.y, scoreBarView.contentSize.width, 1);
}

#pragma mark CorePlot Visualization Functions

- (void)drawCorePlot {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    
    int i, j;
    
    // loop thru all profiles
    for(i = 0; i < tabControl.profiles.count; i++) {
        
        NSMutableArray *trialScores = [[NSMutableArray alloc]init];
        
        // get the component score for each profile
        for(j = 0; j < tabControl.trialRuns.count; j++) {
            
            AprilTestSimRun *simRun = [tabControl.trialRuns objectAtIndex:j];
            AprilTestNormalizedVariable *simRunNormal = [tabControl.trialRunsNormalized objectAtIndex:j];
            
            
            NSArray *currentProfile = [[NSArray alloc]init];
            currentProfile = [tabControl.profiles objectAtIndex:i];
            
            NSMutableArray *currentConcernRanking = [[NSMutableArray alloc]init];
            
            // get the concernRanking for the currentProfile
            for (int j = 3; j < [currentProfile count]; j++) {
                [currentConcernRanking addObject:[[AprilTestVariable alloc] initWith:[concernNames objectForKey:[currentProfile objectAtIndex:j]] withDisplayName:[currentProfile objectAtIndex: j] withNumVar:1 withWidth:widthOfTitleVisualization withRank:10-j]];
            }
            
            float priorityTotal= 0;
            float scoreTotal = 0;
            for(int j = 0; j < currentConcernRanking.count; j++){
                
                priorityTotal += [(AprilTestVariable *)[currentConcernRanking objectAtIndex:j] currentConcernRanking];
            }
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [formatter setGroupingSeparator:@","];
            
            NSArray *sortedArray = [currentConcernRanking sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSInteger first = [(AprilTestVariable*)a currentConcernRanking];
                NSInteger second = [(AprilTestVariable*)b currentConcernRanking];
                if(first > second) return NSOrderedAscending;
                else return NSOrderedDescending;
            }];
            NSMutableArray *scoreVisVals = [[NSMutableArray alloc] init];
            NSMutableArray *scoreVisNames = [[NSMutableArray alloc] init];
            
            for(int j = 0 ; j < currentConcernRanking.count ; j++){
                
                AprilTestVariable * currentVar =[sortedArray objectAtIndex:j];
                
                //laziness: this is just the investment costs
                if([currentVar.name compare: @"publicCost"] == NSOrderedSame){
                    float investmentInstallN = simRunNormal.publicInstallCost;
                    float investmentMaintainN = simRunNormal.publicMaintenanceCost;
                    
                    scoreTotal += (currentVar.currentConcernRanking/priorityTotal * (1 - investmentInstallN));
                    //scoreTotal += ((currentVar.currentConcernRanking/2.0)/priorityTotal * (1 - investmentMaintainN));
                    //scoreTotal += ((currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRun.impactNeighbors));
                    
                    [scoreVisVals addObject:[NSNumber numberWithFloat:((currentVar.currentConcernRanking)/priorityTotal * (1 - investmentInstallN))]];
                    //[scoreVisVals addObject:[NSNumber numberWithFloat:((currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRun.impactNeighbors))]];
                    [scoreVisNames addObject: @"publicCost"];
                    //[scoreVisNames addObject: @"publicCostD"];
                    
                    
                    //just damages now
                } else if ([currentVar.name compare: @"privateCost"] == NSOrderedSame){
                    
                    scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.privateDamages);
                    
                    //add values for the score visualization
                    
                    [scoreVisVals addObject:[NSNumber numberWithFloat:(currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.privateDamages))]];
                    //scoreTotal +=currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.privateDamages);
                    //[scoreVisVals addObject: [NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.privateDamages)]];
                    [scoreVisNames addObject: @"privateCostD"];
                    
                } else if ([currentVar.name compare: @"impactingMyNeighbors"] == NSOrderedSame){
                    
                    scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.impactNeighbors);
                    [scoreVisVals addObject:[NSNumber numberWithFloat: currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.impactNeighbors)]];
                    [scoreVisNames addObject: currentVar.name];
                    
                } else if ([currentVar.name compare: @"groundwaterInfiltration"] == NSOrderedSame){
                    
                    
                    scoreTotal += (currentVar.currentConcernRanking/priorityTotal) * (simRunNormal.infiltration );
                    [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * ( simRunNormal.infiltration )]];
                    [scoreVisNames addObject: currentVar.name];
                } else if([currentVar.name compare:@"puddleTime"] == NSOrderedSame){
                    
                    
                    scoreTotal += (currentVar.currentConcernRanking + 1)/priorityTotal * (1 - simRunNormal.standingWater);
                    [scoreVisVals addObject:[NSNumber numberWithFloat:(currentVar.currentConcernRanking + 1)/priorityTotal * (1- simRunNormal.standingWater)]];
                    [scoreVisNames addObject: currentVar.name];
                    
                } else if([currentVar.name compare:@"puddleMax"] == NSOrderedSame){
                    
                    scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.floodedStreets);
                    [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1- simRunNormal.floodedStreets)]];
                    [scoreVisNames addObject: currentVar.name];
                } else if ([currentVar.name compare: @"capacity"] == NSOrderedSame){
                    
                    scoreTotal += currentVar.currentConcernRanking/priorityTotal *  (1- simRunNormal.efficiency);
                    [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal *  (1-simRunNormal.efficiency)]];
                    //NSLog(@"%@", NSStringFromCGRect(ev.frame));
                    [scoreVisNames addObject: currentVar.name];
                    
                } else if ([currentVar.name compare: @"efficiencyOfIntervention"] == NSOrderedSame){
                    scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1 - simRun.dollarsGallons/25.19);
                    [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1 - simRun.dollarsGallons/25.19)]];
                    [scoreVisNames addObject:currentVar.name];
                }
            }
            
            [trialScores addObject:[NSNumber numberWithFloat:scoreTotal]];
        }
        // draw line for this profiles scores
        
        float scores[trialScores.count];
        
        for (int k = 0; k < trialScores.count; k++) {
            scores[k] = [[trialScores objectAtIndex:k]floatValue];
        }
        

        
    }
}

#pragma mark Score Bar Visualization Functions

/*
 Method Description: Draws score bars in Score Bar Visualization
 Inputs: profileIndex - index of profile within tabControl.profiles, scoreIndex - index of score bar within scoreBars NSMutableArray, trialNum - trial number to be loaded for score bar
 Outputs: None
 */
- (void)drawScoreBarVisualizationWithProfileIndex:(int)profileIndex andScoreIndex:(int)scoreIndex andTrial:(int)trialNum{
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    
    if ([tabControl.trialRuns count] <= trialNum)
        return;
    
    //find how many score bars will be needed
    //int numberOfScoreBarsToDraw = [tabControl.profiles count];
    
    // create any new scorebar views that are needed
    // add any new line dividers needed
    if (scoreIndex >= [scoreBars count]) {
        UIView  *newScoreBarView =  [[UIView alloc]initWithFrame:CGRectMake((scoreIndex/2) * 500, (scoreIndex % 2) * 270, 500, 270)];
        UILabel *fullValueBorder =  [[UILabel alloc] initWithFrame:CGRectMake(256, 60,  228, 52)];
        UILabel *fullValue =        [[UILabel alloc] initWithFrame:CGRectMake(258, 62,  224, 48)];
        UILabel *profileName =      [[UILabel alloc]initWithFrame:CGRectMake(256, 160, 228, 20)];
        UILabel *trialNumber =      [[UILabel alloc]initWithFrame:CGRectMake(256, 190, 228, 20)];
        UILabel *impact =           [[UILabel alloc]init];
        UILabel *groundwater =      [[UILabel alloc]init];
        UILabel *maxFlood =         [[UILabel alloc]init];
        UILabel *waterDepth =       [[UILabel alloc]init];
        UILabel *interventionCap =  [[UILabel alloc]init];
        UILabel *efficiency =       [[UILabel alloc]init];
        UILabel *damageReduc =      [[UILabel alloc]init];
        UILabel *investment =       [[UILabel alloc]init];
        UILabel *scoreName =        [[UILabel alloc]init];
        UILabel *scoreNumber =      [[UILabel alloc]init];
        
        scoreName.font = [UIFont systemFontOfSize:14.0];
        scoreNumber.font = [UIFont systemFontOfSize:14.0];
        
        [scoreName setTextAlignment:NSTextAlignmentCenter];
        [scoreNumber setTextAlignment:NSTextAlignmentCenter];
        
        impact.userInteractionEnabled = YES;
        groundwater.userInteractionEnabled = YES;
        maxFlood.userInteractionEnabled = YES;
        waterDepth.userInteractionEnabled = YES;
        interventionCap.userInteractionEnabled = YES;
        efficiency.userInteractionEnabled = YES;
        damageReduc.userInteractionEnabled = YES;
        investment.userInteractionEnabled = YES;
        
        
        UITapGestureRecognizer *impactRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(impactTapped)];
        impactRecognizer.numberOfTapsRequired = 1;
        UITapGestureRecognizer *groundwaterRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(groundwaterTapped)];
        groundwaterRecognizer.numberOfTapsRequired = 1;
        UITapGestureRecognizer *maxFloodRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maxFloodTapped)];
        maxFloodRecognizer.numberOfTapsRequired = 1;
        UITapGestureRecognizer *waterDepthRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(waterDepthTapped)];
        waterDepthRecognizer.numberOfTapsRequired = 1;
        UITapGestureRecognizer *interventionCapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(interventionCapTapped)];
        interventionCapRecognizer.numberOfTapsRequired = 1;
        UITapGestureRecognizer *efficiencyRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(efficiencyTapped)];
        efficiencyRecognizer.numberOfTapsRequired = 1;
        UITapGestureRecognizer *damageReducRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(damageReducTapped)];
        damageReducRecognizer.numberOfTapsRequired = 1;
        UITapGestureRecognizer *investmentRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(investmentTapped)];
        investmentRecognizer.numberOfTapsRequired = 1;
        
        
        [impact addGestureRecognizer:impactRecognizer];
        [groundwater addGestureRecognizer:groundwaterRecognizer];
        [maxFlood addGestureRecognizer:maxFloodRecognizer];
        [waterDepth addGestureRecognizer:waterDepthRecognizer];
        [interventionCap addGestureRecognizer:interventionCapRecognizer];
        [efficiency addGestureRecognizer:efficiencyRecognizer];
        [damageReduc addGestureRecognizer:damageReducRecognizer];
        [investment addGestureRecognizer:investmentRecognizer];
        
        
        NSMutableDictionary *scoreBar = [[NSMutableDictionary alloc]initWithObjects:[NSArray arrayWithObjects:newScoreBarView, fullValueBorder, fullValue, profileName, trialNumber, impact, groundwater, maxFlood, waterDepth, interventionCap, efficiency, damageReduc, investment, scoreName, scoreNumber, nil] forKeys:[NSArray arrayWithObjects:@"scoreBar", @"valueBorder", @"value", @"profileName", @"trialNumber", @"impactingMyNeighbors", @"groundwaterInfiltration", @"puddleMax", @"puddleTime", @"capacity", @"efficiencyOfIntervention", @"privateCostD", @"publicCost", @"scoreName", @"scoreNumber", nil]];
        
        [scoreBars addObject:scoreBar];
        
        [scoreBarView addSubview:newScoreBarView];
        
        fullValueBorder.backgroundColor = [UIColor grayColor];
        [newScoreBarView addSubview:fullValueBorder];
        
        fullValue.backgroundColor = [UIColor whiteColor];
        [newScoreBarView addSubview:fullValue];
        
        [newScoreBarView addSubview:profileName];
        [newScoreBarView addSubview:trialNumber];
        [newScoreBarView addSubview:impact];
        [newScoreBarView addSubview:groundwater];
        [newScoreBarView addSubview:maxFlood];
        [newScoreBarView addSubview:waterDepth];
        [newScoreBarView addSubview:interventionCap];
        [newScoreBarView addSubview:efficiency];
        [newScoreBarView addSubview:damageReduc];
        [newScoreBarView addSubview:investment];
        [newScoreBarView addSubview:scoreName];
        [newScoreBarView addSubview:scoreNumber];
        
    }
    
    // draw the dividers between each scoreBarView
    if (scoreIndex % 2 == 0) {
        UIView *verticalLine = [[UIView alloc]init];
        verticalLine.frame = CGRectMake(scoreIndex / 2 * 500 + 500, -1000, 1, scoreBarView.frame.size.height + 2000);
        verticalLine.layer.borderColor = [UIColor lightGrayColor].CGColor;
        verticalLine.layer.borderWidth = 1.0;
        verticalLine.tag = 9004;
        [scoreBarView addSubview:verticalLine];
    }
    
    
    NSMutableDictionary *scoreBarDict = [scoreBars objectAtIndex:scoreIndex];
    UILabel *profileName = (UILabel*)[scoreBarDict objectForKey:@"profileName"];
    UILabel *trialNumber = (UILabel*)[scoreBarDict objectForKey:@"trialNumber"];
    
    if ([[[tabControl.profiles objectAtIndex:profileIndex] objectAtIndex:1] isEqualToString:[[UIDevice currentDevice]name]]) {
        profileName.text = [NSString stringWithFormat:@"User: %@ - (You)",[[tabControl.profiles objectAtIndex:profileIndex] objectAtIndex:2]];
    }
    else
        profileName.text = [NSString stringWithFormat:@"User: %@",[[tabControl.profiles objectAtIndex:profileIndex] objectAtIndex:2]];
    [profileName setTextAlignment:NSTextAlignmentCenter];
    profileName.font = [UIFont systemFontOfSize:14.0];
    trialNumber.text = [arrStatus_social objectAtIndex:trialNum];
    [trialNumber setTextAlignment:NSTextAlignmentCenter];
    trialNumber.font = [UIFont systemFontOfSize:14.0];
    
    // empty the text for all scoreBars scoreNumber and scoreName
    UILabel *scoreNumber = (UILabel*)[scoreBarDict objectForKey:@"scoreNumber"];
    UILabel *scoreName = (UILabel*)[scoreBarDict objectForKey:@"scoreName"];
    
    scoreNumber.text = @"";
    scoreName.text = @"";
    
    //draw pie chart
    if (tabControl.pieCharts.count > profileIndex) {
        [tabControl reloadDataForPieChartAtIndex:profileIndex];
        [[tabControl.pieChartsForScoreBarView objectAtIndex:profileIndex] reloadData];
        [[[scoreBars objectAtIndex:scoreIndex] objectForKey:@"scoreBar"] addSubview:[tabControl.pieChartsForScoreBarView objectAtIndex:profileIndex]];
        
    }
    
    NSMutableArray* scores = [tabControl getScoreBarValuesForProfile:profileIndex forTrial:trialNum isDynamicTrial:0];
    NSMutableArray* scoreVisVals = [scores objectAtIndex:0];
    NSMutableArray* scoreVisNames = [scores objectAtIndex:1];
    
    //NSLog(@" %@", scoreVisVals);
    float x = 0;
    float totalScore = 0;
    UILabel * componentScore;
    UILabel * scoreBar = [[scoreBars objectAtIndex:0] objectForKey:@"value"];
    
    //computing and drawing the final component score
    for(int j =  0; j < scoreVisVals.count; j++){
        componentScore = [[scoreBars objectAtIndex:scoreIndex] objectForKey:[scoreVisNames objectAtIndex:j]];
        
        float scoreWidth = [[scoreVisVals objectAtIndex: j] floatValue] * 100 * 2;
        if (scoreWidth < 0) scoreWidth = 0.0;
        totalScore += scoreWidth;
        componentScore.frame = CGRectMake(scoreBar.frame.origin.x + x, scoreBar.frame.origin.y, floor(scoreWidth), 48);
        componentScore.backgroundColor = [scoreColors objectForKey:[scoreVisNames objectAtIndex:j]];
        x+=floor(scoreWidth);
    }
}


#pragma mark Username Update Functions

/*
 Method Description: Update username, called from a notification from AprilTestTabController
 Inputs: note - contains index of profile to have username updated
 Outputs: None
 */
- (void)usernameUpdate:(NSNotification *)note {
    // do nothing if favorites are currently loaded
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    if (tabControl.trialNum == trialChosen)
        return;
    
    NSDictionary *dict  = note.userInfo;
    int index = [[dict objectForKey:@"data"]integerValue];
    
    if ([tabControl.profiles count] <= index)
        return;
    
    UIView *viewInUsernamesWindow = [_usernamesWindow viewWithTag:index + 1];
    UILabel *nameLabel = (UILabel*) [viewInUsernamesWindow viewWithTag:1];
    nameLabel.text = [NSString stringWithFormat:@"  %@",[[tabControl.profiles objectAtIndex:index]objectAtIndex:2]];
}

#pragma mark Profile Update Functions

/*
 Method Description: Draws profiles in _profilesWindow and _usernamesWindow depending on which trial is selected
 Inputs: None
 Outputs: None
 */
- (void)profileUpdate {
    // check to see if we should load the favorites
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    if (tabControl.trialNum == trialChosen) {
        if (tabControl.trialNum > 0) {
            [_loadingIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];
            [self loadFavorites];
            [_loadingIndicator stopAnimating];        }
        return;
    }
    else if(tabControl.trialNum + 1 == trialChosen) {
        if (tabControl.trialNum > 0) {
            [_loadingIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];
            [self loadLeastFavorites];
            [_loadingIndicator stopAnimating];
        }
        return;
    }
    
    if (tabControl.trialNum == 0)
        return;
    
    [_loadingIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];
    [self loadVisualizationForNewTrial];
    [_loadingIndicator stopAnimating];
    
    _trialPickerTextField.text = arrStatus_social[trialChosen];
    
    
    NSLog(@"Updated profile in Social View");
}

/*
 Method Description: Called from notification in AprilTestTabBarController if another user updated which trial is their favorite or least favorite
 Inputs: note - contains index of profile to update within tabControl.profiles
 Outputs: None
 */
- (void)updateFavoriteOrLeastFavoriteChosenForProfile:(NSNotification *)note {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    if (tabControl.trialNum == trialChosen) {
        [self updateSingleProfileForFavorites:(NSNotification *)note];
        // draw score bars and reloads maps in _mapWindow
        [self drawScoreBarVisualizationHelper];
        return;
    }
    else if (tabControl.trialNum + 1 ==trialChosen) {
        [self updateSingleProfileForLeastFavorites:(NSNotification *)note];
        // draw score bars and reloads maps in _mapWindow
        [self drawScoreBarVisualizationHelper];
        return;
    }
}

/*
 Method Description: Called from notification in AprilTestTabBarController if another user updated their concern rankings.
 Inputs: note - contains index of profile to update within tabControl.profiles
 Outputs: None
 */
- (void)updateSingleProfile:(NSNotification *)note {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    if (tabControl.trialNum == trialChosen) {
        [self updateSingleProfileForFavorites:(NSNotification *)note];
        return;
    }
    else if (tabControl.trialNum + 1 ==trialChosen) {
        [self updateSingleProfileForLeastFavorites:(NSNotification *)note];
        return;
    }
    
    NSDictionary *dict = note.userInfo;
    int index = [[dict objectForKey:@"data"]integerValue];
    
    if([tabControl.profiles count] <= index)
        return;
    
    
    UIView *viewInProfilesWindow = [_profilesWindow viewWithTag:index + 1];
    [viewInProfilesWindow removeFromSuperview];
    UIView *viewInUsernamesWindow = [_usernamesWindow viewWithTag:index + 1];
    [viewInUsernamesWindow removeFromSuperview];
    
    [self createSubviewsForUsernamesWindow:index];
    [self createSubviewsForProfilesWindow:index];
    [self drawTrialForSpecificTrial:trialChosen forProfile:index withViewIndex:index];
}

/*
 Method Description: Called when a profile update is needed (another user changed their least favorite trial or changed their concern rankings)
 Inputs: note - contains index of profile to update within tabControl.profiles
 Outputs: None
 */
- (void)updateSingleProfileForLeastFavorites:(NSNotification *)note {
    // within the note is the index of the profile within tabControl.profiles
    // get the device name for that profile and find its index in tabControl.leastFavorites
    
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    
    NSDictionary *dict = note.userInfo;
    int index = [[dict objectForKey:@"data"]integerValue];
    NSArray *profile = [tabControl.profiles objectAtIndex:index];
    
    int indexOfLeastFavorite = -1;
    int trialNum = -1;
    
    for (int i = 0; i < tabControl.leastFavorites.count; i++) {
        if([[profile objectAtIndex:1] isEqualToString:[[tabControl.leastFavorites objectAtIndex:i]objectAtIndex:1]]) {
            indexOfLeastFavorite = i;
            trialNum = [[[tabControl.leastFavorites objectAtIndex:i] objectAtIndex:2]integerValue];
        }
    }
    
    if (indexOfLeastFavorite == -1)
        return;
    
    [[_usernamesWindow viewWithTag:indexOfLeastFavorite + 1] removeFromSuperview];
    [[_profilesWindow viewWithTag:indexOfLeastFavorite + 1] removeFromSuperview];
    
    // draw views in _usernamesWindow
    // tag for each view is 1+(index of device name in tabControl.leastFavorites)
    UIView *usernameSubview = [[UIView alloc]init];
    usernameSubview.frame = CGRectMake(0, indexOfLeastFavorite * heightOfVisualization, _usernamesWindow.frame.size.width, heightOfVisualization);
    // tag == i + 1 since 0 tag goes to the superview
    usernameSubview.tag = indexOfLeastFavorite + 1;
    [_usernamesWindow addSubview:usernameSubview];
    
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.tag = 1;
    nameLabel.backgroundColor = [UIColor whiteColor];
    nameLabel.frame = CGRectMake(0, 2, widthOfUsernamesWindowWhenOpen, 40);
    nameLabel.font = [UIFont boldSystemFontOfSize:15.3];
    if ([profile isEqual:tabControl.ownProfile]) {
        nameLabel.text = [NSString stringWithFormat:@"  %@ (You) - Trial %d", [profile objectAtIndex:2], (int)[[[tabControl.leastFavorites objectAtIndex:indexOfLeastFavorite] objectAtIndex:2] integerValue] + 1];
    }
    else {
        nameLabel.text = [NSString stringWithFormat:@"  %@ - Trial %d", [profile objectAtIndex:2], (int)[[[tabControl.leastFavorites objectAtIndex:indexOfLeastFavorite] objectAtIndex:2] integerValue] + 1];
    }
    if(nameLabel != NULL) {
        [[_usernamesWindow viewWithTag:indexOfLeastFavorite + 1] addSubview:nameLabel];
    }
    
    
    [tabControl reloadDataForPieChartAtIndex:index];
    [[tabControl.pieCharts objectAtIndex:index] reloadData];
    [[_usernamesWindow viewWithTag:indexOfLeastFavorite + 1] addSubview:[tabControl.pieCharts objectAtIndex:index]];
    
    UIView *profileSubview = [[UIView alloc]init];
    profileSubview.frame = CGRectMake(0, indexOfLeastFavorite * heightOfVisualization, widthOfTitleVisualization * 8, heightOfVisualization);
    // tag == i + 1 since 0 tag goes to the superview
    profileSubview.tag = indexOfLeastFavorite + 1;
    [_profilesWindow addSubview:profileSubview];
    
    
    // draw profile concerns in order
    int width = 0;
    for (int j = 3; j < profile.count; j++) {
        
        UILabel *currentLabel = [[UILabel alloc]init];
        currentLabel.backgroundColor = [concernColors objectForKey:[profile objectAtIndex:j]];
        currentLabel.frame = CGRectMake(width, 0, widthOfTitleVisualization, 40);
        currentLabel.font = [UIFont boldSystemFontOfSize:15.3];
        
        if([[profile objectAtIndex:j] isEqualToString:@"Investment"]) {
            currentLabel.text = @"  Investment";
        }
        else if([[profile objectAtIndex:j] isEqualToString:@"Damage Reduction"]) {
            currentLabel.text = @"  Damage Reduction";
        }
        else if([[profile objectAtIndex:j] isEqualToString:@"Efficiency of Intervention ($/Gallon)"]) {
            currentLabel.text = @"  Efficiency of Intervention";
        }
        else if([[profile objectAtIndex:j] isEqualToString:@"Capacity Used"]) {
            currentLabel.text = @"  Intervention Capacity";
        }
        else if([[profile objectAtIndex:j] isEqualToString:@"Water Flow Path"]) {
            currentLabel.text = @"  Water Flow";
        }
        else if([[profile objectAtIndex:j] isEqualToString:@"Maximum Flooded Area"]) {
            currentLabel.text = @"  Maximum Flooded Area";
        }
        else if([[profile objectAtIndex:j] isEqualToString:@"Groundwater Infiltration"]) {
            currentLabel.text = @"  Groundwater Infiltration";
        }
        else if([[profile objectAtIndex:j] isEqualToString:@"Impact on my Neighbors"]) {
            currentLabel.text = @"  Impact on my Neighbors";
        }
        else {
            currentLabel = NULL;
        }
        
        if(currentLabel != NULL){
            [profileSubview addSubview:currentLabel];
            width += widthOfTitleVisualization;
        }
    }
    
    [self drawTrialForSpecificTrial:trialNum forProfile:index withViewIndex:indexOfLeastFavorite];
}

/*
 Method Description: Called when a profile update is needed (another user changed their favorite trial or changed their concern rankings)
 Inputs: note - contains index of profile to update within tabControl.profiles
 Outputs: None
 */
- (void)updateSingleProfileForFavorites:(NSNotification *)note {
    // within the note is the index of the profile within tabControl.profiles
    // get the device name for that profile and find its index in tabControl.favorites
    
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    
    NSDictionary *dict = note.userInfo;
    int index = [[dict objectForKey:@"data"]integerValue];
    NSArray *profile = [tabControl.profiles objectAtIndex:index];
    
    int indexOfFavorite = -1;
    int trialNum = -1;
    
    for (int i = 0; i < tabControl.favorites.count; i++) {
        if([[profile objectAtIndex:1] isEqualToString:[[tabControl.favorites objectAtIndex:i]objectAtIndex:1]]) {
            indexOfFavorite = i;
            trialNum = [[[tabControl.favorites objectAtIndex:i] objectAtIndex:2]integerValue];
        }
    }
    
    if (indexOfFavorite == -1)
        return;
    
    [[_usernamesWindow viewWithTag:indexOfFavorite + 1] removeFromSuperview];
    [[_profilesWindow viewWithTag:indexOfFavorite + 1] removeFromSuperview];
    
    // draw views in _usernamesWindow
    // tag for each view is 1+(index of device name in tabControl.favorites)
    UIView *usernameSubview = [[UIView alloc]init];
    usernameSubview.frame = CGRectMake(0, indexOfFavorite * heightOfVisualization, _usernamesWindow.frame.size.width, heightOfVisualization);
    // tag == i + 1 since 0 tag goes to the superview
    usernameSubview.tag = indexOfFavorite + 1;
    [_usernamesWindow addSubview:usernameSubview];
    
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.tag = 1;
    nameLabel.backgroundColor = [UIColor whiteColor];
    nameLabel.frame = CGRectMake(0, 2, widthOfUsernamesWindowWhenOpen, 40);
    nameLabel.font = [UIFont boldSystemFontOfSize:15.3];
    if ([profile isEqual:tabControl.ownProfile]) {
        nameLabel.text = [NSString stringWithFormat:@"  %@ (You) - Trial %d", [profile objectAtIndex:2], (int)[[[tabControl.favorites objectAtIndex:indexOfFavorite] objectAtIndex:2] integerValue] + 1];
    }
    else {
        nameLabel.text = [NSString stringWithFormat:@"  %@ - Trial %d", [profile objectAtIndex:2], (int)[[[tabControl.favorites objectAtIndex:indexOfFavorite] objectAtIndex:2] integerValue] + 1];
    }
    if(nameLabel != NULL) {
        [[_usernamesWindow viewWithTag:indexOfFavorite + 1] addSubview:nameLabel];
    }
    
    
    [tabControl reloadDataForPieChartAtIndex:index];
    [[tabControl.pieCharts objectAtIndex:index] reloadData];
    [[_usernamesWindow viewWithTag:indexOfFavorite + 1] addSubview:[tabControl.pieCharts objectAtIndex:index]];
    
    UIView *profileSubview = [[UIView alloc]init];
    profileSubview.frame = CGRectMake(0, indexOfFavorite * heightOfVisualization, widthOfTitleVisualization * 8, heightOfVisualization);
    // tag == i + 1 since 0 tag goes to the superview
    profileSubview.tag = indexOfFavorite + 1;
    [_profilesWindow addSubview:profileSubview];
    
    
    // draw profile concerns in order
    int width = 0;
    for (int j = 3; j < profile.count; j++) {
        
        UILabel *currentLabel = [[UILabel alloc]init];
        currentLabel.backgroundColor = [concernColors objectForKey:[profile objectAtIndex:j]];
        currentLabel.frame = CGRectMake(width, 0, widthOfTitleVisualization, 40);
        currentLabel.font = [UIFont boldSystemFontOfSize:15.3];
        
        if([[profile objectAtIndex:j] isEqualToString:@"Investment"]) {
            currentLabel.text = @"  Investment";
        }
        else if([[profile objectAtIndex:j] isEqualToString:@"Damage Reduction"]) {
            currentLabel.text = @"  Damage Reduction";
        }
        else if([[profile objectAtIndex:j] isEqualToString:@"Efficiency of Intervention ($/Gallon)"]) {
            currentLabel.text = @"  Efficiency of Intervention";
        }
        else if([[profile objectAtIndex:j] isEqualToString:@"Capacity Used"]) {
            currentLabel.text = @"  Intervention Capacity";
        }
        else if([[profile objectAtIndex:j] isEqualToString:@"Water Flow Path"]) {
            currentLabel.text = @"  Water Flow";
        }
        else if([[profile objectAtIndex:j] isEqualToString:@"Maximum Flooded Area"]) {
            currentLabel.text = @"  Maximum Flooded Area";
        }
        else if([[profile objectAtIndex:j] isEqualToString:@"Groundwater Infiltration"]) {
            currentLabel.text = @"  Groundwater Infiltration";
        }
        else if([[profile objectAtIndex:j] isEqualToString:@"Impact on my Neighbors"]) {
            currentLabel.text = @"  Impact on my Neighbors";
        }
        else {
            currentLabel = NULL;
        }
        
        if(currentLabel != NULL){
            [profileSubview addSubview:currentLabel];
            width += widthOfTitleVisualization;
        }
    }
    
    [self drawTrialForSpecificTrial:trialNum forProfile:index withViewIndex:indexOfFavorite];
    
}

/*
 Method Description: If a new user connects to Momma, draw their profile in _usernamesWindow and _profilesWindow
 Inputs: None
 Outputs: None
 */
- (void)drawNewProfile {
    // do nothing if favorites are currently loaded
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    if (tabControl.trialNum == trialChosen || tabControl.trialNum + 1 == trialChosen)
        return;
    
    int index = [tabControl.profiles count] - 1;
    
    [self createSubviewsForUsernamesWindow:index];
    [self createSubviewsForProfilesWindow:index];
    [self drawTrialForSpecificTrial:trialChosen forProfile:index withViewIndex:index];
}

#pragma mark UI Picker Functions

/*
 Method Description: Updates picker rows whenever a new trial is loaded
 Inputs: None
 Outputs: None
 */
- (void)updatePicker {
    [self pickerView:SortType_social numberOfRowsInComponent:0];
    
    [arrStatus_social removeAllObjects];
    
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    for (int i = 0; i < tabControl.trialNum; i++) {
        [arrStatus_social addObject:[NSString stringWithFormat:@"Trial %d", i + 1]];
    }
    
    [arrStatus_social addObject:@"Favorite Trials"];
    [arrStatus_social addObject:@"Least Favorite Trials"];
    
    [SortType_social reloadAllComponents];
}

/*
 Method Description: Called when user selects a row in UIPicker
 Inputs: pickerView - the UIPickerView which the user selected a row in, row - index of the row selected, component - index of the component in which the row was selected
 Outputs: None
 */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // if the chosen trial is already loaded, return
    //if (trialChosen == row) {
    //   [SortType_social removeFromSuperview];
    //   return;
    //}
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    trialChosen = (int)row;
    
    //Log inspected trial
    NSString *logEntry = [tabControl generateLogEntryWith:[NSString stringWithFormat:@"\t%@ Chosen For Inspection (Social View)", arrStatus_social[row]]];
    [tabControl writeToLogFileString:logEntry];
    
    // Handle the selection
    if (row == tabControl.trialNum && tabControl.trialNum != 0) {
        _trialPickerTextField.text = @"Favorite Trials";
        if (tabControl.trialNum > 0) {
            [_loadingIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];
            [self loadFavorites];
            [self drawScoreBarVisualizationHelper];
            [_loadingIndicator stopAnimating];
        }
        [SortType_social removeFromSuperview];
        return;
    }
    else if(row == tabControl.trialNum + 1 && tabControl.trialNum != 0) {
        _trialPickerTextField.text = @"Least Favorite Trials";
        if (tabControl.trialNum > 0) {
            [_loadingIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];
            [self loadLeastFavorites];
            [self drawScoreBarVisualizationHelper];
            [_loadingIndicator stopAnimating];
        }
        [SortType_social removeFromSuperview];
        return;
    }
    else if(tabControl.trialNum != 0) {
        _trialPickerTextField.text = [NSString stringWithFormat:@"Trial %d", (int)row + 1];
    }
    else {
        _trialPickerTextField.text = @"No Trials Loaded";
    }
    
    [SortType_social removeFromSuperview];
    
    
    [self profileUpdate];
    [self drawScoreBarVisualizationHelper];
    
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [arrStatus_social count];
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

/*
 Method Description: Sets up the rows for a UIPickerView
 Inputs: pickerView - UIPickerView* to be set up, row - index of row to be set up, component - index of component to be set up, view - view to reuse
 Outputs: UIView*
 */
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        tView.frame = CGRectMake(0, 0, 250, 30);
        tView.font = [UIFont boldSystemFontOfSize:15.0];
        
    }
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    if (row == tabControl.trialNum && tabControl.trialNum != 0)
        tView.text = @"Favorite Trials";
    else if(row == tabControl.trialNum + 1 && tabControl.trialNum != 0)
        tView.text = @"Least Favorite Trials";
    else if (row != tabControl.trialNum && tabControl.trialNum != 0)
        tView.text = [NSString stringWithFormat:@"Trial %d", (int)row + 1];
    else
        tView.text = @"";
    // Fill the label text here
    
    return tView;
}


#pragma mark UI View Creation Functions

/*
 Method Description: Creates a subview which will hold all the profile information for a specific user
 Inputs: i - index of profile within tabControl.profiles
 Outputs: None
 */
- (void)createSubviewsForProfilesWindow:(int) i {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    UIView *profileSubview = [[UIView alloc]init];
    profileSubview.frame = CGRectMake(0, i * heightOfVisualization, widthOfTitleVisualization * 8, heightOfVisualization);
    // tag == i + 1 since 0 tag goes to the superview
    profileSubview.tag = i + 1;
    [_profilesWindow addSubview:profileSubview];
    
    
    // draw profile concerns in order
    int width = 0;
    for (int j = 3; j < [[tabControl.profiles objectAtIndex:i] count]; j++) {
        NSArray *profileArray = [tabControl.profiles objectAtIndex:i];
        
        UILabel *currentLabel = [[UILabel alloc]init];
        currentLabel.backgroundColor = [concernColors objectForKey:[profileArray objectAtIndex:j]];
        currentLabel.frame = CGRectMake(width, 0, widthOfTitleVisualization, 40);
        currentLabel.font = [UIFont boldSystemFontOfSize:15.3];
        
        if([[profileArray objectAtIndex:j] isEqualToString:@"Investment"]) {
            currentLabel.text = @"  Investment";
        }
        else if([[profileArray objectAtIndex:j] isEqualToString:@"Damage Reduction"]) {
            currentLabel.text = @"  Damage Reduction";
        }
        else if([[profileArray objectAtIndex:j] isEqualToString:@"Efficiency of Intervention ($/Gallon)"]) {
            currentLabel.text = @"  Efficiency of Intervention";
        }
        else if([[profileArray objectAtIndex:j] isEqualToString:@"Capacity Used"]) {
            currentLabel.text = @"  Intervention Capacity";
        }
        else if([[profileArray objectAtIndex:j] isEqualToString:@"Water Flow Path"]) {
            currentLabel.text = @"  Water Flow";
        }
        else if([[profileArray objectAtIndex:j] isEqualToString:@"Maximum Flooded Area"]) {
            currentLabel.text = @"  Maximum Flooded Area";
        }
        else if([[profileArray objectAtIndex:j] isEqualToString:@"Groundwater Infiltration"]) {
            currentLabel.text = @"  Groundwater Infiltration";
        }
        else if([[profileArray objectAtIndex:j] isEqualToString:@"Impact on my Neighbors"]) {
            currentLabel.text = @"  Impact on my Neighbors";
        }
        else {
            currentLabel = NULL;
        }
        
        if(currentLabel != NULL){
            [profileSubview addSubview:currentLabel];
            width += widthOfTitleVisualization;
        }
    }
}

/*
 Method Description: Creates a subview which will hold all the username information for a specific user
 Inputs: i - index of profile within tabControl.profiles
 Outputs: None
 */
- (void)createSubviewsForUsernamesWindow:(int) i {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    UIView *usernameSubview = [[UIView alloc]init];
    usernameSubview.frame = CGRectMake(0, i * heightOfVisualization, _usernamesWindow.frame.size.width, heightOfVisualization);
    // tag == i + 1 since 0 tag goes to the superview
    usernameSubview.tag = i + 1;
    [_usernamesWindow addSubview:usernameSubview];
    
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.tag = 1;
    nameLabel.backgroundColor = [UIColor whiteColor];
    nameLabel.frame = CGRectMake(0, 2, widthOfUsernamesWindowWhenOpen, 40);
    nameLabel.font = [UIFont boldSystemFontOfSize:15.3];
    if ([[tabControl.profiles objectAtIndex:i] isEqual:tabControl.ownProfile]) {
        nameLabel.text = [NSString stringWithFormat:@"  %@ (You)", [[tabControl.profiles objectAtIndex:i] objectAtIndex:2]];
    }
    else {
        nameLabel.text = [NSString stringWithFormat:@"  %@", [[tabControl.profiles objectAtIndex:i] objectAtIndex:2]];
    }
    if(nameLabel != NULL) {
        [[_usernamesWindow viewWithTag:i + 1] addSubview:nameLabel];
    }
    
    
    [tabControl reloadDataForPieChartAtIndex:i];
    [[tabControl.pieCharts objectAtIndex:i] reloadData];
    [[_usernamesWindow viewWithTag:i + 1] addSubview:[tabControl.pieCharts objectAtIndex:i]];
}

/*
 Method Description: Draws a vertical line in a particular view
 Inputs: view - UIView* where the line will be drawn, x - x position for the starting point of the line
 Outputs: None
 */
- (void)drawLineInView:(UIView*)view withXVal:(int)x {
    UIView *lineBelowData = [[UIView alloc]init];
    lineBelowData.frame = CGRectMake(x, 0, 1, view.frame.origin.y + view.frame.size.height + 10000);
    lineBelowData.layer.borderColor = [UIColor lightGrayColor].CGColor;
    lineBelowData.layer.borderWidth = 1.0;
    lineBelowData.tag = 9005;
    [view addSubview:lineBelowData];
}

#pragma mark Favorite and Least Favorite Functions

/*
 Method Description: Loads favorite trials for all users
 Inputs: None
 Outputs: None
 */
- (void)loadFavorites {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    
    // first, remove all current subviews from the 3 visualization scrollViews
    for (UIView *subview in [_profilesWindow subviews]) {
        if (subview.tag != 9005) {
            for (UIView *subsubview in [subview subviews])
                [subsubview removeFromSuperview];
            [subview removeFromSuperview];
        }
    }
    for (UIView *subview in [_usernamesWindow subviews]) {
        for (UIView *subsubview in [subview subviews])
            [subsubview removeFromSuperview];
        [subview removeFromSuperview];
    }
    for (int i = 0; i < [imageViewsToRemove count]; i++) {
        [[imageViewsToRemove objectAtIndex:i] removeFromSuperview];
    }
    
    // loop thru all favorites and make sure someone did not favorite a trial you don't have
    // if this happened, send request to momma for any new trials
    for (NSArray *favorite in tabControl.favorites) {
        if (tabControl.trialNum <= [[favorite objectAtIndex:2] integerValue]) {
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Error" message:@"Necessary trials not loaded. Loading now." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    
    // if there are no favorites, load a message telling the user this
    if (tabControl.favorites.count == 0) {
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"No favorites loaded" message:@"Wait for other users to select their favorite trial" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    // sort favorites so that the user of the device is at the top
    int indexOfCurrentDevice = -1;
    for (int i = 0; i <tabControl.favorites.count; i++) {
        if([[[tabControl.favorites objectAtIndex:i] objectAtIndex:1] isEqualToString:[[UIDevice currentDevice]name]]) {
            indexOfCurrentDevice = i;
        }
    }
    
    if (indexOfCurrentDevice != -1) {
        NSArray *currentDeviceArray = [tabControl.favorites objectAtIndex:indexOfCurrentDevice];
        
        [tabControl.favorites replaceObjectAtIndex:indexOfCurrentDevice withObject:[tabControl.favorites objectAtIndex:0]];
        [tabControl.favorites replaceObjectAtIndex:0 withObject:currentDeviceArray];
    }
    
    [efficiencySocial removeAllObjects];
    
    int indexOfProfileInTabControlProfiles = -1;
    
    for (int i = 0; i < tabControl.favorites.count; i++) {
        NSArray *profile = [[NSArray alloc]init];
        
        // find the profile for this user
        for(int j = 0; j < tabControl.profiles.count; j++) {
            if(tabControl.profiles.count < j)
                return;
            if ([[[tabControl.favorites objectAtIndex:i] objectAtIndex:1] isEqualToString:[[tabControl.profiles objectAtIndex:j] objectAtIndex:1]]) {
                profile = [tabControl.profiles objectAtIndex:j];
                indexOfProfileInTabControlProfiles = j;
            }
        }
        
        //exit if profile is not found
        if (indexOfProfileInTabControlProfiles == -1 || [profile count] < 3) {
            NSLog(@"Exiting from drawing views in _usernamesWindow for favorite trials");
            return;
        }
        
        // draw views in _usernamesWindow
        // tag for each view is 1+(index of device name in tabControl.favorites)
        UIView *usernameSubview = [[UIView alloc]init];
        usernameSubview.frame = CGRectMake(0, i * heightOfVisualization, _usernamesWindow.frame.size.width, heightOfVisualization);
        // tag == i + 1 since 0 tag goes to the superview
        usernameSubview.tag = i + 1;
        [_usernamesWindow addSubview:usernameSubview];
        
        UILabel *nameLabel = [[UILabel alloc]init];
        nameLabel.tag = 1;
        nameLabel.backgroundColor = [UIColor whiteColor];
        nameLabel.frame = CGRectMake(0, 2, widthOfUsernamesWindowWhenOpen, 40);
        nameLabel.font = [UIFont boldSystemFontOfSize:15.3];
        if ([profile isEqual:tabControl.ownProfile]) {
            nameLabel.text = [NSString stringWithFormat:@"  %@ (You) - Trial %d", [profile objectAtIndex:2], (int)[[[tabControl.favorites objectAtIndex:i] objectAtIndex:2] integerValue] + 1];
        }
        else {
            nameLabel.text = [NSString stringWithFormat:@"  %@ - Trial %d", [profile objectAtIndex:2], (int)[[[tabControl.favorites objectAtIndex:i] objectAtIndex:2] integerValue] + 1];
        }
        if(nameLabel != NULL) {
            [[_usernamesWindow viewWithTag:i + 1] addSubview:nameLabel];
        }
        
        
        [tabControl reloadDataForPieChartAtIndex:i];
        [[tabControl.pieCharts objectAtIndex:i] reloadData];
        [[_usernamesWindow viewWithTag:i + 1] addSubview:[tabControl.pieCharts objectAtIndex:indexOfProfileInTabControlProfiles]];
    }
    
    
    
    // draw views in _profilesWindow
    // tag for each view is 1+(index of device name in tabControl.favorites)
    for (int i = 0; i < tabControl.favorites.count; i++) {
        NSArray *profile = [[NSArray alloc]init];
        
        // find the profile for this user
        for(int j = 0; j < tabControl.favorites.count; j++) {
            if ([[[tabControl.favorites objectAtIndex:i] objectAtIndex:1] isEqualToString:[[tabControl.profiles objectAtIndex:j] objectAtIndex:1]]) {
                profile = [tabControl.profiles objectAtIndex:j];
                indexOfProfileInTabControlProfiles = j;
            }
        }
        
        UIView *profileSubview = [[UIView alloc]init];
        profileSubview.frame = CGRectMake(0, i * heightOfVisualization, widthOfTitleVisualization * 8, heightOfVisualization);
        // tag == i + 1 since 0 tag goes to the superview
        profileSubview.tag = i + 1;
        [_profilesWindow addSubview:profileSubview];
        
        
        // draw profile concerns in order
        int width = 0;
        for (int j = 3; j < profile.count; j++) {
            
            UILabel *currentLabel = [[UILabel alloc]init];
            currentLabel.backgroundColor = [concernColors objectForKey:[profile objectAtIndex:j]];
            currentLabel.frame = CGRectMake(width, 0, widthOfTitleVisualization, 40);
            currentLabel.font = [UIFont boldSystemFontOfSize:15.3];
            
            if([[profile objectAtIndex:j] isEqualToString:@"Investment"]) {
                currentLabel.text = @"  Investment";
            }
            else if([[profile objectAtIndex:j] isEqualToString:@"Damage Reduction"]) {
                currentLabel.text = @"  Damage Reduction";
            }
            else if([[profile objectAtIndex:j] isEqualToString:@"Efficiency of Intervention ($/Gallon)"]) {
                currentLabel.text = @"  Efficiency of Intervention";
            }
            else if([[profile objectAtIndex:j] isEqualToString:@"Capacity Used"]) {
                currentLabel.text = @"  Intervention Capacity";
            }
            else if([[profile objectAtIndex:j] isEqualToString:@"Water Flow Path"]) {
                currentLabel.text = @"  Water Flow";
            }
            else if([[profile objectAtIndex:j] isEqualToString:@"Maximum Flooded Area"]) {
                currentLabel.text = @"  Maximum Flooded Area";
            }
            else if([[profile objectAtIndex:j] isEqualToString:@"Groundwater Infiltration"]) {
                currentLabel.text = @"  Groundwater Infiltration";
            }
            else if([[profile objectAtIndex:j] isEqualToString:@"Impact on my Neighbors"]) {
                currentLabel.text = @"  Impact on my Neighbors";
            }
            else {
                currentLabel = NULL;
            }
            
            if(currentLabel != NULL){
                [profileSubview addSubview:currentLabel];
                width += widthOfTitleVisualization;
            }
        }
    }
    
    
    for (int i = 0; i < tabControl.favorites.count; i++) {
        int trialNum = [[[tabControl.favorites objectAtIndex:i] objectAtIndex:2]integerValue];
        
        // find the profile for this user
        for(int j = 0; j < tabControl.favorites.count; j++) {
            if ([[[tabControl.favorites objectAtIndex:i] objectAtIndex:1] isEqualToString:[[tabControl.profiles objectAtIndex:j] objectAtIndex:1]]) {
                indexOfProfileInTabControlProfiles = j;
            }
        }
        
        [self drawTrialForSpecificTrial:trialNum forProfile:indexOfProfileInTabControlProfiles withViewIndex:i];
    }
    
    [_profilesWindow setContentSize:CGSizeMake(widthOfTitleVisualization * 8 + 10, tabControl.favorites.count * heightOfVisualization + 10)];
    [_usernamesWindow setContentSize:CGSizeMake(_usernamesWindow.frame.size.width, tabControl.favorites.count * heightOfVisualization + 10)];
    
    
}


/*
 Method Description: Loads least favorite trial for all users
 Inputs: None
 Outputs: None
 */
- (void)loadLeastFavorites {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    
    // first, remove all current subviews from the 3 visualization scrollViews
    for (UIView *subview in [_profilesWindow subviews]) {
        if (subview.tag != 9005) {
            for (UIView *subsubview in [subview subviews])
                [subsubview removeFromSuperview];
            [subview removeFromSuperview];
        }
    }
    for (UIView *subview in [_usernamesWindow subviews]) {
        for (UIView *subsubview in [subview subviews])
            [subsubview removeFromSuperview];
        [subview removeFromSuperview];
    }
    for (int i = 0; i < [imageViewsToRemove count]; i++) {
        [[imageViewsToRemove objectAtIndex:i] removeFromSuperview];
    }
    
    // loop thru all least favorites and make sure someone did not favorite a trial you don't have
    // if this happened, send request to momma for any new trials
    for (NSArray *leastFavorite in tabControl.leastFavorites) {
        if (tabControl.trialNum <= [[leastFavorite objectAtIndex:2] integerValue]) {
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Error" message:@"Necessary trials not loaded. Loading now." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    
    // if there are no favorites, load a message telling the user this
    if (tabControl.leastFavorites.count == 0) {
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"No least favorites loaded" message:@"Wait for other users to select their least favorite trial" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    [efficiencySocial removeAllObjects];
    
    
    // sort favorites so that the user of the device is at the top
    int indexOfCurrentDevice = -1;
    for (int i = 0; i <tabControl.leastFavorites.count; i++) {
        if([[[tabControl.leastFavorites objectAtIndex:i] objectAtIndex:1] isEqualToString:[[UIDevice currentDevice]name]]) {
            indexOfCurrentDevice = i;
        }
    }
    
    if (indexOfCurrentDevice != -1) {
        NSArray *currentDeviceArray = [tabControl.leastFavorites objectAtIndex:indexOfCurrentDevice];
        
        [tabControl.leastFavorites replaceObjectAtIndex:indexOfCurrentDevice withObject:[tabControl.leastFavorites objectAtIndex:0]];
        [tabControl.leastFavorites replaceObjectAtIndex:0 withObject:currentDeviceArray];
    }
    
    int indexOfProfileInTabControlProfiles = -1;
    
    for (int i = 0; i < tabControl.leastFavorites.count; i++) {
        NSArray *profile = [[NSArray alloc]init];
        
        // find the profile for this user
        for(int j = 0; j < tabControl.profiles.count; j++) {
            if ([[[tabControl.leastFavorites objectAtIndex:i] objectAtIndex:1] isEqualToString:[[tabControl.profiles objectAtIndex:j] objectAtIndex:1]]) {
                profile = [tabControl.profiles objectAtIndex:j];
                indexOfProfileInTabControlProfiles = j;
            }
        }
        
        //exit if profile is not found
        if (indexOfProfileInTabControlProfiles == -1) {
            NSLog(@"Exiting from drawing views in _usernamesWindow for least favorite trials");
            return;
        }
        
        // draw views in _usernamesWindow
        // tag for each view is 1+(index of device name in tabControl.favorites)
        UIView *usernameSubview = [[UIView alloc]init];
        usernameSubview.frame = CGRectMake(0, i * heightOfVisualization, _usernamesWindow.frame.size.width, heightOfVisualization);
        // tag == i + 1 since 0 tag goes to the superview
        usernameSubview.tag = i + 1;
        [_usernamesWindow addSubview:usernameSubview];
        
        UILabel *nameLabel = [[UILabel alloc]init];
        nameLabel.tag = 1;
        nameLabel.backgroundColor = [UIColor whiteColor];
        nameLabel.frame = CGRectMake(0, 2, widthOfUsernamesWindowWhenOpen, 40);
        nameLabel.font = [UIFont boldSystemFontOfSize:15.3];
        if ([profile isEqual:tabControl.ownProfile]) {
            nameLabel.text = [NSString stringWithFormat:@"  %@ (You) - Trial %d", [profile objectAtIndex:2], (int)[[[tabControl.leastFavorites objectAtIndex:i] objectAtIndex:2] integerValue] + 1];
        }
        else {
            nameLabel.text = [NSString stringWithFormat:@"  %@ - Trial %d", [profile objectAtIndex:2], (int)[[[tabControl.leastFavorites objectAtIndex:i] objectAtIndex:2] integerValue] + 1];
        }
        if(nameLabel != NULL) {
            [[_usernamesWindow viewWithTag:i + 1] addSubview:nameLabel];
        }
        
        
        [tabControl reloadDataForPieChartAtIndex:i];
        [[tabControl.pieCharts objectAtIndex:i] reloadData];
        [[_usernamesWindow viewWithTag:i + 1] addSubview:[tabControl.pieCharts objectAtIndex:indexOfProfileInTabControlProfiles]];
    }
    
    
    
    // draw views in _profilesWindow
    // tag for each view is 1+(index of device name in tabControl.favorites)
    for (int i = 0; i < tabControl.leastFavorites.count; i++) {
        NSArray *profile = [[NSArray alloc]init];
        
        // find the profile for this user
        for(int j = 0; j < tabControl.leastFavorites.count; j++) {
            if ([[[tabControl.leastFavorites objectAtIndex:i] objectAtIndex:1] isEqualToString:[[tabControl.profiles objectAtIndex:j] objectAtIndex:1]]) {
                profile = [tabControl.profiles objectAtIndex:j];
                indexOfProfileInTabControlProfiles = j;
            }
        }
        
        UIView *profileSubview = [[UIView alloc]init];
        profileSubview.frame = CGRectMake(0, i * heightOfVisualization, widthOfTitleVisualization * 8, heightOfVisualization);
        // tag == i + 1 since 0 tag goes to the superview
        profileSubview.tag = i + 1;
        [_profilesWindow addSubview:profileSubview];
        
        
        // draw profile concerns in order
        int width = 0;
        for (int j = 3; j < profile.count; j++) {
            
            UILabel *currentLabel = [[UILabel alloc]init];
            currentLabel.backgroundColor = [concernColors objectForKey:[profile objectAtIndex:j]];
            currentLabel.frame = CGRectMake(width, 0, widthOfTitleVisualization, 40);
            currentLabel.font = [UIFont boldSystemFontOfSize:15.3];
            
            if([[profile objectAtIndex:j] isEqualToString:@"Investment"]) {
                currentLabel.text = @"  Investment";
            }
            else if([[profile objectAtIndex:j] isEqualToString:@"Damage Reduction"]) {
                currentLabel.text = @"  Damage Reduction";
            }
            else if([[profile objectAtIndex:j] isEqualToString:@"Efficiency of Intervention ($/Gallon)"]) {
                currentLabel.text = @"  Efficiency of Intervention";
            }
            else if([[profile objectAtIndex:j] isEqualToString:@"Capacity Used"]) {
                currentLabel.text = @"  Intervention Capacity";
            }
            else if([[profile objectAtIndex:j] isEqualToString:@"Water Flow Path"]) {
                currentLabel.text = @"  Water Flow";
            }
            else if([[profile objectAtIndex:j] isEqualToString:@"Maximum Flooded Area"]) {
                currentLabel.text = @"  Maximum Flooded Area";
            }
            else if([[profile objectAtIndex:j] isEqualToString:@"Groundwater Infiltration"]) {
                currentLabel.text = @"  Groundwater Infiltration";
            }
            else if([[profile objectAtIndex:j] isEqualToString:@"Impact on my Neighbors"]) {
                currentLabel.text = @"  Impact on my Neighbors";
            }
            else {
                currentLabel = NULL;
            }
            
            if(currentLabel != NULL){
                [profileSubview addSubview:currentLabel];
                width += widthOfTitleVisualization;
            }
        }
    }
    
    
    for (int i = 0; i < tabControl.leastFavorites.count; i++) {
        int trialNum = [[[tabControl.leastFavorites objectAtIndex:i] objectAtIndex:2]integerValue];
        
        // find the profile for this user
        for(int j = 0; j < tabControl.leastFavorites.count; j++) {
            if ([[[tabControl.leastFavorites objectAtIndex:i] objectAtIndex:1] isEqualToString:[[tabControl.profiles objectAtIndex:j] objectAtIndex:1]]) {
                indexOfProfileInTabControlProfiles = j;
            }
        }
        
        [self drawTrialForSpecificTrial:trialNum forProfile:indexOfProfileInTabControlProfiles withViewIndex:i];
    }
    
    
    [_profilesWindow setContentSize:CGSizeMake(widthOfTitleVisualization * 8 + 10, tabControl.leastFavorites.count * heightOfVisualization + 10)];
    [_usernamesWindow setContentSize:CGSizeMake(_usernamesWindow.frame.size.width, tabControl.leastFavorites.count * heightOfVisualization + 10)];
}


// create a new subview for each profile with frame.origin.y = i * heightOfVisualization and width = widthOfTitleVisualization * 8
// fill subview in _profilesWindow with profile information
// fill subview in _profilesWindow with trial information
// create a new subview for each username with frame.origin.y = i * heightOfVisualization and width = _usernameWindow...width
// fill subview in _usernamesWindow with username info and profile pie chart
// create a new subview for each map with frame.origin.x = i * heightOfVisualization
// fill subview in _mapWindow with map visualization
- (void)loadVisualizationForNewTrial {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    int numberOfProfiles = tabControl.profiles.count;
    
    // first, remove all current subviews from the 3 visualization scrollViews
    for (UIView *subview in [_profilesWindow subviews]) {
        if (subview.tag != 9005) {
            for (UIView *subsubview in [subview subviews])
                [subsubview removeFromSuperview];
            [subview removeFromSuperview];
        }
    }
    for (UIView *subview in [_usernamesWindow subviews]) {
        for (UIView *subsubview in [subview subviews])
            [subsubview removeFromSuperview];
        [subview removeFromSuperview];
    }
    for (UIView *subview in [bottomOfMapWindow subviews]) {
        for (UIView *subsubview in [subview subviews])
            [subsubview removeFromSuperview];
        [subview removeFromSuperview];
    }
    for (int i = 0; i < [imageViewsToRemove count]; i++) {
        [[imageViewsToRemove objectAtIndex:i] removeFromSuperview];
    }
    
    [imageViewsToRemove removeAllObjects];
    
    
    // load map visualization
    if ([tabControl.trialRuns count] > trialChosen) {
        UILabel *mapWindowLabel = [[UILabel alloc]init];
        mapWindowLabel.text = [NSString stringWithFormat:@"             Trial %d", trialChosen + 1];
        mapWindowLabel.font = [UIFont systemFontOfSize:15.3];
        [mapWindowLabel sizeToFit];
        mapWindowLabel.frame = CGRectMake(0, 2, mapWindowLabel.frame.size.width, mapWindowLabel.frame.size.height);
        [bottomOfMapWindow addSubview:mapWindowLabel];
        
        AprilTestSimRun *simRun = [tabControl.trialRuns objectAtIndex:trialChosen];
        
        [bottomOfMapWindow setContentSize:CGSizeMake(_mapWindow.frame.size.width, bottomOfMapWindow.frame.size.height)];
        
        FebTestIntervention *interventionView = [[FebTestIntervention alloc] initWithPositionArray:simRun.map andFrame:(CGRectMake(mapWindowLabel.frame.origin.x + 20, mapWindowLabel.frame.size.height + 5, 115, 125))];
        interventionView.view = [[bottomOfMapWindow subviews] objectAtIndex:0];
        [interventionView updateView];
    }
    
    [efficiencySocial removeAllObjects];
    
    // create subviews in _usernamesWindow
    // nameLabel.tag == 1
    for (int i = 0; i < numberOfProfiles; i++) {
        [self createSubviewsForUsernamesWindow:i];
    }
    
    for (int i = 0; i < numberOfProfiles; i++) {
        [self createSubviewsForProfilesWindow:i];
    }
    
    for (int i = 0; i < numberOfProfiles; i++) {
        // draw trial for each profile
        [self drawTrialForSpecificTrial:trialChosen forProfile:i withViewIndex:i];
    }
    
    
    [_usernamesWindow setContentSize: CGSizeMake(_usernamesWindow.frame.size.width, numberOfProfiles * heightOfVisualization + 10)];
    [_profilesWindow setContentSize: CGSizeMake(widthOfTitleVisualization * 8 + 10, numberOfProfiles * heightOfVisualization + 10)];
}


#pragma mark Drawing Functions

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




/*
 Method Description: Draws the trial information.
 Inputs: trial - trial number, currentProfileIndex - index of profile within tabControl.profiles, viewIndex - index of which view to draw the trial information into within _usernamesWindow and _profilesWindow
 Outputs: None
 */
- (void) drawTrialForSpecificTrial:(int)trial forProfile:(int)currentProfileIndex withViewIndex:(int)viewIndex {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    
    // error checking
    if ([tabControl.profiles count] < currentProfileIndex + 1)
        return;
    
    // make sure trial asked for is loaded
    if ([tabControl.trialRuns count] < trial + 1)
        return;
    
    
    AprilTestSimRun *simRun = [tabControl.trialRuns objectAtIndex:trial];
    AprilTestNormalizedVariable *simRunNormal = [tabControl.trialRunsNormalized objectAtIndex:trial];
    
    NSArray *currentProfile = [[NSArray alloc]init];
    currentProfile = [tabControl.profiles objectAtIndex:currentProfileIndex];
    
    NSMutableArray *currentConcernRanking = [[NSMutableArray alloc]init];
    
    for (int j = 3; j < [currentProfile count]; j++) {
        [currentConcernRanking addObject:[[AprilTestVariable alloc] initWith:[concernNames objectForKey:[currentProfile objectAtIndex:j]] withDisplayName:[currentProfile objectAtIndex: j] withNumVar:1 withWidth:widthOfTitleVisualization withRank:10-j]];
    }

    int width = 0;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:@","];
    
    NSArray *sortedArray = [currentConcernRanking sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSInteger first = [(AprilTestVariable*)a currentConcernRanking];
        NSInteger second = [(AprilTestVariable*)b currentConcernRanking];
        if(first > second) return NSOrderedAscending;
        else return NSOrderedDescending;
    }];
    AprilTestCostDisplay *cd;
    int visibleIndex = 0;
    
    for(int i = 0 ; i < currentConcernRanking.count ; i++){
        
        AprilTestVariable * currentVar =[sortedArray objectAtIndex:i];
        
        //laziness: this is just the investment costs
        if([currentVar.name compare: @"publicCost"] == NSOrderedSame){
            float investmentInstall = simRun.publicInstallCost;
            float investmentMaintain = simRun.publicMaintenanceCost;
            float investmentInstallN = simRunNormal.publicInstallCost;
            //float investmentMaintainN = simRunNormal.publicMaintenanceCost;
            dynamic_cd_width = [self getWidthFromSlider:_BudgetSlider toValue:tabControl.budget];
            CGRect frame = CGRectMake(width + 25, 60, dynamic_cd_width, 30);
            
            float costWidth = [self getWidthFromSlider:_BudgetSlider toValue:simRun.publicInstallCost];
            float maxBudgetWidth = [self getWidthFromSlider:_BudgetSlider toValue:tabControl.budget];
            
            cd = [[AprilTestCostDisplay alloc] initWithCost:investmentInstall normScore:investmentInstallN costWidth:costWidth maxBudgetWidth:maxBudgetWidth andFrame:frame];
            
            [[_profilesWindow viewWithTag:viewIndex + 1] addSubview: cd];
            
            //checks if over budget, if so, prints warning message
            if (simRun.publicInstallCost > tabControl.budget){
                //store update labels for further use (updating over budget when using absolute val)
                
                UILabel *valueLabel;
                [self drawTextBasedVar:[NSString stringWithFormat: @"Over budget by $%@", [formatter stringFromNumber: [NSNumber numberWithInt: (int) (investmentInstall-tabControl.budget)]] ] withConcernPosition:width+25 andyValue:100 andColor:[UIColor redColor] to:&valueLabel withIndex:viewIndex];
            }
            
            
            [self drawTextBasedVar: [NSString stringWithFormat:@"Maintenance Cost: $%@", [formatter stringFromNumber: [NSNumber numberWithInt:investmentMaintain ]]] withConcernPosition:width + 25 andyValue:120 andColor:[UIColor blackColor] to:nil withIndex:viewIndex];
            
            //just damages now
        } else if ([currentVar.name compare: @"privateCost"] == NSOrderedSame){
            
            [self drawTextBasedVar: [NSString stringWithFormat:@"Rain Damage: $%@", [formatter stringFromNumber: [NSNumber numberWithInt:simRun.privateDamages]]] withConcernPosition:width + 20 andyValue:60 andColor:[UIColor blackColor] to:nil withIndex:viewIndex];
            [self drawTextBasedVar: [NSString stringWithFormat:@"Damaged Reduced by: %@%%", [formatter stringFromNumber: [NSNumber numberWithInt: 100 -(int)(100*simRunNormal.privateDamages)]]] withConcernPosition:width + 20 andyValue: 90 andColor:[UIColor blackColor] to:nil withIndex:viewIndex];
            [self drawTextBasedVar: [NSString stringWithFormat:@"Sewer Load: %.2f%%", 100*simRun.neighborsImpactMe] withConcernPosition:width + 20 andyValue:120 andColor:[UIColor blackColor] to:nil withIndex:viewIndex];
            [self drawTextBasedVar: [NSString stringWithFormat:@"Storms like this one to"] withConcernPosition:width + 20 andyValue:150 andColor:[UIColor blackColor] to:nil withIndex:viewIndex];
            [self drawTextBasedVar: [NSString stringWithFormat:@"recoup investment cost: %d", (int)((simRun.publicInstallCost)/(simRun.privateDamages))] withConcernPosition:width + 20 andyValue:165 andColor:[UIColor blackColor] to:nil withIndex:viewIndex];
            
        } else if ([currentVar.name compare: @"impactingMyNeighbors"] == NSOrderedSame){
            
            
            [self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%% of rainwater", 100*simRun.impactNeighbors] withConcernPosition:width + 30 andyValue:60 andColor:[UIColor blackColor] to:nil withIndex:viewIndex];
            [self drawTextBasedVar: [NSString stringWithFormat:@" flowed to neighbors"] withConcernPosition:width + 30 andyValue: 75 andColor:[UIColor blackColor] to:nil withIndex:viewIndex];
        }  else if ([currentVar.name compare: @"neighborImpactingMe"] == NSOrderedSame){
            
            
            [self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%%", 100*simRun.neighborsImpactMe] withConcernPosition:width + 50 andyValue:60 andColor:[UIColor blackColor] to:nil withIndex:viewIndex];
        } else if ([currentVar.name compare: @"groundwaterInfiltration"] == NSOrderedSame){
            
            
            [self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%% of possible", 100*simRun.infiltration] withConcernPosition:width + 30 andyValue:60 andColor:[UIColor blackColor] to:nil withIndex:viewIndex];
            [self drawTextBasedVar: [NSString stringWithFormat:@" groundwater infiltration"] withConcernPosition:width + 30 andyValue:75  andColor:[UIColor blackColor] to:nil withIndex:viewIndex];
        } else if([currentVar.name compare:@"puddleTime"] == NSOrderedSame){
            ((FebTestWaterDisplay*)[tabControl.waterDisplaysInTab objectAtIndex:trial]).thresholdValue = thresh_social;
            [[tabControl.waterDisplaysInTab objectAtIndex:trial] fastUpdateView:hoursAfterStorm_social];
            
            UIImageView *waterDisplayView = [[UIImageView alloc]initWithFrame:CGRectMake(width + 52, 60, 115, 125)];
            waterDisplayView.image = [tabControl viewToImageForWaterDisplay:[tabControl.waterDisplaysInTab objectAtIndex:trial]];
            [waterDisplayView setUserInteractionEnabled:YES];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resizeImage:)];
            tap.numberOfTapsRequired = 1;
            [waterDisplayView addGestureRecognizer:tap];

            [[_profilesWindow viewWithTag:viewIndex + 1]addSubview:waterDisplayView];
            
            [imageViewsToRemove addObject:waterDisplayView];
        } else if([currentVar.name compare:@"puddleMax"] == NSOrderedSame){
            
            ((FebTestWaterDisplay*)[tabControl.maxWaterDisplaysInTab objectAtIndex:trial]).thresholdValue = thresh_social;
            [[tabControl.maxWaterDisplaysInTab objectAtIndex:trial] updateView:48];
            
            UIImageView *maxWaterDisplayView = [[UIImageView alloc]initWithFrame:CGRectMake(width + 52, 60, 115, 125)];
            maxWaterDisplayView.image = [tabControl viewToImageForWaterDisplay:[tabControl.maxWaterDisplaysInTab objectAtIndex:trial]];
            [maxWaterDisplayView setUserInteractionEnabled:YES];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resizeImage:)];
            tap.numberOfTapsRequired = 1;
            [maxWaterDisplayView addGestureRecognizer:tap];

            [[_profilesWindow viewWithTag:viewIndex + 1]addSubview:maxWaterDisplayView];
            
            [imageViewsToRemove addObject:maxWaterDisplayView];
        } else if ([currentVar.name compare: @"capacity"] == NSOrderedSame){
            
            
            AprilTestEfficiencyView *ev;
            
            //NSLog(@"Drawing efficiency display for first time");
            ev = [[AprilTestEfficiencyView alloc] initWithFrame:CGRectMake(width, 60, 130, 150) withContent: simRun.efficiency];
            ev.trialNum = trial;
            ev.view = [_profilesWindow viewWithTag:viewIndex + 1];
            [efficiencySocial addObject:ev];

            [ev updateViewForHour: hoursAfterStorm_social];
            
        } else if ([currentVar.name compare: @"efficiencyOfIntervention"] == NSOrderedSame){
            [self drawTextBasedVar: [NSString stringWithFormat:@"$/Gallon Spent: $%.2f", simRun.dollarsGallons  ] withConcernPosition:width + 25 andyValue: 60 andColor: [UIColor blackColor] to:nil withIndex:viewIndex];
        }
        
        width+= currentVar.widthOfVisualization;
        if (currentVar.widthOfVisualization > 0) visibleIndex++;
    }
    
    //border around component score
    UILabel *fullValueBorder = [[UILabel alloc] initWithFrame:CGRectMake(148, 78,  114, 26)];
    fullValueBorder.backgroundColor = [UIColor grayColor];
    UILabel *fullValue = [[UILabel alloc] initWithFrame:CGRectMake(150, 80,  110, 22)];
    fullValue.backgroundColor = [UIColor whiteColor];
    [[_usernamesWindow viewWithTag:viewIndex + 1] addSubview:fullValueBorder];
    [[_usernamesWindow viewWithTag:viewIndex + 1] addSubview:fullValue];
    //NSLog(@" %@", scoreVisVals);
    float maxX = 150;
    float totalScore = 0;
    UILabel * componentScore;
    
    // get score bar visualization values
    NSMutableArray *score = [tabControl getScoreBarValuesForProfile:currentProfileIndex forTrial:trial isDynamicTrial:0];
    NSMutableArray *scoreVisVals = [score objectAtIndex:0];
    NSMutableArray *scoreVisNames = [score objectAtIndex:1];
    
    //computing and drawing the final component score
    for(int i =  0; i < scoreVisVals.count; i++){
        float scoreWidth = [[scoreVisVals objectAtIndex: i] floatValue] * 100;
        if (scoreWidth < 0) scoreWidth = 0.0;
        totalScore += scoreWidth;
        componentScore = [[UILabel alloc] initWithFrame:CGRectMake(maxX, 80, floor(scoreWidth), 22)];
        componentScore.backgroundColor = [scoreColors objectForKey:[scoreVisNames objectAtIndex:i]];
        [[_usernamesWindow viewWithTag:viewIndex + 1] addSubview:componentScore];
        maxX+=floor(scoreWidth);
    }
    
    [_profilesWindow setContentSize:CGSizeMake(width+=20, [tabControl.profiles count] * heightOfVisualization + 10)];
    
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 40, 0, 0)];
    //scoreLabel.text = [NSString stringWithFormat:  @"Score: %.0f / 100", totalScore];
    scoreLabel.text = @"Performance:";
    scoreLabel.font = [UIFont systemFontOfSize:14.0];
    [scoreLabel sizeToFit];
    scoreLabel.textColor = [UIColor blackColor];
    [[_usernamesWindow viewWithTag:viewIndex + 1] addSubview:scoreLabel];
    UILabel *scoreLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(150, 65, 0, 0)];
    scoreLabel2.text = [NSString stringWithFormat:  @"Broken down by source:"];
    scoreLabel2.font = [UIFont systemFontOfSize:10.0];
    [scoreLabel2 sizeToFit];
    scoreLabel2.textColor = [UIColor blackColor];
    [[_usernamesWindow viewWithTag:viewIndex + 1] addSubview:scoreLabel2];
}


//Draws Labels to set on the dataWindow Scrollview but also returns object to be added into a MutableArray (used for updating labels)
-(void) drawTextBasedVar: (NSString *) outputValue withConcernPosition: (int) concernPos andyValue: (int) yValue andColor: (UIColor*) color to:(UILabel**) label withIndex:(int)currentProfileIndex{
    if (label != nil){
        *label = [[UILabel alloc] init];
        (*label).text = outputValue;
        (*label).frame =CGRectMake(concernPos, yValue, 0, 0);
        [*label sizeToFit ];
        (*label).font = [UIFont systemFontOfSize:14.0];
        (*label).textColor = color;
        [[_profilesWindow viewWithTag:currentProfileIndex + 1] addSubview:*label];
    }else
    {
        UILabel *valueLabel = [[UILabel alloc] init];
        valueLabel.text = outputValue;
        valueLabel.frame =CGRectMake(concernPos, yValue, 0, 0);
        [valueLabel sizeToFit ];
        valueLabel.font = [UIFont systemFontOfSize:14.0];
        valueLabel.textColor = color;
        [[_profilesWindow viewWithTag:currentProfileIndex + 1] addSubview:valueLabel];
    }
}

/**
 * Returns the width from the minimum end of a slider
 * to a particular value on the slider
 *
 * Used to draw the budget labels underneath the budget slider
 */
- (int)getWidthFromSlider:(UISlider *)aSlider toValue:(float)value {
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


/*
 Method Description: Syncronizes vertical scrolling between _usernamesWindow and _profilesWindow
 Inputs: scrollView - UIScrollView* which is scrolled by user
 Outputs: None
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:_usernamesWindow]) {
        float verticalOffset = _usernamesWindow.contentOffset.y;
        CGPoint contentOffset;
        contentOffset.y = verticalOffset;
        contentOffset.x = _profilesWindow.contentOffset.x;
        [_profilesWindow setContentOffset:contentOffset];
    }
    else if ([scrollView isEqual:_profilesWindow]) {
        float verticalOffset = _profilesWindow.contentOffset.y;
        CGPoint contentOffset;
        contentOffset.y = verticalOffset;
        contentOffset.x = _usernamesWindow.contentOffset.x;
        [_usernamesWindow setContentOffset:contentOffset];
    }
}


#pragma mark Label Drawing and Editing Functions

/*
 Method Description: Called when Storm Playback Hours label needs to be changed (user slid UISlider)
 Inputs: None
 Outputs: None
 */
- (void)changeHoursLabel {
    hoursAfterStormLabel.text = [NSString stringWithFormat:@"Storm Playback: %d hours", (int)_StormPlayBack.value];
    [hoursAfterStormLabel sizeToFit];
    hoursAfterStormLabel.frame = CGRectMake(hoursAfterStormLabel.frame.origin.x, _StormPlayBack.frame.origin.y, hoursAfterStormLabel.frame.size.width, _StormPlayBack.frame.size.height);
    hours_social = (int)_StormPlayBack.value;
}

/*
 Method Description: Called when Budget label needs to be changed (Momma Bird changed budget)
 Inputs: budget - new budget
 Outputs: None
 */
- (void)changeBudgetLabel:(int)budget {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:@","];
    
    budgetLabel.text = [NSString stringWithFormat:@"Budget $%@", [formatter stringFromNumber:[NSNumber numberWithInt:budget]]];
    [budgetLabel sizeToFit];
    budgetLabel.frame = CGRectMake(maxLabelStorm.frame.origin.x + maxLabelStorm.frame.size.width - budgetLabel.frame.size.width, maxLabelStorm.frame.origin.y - budgetLabel.frame.size.height - 4, budgetLabel.frame.size.width, budgetLabel.frame.size.height);

}

/*
 Method Description: Called from viewDidLoad to draw all the labels for Storm Playback and Budget
 Inputs: None
 Outputs: None
 */
- (void)drawMinMaxSliderLabels {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:@","];
    
    UILabel *minLabelStorm = [[UILabel alloc]init];
    minLabelStorm.text = @"0 hrs";
    minLabelStorm.font = [UIFont systemFontOfSize:15.0];
    [minLabelStorm sizeToFit];
    minLabelStorm.frame = (CGRectMake(_StormPlayBack.frame.origin.x - (minLabelStorm.frame.size.width + 10), _StormPlayBack.frame.origin.y, minLabelStorm.frame.size.width, _StormPlayBack.frame.size.height));
    [minLabelStorm setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:minLabelStorm];
    
    maxLabelStorm = [[UILabel alloc]init];
    maxLabelStorm.text = @"48 hrs";
    maxLabelStorm.font = [UIFont systemFontOfSize: 15.0];
    [maxLabelStorm sizeToFit];
    maxLabelStorm.frame = CGRectMake(_StormPlayBack.frame.origin.x + (_StormPlayBack.frame.size.width + 10), _StormPlayBack.frame.origin.y, maxLabelStorm.frame.size.width, _StormPlayBack.frame.size.height);
    [maxLabelStorm setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:maxLabelStorm];
    
    hoursAfterStormLabel = [[UILabel alloc]init];
    hoursAfterStormLabel.text = [NSString stringWithFormat:@"Storm Playback: %d hours", (int)hours_social];
    hoursAfterStormLabel.font = [UIFont systemFontOfSize:15.0];
    [hoursAfterStormLabel sizeToFit];
    hoursAfterStormLabel.frame = CGRectMake(minLabelStorm.frame.origin.x - hoursAfterStormLabel.frame.size.width - 25, _StormPlayBack.frame.origin.y, hoursAfterStormLabel.frame.size.width, _StormPlayBack.frame.size.height);
    [hoursAfterStormLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:hoursAfterStormLabel];
    
    budgetLabel = [[UILabel alloc]init];
    budgetLabel.text = [NSString stringWithFormat:@"Budget $%@", [formatter stringFromNumber:[NSNumber numberWithInt:tabControl.budget]]];
    budgetLabel.font = [UIFont systemFontOfSize:15.0];
    [budgetLabel sizeToFit];
    budgetLabel.frame = CGRectMake(maxLabelStorm.frame.origin.x + maxLabelStorm.frame.size.width - budgetLabel.frame.size.width, maxLabelStorm.frame.origin.y - budgetLabel.frame.size.height - 4, budgetLabel.frame.size.width, budgetLabel.frame.size.height);
    [budgetLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:budgetLabel];
}



#pragma mark Storm or Budget Change Functions


//selector method that handles a change in value when budget changes (slider under titles)
-(void)BudgetChanged{
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    
    _BudgetSlider.value = tabControl.budget;
    
    [self changeBudgetLabel:tabControl.budget];
    
    
    if (tabControl.trialNum == trialChosen) {
        if (tabControl.trialNum > 0) {
            [_loadingIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];
            [self loadFavorites];
            [_loadingIndicator stopAnimating];
        }
    }
    if (tabControl.trialNum + 1 == trialChosen) {
        if (tabControl.trialNum > 0) {
            [_loadingIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];
            [self loadLeastFavorites];
            [_loadingIndicator stopAnimating];
        }
    }
    else {
        //only update all labels/bars if Static normalization is switched on
        [self profileUpdate];
        [self drawScoreBarVisualizationHelper];
    }
}

/*
 Method Description: Called when storm hour is changed by user, sets hoursAfterStorm_social to be divisible by 2
 Inputs: sender - UISlider for storm hours
 Outputs: None
 */
-(void)StormHoursChanged:(id)sender{
    UISlider *slider = (UISlider*)sender;
    hours_social= slider.value;
    _StormPlayBack.value = hours_social;
    
    hoursAfterStorm_social = floorf(hours_social);
    if (hoursAfterStorm_social % 2 != 0) hoursAfterStorm_social--;
    
}

/*
 Method Description: Called when user picks up finger from sliding UISlider for storm hours. Redraws trials with new storm hours info.
 Inputs: notification - unused
 Outputs: None
 */
- (void)StormHoursChosen:(NSNotification *)notification {
    
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    
    if (tabControl.trialNum == trialChosen) {
        if (tabControl.trialNum > 0) {
            [_loadingIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];
            [self loadFavorites];
            [_loadingIndicator stopAnimating];
        }
    }
    if (tabControl.trialNum + 1 == trialChosen) {
        if (tabControl.trialNum > 0) {
            [_loadingIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];
            [self loadLeastFavorites];
            [_loadingIndicator stopAnimating];
        }
    }
    else
        [self profileUpdate];
    
    
    
    NSMutableString * content = [NSMutableString alloc];
    
    NSDate *myDate = [[NSDate alloc] init];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    NSString *prettyVersion = [dateFormat stringFromDate:myDate];
    
    //if(notification == UIControlEventTouchUpInside || notification == UIControlEventTouchUpOutside){
    content = [content initWithFormat:@"%@\tHours after storm set to: %d",prettyVersion, hoursAfterStorm_social];
    
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


#pragma mark Pie Chart Functions

// returns the number of slices that will be in a pieChart (8 slices for 8 concerns)
- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return 8;
}


- (CGFloat) pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    return [[[tabControl.slices objectAtIndex:tabControl.pieIndex]objectAtIndex:index] intValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    return [sliceColors objectAtIndex:(index % sliceColors.count)];
}

#pragma mark Memory Warning Functions


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
//
//  AprilTestSecondViewController.m
//  AprilTest
//
//  Created by Tia on 4/7/14.
//  Copyright (c) 2014 Tia. All rights reserved.
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

@interface OutcomeSalienceViewController ()

@end

@implementation OutcomeSalienceViewController
@synthesize studyNum = _studyNum;
@synthesize url = _url;
@synthesize dataWindow = _dataWindow;
@synthesize mapWindow = _mapWindow;
@synthesize titleWindow = _titleWindow;
@synthesize hoursAfterStorm = _hoursAfterStorm;
@synthesize hoursAfterStormLabel = _hoursAfterStormLabel;
@synthesize loadingIndicator = _loadingIndicator;
@synthesize scenarioNames = _scenarioNames;

//structs that will keep track of the highest and lowest costs of Installation and maintenance (for convenience)
typedef struct Value
{
    float highestCost;
    float lowestCost;
}Value;

typedef struct Node{
    float val;
    struct Node* next;
}Node;

Value  *installationCost  = NULL;
Value  *maintenanceCost   = NULL;
Value  *privateDamages    = NULL;
Value  *impactNeighbors   = NULL;
Value  *neighborsImpactMe = NULL;
Value  *gw_infiltration   = NULL;
Value  *floodedStreets    = NULL;
Value  *standingWater     = NULL;
Value  *efficiency_val    = NULL;
Node   *floodedStreetVals = NULL;

NSMutableArray * trialRuns;             //contains list of simulation data from trials pulled
NSMutableArray * trialRunsNormalized;   //contains list of simulation data from trials pulled in normalized form
NSMutableArray * waterDisplays;
NSMutableArray * maxWaterDisplays;
NSMutableArray * efficiency;
NSMutableArray *lastKnownConcernProfile;
NSMutableArray *bgCols;
NSMutableArray *privateDamagesLabels;
NSMutableArray *ImpactNeighborsLabels;
NSMutableArray *NeighborsImpactMeLabels;
NSMutableArray *gw_infiltration_Labels;
NSMutableArray *publicCostDisplays;
UILabel *redThreshold;
NSArray *arrStatus;
NSMutableDictionary *scoreColors;
int lastMoved = 0;
int trialNum = 0;
bool passFirstThree = FALSE;
float kOFFSET_FOR_KEYBOARD = 425.0;
float offsetForMoving = 0.0;
float originalOffset = 0.0;
UITextField *edittingTX;
NSTimer *scrollingTimer = nil;

//hardcoded values that will represent the flooding depth slider
float thresh = 65; //used for the max flooded area

float currInvest = 0;
float minInvest = 0;
float maxInvest = 5000000;
float frame_x = 137;
float frame_y = 642;
float frame_width = 214;
float frame_height = 31;

@synthesize currentConcernRanking = _currentConcernRanking;

- (void)viewDidLoad
{
    [super viewDidLoad];
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    _currentConcernRanking = tabControl.currentConcernRanking;
    _studyNum = tabControl.studyNum;
    _url = tabControl.url;
    trialRuns = [[NSMutableArray alloc] init];
    trialRunsNormalized = [[NSMutableArray alloc] init];
    waterDisplays = [[NSMutableArray alloc] init];
    maxWaterDisplays = [[NSMutableArray alloc] init];
    efficiency = [[NSMutableArray alloc] init];
    _scenarioNames = [[NSMutableArray alloc] init];
    publicCostDisplays = [[NSMutableArray alloc] init];
    privateDamagesLabels = [[NSMutableArray alloc] init];
    ImpactNeighborsLabels = [[NSMutableArray alloc] init];
    gw_infiltration_Labels = [[NSMutableArray alloc] init];
    _mapWindow.delegate = self;
    _dataWindow.delegate = self;
    _titleWindow.delegate = self;
    bgCols = [[NSMutableArray alloc] init];
    
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _loadingIndicator.center = CGPointMake(512, 300);
    _loadingIndicator.color = [UIColor blueColor];
    [self.view addSubview:_loadingIndicator];

     arrStatus = [[NSArray alloc] initWithObjects:@"Trial Number", @"Best Score", @"Public Cost", @"Private Cost", @"Rainwater to Neighbors", @"Rainwater from Neighbors", @"Intervention Efficiency", @"% Rainwater Infiltrated", nil];
    
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
    
}

- (void) viewWillAppear:(BOOL)animated{
    //[trialRuns removeAllObjects];
    //[waterDisplays removeAllObjects];
    //[efficiency removeAllObjects];
    for (UIView *view in [_titleWindow subviews]){
        [view removeFromSuperview];
    }
    for( UIView *view in [_dataWindow subviews]){
        [view removeFromSuperview];
    }
    for (UIView *view in [_mapWindow subviews]){
        [view removeFromSuperview];
    }
//    int prevTrialNum = trialNum;
//    trialNum = 0;
    for (int i =0; i < trialNum; i++){
        [self drawTrial:i];
    }
    [self drawTitles];
    [_dataWindow setContentOffset:CGPointMake(0, 0)];
    [_mapWindow setContentOffset:CGPointMake(0,0 )];
    [_dataWindow flashScrollIndicators];
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
  
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)pullNextRun:(id)sender {
    [_loadingIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];
    [self loadNextSimulationRun];
}

//Max Investment Slider updater
- (IBAction)investmentChanged:(UISlider *)sender {
    int newVal = sender.value;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    newVal = 1000.0 * floor((newVal/1000.0)+0.5);
    
    _currentMaxInvestment.text = [NSString stringWithFormat:@"$%@", [formatter stringFromNumber:[NSNumber numberWithInt:newVal]]];
    currInvest = newVal;
}

-(void) insertNewFloodedStreet: (Node**) floodedStreets withTrial:(int) trial
{
    AprilTestNormalizedVariable *simRunNorm = [trialRunsNormalized objectAtIndex:trial];
    if (*floodedStreets == NULL){
         *floodedStreets        = (Node*) malloc(sizeof(Node));
        (*floodedStreets)->val  = simRunNorm.floodedStreets;
        (*floodedStreets)->next = NULL;
    }
    else{
        Node *currList = *floodedStreets;
        while (currList != NULL){
            if (currList->next == NULL){
                Node *temp      = (Node*) malloc(sizeof(Node));
                temp->val       = simRunNorm.floodedStreets;
                temp->next      = NULL;
                currList->next = temp;
                break;
            }
            currList = currList->next;
        }
        
    }
}

-(void) normalizeAllandUpdateDynamically
{
    //normalize right after adding the newest trial
    [self normalize];
    
    //updates the normalization of the previous trials in respect to the newest trial
    [self updatePublicCostDisplays: trialNum];
    [self updateLabels: trialNum];
    
    //updates the component scores
    for (int i = 0; i < trialNum; i++)
        [self updateComponentScore:i];
}

-(void) normalizeStatically: (int) trial
{
    AprilTestSimRun *someTrial = [trialRuns objectAtIndex:trial];
    AprilTestNormalizedVariable *someTrialNorm = [trialRunsNormalized objectAtIndex:trial];
    
    if (currInvest == 0){ currInvest += .01; }
    
    //public cost
    someTrialNorm.publicInstallCost     = ((float)someTrial.publicInstallCost/(currInvest));
    someTrialNorm.publicMaintenanceCost = ((float)someTrial.publicMaintenanceCost/(currInvest));
    
    
    //private cost
    if (currInvest <= someTrial.privateDamages) {
        printf("Way over budget!!\n");
        someTrialNorm.privateDamages        =  1;
    } else{
        someTrialNorm.privateDamages        = (float)someTrial.privateDamages/(currInvest);
    }
    
    /*
    someTrialNorm.impactNeighbors       = (someTrial.impactNeighbors * 100);
    someTrialNorm.neighborsImpactMe     = (someTrial.neighborsImpactMe * 100);
    
    someTrialNorm.infiltration          = (someTrial.infiltration * 100);*/
}

//will normalize the cost of installation and maintenance
- (void)normalize
{
    if (installationCost == NULL)  { installationCost = (Value*)malloc(sizeof(Value));  }
    if (maintenanceCost == NULL)   { maintenanceCost = (Value*) malloc(sizeof(Value));  }
    if (privateDamages == NULL)    { privateDamages = (Value*)malloc(sizeof(Value));    }
    if (neighborsImpactMe == NULL) { neighborsImpactMe = (Value*)malloc(sizeof(Value)); }
    if (impactNeighbors == NULL)   { impactNeighbors = (Value*)malloc(sizeof(Value));   }
    if (gw_infiltration == NULL)   { gw_infiltration = (Value*) malloc(sizeof(Value));  }
    if (floodedStreets == NULL)    { floodedStreets = (Value*) malloc(sizeof(Value));   }
    if (standingWater == NULL)     { standingWater = (Value*) malloc(sizeof(Value));    }
    if (efficiency_val == NULL)    { efficiency_val = (Value*) malloc(sizeof(Value));   }
    
    Node *vals = floodedStreetVals;
    float currValStreets;
    
    //Obtain the min and max of the data elements found in a trial
    int i;
    for (i = 0; i < trialRuns.count; i++)
    {
        AprilTestSimRun  *someTrial     = [trialRuns objectAtIndex:i];
        AprilTestNormalizedVariable *someTrialNorm = [trialRunsNormalized objectAtIndex:i];
        
        currValStreets = vals->val;
        /*
        printf("Trial %d\n"
               "Install     Cost:%d\n"
               "Maintenance Cost:%d\n"
               "Private Damages :%d\n"
               "Neighbors -> Me :%f\n"
               "Me -> Neighbors :%f\n"
               "GW Infiltration :%f\n"
               "Flooded Streets :%f\n"
               "Standing Water  :%f\n"
               "Efficiency      :%f\n\n",i+1, someTrial.publicInstallCost, someTrial.publicMaintenanceCost, someTrial.privateDamages, someTrial.neighborsImpactMe, someTrial.impactNeighbors, someTrial.infiltration, currValStreets, someTrialNorm.standingWater, someTrialNorm.efficiency);*/
        
        if (i == 0){
            installationCost->highestCost  =  someTrial.publicInstallCost;
            installationCost->lowestCost   =  someTrial.publicInstallCost;
            
            maintenanceCost->highestCost   =  someTrial.publicMaintenanceCost;
            maintenanceCost->lowestCost    =  someTrial.publicMaintenanceCost;
            
            privateDamages->highestCost    = someTrial.privateDamages;
            privateDamages->lowestCost     = someTrial.privateDamages;
            
            impactNeighbors->highestCost   = someTrial.impactNeighbors;
            impactNeighbors->lowestCost    = someTrial.impactNeighbors;
            
            neighborsImpactMe->highestCost = someTrial.neighborsImpactMe;
            neighborsImpactMe->lowestCost  = someTrial.neighborsImpactMe;
            
            gw_infiltration->highestCost   = someTrial.infiltration;
            gw_infiltration->lowestCost    = someTrial.infiltration;
            
            floodedStreets->highestCost    = currValStreets;
            floodedStreets->lowestCost     = currValStreets;
            
            standingWater->highestCost     = someTrialNorm.standingWater;
            standingWater->lowestCost      = someTrialNorm.standingWater;
            
            efficiency_val->highestCost    = someTrialNorm.efficiency;
            efficiency_val->lowestCost     = someTrialNorm.efficiency;
        }
        
        //public cost
        if (someTrial.publicMaintenanceCost <= maintenanceCost->lowestCost) { maintenanceCost->lowestCost = someTrial.publicMaintenanceCost; }
        if (someTrial.publicMaintenanceCost >= maintenanceCost->highestCost){ maintenanceCost->highestCost = someTrial.publicMaintenanceCost; }
        
        if (someTrial.publicInstallCost <= installationCost->lowestCost){ installationCost->lowestCost = someTrial.publicInstallCost; }
        if (someTrial.publicInstallCost >= installationCost->highestCost) { installationCost->highestCost = someTrial.publicInstallCost; }
        
        //private cost
        if (someTrial.privateDamages <= privateDamages->lowestCost){  privateDamages->lowestCost = someTrial.privateDamages; }
        if (someTrial.privateDamages >= privateDamages->highestCost){ privateDamages->highestCost = someTrial.privateDamages; }
        
        //neighbors
        if (someTrial.impactNeighbors <= impactNeighbors->lowestCost){  impactNeighbors->lowestCost = someTrial.impactNeighbors; }
        if (someTrial.impactNeighbors >= impactNeighbors->highestCost){ impactNeighbors->highestCost = someTrial.impactNeighbors; }
        
        if (someTrial.neighborsImpactMe <= neighborsImpactMe->lowestCost){ neighborsImpactMe->lowestCost = someTrial.neighborsImpactMe; }
        if (someTrial.neighborsImpactMe >= neighborsImpactMe->highestCost){neighborsImpactMe->highestCost = someTrial.neighborsImpactMe; }
        
        //infiltration
        if (someTrial.infiltration <= gw_infiltration->lowestCost){ gw_infiltration->lowestCost = someTrial.infiltration; }
        if (someTrial.infiltration >= gw_infiltration->highestCost){ gw_infiltration->highestCost = someTrial.infiltration; }
        
        //flooded streets
        if (currValStreets <= floodedStreets->lowestCost){ floodedStreets->lowestCost = currValStreets; }
        if (currValStreets >= floodedStreets->highestCost){ floodedStreets->highestCost = currValStreets; }
        
        //standing water
        if (someTrialNorm.standingWater <= standingWater->lowestCost) { standingWater->lowestCost = someTrialNorm.standingWater; }
        if (someTrialNorm.standingWater >= standingWater->highestCost){ standingWater->highestCost = someTrialNorm.standingWater;}
        
        //efficiency
        if (someTrialNorm.efficiency <= efficiency_val->lowestCost){ efficiency_val->lowestCost = someTrialNorm.efficiency; }
        if (someTrialNorm.efficiency >= efficiency_val->highestCost){ efficiency_val->highestCost = someTrialNorm.efficiency; }
        
        vals = vals->next;
    }

    //printf("\n");
    
    //if the max happens to be 0, avoid division by 0
    if (maintenanceCost->highestCost == 0 || installationCost->highestCost == 0){
        maintenanceCost->highestCost = 1;
        installationCost->highestCost = 1;
    }
    if (privateDamages->highestCost == 0){
        privateDamages->highestCost = 1;
    }
    
    if (impactNeighbors->highestCost == 0) {
        impactNeighbors->highestCost = 1;
    }
    if (neighborsImpactMe->highestCost == 0) {
        neighborsImpactMe->highestCost = 1;
    }
    if (gw_infiltration->highestCost == 0){
        gw_infiltration->highestCost = 1;
    }
    if (floodedStreets->highestCost == 0){
        floodedStreets->highestCost = 1;
    }
    if (standingWater->highestCost == 0){
        standingWater->highestCost = 1;
    }
    if (efficiency_val->highestCost == 0){
        efficiency_val->highestCost = 1;
    }
    
    vals = floodedStreetVals;
    //normalize all the variables in accordance to the max value of all current trials
    for (i = 0; i < trialRuns.count; i++)
    {
        AprilTestSimRun  *someTrial     = [trialRuns objectAtIndex:i];
        AprilTestNormalizedVariable  *someTrialNorm = [trialRunsNormalized objectAtIndex:i];
        currValStreets = vals->val;
        
        someTrialNorm.publicInstallCost     = (float)someTrial.publicInstallCost/installationCost->highestCost;
        someTrialNorm.publicMaintenanceCost = (float)someTrial.publicMaintenanceCost/maintenanceCost->highestCost;
        
        someTrialNorm.privateDamages        = (float)someTrial.privateDamages/privateDamages->highestCost;
        
        someTrialNorm.impactNeighbors       = (someTrial.impactNeighbors * 100)/(impactNeighbors->highestCost *100);
        someTrialNorm.neighborsImpactMe     = (someTrial.neighborsImpactMe * 100)/(neighborsImpactMe->highestCost * 100);
        
        someTrialNorm.infiltration          = (someTrial.infiltration * 100)/(gw_infiltration->highestCost * 100);
        
        someTrialNorm.floodedStreets        =  currValStreets/(floodedStreets->highestCost); //Thought that it was a decimal value?
        someTrialNorm.standingWater         = (someTrialNorm.standingWater   *100)/(standingWater->highestCost  *100);
        someTrialNorm.efficiency            = (someTrialNorm.efficiency      *100)/(efficiency_val->highestCost *100);
        
        /*
        printf("Trial %d\n"
               "Install Cost    :%f\n"
               "Maintenance Cost:%f\n"
               "Private Damages :%f\n"
               "Neighbors -> Me :%f\n"
               "Me -> Neighbors :%f\n"
               "GW Infiltration :%f\n"
               "Flooded Streets :%f\n"
               "Standing Water  :%f\n"
               "Efficiency      :%f\n\n",i+1, someTrialNorm.publicInstallCost, someTrialNorm.publicMaintenanceCost, someTrialNorm.privateDamages, someTrialNorm.neighborsImpactMe, someTrialNorm.impactNeighbors, someTrialNorm.infiltration, someTrialNorm.floodedStreets, someTrialNorm.standingWater, someTrialNorm.efficiency);*/
        
        vals = vals->next;
    }
    //printf("\n");
}

//updates the score of the public install costs to reflect new trial
- (void) updatePublicCostDisplays:(int) trial
{
    for (int i = 0; i < trial; i++)
    {
        AprilTestCostDisplay *newCD = [publicCostDisplays objectAtIndex:i];
        AprilTestNormalizedVariable *normVar = [trialRunsNormalized objectAtIndex:i];
        
        [newCD updateCDWithScore:normVar.publicInstallCost andFrame:CGRectMake(25, normVar.trialNum*175 + 40, 130, 30)];
    }
}

//Updates the text of a UILabel (used to update labels after new trials are fetched)
- (NSMutableAttributedString *)myLabelAttributes:(NSString *)input{
    NSMutableAttributedString *labelAttributes = [[NSMutableAttributedString alloc] initWithString:input];
    return labelAttributes;
}

//takes care of updating all labels that need to be updated after new normalized data comes up
- (void) updateLabels: (int) trial
{
    UILabel *trialDamagesLabel;
    UILabel *trialImpactNeighbors;
    UILabel *trialNeighborsImpact;
    UILabel *trialInfiltration;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    for (int i = 0; i < trial; i++)
    {
        AprilTestNormalizedVariable *simRunNormal = [trialRunsNormalized objectAtIndex:i];
        
        if (i < privateDamagesLabels.count){
            trialDamagesLabel = [privateDamagesLabels objectAtIndex:i];
            
            [trialDamagesLabel setAttributedText:[self myLabelAttributes: [NSString stringWithFormat:@"Damaged Reduced by: %@%%", [formatter stringFromNumber: [NSNumber numberWithInt: 100 -(int)(100*simRunNormal.privateDamages)]]]]];
        }
        if (i < ImpactNeighborsLabels.count) {
            trialImpactNeighbors = [ImpactNeighborsLabels objectAtIndex:i];
            
            [trialImpactNeighbors setAttributedText:[self myLabelAttributes: [NSString stringWithFormat:@"%.2f%%", 100*simRunNormal.impactNeighbors]]];
        }
        if (i < NeighborsImpactMeLabels.count){
            trialNeighborsImpact = [NeighborsImpactMeLabels objectAtIndex:i];
            
            [trialNeighborsImpact setAttributedText:[self myLabelAttributes: [NSString stringWithFormat:@"poopy%.2f%%", 100*simRunNormal.neighborsImpactMe]]];
        }
        if (i < gw_infiltration_Labels.count){
            trialInfiltration = [gw_infiltration_Labels objectAtIndex:i];
            
            [trialInfiltration setAttributedText:[self myLabelAttributes:[NSString stringWithFormat:@"%.2f%%", 100*simRunNormal.infiltration]]];
        }
        
    }
}

- (void) updateComponentScore: (int) trial{
    AprilTestSimRun *simRun = [trialRuns objectAtIndex:trial];
    AprilTestNormalizedVariable *simRunNormal = [trialRunsNormalized objectAtIndex:trial];
    
    float priorityTotal= 0;
    float scoreTotal = 0;
    
    for(int i = 0; i < _currentConcernRanking.count; i++){
        
        priorityTotal += [(AprilTestVariable *)[_currentConcernRanking objectAtIndex:i] currentConcernRanking];
    }
    
    int width = 0;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSArray *sortedArray = [_currentConcernRanking sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSInteger first = [(AprilTestVariable*)a currentConcernRanking];
        NSInteger second = [(AprilTestVariable*)b currentConcernRanking];
        if(first > second) return NSOrderedAscending;
        else return NSOrderedDescending;
    }];
    NSMutableArray *scoreVisVals = [[NSMutableArray alloc] init];
    NSMutableArray *scoreVisNames = [[NSMutableArray alloc] init];
    
    int visibleIndex = 0;
    
    for(int i = 0 ; i <_currentConcernRanking.count ; i++){
        AprilTestVariable * currentVar =[sortedArray objectAtIndex:i];
        
        if([currentVar.name compare: @"publicCost"] == NSOrderedSame){
            float investmentInstallN = simRunNormal.publicInstallCost;
            float investmentMaintainN = simRunNormal.publicMaintenanceCost;
            
            scoreTotal += ((currentVar.currentConcernRanking/2.0)/priorityTotal * (1 - investmentInstallN));
            scoreTotal += ((currentVar.currentConcernRanking/2.0)/priorityTotal * (1 - investmentMaintainN));
            
            [scoreVisVals addObject:[NSNumber numberWithFloat:((currentVar.currentConcernRanking/2.0)/priorityTotal * (1 - investmentInstallN))]];
            [scoreVisVals addObject:[NSNumber numberWithFloat:((currentVar.currentConcernRanking/2.0)/priorityTotal * (1 - investmentMaintainN))]];
            
            [scoreVisNames addObject: @"publicCostI"];
            [scoreVisNames addObject: @"publicCostM"];
        }
        else if ([currentVar.name compare: @"privateCost"] == NSOrderedSame){
            
            scoreTotal += (currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.privateDamages) + currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.neighborsImpactMe)) /2;
            
            [scoreVisVals addObject:[NSNumber numberWithFloat:(currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.privateDamages) + currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.neighborsImpactMe)) /2]];
            
            [scoreVisNames addObject: @"privateCostD"];
            
        }
        else if ([currentVar.name compare: @"impactingMyNeighbors"] == NSOrderedSame){
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.impactNeighbors);
            [scoreVisVals addObject:[NSNumber numberWithFloat: currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.impactNeighbors)]];
            [scoreVisNames addObject: currentVar.name];
        }
        else if ([currentVar.name compare: @"neighborImpactingMe"] == NSOrderedSame){
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (simRunNormal.neighborsImpactMe);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * ( simRunNormal.neighborsImpactMe)]];
            [scoreVisNames addObject: currentVar.name];
        }
        else if ([currentVar.name compare: @"groundwaterInfiltration"] == NSOrderedSame){
           
            scoreTotal += (currentVar.currentConcernRanking/priorityTotal) * (simRunNormal.infiltration );
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * ( simRunNormal.infiltration )]];
            [scoreVisNames addObject: currentVar.name];
        }
        else if([currentVar.name compare:@"puddleTime"] == NSOrderedSame){
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.floodedStreets);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1- simRunNormal.floodedStreets)]];
            [scoreVisNames addObject: currentVar.name];
            
        }
        else if([currentVar.name compare:@"puddleMax"] == NSOrderedSame){
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.standingWater);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1- simRunNormal.standingWater)]];
            [scoreVisNames addObject: currentVar.name];
            
        }
        else if ([currentVar.name compare: @"capacity"] == NSOrderedSame){
        
            scoreTotal += currentVar.currentConcernRanking/priorityTotal *  simRunNormal.efficiency;
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal *  simRunNormal.efficiency]];
            [scoreVisNames addObject: currentVar.name];
        
            
        }
        else if ([currentVar.name compare: @"efficiencyOfIntervention"] == NSOrderedSame){
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * 1;
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * 0]];
            [scoreVisNames addObject:currentVar.name];
        }
        
        width+= currentVar.widthOfVisualization;
        if (currentVar.widthOfVisualization > 0) visibleIndex++;
    }

    //border around component score
    UILabel *fullValueBorder = [[UILabel alloc] initWithFrame:CGRectMake(148, (simRun.trialNum)*175 + 88,  114, 26)];
    fullValueBorder.backgroundColor = [UIColor grayColor];
    UILabel *fullValue = [[UILabel alloc] initWithFrame:CGRectMake(150, (simRun.trialNum)*175 + 90,  110, 22)];
    fullValue.backgroundColor = [UIColor whiteColor];
    [_mapWindow addSubview:fullValueBorder];
    [_mapWindow addSubview:fullValue];
    //NSLog(@" %@", scoreVisVals);
    float maxX = 150;
    float totalScore = 0;
    
    //computing and drawing the final component score
    for(int i =  0; i < scoreVisVals.count; i++){
        float scoreWidth = [[scoreVisVals objectAtIndex: i] floatValue] * 100;
        if (scoreWidth < 0) scoreWidth = 0.0;
        totalScore += scoreWidth;
        UILabel * componentScore = [[UILabel alloc] initWithFrame:CGRectMake(maxX, (simRun.trialNum)*175 + 90, floor(scoreWidth), 22)];
        componentScore.backgroundColor = [scoreColors objectForKey:[scoreVisNames objectAtIndex:i]];
        [_mapWindow addSubview:componentScore];
        maxX+=floor(scoreWidth);
    }
    
}

- (void)loadNextSimulationRun{
    
    //pull content from the server that is said to be from le trial with real vals
    NSString * urlPlusFile = [NSString stringWithFormat:@"%@/%@", _url, @"simOutput.php"];
    NSString *myRequestString = [[NSString alloc] initWithFormat:@"trialID=%d&studyID=%d", trialNum, _studyNum ];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString: urlPlusFile ] ];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    
    NSString *content;
    while( !content){
        NSURLResponse *response;
        NSError *err;
        NSData *returnData = [ NSURLConnection sendSynchronousRequest: request returningResponse:&response error:&err];
        //NSLog(@"error: %@", err);
        
        if( [returnData bytes]) content = [NSString stringWithUTF8String:[returnData bytes]];
        //NSLog(@"responseData: %@", content);
    }
    
    //pull content from the server that is said to be from le trial that is said to be normalized vals (ranging from 0 to 1)
    NSString *urlPlusFileN = [NSString stringWithFormat:@"%@/%@", _url, @"simOutputN.php"];
    NSString *myRequestStringN = [[NSString alloc] initWithFormat:@"trialID=%d&studyID=%d", trialNum, _studyNum ];
    NSData *myRequestDataN = [ NSData dataWithBytes: [ myRequestStringN UTF8String ] length: [ myRequestStringN length ] ];
    NSMutableURLRequest *requestN = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString: urlPlusFileN ] ];
    [ requestN setHTTPMethod: @"POST" ];
    [ requestN setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ requestN setHTTPBody: myRequestDataN ];

    NSString *contentN;
    while( !contentN){
        NSURLResponse *responseN;
        NSError *err;
        NSData *returnDataN = [ NSURLConnection sendSynchronousRequest: requestN returningResponse:&responseN error:&err];
        //NSLog(@"error: %@", err);
        
        if( [returnDataN bytes]) contentN = [NSString stringWithUTF8String:[returnDataN bytes]];
       //NSLog(@"responseData: %@", contentN);
    }
    
    
    if(content != NULL && content.length > 100 && contentN != NULL){
        
        //Adds a new trial to a list of trials (normalized and real)
        AprilTestSimRun *simRun = [[AprilTestSimRun alloc] init:content withTrialNum:trialNum];
        AprilTestNormalizedVariable *simRunNormal = [[AprilTestNormalizedVariable alloc] init: contentN withTrialNum:trialNum];
        [trialRunsNormalized addObject:simRunNormal];
        [trialRuns addObject: simRun];
        [self insertNewFloodedStreet:&floodedStreetVals withTrial:trialNum];  //make sure to save the values of flooded streets
        
        //chooses between static/dynamic normalization of trial data
        if (!_StaticNormalization.isOn) {
            //NSLog(@"I am implementing a Dynamic Normalization approach\n");
            [self normalizeAllandUpdateDynamically];
            
        }
        else{
            //NSLog(@"I am implementing a Static Normalization approach\n");
            [self normalizeStatically:trialNum]; //can be done trial at a time (since max Investment is already given)
        }
        
        //draws the newest trial
        [self drawTrial: trialNum];
        
        trialNum++;
    }
    
    //automatically scroll to the bottom (subject to change since its a little to rapid a transformation... maybeee) UPDATE: Scroling was smoothened
    if (trialNum > 3)
        scrollingTimer = [NSTimer scheduledTimerWithTimeInterval:(0.10)
                                                                  target:self selector:@selector(autoscrollTimerFired) userInfo:nil repeats:NO];
    
    
    [_loadingIndicator stopAnimating];
    
}

//autoscroll to the bottom of the mapwindow (trial and component score) scrollview
- (void) autoscrollTimerFired
{
    CGPoint bottomOffset = CGPointMake(0, _mapWindow.contentSize.height - _mapWindow.bounds.size.height);
    [_mapWindow setContentOffset:bottomOffset animated:YES];
}

-(void) drawTrial: (int) trial{

    AprilTestSimRun *simRun = [trialRuns objectAtIndex:trial];
    AprilTestNormalizedVariable *simRunNormal = [trialRunsNormalized objectAtIndex:trial];
    FebTestIntervention *interventionView = [[FebTestIntervention alloc] initWithPositionArray:simRun.map andFrame:(CGRectMake(20, 175 * (trial) + 40, 115, 125))];
    interventionView.view = _mapWindow;
    [interventionView updateView];

    [_mapWindow setContentSize: CGSizeMake(_mapWindow.contentSize.width, (simRun.trialNum+1)*200)];
    
    //int scoreBar=0;
    float priorityTotal= 0;
    float scoreTotal = 0;
    
    for(int i = 0; i < _currentConcernRanking.count; i++){

        priorityTotal += [(AprilTestVariable *)[_currentConcernRanking objectAtIndex:i] currentConcernRanking];
    }
    UITextField *tx;
    if(trial >= _scenarioNames.count){
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
        tx.text = [NSString stringWithFormat:  @"Trial %d", trial + 1];
        [_mapWindow addSubview:tx];
        [_scenarioNames addObject:tx];
    } else {
        tx = [_scenarioNames objectAtIndex:trial];
        tx.frame = CGRectMake(20, 175*(trial)+5, 245, 30);
        [_mapWindow addSubview:tx];
    }
    
    int width = 0;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSArray *sortedArray = [_currentConcernRanking sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSInteger first = [(AprilTestVariable*)a currentConcernRanking];
        NSInteger second = [(AprilTestVariable*)b currentConcernRanking];
        if(first > second) return NSOrderedAscending;
        else return NSOrderedDescending;
    }];
    NSMutableArray *scoreVisVals = [[NSMutableArray alloc] init];
    NSMutableArray *scoreVisNames = [[NSMutableArray alloc] init];
    int visibleIndex = 0;
    
    for(int i = 0 ; i <_currentConcernRanking.count ; i++){
        UILabel *savedLabel;
        
        AprilTestVariable * currentVar =[sortedArray objectAtIndex:i];
        if(simRun.trialNum ==0 && visibleIndex %2 == 0 && currentVar.widthOfVisualization > 0){
            UILabel *bgCol = [[UILabel alloc] initWithFrame:CGRectMake(width, -2, currentVar.widthOfVisualization+1, _dataWindow.contentSize.height + 100)];
            bgCol.backgroundColor = [UIColor whiteColor];
            bgCol.layer.borderColor = [UIColor lightGrayColor].CGColor;
            bgCol.layer.borderWidth = 2.0;
            [_dataWindow addSubview:bgCol];
            [bgCols addObject:bgCol];
        }
        
        //laziness: this is just the investment costs
        if([currentVar.name compare: @"publicCost"] == NSOrderedSame){
            float investmentInstall = simRun.publicInstallCost;
            float investmentMaintain = simRun.publicMaintenanceCost;
            float investmentInstallN = simRunNormal.publicInstallCost;
            float investmentMaintainN = simRunNormal.publicMaintenanceCost;
            
            AprilTestCostDisplay *cd;
            if(publicCostDisplays.count <= trial){
                //NSLog(@"Drawing water display for first time");
                cd = [[AprilTestCostDisplay alloc] initWithCost:investmentInstall andScore:investmentInstallN andFrame:CGRectMake(width +25, simRun.trialNum*175 + 40, 130, 30)];
                [_dataWindow addSubview: cd];
                [publicCostDisplays addObject:cd];
            } else {
                //NSLog(@"Repositioning water display");
                cd = [publicCostDisplays objectAtIndex:trial];
                cd.frame = CGRectMake(width + 25, simRun.trialNum*175 + 40, 130, 30);
                [_dataWindow addSubview:cd];
            }
            
            //checks if over budget, if so, prints warning message
            if(simRun.publicInstallCost > 800000){
                UILabel *valueLabel = [[UILabel alloc] init];
                valueLabel.text = [NSString stringWithFormat: @"Over budget: $%@", [formatter stringFromNumber: [NSNumber numberWithInt: (int) (investmentInstall-800000)]] ];
                valueLabel.frame =CGRectMake(width+25, simRun.trialNum *175 + 80, 0, 0);
                [valueLabel sizeToFit ];
                valueLabel.font = [UIFont boldSystemFontOfSize:12.0];
                valueLabel.textColor = [UIColor redColor];
                [[self dataWindow] addSubview:valueLabel];
            }
            [self drawTextBasedVar: [NSString stringWithFormat:@"Maintenance Cost: $%@", [formatter stringFromNumber: [NSNumber numberWithInt:investmentMaintain ]]] withConcernPosition:width + 25 andyValue: (simRun.trialNum * 175) +100];
            
            
            scoreTotal += ((currentVar.currentConcernRanking/2.0)/priorityTotal * (1 - investmentInstallN));
            scoreTotal += ((currentVar.currentConcernRanking/2.0)/priorityTotal * (1 - investmentMaintainN));
            //scoreTotal += ((currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRun.impactNeighbors));

            [scoreVisVals addObject:[NSNumber numberWithFloat:((currentVar.currentConcernRanking/2.0)/priorityTotal * (1 - investmentInstallN))]];
            [scoreVisVals addObject:[NSNumber numberWithFloat:((currentVar.currentConcernRanking/2.0)/priorityTotal * (1 - investmentMaintainN))]];
            //[scoreVisVals addObject:[NSNumber numberWithFloat:((currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRun.impactNeighbors))]];
            [scoreVisNames addObject: @"publicCostI"];
            [scoreVisNames addObject: @"publicCostM"];
            //[scoreVisNames addObject: @"publicCostD"];


            //just damages now
        } else if ([currentVar.name compare: @"privateCost"] == NSOrderedSame){
            
            [self drawTextBasedVar: [NSString stringWithFormat:@"Rain Damage: $%@", [formatter stringFromNumber: [NSNumber numberWithInt:simRun.privateDamages]]] withConcernPosition:width + 25 andyValue: (simRun.trialNum*175) +40];
            savedLabel = [self drawTextBasedVar: [NSString stringWithFormat:@"Damaged Reduced by: %@%%", [formatter stringFromNumber: [NSNumber numberWithInt: 100 -(int)(100*simRunNormal.privateDamages)]]] withConcernPosition:width + 25 andyValue: (simRun.trialNum*175) +70];
            [privateDamagesLabels addObject:savedLabel];
            [self drawTextBasedVar: [NSString stringWithFormat:@"Sewer Load:%.2f%%", 100*simRun.neighborsImpactMe] withConcernPosition:width + 25 andyValue: (simRun.trialNum ) * 175 + 100];
            

            scoreTotal += (currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.privateDamages) + currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.neighborsImpactMe)) /2;

            //add values for the score visualization
    
            [scoreVisVals addObject:[NSNumber numberWithFloat:(currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.privateDamages) + currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.neighborsImpactMe)) /2]];
            //scoreTotal +=currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.privateDamages);
            //[scoreVisVals addObject: [NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.privateDamages)]];
            [scoreVisNames addObject: @"privateCostD"];
            
        } else if ([currentVar.name compare: @"impactingMyNeighbors"] == NSOrderedSame){
            
            if (!_StaticNormalization.isOn){
                savedLabel =[self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%%", 100*simRunNormal.impactNeighbors] withConcernPosition:width +50 andyValue: (simRun.trialNum ) * 175 + 40];
            }
            else{
                savedLabel = [self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%%", 100*simRun.impactNeighbors] withConcernPosition:width +50 andyValue: (simRun.trialNum ) * 175 + 40];
            }
            
            [ImpactNeighborsLabels addObject:savedLabel];
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.impactNeighbors);
            [scoreVisVals addObject:[NSNumber numberWithFloat: currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.impactNeighbors)]];
            [scoreVisNames addObject: currentVar.name];
        } else if ([currentVar.name compare: @"neighborImpactingMe"] == NSOrderedSame){
            
            if (!_StaticNormalization.isOn){
                savedLabel = [self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%%", 100*simRunNormal.neighborsImpactMe] withConcernPosition:width + 50 andyValue: (simRun.trialNum)*175 + 40];
            }
            else{
                savedLabel = [self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%%", 100*simRun.neighborsImpactMe] withConcernPosition:width + 50 andyValue: (simRun.trialNum)*175 + 40];
            }
    
            [NeighborsImpactMeLabels addObject:savedLabel];
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * ( simRunNormal.neighborsImpactMe);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * ( simRunNormal.neighborsImpactMe)]];
            [scoreVisNames addObject: currentVar.name];
        } else if ([currentVar.name compare: @"groundwaterInfiltration"] == NSOrderedSame){
            
            if (!_StaticNormalization.isOn){
                savedLabel = [self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%%", 100*simRunNormal.infiltration] withConcernPosition:width + 50 andyValue: (simRun.trialNum)* 175 + 40 ];
            }
            else{
                savedLabel = [self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%%", 100*simRun.infiltration] withConcernPosition:width + 50 andyValue: (simRun.trialNum)* 175 + 40 ];
            }
            
            [gw_infiltration_Labels addObject:savedLabel];
            
            scoreTotal += (currentVar.currentConcernRanking/priorityTotal) * (simRunNormal.infiltration );
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * ( simRunNormal.infiltration )]];
            [scoreVisNames addObject: currentVar.name];
        } else if([currentVar.name compare:@"puddleTime"] == NSOrderedSame){
            FebTestWaterDisplay * wd;
            //NSLog(@"%d, %d", waterDisplays.count, i);
            if(waterDisplays.count <= trial){
                //NSLog(@"Drawing water display for first time");
                wd = [[FebTestWaterDisplay alloc] initWithFrame:CGRectMake(width + 10, (simRun.trialNum)*175 + 40, 115, 125) andContent:simRun.standingWater];
                wd.view = _dataWindow;
                [waterDisplays addObject:wd];
            } else {
                wd = [waterDisplays objectAtIndex:trial];
                wd.frame = CGRectMake(width + 10, (simRun.trialNum)*175 + 40, 115, 125);
            }
            wd.thresholdValue = thresh;
            [wd fastUpdateView: _hoursAfterStorm.value];
            
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.floodedStreets);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1- simRunNormal.floodedStreets)]];
            [scoreVisNames addObject: currentVar.name];
            
        }else if([currentVar.name compare:@"puddleMax"] == NSOrderedSame){
            //display window for maxHeights
            FebTestWaterDisplay * mwd;
            if(maxWaterDisplays.count <= trial){
                mwd  = [[FebTestWaterDisplay alloc] initWithFrame:CGRectMake(width + 10, (simRun.trialNum)*175 + 40, 115, 125) andContent:simRun.maxWaterHeights];
                mwd.view = _dataWindow;
                [maxWaterDisplays addObject:mwd];
            } else {
                mwd = [maxWaterDisplays objectAtIndex:trial];
                mwd.frame = CGRectMake(width + 10, (simRun.trialNum)*175 + 40, 115, 125);
            }
            mwd.thresholdValue = thresh;
            [mwd updateView:48];
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.standingWater);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1- simRunNormal.standingWater)]];
            [scoreVisNames addObject: currentVar.name];

        } else if ([currentVar.name compare: @"capacity"] == NSOrderedSame){
            AprilTestEfficiencyView *ev;
            if( efficiency.count <= trial){
                //NSLog(@"Drawing efficiency display for first time");
            ev = [[AprilTestEfficiencyView alloc] initWithFrame:CGRectMake(width, (simRun.trialNum )*175 + 40, 130, 150) withContent: simRun.efficiency];
                ev.trialNum = i;
                ev.view = _dataWindow;
                [efficiency addObject:ev];
            } else {
                //NSLog(@"Repositioning efficiency display");
                ev = [efficiency objectAtIndex:trial];
                ev.frame = CGRectMake(width, (simRun.trialNum )*175 + 40, 130, 150);
            }
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal *  simRunNormal.efficiency;
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal *  simRunNormal.efficiency]];
            //NSLog(@"%@", NSStringFromCGRect(ev.frame));
            [scoreVisNames addObject: currentVar.name];
            
            [ev updateViewForHour: _hoursAfterStorm.value];
            
        } else if ([currentVar.name compare: @"efficiencyOfIntervention"] == NSOrderedSame){
            [self drawTextBasedVar: [NSString stringWithFormat:@"$/Gallon Spent: $%.2f", simRun.dollarsGallons  ] withConcernPosition:width + 25 andyValue: (simRun.trialNum * 175) + 40];
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * 1;
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * 0]];
            [scoreVisNames addObject:currentVar.name];
        }

        width+= currentVar.widthOfVisualization;
        if (currentVar.widthOfVisualization > 0) visibleIndex++;
    }
    //border around component score
    UILabel *fullValueBorder = [[UILabel alloc] initWithFrame:CGRectMake(148, (simRun.trialNum)*175 + 88,  114, 26)];
    fullValueBorder.backgroundColor = [UIColor grayColor];
    UILabel *fullValue = [[UILabel alloc] initWithFrame:CGRectMake(150, (simRun.trialNum)*175 + 90,  110, 22)];
    fullValue.backgroundColor = [UIColor whiteColor];
    [_mapWindow addSubview:fullValueBorder];
    [_mapWindow addSubview:fullValue];
    //NSLog(@" %@", scoreVisVals);
    float maxX = 150;
    float totalScore = 0;
    
    //computing and drawing the final component score
    for(int i =  0; i < scoreVisVals.count; i++){
        float scoreWidth = [[scoreVisVals objectAtIndex: i] floatValue] * 100;
        if (scoreWidth < 0) scoreWidth = 0.0;
        totalScore += scoreWidth;
          UILabel * componentScore = [[UILabel alloc] initWithFrame:CGRectMake(maxX, (simRun.trialNum)*175 + 90, floor(scoreWidth), 22)];
        componentScore.backgroundColor = [scoreColors objectForKey:[scoreVisNames objectAtIndex:i]];
        [_mapWindow addSubview:componentScore];
        maxX+=floor(scoreWidth);
    }

    
    [_dataWindow setContentSize:CGSizeMake(width+=100, (simRun.trialNum+1)*200)];
    for(UILabel * bgCol in bgCols){
        if(_dataWindow.contentSize.height > _dataWindow.frame.size.height){
            [bgCol setFrame: CGRectMake(bgCol.frame.origin.x, bgCol.frame.origin.y, bgCol.frame.size.width, _dataWindow.contentSize.height + 100)];
        }else {
            [bgCol setFrame: CGRectMake(bgCol.frame.origin.x, bgCol.frame.origin.y, bgCol.frame.size.width, _dataWindow.frame.size.height + 100)];
        }
    }
    
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 175*(trial) + 50, 0, 0)];
    //scoreLabel.text = [NSString stringWithFormat:  @"Score: %.0f / 100", totalScore];
    scoreLabel.text = @"Performance:";
    scoreLabel.font = [UIFont systemFontOfSize:14.0];
    [scoreLabel sizeToFit];
    scoreLabel.textColor = [UIColor blackColor];
    [_mapWindow addSubview:scoreLabel];
    UILabel *scoreLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(150, 175*(trial) + 75, 0, 0)];
    scoreLabel2.text = [NSString stringWithFormat:  @"Broken down by source:"];
    scoreLabel2.font = [UIFont systemFontOfSize:10.0];
    [scoreLabel2 sizeToFit];
    scoreLabel2.textColor = [UIColor blackColor];
    [_mapWindow addSubview:scoreLabel2];
    
    
    [_dataWindow flashScrollIndicators];          
    
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
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGPoint rect = self.mapWindow.contentOffset;
    CGPoint rect2 = self.dataWindow.contentOffset;
    
    if (movedUp)
    {
        
        originalOffset = rect.y;
        rect.y += (edittingTX.frame.origin.y + _mapWindow.contentOffset.y) - 225;
        rect2.y = rect.y;
    }
    else
    {
        // revert back to the normal state.
        rect.y = originalOffset;
        rect2.y = originalOffset;

    }
    self.mapWindow.contentOffset = rect;
    self.dataWindow.contentOffset = rect2;
    
    [UIView commitAnimations];
}

//Draws Labels to set on the dataWindo Scrollview but also returns object to be added into a MutableArray (used for updating labels)
-(UILabel*) drawTextBasedVar: (NSString *) outputValue withConcernPosition: (int) concernPos andyValue: (int) yValue{
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.text = outputValue;
    valueLabel.frame =CGRectMake(concernPos, yValue, 0, 0);
    [valueLabel sizeToFit ];
    valueLabel.font = [UIFont systemFontOfSize:14.0];
    valueLabel.textColor = [UIColor blackColor];
    [[self dataWindow] addSubview:valueLabel];
    
    return valueLabel;
}

-(void) drawTitles{
    int width = 0;

    NSArray *sortedArray = [_currentConcernRanking sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSInteger first = [(AprilTestVariable*)a currentConcernRanking];
        NSInteger second = [(AprilTestVariable*)b currentConcernRanking];
        if(first > second) return NSOrderedAscending;
        else return NSOrderedDescending;
    }];
    
    int visibleIndex = 0;
    for(int i = 0 ; i <_currentConcernRanking.count ; i++){

        AprilTestVariable * currentVar =[sortedArray objectAtIndex:i];
        UILabel * currentVarLabel = [[UILabel alloc] init];
        currentVarLabel.backgroundColor = [scoreColors objectForKey:currentVar.name];
        currentVarLabel.frame = CGRectMake(width, 2, currentVar.widthOfVisualization, 40);
        currentVarLabel.font = [UIFont boldSystemFontOfSize:15.3];
        if([currentVar.name compare: @"publicCost"] == NSOrderedSame){
            currentVarLabel.text = @"  Investment";
        } else if ([currentVar.name compare: @"privateCost"] == NSOrderedSame){
            currentVarLabel.text =@"  Damage Reduction";
        } else if ([currentVar.name compare: @"impactingMyNeighbors"] == NSOrderedSame){
            currentVarLabel.text =@"  Impact on my Neighbors";
        } else if ([currentVar.name compare: @"neighborImpactingMe"] == NSOrderedSame){
            currentVarLabel.text=@"  Rainwater from Neighbors";
        } else if ([currentVar.name compare: @"efficiencyOfIntervention"] == NSOrderedSame){
            currentVarLabel.text =@"  Efficiency of Intervention";
        } else if ([currentVar.name compare:@"puddleTime"] == NSOrderedSame){
            currentVarLabel.text = @"  Water Depth Over Storm";
        } else if( [currentVar.name compare:@"groundwaterInfiltration"] == NSOrderedSame){
            currentVarLabel.text = @"  Groundwater Infiltration";
        } else if( [currentVar.name compare:@"puddleMax"] == NSOrderedSame){
            currentVarLabel.text = @"  Maximum Flooded Area";
        } else if( [currentVar.name compare:@"capacity"] == NSOrderedSame){
            currentVarLabel.text = @"  Intervention Capacity";
        }
        else {
            currentVarLabel = NULL;
        }
        if(currentVar.widthOfVisualization != 0) visibleIndex++;
        
        if(currentVarLabel != NULL){
        [_titleWindow addSubview:currentVarLabel];
        }
        width+= currentVar.widthOfVisualization;
    }
    
    [_dataWindow setContentSize: CGSizeMake(width + 10, _dataWindow.contentSize.height)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if([scrollView isEqual:_dataWindow]) {
        CGPoint offset = _mapWindow.contentOffset;
        offset.y = _dataWindow.contentOffset.y;
        CGPoint titleOffset = _titleWindow.contentOffset;
        titleOffset.x = _dataWindow.contentOffset.x;
        [_titleWindow setContentOffset:titleOffset];
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

//updted so that it only updates the slider for hours after storm
- (IBAction)sliderChanged:(id)sender {
    
    NSMutableString * content = [NSMutableString alloc];
   
    int hoursAfterStorm = floorf(_hoursAfterStorm.value);
    if (hoursAfterStorm % 2 != 0) hoursAfterStorm--;
    _hoursAfterStorm.value = hoursAfterStorm;
    _hoursAfterStormLabel.text = [NSString stringWithFormat:@"%d hours", hoursAfterStorm];
    [_hoursAfterStormLabel sizeToFit];
    for(int i = 0; i < waterDisplays.count; i++){
        FebTestWaterDisplay * temp = (FebTestWaterDisplay *) [waterDisplays objectAtIndex:i];
        AprilTestEfficiencyView * temp2 = (AprilTestEfficiencyView *)[efficiency objectAtIndex:i];
        FebTestWaterDisplay * tempHeights = (FebTestWaterDisplay *) [maxWaterDisplays objectAtIndex: i];
        [temp2 updateViewForHour:hoursAfterStorm];
        //[temp updateView:hoursAfterStorm];
        [temp fastUpdateView:hoursAfterStorm];
        [tempHeights updateView:48];
    }

    [_hoursAfterStorm setEnabled:TRUE];
    [_mapWindow setScrollEnabled:TRUE];
    [_dataWindow setScrollEnabled:TRUE];
    [_titleWindow setScrollEnabled:TRUE];
    [_loadingIndicator stopAnimating];
    NSDate *myDate = [[NSDate alloc] init];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    NSString *prettyVersion = [dateFormat stringFromDate:myDate];
    
    if(sender == _hoursAfterStorm){
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
    }

}




- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
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
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        tView.frame = CGRectMake(0, 0, 250, 30);
        tView.font = [UIFont boldSystemFontOfSize:15.0];

    }
    tView.text = [arrStatus objectAtIndex:row];
    // Fill the label text here

    return tView;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {

    return [arrStatus objectAtIndex:row];
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 250;
    
    return sectionWidth;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    int rowHeight = 20;
    return rowHeight;
}


@end

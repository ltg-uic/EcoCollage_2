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

@interface SocialViewController ()
@end

@implementation SocialViewController

@synthesize studyNum = _studyNum;
@synthesize profilesWindow = _profilesWindow;
@synthesize usernamesWindow = _usernamesWindow;
@synthesize trialNumber = _trialNumber;
@synthesize BudgetSlider = _BudgetSlider;
@synthesize StormPlayBack = _StormPlayBack;

NSMutableDictionary *concernColors;
NSMutableDictionary *concernNames;
NSMutableDictionary *scoreColors;
NSMutableArray *OverBudgetLabels;
int widthOfTitleVisualization = 220;
int heightOfVisualization = 200;
int dynamic_cd_width = 0;
int maxBudget;
float min_budget = 100000;
float max_budget = 700000;
UILabel *budgetLabel;



- (void)viewDidLoad {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    _studyNum = tabControl.studyNum;
    
    self.trialNumber.delegate = self;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleProfileUpdate)
                                                 name:@"profileUpdate"
                                               object:nil];
    
    
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
                    [UIColor colorWithHue:.55 saturation:.8 brightness:.9 alpha: 0.5], nil]  forKeys: [[NSArray alloc] initWithObjects: @"Investment", @"publicCostI", @"publicCostM", @"publicCostD", @"Damage Reduction", @"privateCostI", @"privateCostM", @"privateCostD",  @"Efficiency of Intervention ($/Gallon)", @"Water Depth Over Time", @"Maximum Flooded Area", @"Groundwater Infiltration", @"Impact on my Neighbors", @"Capacity Used", nil] ];
    
    concernNames = [[NSMutableDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects: @"publicCost", @"privateCost", @"efficiencyOfIntervention", @"capacity", @"puddleTime", @"puddleMax", @"groundwaterInfiltration", @"impactingMyNeighbors", nil] forKeys:[[NSArray alloc] initWithObjects:@"Investment", @"Damage Reduction", @"Efficiency of Intervention ($/Gallon)", @"Capacity Used", @"Water Depth Over Time", @"Maximum Flooded Area", @"Groundwater Infiltration", @"Impact on my Neighbors", nil]];
    
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
    
    
    OverBudgetLabels    = [[NSMutableArray alloc] init];
    
    
    [self drawMinMaxSliderLabels];
    _BudgetSlider.minimumValue = min_budget;
    _BudgetSlider.maximumValue = max_budget;
    [_BudgetSlider addTarget:self action:@selector(BudgetChanged:) forControlEvents:UIControlEventValueChanged];
    [self BudgetChanged:_BudgetSlider];
    
    _profilesWindow.delegate = self;
    _usernamesWindow.delegate = self;
    
    _profilesWindow.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _profilesWindow.layer.borderWidth = 1.0;
    
}


-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// release notification if view is unloaded for memory purposes
- (void) viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleProfileUpdate)
                                                 name:@"profileUpdate"
                                               object:nil];
    
    [self handleProfileUpdate];
}


- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)handleProfileUpdate {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];

    // then load other user profiles
    for (UIView *view in [_profilesWindow subviews]){
        [view removeFromSuperview];
    }
    
    // load profile usernames
    [self loadUsernames];
    
    
    int amountOfProfilesLoaded = 0;
    int height = 0;
    int overallWidth = widthOfTitleVisualization * 8;
    
    for (NSArray *profileArray in tabControl.profiles) {
        int width = 0;
        // load concerns in order
        for (int i = 3; i < profileArray.count; i++) {
            UILabel *currentLabel = [[UILabel alloc]init];
            currentLabel.backgroundColor = [concernColors objectForKey:[profileArray objectAtIndex:i]];
            currentLabel.frame = CGRectMake(width, amountOfProfilesLoaded * heightOfVisualization + 2, widthOfTitleVisualization, 40);
            currentLabel.font = [UIFont boldSystemFontOfSize:15.3];
        
            if([[profileArray objectAtIndex:i] isEqualToString:@"Investment"])
                currentLabel.text = @"  Investment";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Damage Reduction"])
                currentLabel.text = @"  Damage Reduction";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Efficiency of Intervention ($/Gallon)"])
                currentLabel.text = @"  Efficiency of Intervention";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Capacity Used"])
                currentLabel.text = @"  Intervention Capacity";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Water Depth Over Time"])
                currentLabel.text = @"  Water Depth Over Storm";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Maximum Flooded Area"])
                currentLabel.text = @"  Maximum Flooded Area";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Groundwater Infiltration"])
                currentLabel.text = @"  Groundwater Infiltration";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Impact on my Neighbors"])
                currentLabel.text = @"  Impact on my Neighbors";
            else {
                currentLabel = NULL;
            }
        
            if(currentLabel != NULL){
                [_profilesWindow addSubview:currentLabel];
                width += widthOfTitleVisualization;
            }
        }
            
        amountOfProfilesLoaded++;
        height += heightOfVisualization;

    }
    
    [_profilesWindow setContentSize: CGSizeMake(overallWidth + 10, height)];
    
    // draw trial for each user
    for (int i = 0; i < tabControl.profiles.count; i++) {
        [self drawTrial:_trialNumber.text.integerValue withProfileIndex:i];
    }
    
}



- (void)loadUsernames {
    // remove all labels
    for (UIView *view in [_usernamesWindow subviews]) {
        [view removeFromSuperview];
    }
    
    int height = 0;
    
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];

    int numberOfUsernames = 0;
    
    // loop through other profiles and load their name labels
    for (NSArray *profile in tabControl.profiles) {
        UILabel *nameLabel = [[UILabel alloc]init];
        nameLabel.backgroundColor = [UIColor whiteColor];
        nameLabel.frame = CGRectMake(0, numberOfUsernames * heightOfVisualization + 2, _usernamesWindow.frame.size.width, 40);
        nameLabel.font = [UIFont boldSystemFontOfSize:15.3];
        if ([profile isEqual:tabControl.ownProfile])
            nameLabel.text = [NSString stringWithFormat:@"  %@ (You)", [profile objectAtIndex:2]];
        else
            nameLabel.text = [NSString stringWithFormat:@"  %@", [profile objectAtIndex:2]];
        if(nameLabel != NULL) {
            [_usernamesWindow addSubview:nameLabel];
            numberOfUsernames++;
            height += heightOfVisualization;
        }
    }
    
    [_usernamesWindow setContentSize: CGSizeMake(_usernamesWindow.contentSize.width, height)];
}


- (void)drawTrial:(int) trial withProfileIndex:(int) profileIndex {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    
    // error checking
    if ([tabControl.profiles count] < profileIndex + 1)
        return;
    
    // make sure trial asked for is loaded
    if ([tabControl.trialRuns count] < trial + 1)
        return;

    // first, draw the FebTestIntervention in usernames window
    AprilTestSimRun *simRun = [tabControl.trialRuns objectAtIndex:trial];
    AprilTestNormalizedVariable *simRunNormal = [tabControl.trialRunsNormalized objectAtIndex:trial];
    FebTestIntervention *interventionView = [[FebTestIntervention alloc] initWithPositionArray:simRun.map andFrame:(CGRectMake(20, 40, 115, 125))];
    interventionView.view = [[_usernamesWindow subviews] objectAtIndex:profileIndex];
    [interventionView updateView];

    
    NSMutableArray *currentConcernRanking = [[NSMutableArray alloc]init];
    NSArray *currentProfile = [[NSArray alloc]init];
    currentProfile = [tabControl.profiles objectAtIndex:profileIndex];

    for (int i = 3; i < [currentProfile count]; i++) {
        [currentConcernRanking addObject:[[AprilTestVariable alloc] initWith:[concernNames objectForKey:[currentProfile objectAtIndex:i]] withDisplayName:[currentProfile objectAtIndex: i] withNumVar:1 withWidth:widthOfTitleVisualization withRank:9-i]];
    }
    
    float priorityTotal= 0;
    float scoreTotal = 0;
    for(int i = 0; i < currentConcernRanking.count; i++){
        
        priorityTotal += [(AprilTestVariable *)[currentConcernRanking objectAtIndex:i] currentConcernRanking];
    }

    
    int width = 0;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    
    NSArray *sortedArray = [currentConcernRanking sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSInteger first = [(AprilTestVariable*)a currentConcernRanking];
        NSInteger second = [(AprilTestVariable*)b currentConcernRanking];
        if(first > second) return NSOrderedAscending;
        else return NSOrderedDescending;
    }];
    NSMutableArray *scoreVisVals = [[NSMutableArray alloc] init];
    NSMutableArray *scoreVisNames = [[NSMutableArray alloc] init];
    AprilTestCostDisplay *cd;
    int visibleIndex = 0;
    
    for(int i = 0 ; i < currentConcernRanking.count ; i++){
        
        AprilTestVariable * currentVar =[sortedArray objectAtIndex:i];
        
        //laziness: this is just the investment costs
        if([currentVar.name compare: @"publicCost"] == NSOrderedSame){
            float investmentInstall = simRun.publicInstallCost;
            float investmentMaintain = simRun.publicMaintenanceCost;
            float investmentInstallN = simRunNormal.publicInstallCost;
            float investmentMaintainN = simRunNormal.publicMaintenanceCost;
            dynamic_cd_width = [self getWidthFromSlider:_BudgetSlider toValue:maxBudget];
            CGRect frame = CGRectMake(width + 25, profileIndex*heightOfVisualization + 60, dynamic_cd_width, 30);
            
            
            //NSLog(@"Drawing water display for first time");
            
            //cd = [[AprilTestCostDisplay alloc] initWithCost:investmentInstall andMaxBudget:maxBudget andbudgetLimit:max_budget_limit  andScore:investmentInstallN andFrame:CGRectMake(width + 25, profileIndex*heightOfVisualization + 60, dynamic_cd_width, 30)];
            
            float costWidth = [self getWidthFromSlider:_BudgetSlider toValue:simRun.publicInstallCost];
            float maxBudgetWidth = [self getWidthFromSlider:_BudgetSlider toValue:maxBudget];
            
            cd = [[AprilTestCostDisplay alloc] initWithCost:investmentInstall normScore:investmentInstallN costWidth:costWidth maxBudgetWidth:maxBudgetWidth andFrame:frame];
            
            [_profilesWindow addSubview: cd];
            
            //checks if over budget, if so, prints warning message
            if (simRun.publicInstallCost > maxBudget){
                //store update labels for further use (updating over budget when using absolute val)
                
                UILabel *valueLabel;
                [self drawTextBasedVar:[NSString stringWithFormat: @"Over budget: $%@", [formatter stringFromNumber: [NSNumber numberWithInt: (int) (investmentInstall-maxBudget)]] ] withConcernPosition:width+25 andyValue:profileIndex *heightOfVisualization + 100 andColor:[UIColor redColor] to:&valueLabel];
                
                [OverBudgetLabels addObject:valueLabel];
            }
            
            
             [self drawTextBasedVar: [NSString stringWithFormat:@"Maintenance Cost: $%@", [formatter stringFromNumber: [NSNumber numberWithInt:investmentMaintain ]]] withConcernPosition:width + 25 andyValue: (profileIndex * heightOfVisualization) +120 andColor:[UIColor blackColor] to:nil];
            
            
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
            
            
            [self drawTextBasedVar: [NSString stringWithFormat:@"Rain Damage: $%@", [formatter stringFromNumber: [NSNumber numberWithInt:simRun.privateDamages]]] withConcernPosition:width + 25 andyValue: (profileIndex*heightOfVisualization) +60 andColor:[UIColor blackColor] to:nil];
            [self drawTextBasedVar: [NSString stringWithFormat:@"Damaged Reduced by: %@%%", [formatter stringFromNumber: [NSNumber numberWithInt: 100 -(int)(100*simRunNormal.privateDamages)]]] withConcernPosition:width + 25 andyValue: (profileIndex*heightOfVisualization) +90 andColor:[UIColor blackColor] to:nil];
            [self drawTextBasedVar: [NSString stringWithFormat:@"Sewer Load:%.2f%%", 100*simRun.neighborsImpactMe] withConcernPosition:width + 25 andyValue: (profileIndex ) * heightOfVisualization + 120 andColor:[UIColor blackColor] to:nil];
            
            
            scoreTotal += (currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.privateDamages) + currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.neighborsImpactMe)) /2;
            
            //add values for the score visualization
            
            [scoreVisVals addObject:[NSNumber numberWithFloat:(currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.privateDamages) + currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.neighborsImpactMe)) /2]];
            //scoreTotal +=currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.privateDamages);
            //[scoreVisVals addObject: [NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.privateDamages)]];
            [scoreVisNames addObject: @"privateCostD"];
            
        } else if ([currentVar.name compare: @"impactingMyNeighbors"] == NSOrderedSame){
            
            
            [self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%% of rainwater", 100*simRun.impactNeighbors] withConcernPosition:width + 30 andyValue: (profileIndex ) * heightOfVisualization + 60 andColor:[UIColor blackColor] to:nil];
            [self drawTextBasedVar: [NSString stringWithFormat:@" run-off to neighbors"] withConcernPosition:width + 30 andyValue: (profileIndex ) * heightOfVisualization + 75 andColor:[UIColor blackColor] to:nil];
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.impactNeighbors);
            [scoreVisVals addObject:[NSNumber numberWithFloat: currentVar.currentConcernRanking/priorityTotal * (1-simRunNormal.impactNeighbors)]];
            [scoreVisNames addObject: currentVar.name];
        }  else if ([currentVar.name compare: @"neighborImpactingMe"] == NSOrderedSame){
            
            
            [self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%%", 100*simRun.neighborsImpactMe] withConcernPosition:width + 50 andyValue: (profileIndex)*heightOfVisualization + 60 andColor:[UIColor blackColor] to:nil];
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * ( simRunNormal.neighborsImpactMe);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * ( simRunNormal.neighborsImpactMe)]];
            [scoreVisNames addObject: currentVar.name];
        } else if ([currentVar.name compare: @"groundwaterInfiltration"] == NSOrderedSame){
            
            
            [self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%% of rainwater was", 100*simRun.infiltration] withConcernPosition:width + 30 andyValue: (profileIndex)* heightOfVisualization + 60 andColor:[UIColor blackColor] to:nil];
            [self drawTextBasedVar: [NSString stringWithFormat:@" infiltrated by the swales"] withConcernPosition:width + 30 andyValue: (profileIndex)* heightOfVisualization + 75  andColor:[UIColor blackColor] to:nil];
            
            scoreTotal += (currentVar.currentConcernRanking/priorityTotal) * (simRunNormal.infiltration );
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * ( simRunNormal.infiltration )]];
            [scoreVisNames addObject: currentVar.name];
        } else if([currentVar.name compare:@"puddleTime"] == NSOrderedSame){
            /*
            FebTestWaterDisplay * wd;
            //NSLog(@"%d, %d", waterDisplays.count, i);
            if(waterDisplays.count <= trial){
                //NSLog(@"Drawing water display for first time");
                wd = [[FebTestWaterDisplay alloc] initWithFrame:CGRectMake(width + 10, (profileIndex)*heightOfVisualization + 60, 115, 125) andContent:simRun.standingWater];
                wd.view = _dataWindow;
                [waterDisplays addObject:wd];
            } else {
                wd = [waterDisplays objectAtIndex:trial];
                wd.frame = CGRectMake(width + 10, (profileIndex)*heightOfVisualization + 60, 115, 125);
            }
            wd.thresholdValue = thresh;
            [wd fastUpdateView: StormPlayBack.value];
            
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.floodedStreets);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1- simRunNormal.floodedStreets)]];
            [scoreVisNames addObject: currentVar.name];
             */
            
        } else if([currentVar.name compare:@"puddleMax"] == NSOrderedSame){
            /*
            //display window for maxHeights
            FebTestWaterDisplay * mwd;
            if(maxWaterDisplays.count <= trial){
                mwd  = [[FebTestWaterDisplay alloc] initWithFrame:CGRectMake(width + 10, (profileIndex)*heightOfVisualization + 60, 115, 125) andContent:simRun.maxWaterHeights];
                mwd.view = _dataWindow;
                [maxWaterDisplays addObject:mwd];
            } else {
                mwd = [maxWaterDisplays objectAtIndex:trial];
                mwd.frame = CGRectMake(width + 10, (profileIndex)*heightOfVisualization + 60, 115, 125);
            }
            mwd.thresholdValue = thresh;
            [mwd updateView:48];
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.standingWater);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1- simRunNormal.standingWater)]];
            [scoreVisNames addObject: currentVar.name];
            */
        } else if ([currentVar.name compare: @"capacity"] == NSOrderedSame){
            /*
            AprilTestEfficiencyView *ev;
            if( efficiency.count <= trial){
                //NSLog(@"Drawing efficiency display for first time");
                ev = [[AprilTestEfficiencyView alloc] initWithFrame:CGRectMake(width, (profileIndex )*heightOfVisualization + 60, 130, 150) withContent: simRun.efficiency];
                ev.trialNum = i;
                ev.view = _dataWindow;
                [efficiency addObject:ev];
            } else {
                //NSLog(@"Repositioning efficiency display");
                ev = [efficiency objectAtIndex:trial];
                ev.frame = CGRectMake(width, (profileIndex )*heightOfVisualization + 60, 130, 150);
            }
            
            scoreTotal += currentVar.currentConcernRanking/priorityTotal *  simRunNormal.efficiency;
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal *  simRunNormal.efficiency]];
            //NSLog(@"%@", NSStringFromCGRect(ev.frame));
            [scoreVisNames addObject: currentVar.name];
            
            [ev updateViewForHour: StormPlayBack.value];
            */
        } else if ([currentVar.name compare: @"efficiencyOfIntervention"] == NSOrderedSame){
            [self drawTextBasedVar: [NSString stringWithFormat:@"$/Gallon Spent: $%.2f", simRun.dollarsGallons  ] withConcernPosition:width + 25 andyValue: (profileIndex * heightOfVisualization) + 60 andColor: [UIColor blackColor] to:nil];
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * 1;
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * 0]];
            [scoreVisNames addObject:currentVar.name];
        }
        
        width+= currentVar.widthOfVisualization;
        if (currentVar.widthOfVisualization > 0) visibleIndex++;
    }
    //border around component score
    UILabel *fullValueBorder = [[UILabel alloc] initWithFrame:CGRectMake(148, (profileIndex)*heightOfVisualization + 88,  114, 26)];
    fullValueBorder.backgroundColor = [UIColor grayColor];
    UILabel *fullValue = [[UILabel alloc] initWithFrame:CGRectMake(150, (profileIndex)*heightOfVisualization + 90,  110, 22)];
    fullValue.backgroundColor = [UIColor whiteColor];
    [_usernamesWindow addSubview:fullValueBorder];
    [_usernamesWindow addSubview:fullValue];
    //NSLog(@" %@", scoreVisVals);
    float maxX = 150;
    float totalScore = 0;
    UILabel * componentScore;
    
    //computing and drawing the final component score
    for(int i =  0; i < scoreVisVals.count; i++){
        float scoreWidth = [[scoreVisVals objectAtIndex: i] floatValue] * 100;
        if (scoreWidth < 0) scoreWidth = 0.0;
        totalScore += scoreWidth;
        componentScore = [[UILabel alloc] initWithFrame:CGRectMake(maxX, (profileIndex)*heightOfVisualization + 90, floor(scoreWidth), 22)];
        componentScore.backgroundColor = [scoreColors objectForKey:[scoreVisNames objectAtIndex:i]];
        [_usernamesWindow addSubview:componentScore];
        maxX+=floor(scoreWidth);
    }
    
    [_profilesWindow setContentSize:CGSizeMake(width+=20, (profileIndex+1)*200)];
    
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, heightOfVisualization*(profileIndex) + 50, 0, 0)];
    //scoreLabel.text = [NSString stringWithFormat:  @"Score: %.0f / 100", totalScore];
    scoreLabel.text = @"Performance:";
    scoreLabel.font = [UIFont systemFontOfSize:14.0];
    [scoreLabel sizeToFit];
    scoreLabel.textColor = [UIColor blackColor];
    [_usernamesWindow addSubview:scoreLabel];
    UILabel *scoreLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(150, heightOfVisualization*(profileIndex) + 75, 0, 0)];
    scoreLabel2.text = [NSString stringWithFormat:  @"Broken down by source:"];
    scoreLabel2.font = [UIFont systemFontOfSize:10.0];
    [scoreLabel2 sizeToFit];
    scoreLabel2.textColor = [UIColor blackColor];
    [_usernamesWindow addSubview:scoreLabel2];
}



//Draws Labels to set on the dataWindow Scrollview but also returns object to be added into a MutableArray (used for updating labels)
-(void) drawTextBasedVar: (NSString *) outputValue withConcernPosition: (int) concernPos andyValue: (int) yValue andColor: (UIColor*) color to:(UILabel**) label{
    if (label != nil){
        *label = [[UILabel alloc] init];
        (*label).text = outputValue;
        (*label).frame =CGRectMake(concernPos, yValue, 0, 0);
        [*label sizeToFit ];
        (*label).font = [UIFont systemFontOfSize:14.0];
        (*label).textColor = color;
        [_profilesWindow addSubview:*label];
    }else
    {
        UILabel *valueLabel = [[UILabel alloc] init];
        valueLabel.text = outputValue;
        valueLabel.frame =CGRectMake(concernPos, yValue, 0, 0);
        [valueLabel sizeToFit ];
        valueLabel.font = [UIFont systemFontOfSize:14.0];
        valueLabel.textColor = color;
        [_profilesWindow addSubview:valueLabel];
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
    else
        return returnLocation;
}

//selector method that handles a change in value when budget changes (slider under titles)
-(void)BudgetChanged:(id)sender {
    UISlider *slider = (UISlider*)sender;
    int value = slider.value;
    //-- Do further actions
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    value = 1000.0 * floor((value/1000.0)+0.5);
    
    maxBudget = value;
    [self changeBudgetLabel:(int)maxBudget];
    
    //update the width of the public install cost bars (make sure it isn't 0)
    dynamic_cd_width = [self getWidthFromSlider:_BudgetSlider toValue:maxBudget];
    
    //only update all labels/bars if Static normalization is switched on
    [self handleProfileUpdate];
}


// synchronizes vertical scrolling between usersnamesWindow and profilesWindow
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

// calls textFieldDidEndEditing when done
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    
    // draw specific trial for all profiles
    if([textField isEqual:self.trialNumber]) {
        for (int i = 0; i < tabControl.profiles.count; i++)
            [self handleProfileUpdate];
    }
    
}


- (void)drawMinMaxSliderLabels {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    UILabel *minLabel = [[UILabel alloc]init];
    minLabel.text = [NSString stringWithFormat:@"$%@", [formatter stringFromNumber:[NSNumber numberWithInt:min_budget]]];
    minLabel.font = [UIFont systemFontOfSize:14.5];
    [minLabel sizeToFit];
    minLabel.frame = CGRectMake(_BudgetSlider.frame.origin.x - (minLabel.frame.size.width + 10), 663, minLabel.frame.size.width, minLabel.frame.size.height);
    [minLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:minLabel];
    
    UILabel *maxLabel = [[UILabel alloc]init];
    maxLabel.text = [NSString stringWithFormat:@"$%@", [formatter stringFromNumber:[NSNumber numberWithInt:max_budget]]];
    maxLabel.font = [UIFont systemFontOfSize:14.5];
    [maxLabel sizeToFit];
    maxLabel.frame = CGRectMake(_BudgetSlider.frame.origin.x + (_BudgetSlider.frame.size.width + 10), 663, maxLabel.frame.size.width, maxLabel.frame.size.height);
    [maxLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:maxLabel];
    
    budgetLabel = [[UILabel alloc]init];
    budgetLabel.text = [NSString stringWithFormat:@"Set Budget $%@", [formatter stringFromNumber:[NSNumber numberWithInt:min_budget]]];
    budgetLabel.font = [UIFont systemFontOfSize:14.5];
    [budgetLabel sizeToFit];
    budgetLabel.frame = CGRectMake(3 , 663, budgetLabel.frame.size.width, budgetLabel.frame.size.height);
    [budgetLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:budgetLabel];
}


- (void)changeBudgetLabel:(int)budget {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    budgetLabel.text = [NSString stringWithFormat:@"Set Budget $%@", [formatter stringFromNumber:[NSNumber numberWithInt:budget]]];
    [budgetLabel sizeToFit];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
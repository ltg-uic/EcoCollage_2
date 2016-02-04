//
//  StackedBarGraph.m
//  AprilTest
//
//  Created by Ryan Fogarty on 11/5/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import "StackedBarGraph.h"
#import "AprilTestSimRun.h"

@implementation StackedBarGraph

@synthesize stackedBars = _stackedBars;
@synthesize legendView = _legendView;
@synthesize scoreBarsView = _scoreBarsView;

AprilTestTabBarController *tabController;
NSMutableArray *trialGroups;
NSMutableArray *trialLabels;

NSMutableDictionary *scoreColors;

UILabel *investmentLegendLabel;
UILabel *damageReductionLegendLabel;
UILabel *waterFlowLegendLabel;
UILabel *capacityLegendLabel;
UILabel *efficiencyLegendLabel;
UILabel *impactLegendLabel;
UILabel *groundwaterLegendLabel;
UILabel *maxFloodLegendLabel;

NSMutableArray *legendLabels;

UIView *xAxis;
UIView *yAxis;
UILabel *bestForMe;
UILabel *worstForMe;
int bestTrialForMe;
int worstTrialForMe;

int widthOfBar = 36;

int barHeightMultiplier = 4;

#define screen_width 1052
#define legend_width 150
#define scoreBarsView_width 902

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame andTabController:(AprilTestTabBarController *)tabControl withContainers:(int)wC{
    if(tabControl.profiles.count == 0 || tabControl.trialRuns.count == 0) return NULL;
    
    
    UITapGestureRecognizer *resetCategories = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetAllCategories)];
    resetCategories.numberOfTapsRequired = 1;
    [self addGestureRecognizer:resetCategories];
    
    
    tabController = tabControl;
    self = [super initWithFrame:frame];
    _legendView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, legend_width, frame.size.height)];
    [_legendView.layer setBorderWidth:1];
    [_legendView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    _scoreBarsView = [[UIScrollView alloc] initWithFrame:CGRectMake(legend_width, 0, frame.size.width - legend_width, frame.size.height)];
    
    [self addSubview:_legendView];
    [self addSubview:_scoreBarsView];
    
    _stackedBars = [[NSMutableArray alloc]init];
    
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
    
    int investmentIndex = -1;
    int damageReductionIndex = -1;
    int efficiencyIndex = -1;
    int waterFlowIndex = -1;
    int maxFloodIndex = -1;
    int groundwaterInfiltrationIndex = -1;
    int impactIndex = -1;
    int capacityIndex = -1;
    
    // find order of the users concerns to be used when building the legend
    NSMutableArray *primaryUser = [tabControl.profiles objectAtIndex:0];
    for(int i = 3; i < primaryUser.count; i++) {
        if([[primaryUser objectAtIndex:i] isEqualToString:@"Investment"])
            investmentIndex = (int)primaryUser.count - (i + 1);
        if([[primaryUser objectAtIndex:i] isEqualToString:@"Damage Reduction"])
            damageReductionIndex = (int)primaryUser.count - (i + 1);
        if([[primaryUser objectAtIndex:i] isEqualToString:@"Efficiency of Intervention ($/Gallon)"])
            efficiencyIndex = (int)primaryUser.count - (i + 1);
        if([[primaryUser objectAtIndex:i] isEqualToString:@"Capacity Used"])
            capacityIndex = (int)primaryUser.count - (i + 1);
        if([[primaryUser objectAtIndex:i] isEqualToString:@"Water Flow Path"])
            waterFlowIndex = (int)primaryUser.count - (i + 1);
        if([[primaryUser objectAtIndex:i] isEqualToString:@"Maximum Flooded Area"])
            maxFloodIndex = (int)primaryUser.count - (i + 1);
        if([[primaryUser objectAtIndex:i] isEqualToString:@"Groundwater Infiltration"])
            groundwaterInfiltrationIndex = (int)primaryUser.count - (i + 1);
        if([[primaryUser objectAtIndex:i] isEqualToString:@"Impact on my Neighbors"])
            impactIndex = (int)primaryUser.count - (i + 1);
    }
    
    
    // REDUCING SCORE BY LOGARITHM OF AMOUNT OVER BUDGET
    
    NSMutableArray *allScores = [[NSMutableArray alloc]init];
    
    for(int i = 0; i < tabControl.trialRuns.count; i++) {
        AprilTestSimRun *simRun = [tabControl.trialRuns objectAtIndex:i];
        for(int j = 0; j < tabControl.profiles.count; j++) {
            
            NSMutableArray* score = [tabControl getScoreBarValuesForProfile:j forTrial:i isDynamicTrial:0];
            NSMutableArray* scoreVisVals = [score objectAtIndex:0];
            NSMutableArray* scoreVisNames = [score objectAtIndex:1];
            
            int setBudget = tabControl.budget;
            
            int investmentIndex = 0;
            for(int k = 0; k < scoreVisNames.count; k++) {
                if([[scoreVisNames objectAtIndex:k] isEqualToString:@"publicCostI"])
                    investmentIndex = k;
            }
            
            // calculate amount of budget for use in resizing each score
            int amountOverBudget = simRun.publicInstallCost - setBudget;
            
            //computing each score with log skew due to over-investment cost
            for(int k =  0; k < scoreVisVals.count; k++){
                
                float scoreWidth = [[scoreVisVals objectAtIndex: k] floatValue];
                if(amountOverBudget > 0) { // recalculate each score width

                    float modifier = (investmentIndex + 0.5) / (2 * log10(amountOverBudget));
                    if(modifier > 1) modifier = 1;
                    
                    scoreWidth *= modifier;
                }
                if (scoreWidth < 0) scoreWidth = 0.0;
                [scoreVisVals replaceObjectAtIndex:k withObject:[NSNumber numberWithFloat:scoreWidth]];
            }
            
            //[score replaceObjectAtIndex:0 withObject:scoreVisVals];
            NSMutableArray *newScore = [[NSMutableArray alloc]init];
            [newScore addObject:scoreVisVals];
            [newScore addObject:scoreVisNames];
            [allScores addObject:newScore];
        }
    }


    
    // fill this with the max scores for each outcome category over the span of all trials and all users
    //NSMutableArray *maxScores = [[NSMutableArray alloc]init];
    NSMutableArray *tierSizes = [[NSMutableArray alloc]init];
    
    /*
    int maxInvestment = 0, maxDamageReduction = 0, maxEfficiency = 0, maxCapacity = 0, maxWaterFlow = 0, maxMaxFlood = 0, maxGroundwaterInfiltration = 0, maxImpact = 0;
    */
     
    int tierArr[8] = {0, 0, 0, 0, 0, 0, 0, 0};
    
    
    // find max value for each tier
    for(int i = 0; i < tabControl.trialRuns.count; i++) {
        for(int j = 0; j < tabControl.profiles.count; j++) {
            NSMutableArray *score = [allScores objectAtIndex:i * j + j];
            NSMutableArray* scores = [tabControl getScoreBarValuesForProfile:j forTrial:i isDynamicTrial:0];
            NSMutableArray* scoreVisVals = [scores objectAtIndex:0];
            for(int k = 0; k < scoreVisVals.count; k++) {
                if([[scoreVisVals objectAtIndex:k] floatValue] * 100 > tierArr[k])
                    tierArr[k] = [[scoreVisVals objectAtIndex:k]floatValue] * 100;
            }
        }
    }
    
    
    /*
    // find the max value for each outcome category
    // this will determine the "height" for that category
    for(int i = 0; i < tabControl.trialRuns.count; i++) {
        for(int j = 0; j < tabControl.profiles.count; j++) {
            NSMutableArray* scores = [tabControl getScoreBarValuesForProfile:j forTrial:i isDynamicTrial:0];
            NSMutableArray* scoreVisVals = [scores objectAtIndex:0];
            NSMutableArray* scoreVisNames = [scores objectAtIndex:1];
            
            for(int k = 0; k < scoreVisNames.count; k++) {
                if([[scoreVisNames objectAtIndex:k] isEqualToString:@"publicCost"] && ([[scoreVisVals objectAtIndex:k] floatValue] * 100 > maxInvestment)) {
                    maxInvestment = [[scoreVisVals objectAtIndex:k]floatValue] * 100;
                }
                else if([[scoreVisNames objectAtIndex:k] isEqualToString:@"privateCostD"] && ([[scoreVisVals objectAtIndex:k] floatValue] * 100 > maxDamageReduction)) {
                    maxDamageReduction = [[scoreVisVals objectAtIndex:k] floatValue] * 100;
                }
                else if([[scoreVisNames objectAtIndex:k] isEqualToString:@"impactingMyNeighbors"] && ([[scoreVisVals objectAtIndex:k] floatValue] * 100 > maxImpact)) {
                    maxImpact = [[scoreVisVals objectAtIndex:k] floatValue] * 100;
                }
                else if([[scoreVisNames objectAtIndex:k] isEqualToString:@"groundwaterInfiltration"] && ([[scoreVisVals objectAtIndex:k] floatValue] * 100 > maxGroundwaterInfiltration)) {
                    maxGroundwaterInfiltration = [[scoreVisVals objectAtIndex:k] floatValue] * 100;
                }
                else if([[scoreVisNames objectAtIndex:k] isEqualToString:@"puddleTime"] && ([[scoreVisVals objectAtIndex:k] floatValue] * 100 > maxWaterFlow)) {
                    maxWaterFlow = [[scoreVisVals objectAtIndex:k] floatValue] * 100;
                }
                else if([[scoreVisNames objectAtIndex:k] isEqualToString:@"puddleMax"] && ([[scoreVisVals objectAtIndex:k] floatValue] * 100 > maxMaxFlood)) {
                    maxMaxFlood = [[scoreVisVals objectAtIndex:k] floatValue] * 100;
                }
                else if([[scoreVisNames objectAtIndex:k] isEqualToString:@"capacity"] && ([[scoreVisVals objectAtIndex:k] floatValue] * 100 > maxCapacity)) {
                    maxCapacity = [[scoreVisVals objectAtIndex:k] floatValue] * 100 ;
                }
                else if([[scoreVisNames objectAtIndex:k] isEqualToString:@"efficiencyOfIntervention"] && ([[scoreVisVals objectAtIndex:k] floatValue] * 100 > maxEfficiency)) {
                    maxEfficiency = [[scoreVisVals objectAtIndex:k] floatValue] * 100;
                }
            }
        }
    }

    
    // must be added in this specific order
    [maxScores addObject:[NSNumber numberWithInt:maxInvestment]];
    [maxScores addObject:[NSNumber numberWithInt:maxDamageReduction]];
    [maxScores addObject:[NSNumber numberWithInt:maxEfficiency]];
    [maxScores addObject:[NSNumber numberWithInt:maxCapacity]];
    [maxScores addObject:[NSNumber numberWithInt:maxWaterFlow]];
    [maxScores addObject:[NSNumber numberWithInt:maxMaxFlood]];
    [maxScores addObject:[NSNumber numberWithInt:maxGroundwaterInfiltration]];
    [maxScores addObject:[NSNumber numberWithInt:maxImpact]];
     */
    
    for(int i = 0; i < 8; i++) {
        [tierSizes addObject:[NSNumber numberWithInt:tierArr[i]]];
    }
    
    /*
    int sumMaxScores = maxInvestment + maxDamageReduction + maxEfficiency + maxCapacity + maxWaterFlow + maxMaxFlood + maxGroundwaterInfiltration + maxImpact;
    sumMaxScores *= barHeightMultiplier;
     */
    
    int sumTierSizes = 0;
    for(int i = 0; i < 8; i++) {
        sumTierSizes += tierArr[i];
    }
    sumTierSizes *= barHeightMultiplier;
    
    
    
    int x_initial = 10;
    int x = x_initial;
    int y = sumTierSizes + 100; // start at the bottom and work up
    int spaceBetweenTrials = 25;
    widthOfBar = (scoreBarsView_width - spaceBetweenTrials * tabControl.trialRuns.count) / (tabControl.trialRuns.count * tabControl.profiles.count + 2);
    int width = widthOfBar;
    
    
    // draw lines for x and y axis
    int xAxisLength = (width + 1) * tabControl.profiles.count * tabControl.trialRuns.count + spaceBetweenTrials * (tabControl.trialRuns.count - 1) + 50;
    xAxis = [[UIView alloc]initWithFrame:CGRectMake(x_initial, y, xAxisLength, 1)];
    [xAxis setBackgroundColor:[UIColor blackColor]];
    [_scoreBarsView addSubview:xAxis];
    
    
    int yAxisHeight = sumTierSizes + 70;
    yAxis = [[UIView alloc]initWithFrame:CGRectMake(x_initial, y - yAxisHeight, 1, yAxisHeight)];
    [yAxis setBackgroundColor:[UIColor blackColor]];
    [_scoreBarsView addSubview:yAxis];
    
    trialGroups = [[NSMutableArray alloc]init];
    
    NSMutableArray *trialScores = [[NSMutableArray alloc]init];

    // create a stackedBar for each trial for each profile
    for(int i = 0; i < tabControl.trialNum; i++) {
        
        NSMutableArray *trialGroup = [[NSMutableArray alloc]init];
        
        for(int j = 0; j < tabControl.profiles.count; j++) {
            NSMutableArray* scores = [tabControl getScoreBarValuesForProfile:j forTrial:i isDynamicTrial:0];
            NSMutableArray *score = [allScores objectAtIndex:i * j + j];
            
            float *totalScore = malloc(sizeof(float));
            *totalScore = 0.0;
            
            StackedBar *bar = [[StackedBar alloc]initWithFrame:CGRectMake(x, y, width, - sumTierSizes) andProfile:[tabControl.profiles objectAtIndex:j] andScores:scores andScaleSize:1 andTierSizes:tierSizes withContainers:wC withHeightMultipler:barHeightMultiplier withScore:totalScore trialNum:i];
            
            [trialScores addObject:[NSNumber numberWithFloat:*totalScore]];
            free(totalScore);
            
            [bar.name setFrame:CGRectMake(x, yAxis.frame.origin.y + yAxis.frame.size.height, width, 20)];
            [_scoreBarsView addSubview:bar.name];
            
            if(bar.hasContainers) {
                for(UIView *container in bar.outcomeCategoryContainers) {
                    UITapGestureRecognizer *resetCategories = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetAllCategories)];
                    resetCategories.numberOfTapsRequired = 2;
                    [container addGestureRecognizer:resetCategories];
                }
            }
            else {
                for(UIView *category in bar.outcomeCategoryViews) {
                    UITapGestureRecognizer *resetCategories = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetAllCategories)];
                    resetCategories.numberOfTapsRequired = 2;
                    [category addGestureRecognizer:resetCategories];
                }
            }
            
            int sideLength = (width > 30) ? 30 : width;
            [bar.favorite setFrame:CGRectMake(x, yAxis.frame.origin.y + yAxis.frame.size.height + 20, sideLength, sideLength)];
            [bar.favorite setCenter:CGPointMake(x + (width / 2), y + 20 + (sideLength / 2))];
            [bar.leastFavorite setFrame:CGRectMake(x, yAxis.frame.origin.y + yAxis.frame.size.height + 20, sideLength, sideLength)];
            [bar.leastFavorite setCenter:CGPointMake(x + (width / 2), y + 20 + (sideLength / 2))];
            [_scoreBarsView addSubview:bar.favorite];
            [_scoreBarsView addSubview:bar.leastFavorite];
            
            NSArray *profile = [tabControl.profiles objectAtIndex:j];
            
            for(NSArray *favorite in tabControl.favorites) {
                if([[profile objectAtIndex:1] isEqualToString:[favorite objectAtIndex:1]] && [[NSNumber numberWithInt:i] isEqualToNumber:[favorite objectAtIndex:2]]) {
                    [bar.favorite setHidden:NO];
                    [bar.favorite setActive:YES];
                }
            }
            
            for(NSArray *leastFavorite in tabControl.leastFavorites) {
                if([[profile objectAtIndex:1] isEqualToString:[leastFavorite objectAtIndex:1]] && [[NSNumber numberWithInt:i] isEqualToNumber:[leastFavorite objectAtIndex:2]]) {
                    [bar.leastFavorite setHidden:NO];
                    [bar.leastFavorite setActive:YES];
                }
            }
            
            UITapGestureRecognizer *impactRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(impactTapped)];
            impactRecognizer.numberOfTapsRequired = 1;
            UITapGestureRecognizer *groundwaterRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(groundwaterTapped)];
            groundwaterRecognizer.numberOfTapsRequired = 1;
            UITapGestureRecognizer *maxFloodRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maxFloodTapped)];
            maxFloodRecognizer.numberOfTapsRequired = 1;
            UITapGestureRecognizer *waterFlowRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(waterDepthTapped)];
            waterFlowRecognizer.numberOfTapsRequired = 1;
            UITapGestureRecognizer *interventionCapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(interventionCapTapped)];
            interventionCapRecognizer.numberOfTapsRequired = 1;
            UITapGestureRecognizer *efficiencyRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(efficiencyTapped)];
            efficiencyRecognizer.numberOfTapsRequired = 1;
            UITapGestureRecognizer *damageReducRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(damageReducTapped)];
            damageReducRecognizer.numberOfTapsRequired = 1;
            UITapGestureRecognizer *investmentRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(investmentTapped)];
            investmentRecognizer.numberOfTapsRequired = 1;
            
            
            if(wC) {
                bar.impactContainer.userInteractionEnabled = YES;
                bar.groundwaterInfiltrationContainer.userInteractionEnabled = YES;
                bar.maxFloodContainer.userInteractionEnabled = YES;
                bar.waterFlowContainer.userInteractionEnabled = YES;
                bar.capacityContainer.userInteractionEnabled = YES;
                bar.efficiencyContainer.userInteractionEnabled = YES;
                bar.damageReductionContainer.userInteractionEnabled = YES;
                bar.investmentContainer.userInteractionEnabled = YES;
                
                [bar.impactContainer addGestureRecognizer:impactRecognizer];
                [bar.groundwaterInfiltrationContainer addGestureRecognizer:groundwaterRecognizer];
                [bar.maxFloodContainer addGestureRecognizer:maxFloodRecognizer];
                [bar.waterFlowContainer addGestureRecognizer:waterFlowRecognizer];
                [bar.capacityContainer addGestureRecognizer:interventionCapRecognizer];
                [bar.efficiencyContainer addGestureRecognizer:efficiencyRecognizer];
                [bar.damageReductionContainer addGestureRecognizer:damageReducRecognizer];
                [bar.investmentContainer addGestureRecognizer:investmentRecognizer];
            }
            else {
                bar.impact.userInteractionEnabled = YES;
                bar.groundwaterInfiltration.userInteractionEnabled = YES;
                bar.maxFlood.userInteractionEnabled = YES;
                bar.waterFlow.userInteractionEnabled = YES;
                bar.capacity.userInteractionEnabled = YES;
                bar.efficiency.userInteractionEnabled = YES;
                bar.damageReduction.userInteractionEnabled = YES;
                bar.investment.userInteractionEnabled = YES;
                
                [bar.impact addGestureRecognizer:impactRecognizer];
                [bar.groundwaterInfiltration addGestureRecognizer:groundwaterRecognizer];
                [bar.maxFlood addGestureRecognizer:maxFloodRecognizer];
                [bar.waterFlow addGestureRecognizer:waterFlowRecognizer];
                [bar.capacity addGestureRecognizer:interventionCapRecognizer];
                [bar.efficiency addGestureRecognizer:efficiencyRecognizer];
                [bar.damageReduction addGestureRecognizer:damageReducRecognizer];
                [bar.investment addGestureRecognizer:investmentRecognizer];
            }
            
            [_stackedBars addObject:bar];
            
            [trialGroup addObject:bar];
            
            x += width+1;
        }
        [trialGroups addObject: trialGroup];
        x += spaceBetweenTrials;
    }
    
    
    float max = 0;
    bestTrialForMe = -1;
    for(int i = 0; i < trialScores.count; i++) {
        NSNumber *num = [trialScores objectAtIndex:i];
        if([num floatValue] > max) {
            max = [num floatValue];
            bestTrialForMe = i;
        }
    }
    
    float min = sumTierSizes;
    worstTrialForMe = -1;
    for(int i = 0; i < trialScores.count; i++) {
        NSNumber *num = [trialScores objectAtIndex:i];
        if([num floatValue] < min) {
            min = [num floatValue];
            worstTrialForMe = i;
        }
    }
    
    trialLabels = [[NSMutableArray alloc]init];
    
    // create UILabel for each trial
    int i = 0;
    for(NSMutableArray *mArray in trialGroups) {
        if(mArray.count == 0) break;
        StackedBar *fBar = [mArray objectAtIndex:0];
        StackedBar *lBar = [mArray objectAtIndex:mArray.count - 1];
        UIView *trialLabel = [[UIView alloc]initWithFrame:CGRectMake(fBar.frame.origin.x, fBar.frame.origin.y + fBar.frame.size.height + 60, lBar.frame.origin.x + lBar.frame.size.width - fBar.frame.origin.x, 30)];
        trialLabel.tag = i;
        UILabel *trialText = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, lBar.frame.origin.x + lBar.frame.size.width - fBar.frame.origin.x, 30)];
        [trialText setText:[NSString stringWithFormat:@"Trial %d", i+1]];
        [trialText setFont:[UIFont systemFontOfSize:16]];
        [trialText sizeToFit];
        [trialText setCenter:CGPointMake(trialLabel.frame.size.width / 2, trialLabel.frame.size.height / 2)];
        trialText.tag = 101;
        [trialLabel setUserInteractionEnabled:YES];
        UITapGestureRecognizer *trialTapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(trialTapped:)];
        trialTapped.numberOfTapsRequired = 1;
        [trialLabel addGestureRecognizer:trialTapped];
        trialLabel.backgroundColor = [UIColor colorWithRed:73.0f/255.0f green:235.0f/255.0f blue:232.0f/255.0f alpha:.5];
        [trialLabel.layer setBorderColor:[UIColor blackColor].CGColor];
        [trialLabel.layer setBorderWidth:1];

        [trialLabel addSubview:trialText];
        [trialLabels addObject:trialLabel];
        [_scoreBarsView addSubview:trialLabel];
        
        if(i == bestTrialForMe && i != worstTrialForMe) {
            bestForMe = [[UILabel alloc]initWithFrame:CGRectMake(trialLabel.frame.origin.x, trialLabel.frame.origin.y + trialLabel.frame.size.height + 5, trialLabel.frame.size.width, 20)];
            [bestForMe setTextAlignment:NSTextAlignmentCenter];
            [bestForMe setText:@"Best for me"];
            [bestForMe setFont:[UIFont systemFontOfSize:12.0]];
            [_scoreBarsView addSubview:bestForMe];
        }
        if(i == worstTrialForMe && i != bestTrialForMe) {
            worstForMe = [[UILabel alloc]initWithFrame:CGRectMake(trialLabel.frame.origin.x, trialLabel.frame.origin.y + trialLabel.frame.size.height + 5, trialLabel.frame.size.width, 20)];
            [worstForMe setTextAlignment:NSTextAlignmentCenter];
            [worstForMe setText:@"Worst for me"];
            [worstForMe setFont:[UIFont systemFontOfSize:12.0]];
            [_scoreBarsView addSubview:worstForMe];
        }
        
        i++;
    }
    
    /*
    UILabel *yAxisLabel = [[UILabel alloc]init];
    [yAxisLabel setText:@"Performance"];
    [yAxisLabel setTextAlignment:NSTextAlignmentCenter];
    [yAxisLabel sizeToFit];
    [yAxisLabel setFrame:CGRectMake(x_initial - yAxisLabel.frame.size.width - 20, y - yAxisHeight, yAxisLabel.frame.size.width, yAxisHeight)];
     
     
     [_legendView addSubview:yAxisLabel];

     */
    
    // high/low priorty labels along y-axis of graph
    UILabel *highPriority = [[UILabel alloc]initWithFrame:CGRectMake(0, xAxis.frame.origin.y - 20, legend_width, 40)];
    [highPriority setText:@"Highest priority categories"];
    [highPriority setFont:[UIFont systemFontOfSize:14.0]];
    [highPriority setTextAlignment:NSTextAlignmentCenter];
    [highPriority setNumberOfLines:2];
    [_legendView addSubview:highPriority];
    
    UILabel *lowPriority = [[UILabel alloc]initWithFrame:CGRectMake(0, yAxis.frame.origin.y + 40, legend_width, 40)];
    [lowPriority setText:@"Lowest priority categories"];
    [lowPriority setFont:[UIFont systemFontOfSize:14.0]];
    [lowPriority setTextAlignment:NSTextAlignmentCenter];
    [lowPriority setNumberOfLines:2];
    [_legendView addSubview:lowPriority];
    
    int legendHeight = (highPriority.frame.origin.y - (lowPriority.frame.origin.y + lowPriority.frame.size.height)) * 4 / 5;
    UIView *legend = [[UIView alloc]initWithFrame:CGRectMake(0, 0, legend_width, legendHeight)];
    int centerOfLegendY = (highPriority.frame.origin.y - (lowPriority.frame.origin.y + lowPriority.frame.size.height)) / 2 + lowPriority.frame.origin.y + lowPriority.frame.size.height;
    [legend setCenter:CGPointMake(legend_width / 2, centerOfLegendY)];
    [legend.layer setBorderWidth:1];
    [legend.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_legendView addSubview:legend];
    
    UILabel *legendLabel  = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, legend_width, 15)];
    [legendLabel setText:@"Legend"];
    [legendLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [legendLabel setTextAlignment:NSTextAlignmentCenter];
    [legend addSubview:legendLabel];
    
    // figure out how much space we have between our lowPriority and highPriority labels
    int spaceBetweenLegendLabels = 5;
    int heightOfLegendLabels = (legend.frame.size.height - (spaceBetweenLegendLabels * 9) - legendLabel.frame.size.height) / 8;
    int startHeight = 25;
    int heightMultiplier = spaceBetweenLegendLabels + heightOfLegendLabels;
    
    UITapGestureRecognizer *resetLabels1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resetAllCategories)];
    resetLabels1.numberOfTapsRequired = 2;
    UITapGestureRecognizer *resetLabels2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resetAllCategories)];
    resetLabels2.numberOfTapsRequired = 2;
    UITapGestureRecognizer *resetLabels3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resetAllCategories)];
    resetLabels3.numberOfTapsRequired = 2;
    UITapGestureRecognizer *resetLabels4 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resetAllCategories)];
    resetLabels4.numberOfTapsRequired = 2;
    UITapGestureRecognizer *resetLabels5 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resetAllCategories)];
    resetLabels5.numberOfTapsRequired = 2;
    UITapGestureRecognizer *resetLabels6 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resetAllCategories)];
    resetLabels6.numberOfTapsRequired = 2;
    UITapGestureRecognizer *resetLabels7 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resetAllCategories)];
    resetLabels7.numberOfTapsRequired = 2;
    UITapGestureRecognizer *resetLabels8 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resetAllCategories)];
    resetLabels8.numberOfTapsRequired = 2;
    
    // labels for the legend to distinguish which color is which category
    investmentLegendLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, startHeight + heightMultiplier * investmentIndex, legend_width, heightOfLegendLabels)];
    [investmentLegendLabel setText:@"Investment"];
    [investmentLegendLabel setFont:[UIFont systemFontOfSize:12.0]];
    [investmentLegendLabel setBackgroundColor:[scoreColors objectForKey:@"publicCost"]];
    [investmentLegendLabel setTextAlignment:NSTextAlignmentCenter];
    [investmentLegendLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *investmentTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(investmentTapped)];
    investmentTapRecognizer.numberOfTapsRequired = 1;
    [investmentLegendLabel addGestureRecognizer:investmentTapRecognizer];
    [investmentLegendLabel addGestureRecognizer:resetLabels1];
    [legend addSubview:investmentLegendLabel];
    
    damageReductionLegendLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, startHeight + heightMultiplier * damageReductionIndex, legend_width, heightOfLegendLabels)];
    [damageReductionLegendLabel setText:@"Damage Reduction"];
    [damageReductionLegendLabel setFont:[UIFont systemFontOfSize:12.0]];
    [damageReductionLegendLabel setBackgroundColor:[scoreColors objectForKey:@"privateCost"]];
    [damageReductionLegendLabel setTextAlignment:NSTextAlignmentCenter];
    [damageReductionLegendLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *damageReducTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(damageReducTapped)];
    damageReducTapRecognizer.numberOfTapsRequired = 1;
    [damageReductionLegendLabel addGestureRecognizer:damageReducTapRecognizer];
    [damageReductionLegendLabel addGestureRecognizer:resetLabels2];
    [legend addSubview:damageReductionLegendLabel];
    
    efficiencyLegendLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, startHeight + heightMultiplier * efficiencyIndex, legend_width, heightOfLegendLabels)];
    [efficiencyLegendLabel setText:@"Efficiency of Intervention"];
    [efficiencyLegendLabel setFont:[UIFont systemFontOfSize:12.0]];
    [efficiencyLegendLabel setBackgroundColor:[scoreColors objectForKey:@"efficiencyOfIntervention"]];
    [efficiencyLegendLabel setTextAlignment:NSTextAlignmentCenter];
    [efficiencyLegendLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *efficiencyTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(efficiencyTapped)];
    efficiencyTapRecognizer.numberOfTapsRequired = 1;
    [efficiencyLegendLabel addGestureRecognizer:efficiencyTapRecognizer];
    [efficiencyLegendLabel addGestureRecognizer:resetLabels3];
    [legend addSubview:efficiencyLegendLabel];
    
    capacityLegendLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, startHeight + heightMultiplier * capacityIndex, legend_width, heightOfLegendLabels)];
    [capacityLegendLabel setText:@"Intervention Capacity"];
    [capacityLegendLabel setFont:[UIFont systemFontOfSize:12.0]];
    [capacityLegendLabel setBackgroundColor:[scoreColors objectForKey:@"capacity"]];
    [capacityLegendLabel setTextAlignment:NSTextAlignmentCenter];
    [capacityLegendLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *capacityTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(interventionCapTapped)];
    capacityTapRecognizer.numberOfTapsRequired = 1;
    [capacityLegendLabel addGestureRecognizer:capacityTapRecognizer];
    [capacityLegendLabel addGestureRecognizer:resetLabels4];
    [legend addSubview:capacityLegendLabel];
    
    waterFlowLegendLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, startHeight + heightMultiplier * waterFlowIndex, legend_width, heightOfLegendLabels)];
    [waterFlowLegendLabel setText:@"Water Flow"];
    [waterFlowLegendLabel setFont:[UIFont systemFontOfSize:12.0]];
    [waterFlowLegendLabel setBackgroundColor:[scoreColors objectForKey:@"puddleTime"]];
    [waterFlowLegendLabel setTextAlignment:NSTextAlignmentCenter];
    [waterFlowLegendLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *waterDepthTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(waterDepthTapped)];
    waterDepthTapRecognizer.numberOfTapsRequired = 1;
    [waterFlowLegendLabel addGestureRecognizer:waterDepthTapRecognizer];
    [waterFlowLegendLabel addGestureRecognizer:resetLabels5];
    [legend addSubview:waterFlowLegendLabel];
    
    maxFloodLegendLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, startHeight + heightMultiplier * maxFloodIndex, legend_width, heightOfLegendLabels)];
    [maxFloodLegendLabel setText:@"Maximum Flooded Area"];
    [maxFloodLegendLabel setFont:[UIFont systemFontOfSize:12.0]];
    [maxFloodLegendLabel setBackgroundColor:[scoreColors objectForKey:@"puddleMax"]];
    [maxFloodLegendLabel setTextAlignment:NSTextAlignmentCenter];
    [maxFloodLegendLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *maxFloodTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maxFloodTapped)];
    maxFloodTapRecognizer.numberOfTapsRequired = 1;
    [maxFloodLegendLabel addGestureRecognizer:maxFloodTapRecognizer];
    [maxFloodLegendLabel addGestureRecognizer:resetLabels6];
    [legend addSubview:maxFloodLegendLabel];
    
    groundwaterLegendLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, startHeight + heightMultiplier * groundwaterInfiltrationIndex, legend_width, heightOfLegendLabels)];
    [groundwaterLegendLabel setText:@"Groundwater Infiltration"];
    [groundwaterLegendLabel setFont:[UIFont systemFontOfSize:12.0]];
    [groundwaterLegendLabel setBackgroundColor:[scoreColors objectForKey:@"groundwaterInfiltration"]];
    [groundwaterLegendLabel setTextAlignment:NSTextAlignmentCenter];
    [groundwaterLegendLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *groundwaterTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(groundwaterTapped)];
    groundwaterTapRecognizer.numberOfTapsRequired = 1;
    [groundwaterLegendLabel addGestureRecognizer:groundwaterTapRecognizer];
    [groundwaterLegendLabel addGestureRecognizer:resetLabels7];
    [legend addSubview:groundwaterLegendLabel];
    
    impactLegendLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, startHeight + heightMultiplier * impactIndex, legend_width, heightOfLegendLabels)];
    [impactLegendLabel setText:@"Impact on my Neighbors"];
    [impactLegendLabel setFont:[UIFont systemFontOfSize:12.0]];
    [impactLegendLabel setBackgroundColor:[scoreColors objectForKey:@"impactingMyNeighbors"]];
    [impactLegendLabel setTextAlignment:NSTextAlignmentCenter];
    [impactLegendLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *impactTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(impactTapped)];
    impactTapRecognizer.numberOfTapsRequired = 1;
    [impactLegendLabel addGestureRecognizer:impactTapRecognizer];
    [impactLegendLabel addGestureRecognizer:resetLabels8];
    [legend addSubview:impactLegendLabel];
    
    legendLabels = [[NSMutableArray alloc]initWithObjects:impactLegendLabel, investmentLegendLabel, damageReductionLegendLabel, efficiencyLegendLabel, capacityLegendLabel, waterFlowLegendLabel, maxFloodLegendLabel, groundwaterLegendLabel, nil];
    
    
    // add all the bars to this view
    for(StackedBar *s in _stackedBars) {
        [_scoreBarsView addSubview:s];
    }
    
    [_scoreBarsView setContentSize:CGSizeMake(xAxis.frame.size.width + xAxis.frame.origin.x + 60, yAxisHeight + 125)];
    [self setContentSize:CGSizeMake(xAxis.frame.size.width + xAxis.frame.origin.x + 60, yAxisHeight + 125)];
    //[self setContentOffset:CGPointMake(0, self.contentSize.height - self.frame.size.height)];
 
    return self;
}

- (void) reloadGraph:(AprilTestTabBarController *)tabControl withContainers:(int)wC {

    NSMutableArray *tierSizes = [[NSMutableArray alloc]init];

    
    int tierArr[8] = {0, 0, 0, 0, 0, 0, 0, 0};
    
    
    // find max value for each tier
    for(int i = 0; i < tabControl.trialRuns.count; i++) {
        for(int j = 0; j < tabControl.profiles.count; j++) {
            NSMutableArray* scores = [tabControl getScoreBarValuesForProfile:j forTrial:i isDynamicTrial:0];
            NSMutableArray* scoreVisVals = [scores objectAtIndex:0];
            for(int k = 0; k < scoreVisVals.count; k++) {
                if([[scoreVisVals objectAtIndex:k] floatValue] * 100 > tierArr[k])
                    tierArr[k] = [[scoreVisVals objectAtIndex:k]floatValue] * 100;
            }
        }
    }
    
    
    for(int i = 0; i < 8; i++) {
        [tierSizes addObject:[NSNumber numberWithInt:tierArr[i]]];
    }
    
    int sumTierSizes = 0;
    for(int i = 0; i < 8; i++) {
        sumTierSizes += tierArr[i];
    }
    sumTierSizes *= barHeightMultiplier;
    
    
    
    int x_initial = 125;
    int x = x_initial;
    int y = sumTierSizes + 100; // start at the bottom and work up
    int spaceBetweenTrials = 25;
    widthOfBar = (scoreBarsView_width - spaceBetweenTrials * tabControl.trialRuns.count) / (tabControl.trialRuns.count * tabControl.profiles.count + 2);
    int width = widthOfBar;
    
    // draw lines for x and y axis
    int xAxisLength = (width * tabControl.profiles.count + spaceBetweenTrials) * tabControl.trialRuns.count + 100;
    xAxis = [[UIView alloc]initWithFrame:CGRectMake(x_initial, y, xAxisLength, 1)];
    [xAxis setBackgroundColor:[UIColor blackColor]];
    [self addSubview:xAxis];
    
    
    int yAxisHeight = sumTierSizes + 70;
    yAxis = [[UIView alloc]initWithFrame:CGRectMake(x_initial, y - yAxisHeight, 1, yAxisHeight)];
    [yAxis setBackgroundColor:[UIColor blackColor]];
    [self addSubview:yAxis];
    
    //trialGroups = [[NSMutableArray alloc]init];
    
    for(int i = 0; i < tabControl.trialRuns.count; i++) {
        NSMutableArray *trialGroup = [[NSMutableArray alloc]init];
        
        for(int j = 0; j < tabControl.profiles.count; j++) {
            NSMutableArray* scores = [tabControl getScoreBarValuesForProfile:j forTrial:i isDynamicTrial:0];
            
            StackedBar *bar = [_stackedBars objectAtIndex:i * j + j];
            //[bar reloadBar:[tabControl.profiles objectAtIndex:j] andScores:scores andScaleSize:1 andTierSizes:tierSizes withContainers:wC withHeightMultipler:barHeightMultiplier];
            
            
            [bar.name setText:[NSString stringWithFormat:@"%d", i * j + j]];
            //[bar.name setFrame:CGRectMake(x, yAxis.frame.origin.y + yAxis.frame.size.height, width, 20)];
            
            //[trialGroup addObject:bar];
            
            x += width+1;
        }
        
        //[trialGroups addObject:trialGroup];
        
        x += spaceBetweenTrials;
    }
    
    
    //[trialLabels removeAllObjects];
    
    // create UILabel for each trial
    int i = 0;
    for(NSMutableArray *mArray in trialGroups) {
        if(mArray.count == 0) break;
        StackedBar *fBar = [mArray objectAtIndex:0];
        StackedBar *lBar = [mArray objectAtIndex:mArray.count - 1];
        UIView *trialLabel = [[UIView alloc]initWithFrame:CGRectMake(fBar.frame.origin.x, fBar.frame.origin.y + fBar.frame.size.height + 30, lBar.frame.origin.x + lBar.frame.size.width - fBar.frame.origin.x, 30)];
        trialLabel.tag = i;
        UILabel *trialText = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, lBar.frame.origin.x + lBar.frame.size.width - fBar.frame.origin.x, 30)];
        [trialText setText:[NSString stringWithFormat:@"Trial %d", i+1]];
        [trialText setFont:[UIFont systemFontOfSize:16]];
        [trialText sizeToFit];
        [trialText setCenter:CGPointMake(trialLabel.frame.size.width / 2, trialLabel.frame.size.height / 2)];
        trialText.tag = 101;
        [trialLabel setUserInteractionEnabled:YES];
        UITapGestureRecognizer *trialTapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(trialTapped:)];
        trialTapped.numberOfTapsRequired = 1;
        [trialLabel addGestureRecognizer:trialTapped];
        trialLabel.backgroundColor = [UIColor colorWithRed:73.0f/255.0f green:235.0f/255.0f blue:232.0f/255.0f alpha:.5];
        [trialLabel.layer setBorderColor:[UIColor blackColor].CGColor];
        [trialLabel.layer setBorderWidth:1];
        
        [trialLabel addSubview:trialText];
        [trialLabels addObject:trialLabel];
        [self addSubview:trialLabel];
        
        i++;
    }
}

- (void) trialTapped:(UITapGestureRecognizer *)gr {
        UIView *trialLabel = (UIView*)gr.view;
    UILabel *trialText = [trialLabel viewWithTag:101];
    int resizeFactor = 4;
    
    NSMutableArray *mArray = [trialGroups objectAtIndex:trialLabel.tag];
    int shrunk = ((StackedBar*)[mArray objectAtIndex:0]).shrunk;
    
    if(trialLabel.tag == bestTrialForMe && bestForMe != NULL) {
        if([bestForMe isHidden])
            [self performSelector:@selector(toggleHidden:)
                   withObject:bestForMe
                   afterDelay:(0.5f)];
        else
            [self toggleHidden:bestForMe];
    }
    if(trialLabel.tag == worstTrialForMe && worstForMe != NULL) {
        if([worstForMe isHidden])
            [self performSelector:@selector(toggleHidden:)
                   withObject:worstForMe
                   afterDelay:(0.5f)];
        else
            [self toggleHidden:worstForMe];
    }
    
    for(StackedBar *bar in mArray) {
        
        // if we are going to shrink it, hide name
        if(bar.shrunk != 1) {
            [bar.name setHidden:YES];
        }
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    

    

    int i = 0;
    for(StackedBar *bar in mArray) {
        
        // if it is shrunk, we need to grow it
        if(bar.shrunk == 1) {
            [bar setFrame:CGRectMake(bar.frame.origin.x + (widthOfBar - widthOfBar /resizeFactor) * i, bar.frame.origin.y, bar.frame.size.width, bar.frame.size.height)];
            
            [bar.score setHidden:NO];
            [bar grow];
            bar.shrunk = 0;
            if(bar.favorite.isActive) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(toggleFavoriteHidden:) object:bar.favorite];
                [self performSelector:@selector(toggleFavoriteHidden:)
                           withObject:bar.favorite
                           afterDelay:0.5];
            }
            if(bar.leastFavorite.isActive) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(toggleLeastFavoriteHidden:) object:bar.leastFavorite];
                [self performSelector:@selector(toggleLeastFavoriteHidden:)
                           withObject:bar.leastFavorite
                           afterDelay:0.5];
            }
        }
        else { // otherwise, we need to shrink it
            [bar.score setHidden:YES];
            [bar shrink];
            bar.shrunk = 1;
            
            [bar setFrame:CGRectMake(bar.frame.origin.x - (widthOfBar - widthOfBar /resizeFactor) * i, bar.frame.origin.y, bar.frame.size.width, bar.frame.size.height)];
            
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(toggleFavoriteHidden:) object:bar.favorite];
            [bar.favorite setHidden:YES];
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(toggleLeastFavoriteHidden:) object:bar.leastFavorite];
            [bar.leastFavorite setHidden:YES];
        }
        i++;
    }
    
    if(shrunk){ // if shrunken, we gotta grow it
        [trialLabel setFrame:CGRectMake(trialLabel.frame.origin.x, trialLabel.frame.origin.y, trialLabel.frame.size.width * resizeFactor, trialLabel.frame.size.height)];
        [trialText setFont:[UIFont systemFontOfSize:16]];
        [trialText setText:[NSString stringWithFormat:@"Trial %@", trialText.text]];
        [trialText sizeToFit];
        [trialText setCenter:CGPointMake(trialLabel.frame.size.width / 2, trialLabel.frame.size.height / 2)];
        

        NSString *logEntry = [tabController generateLogEntryWith:[NSString stringWithFormat:@"\tGrew Trial \t%@", [trialText.text substringFromIndex:6]]];
        [tabController writeToLogFileString:logEntry];
    }
    else { // otherwise we shrink it
        [trialLabel setFrame:CGRectMake(trialLabel.frame.origin.x, trialLabel.frame.origin.y, trialLabel.frame.size.width / resizeFactor, trialLabel.frame.size.height)];
        [trialText setFont:[UIFont systemFontOfSize:10]];
        [trialText setText:[trialText.text substringFromIndex:6]];
        [trialText sizeToFit];
        [trialText setCenter:CGPointMake(trialLabel.frame.size.width / 2, trialLabel.frame.size.height / 2)];
        
        
        NSString *logEntry = [tabController generateLogEntryWith:[NSString stringWithFormat:@"\tShrunk trial\t%@", trialText.text]];
        [tabController writeToLogFileString:logEntry];
    }
    
    int shiftAmount = mArray.count * (widthOfBar - widthOfBar / resizeFactor);
    if(shrunk) {
        for(i = (int)trialLabel.tag + 1; i < trialGroups.count; i++) {
            [self shiftRight:[trialGroups objectAtIndex:i] amount:shiftAmount];
            UILabel *trialLabel = [trialLabels objectAtIndex:i];
            [trialLabel setFrame:CGRectMake(trialLabel.frame.origin.x + shiftAmount, trialLabel.frame.origin.y, trialLabel.frame.size.width, trialLabel.frame.size.height)];
        }
        if(bestTrialForMe > trialLabel.tag && bestForMe != NULL) {
            [bestForMe setFrame:CGRectMake(bestForMe.frame.origin.x + shiftAmount, bestForMe.frame.origin.y, bestForMe.frame.size.width, bestForMe.frame.size.height)];
        }
        if(worstTrialForMe > trialLabel.tag && worstForMe != NULL) {
            [worstForMe setFrame:CGRectMake(worstForMe.frame.origin.x + shiftAmount, worstForMe.frame.origin.y, worstForMe.frame.size.width, worstForMe.frame.size.height)];
        }
        
    }
    else {
        for(i = (int)trialLabel.tag + 1; i < trialGroups.count; i++) {
            [self shiftLeft:[trialGroups objectAtIndex:i] amount:shiftAmount];
            UILabel *trialLabel = [trialLabels objectAtIndex:i];
            [trialLabel setFrame:CGRectMake(trialLabel.frame.origin.x - shiftAmount, trialLabel.frame.origin.y, trialLabel.frame.size.width, trialLabel.frame.size.height)];
        }
        if(bestTrialForMe > trialLabel.tag && bestForMe != NULL) {
            [bestForMe setFrame:CGRectMake(bestForMe.frame.origin.x - shiftAmount, bestForMe.frame.origin.y, bestForMe.frame.size.width, bestForMe.frame.size.height)];
        }
        if(worstTrialForMe > trialLabel.tag && worstForMe != NULL) {
            [worstForMe setFrame:CGRectMake(worstForMe.frame.origin.x - shiftAmount, worstForMe.frame.origin.y, worstForMe.frame.size.width, worstForMe.frame.size.height)];
        }
    }
    
    
    [UIView commitAnimations];
    
    [self performSelector:@selector(showName:)
               withObject:mArray
               afterDelay:(0.5f)];

}

- (void) toggleFavoriteHidden:(FavoriteView *)favorite {
    if(favorite.isHidden)
        [favorite setHidden:NO];
    else
        [favorite setHidden:YES];
}

- (void) toggleLeastFavoriteHidden:(LeastFavoriteView *)leastFavorite {
    if(leastFavorite.isHidden)
        [leastFavorite setHidden:NO];
    else
        [leastFavorite setHidden:YES];
}

- (void) toggleHidden:(UILabel*)label{
    if([label isHidden])
        [label setHidden:NO];
    else
        [label setHidden:YES];
}


- (void) showName:(NSMutableArray *)mArray {
    for(StackedBar *bar in mArray) {
        
        // if we just shrunk it, do nothing
        if(bar.shrunk == 1) {
        }
        else { // otherwise, we need to display it
            [bar.name setHidden:NO];
        }
    }
}

- (void)shiftLeft:(NSMutableArray*)mArray amount:(int)shiftAmount{
    for(StackedBar *bar in mArray) {
        [bar setFrame:CGRectMake(bar.frame.origin.x - shiftAmount, bar.frame.origin.y, bar.frame.size.width, bar.frame.size.height)];
        [bar.name setFrame:CGRectMake(bar.name.frame.origin.x - shiftAmount, bar.name.frame.origin.y, bar.name.frame.size.width, bar.name.frame.size.height)];
        [bar.favorite setFrame:CGRectMake(bar.favorite.frame.origin.x - shiftAmount, bar.favorite.frame.origin.y, bar.favorite.frame.size.width, bar.favorite.frame.size.height)];
        [bar.leastFavorite setFrame:CGRectMake(bar.leastFavorite.frame.origin.x - shiftAmount, bar.leastFavorite.frame.origin.y, bar.leastFavorite.frame.size.width, bar.leastFavorite.frame.size.height)];
    }
}

- (void)shiftRight:(NSMutableArray*)mArray amount:(int)shiftAmount{
    for(StackedBar *bar in mArray) {
        [bar setFrame:CGRectMake(bar.frame.origin.x + shiftAmount, bar.frame.origin.y, bar.frame.size.width, bar.frame.size.height)];
        [bar.name setFrame:CGRectMake(bar.name.frame.origin.x + shiftAmount, bar.name.frame.origin.y, bar.name.frame.size.width, bar.name.frame.size.height)];
        [bar.favorite setFrame:CGRectMake(bar.favorite.frame.origin.x + shiftAmount, bar.favorite.frame.origin.y, bar.favorite.frame.size.width, bar.favorite.frame.size.height)];
        [bar.leastFavorite setFrame:CGRectMake(bar.leastFavorite.frame.origin.x + shiftAmount, bar.leastFavorite.frame.origin.y, bar.leastFavorite.frame.size.width, bar.leastFavorite.frame.size.height)];
    }
}

- (void) impactTapped {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [impactLegendLabel.layer setBorderWidth:2.0];
    
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    [impactLegendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    [impactLegendLabel setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0]];
    
    for(UILabel *legendLabel in legendLabels) {
        if(![legendLabel isEqual:impactLegendLabel]) {
            [legendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
            [legendLabel setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.25]];
            [legendLabel.layer setBorderWidth:0.0];
        }
    }
     [impactLegendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];   
    for(StackedBar *bar in _stackedBars) {
        [bar.impact.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        [bar.impact setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0]];
        
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.impact.frame.size.height/barHeightMultiplier];
        [bar changeText:text];
        [bar changeTextColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0]];
        
        if(bar.hasContainers) {
            [bar.impact.layer setBorderWidth:0.0];
            [bar.impactContainer.layer setBorderWidth:1.0];
        }
        else {
            [bar.impact.layer setBorderWidth:1.0];
            [bar.impactContainer.layer setBorderWidth:0.0];
        }
        
        for(UIView *category in bar.outcomeCategoryViews) {
            CGFloat hueB;
            CGFloat saturationB;
            CGFloat brightnessB;
            CGFloat alphaB;
            
            if(![category isEqual:bar.impact]) {
                [category.layer setBorderWidth:0.0];
                [category.backgroundColor getHue:&hueB saturation:&saturationB brightness:&brightnessB alpha:&alphaB];
                [category setBackgroundColor:[UIColor colorWithHue:hueB saturation:saturationB brightness:brightnessB alpha:0.25]];
            }
        }
        
        for(UIView *categoryContainer in bar.outcomeCategoryContainers) {
            if(![categoryContainer  isEqual:bar.impactContainer]) {
                [categoryContainer.layer setBorderWidth:0.0];
            }
        }
    }
    
    [UIView commitAnimations];
    
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideScores) object:nil];
    [self performSelector:@selector(hideScores)
               withObject:nil
               afterDelay:5.0];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetAllCategories) object:nil];
    [self performSelector:@selector(resetAllCategories)
               withObject:nil
               afterDelay:5.0];
    
    
    NSString *logEntry = [tabController generateLogEntryWith:@"\tInspected outcome category \tImpact on my Neighbors"];
    [tabController writeToLogFileString:logEntry];
    
}



- (void) groundwaterTapped {

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [groundwaterLegendLabel.layer setBorderWidth:2.0];
    
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    [groundwaterLegendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    [groundwaterLegendLabel setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.85]];
    
    for(UILabel *legendLabel in legendLabels) {
        if(![legendLabel isEqual:groundwaterLegendLabel]) {
            [legendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
            [legendLabel setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.25]];
            [legendLabel.layer setBorderWidth:0.0];
        }
    }
    [groundwaterLegendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    for(StackedBar *bar in _stackedBars) {
        [bar.groundwaterInfiltration.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        [bar.groundwaterInfiltration setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.85]];
        
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.groundwaterInfiltration.frame.size.height/ barHeightMultiplier];
        [bar changeText:text];
        [bar changeTextColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.85]];
        
        if(bar.hasContainers) {
            [bar.groundwaterInfiltration.layer setBorderWidth:0.0];
            [bar.groundwaterInfiltrationContainer.layer setBorderWidth:1.0];
        }
        else {
            [bar.groundwaterInfiltration.layer setBorderWidth:1.0];
            [bar.groundwaterInfiltrationContainer.layer setBorderWidth:0.0];
        }
        
        for(UIView *category in bar.outcomeCategoryViews) {
            CGFloat hueB;
            CGFloat saturationB;
            CGFloat brightnessB;
            CGFloat alphaB;
            
            if(![category isEqual:bar.groundwaterInfiltration]) {
                [category.layer setBorderWidth:0.0];
                [category.backgroundColor getHue:&hueB saturation:&saturationB brightness:&brightnessB alpha:&alphaB];
                [category setBackgroundColor:[UIColor colorWithHue:hueB saturation:saturationB brightness:brightnessB alpha:0.25]];
            }
        }
        
        for(UIView *categoryContainer in bar.outcomeCategoryContainers) {
            if(![categoryContainer  isEqual:bar.groundwaterInfiltrationContainer]) {
                [categoryContainer.layer setBorderWidth:0.0];
            }
        }
    }
    
    [UIView commitAnimations];
    
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideScores) object:nil];
    [self performSelector:@selector(hideScores)
               withObject:nil
               afterDelay:5.0];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetAllCategories) object:nil];
    [self performSelector:@selector(resetAllCategories)
               withObject:nil
               afterDelay:5.0];
    
    
    NSString *logEntry = [tabController generateLogEntryWith:@"\tInspected outcome category \tGroundwater Infiltration"];
    [tabController writeToLogFileString:logEntry];
    
}


- (void) maxFloodTapped {

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [maxFloodLegendLabel.layer setBorderWidth:2.0];
    
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    [maxFloodLegendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    [maxFloodLegendLabel setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.8]];
    
    for(UILabel *legendLabel in legendLabels) {
        if(![legendLabel isEqual:maxFloodLegendLabel]) {
            [legendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
            [legendLabel setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.25]];
            [legendLabel.layer setBorderWidth:0.0];
        }
    }
    [maxFloodLegendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    for(StackedBar *bar in _stackedBars) {
        [[scoreColors objectForKey:@"puddleMax"] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        [bar.maxFlood setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.8]];
        
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.maxFlood.frame.size.height/ barHeightMultiplier];
        [bar changeText:text];
        [bar changeTextColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.8]];
        
        if(bar.hasContainers) {
            [bar.maxFlood.layer setBorderWidth:0.0];
            [bar.maxFloodContainer.layer setBorderWidth:1.0];
        }
        else {
            [bar.maxFlood.layer setBorderWidth:1.0];
            [bar.maxFloodContainer.layer setBorderWidth:0.0];
        }
        
        for(UIView *category in bar.outcomeCategoryViews) {
            CGFloat hueB;
            CGFloat saturationB;
            CGFloat brightnessB;
            CGFloat alphaB;
            
            if(![category isEqual:bar.maxFlood]) {
                [category.layer setBorderWidth:0.0];
                [category.backgroundColor getHue:&hueB saturation:&saturationB brightness:&brightnessB alpha:&alphaB];
                [category setBackgroundColor:[UIColor colorWithHue:hueB saturation:saturationB brightness:brightnessB alpha:0.25]];
            }
        }
        
        for(UIView *categoryContainer in bar.outcomeCategoryContainers) {
            if(![categoryContainer  isEqual:bar.maxFloodContainer]) {
                [categoryContainer.layer setBorderWidth:0.0];
            }
        }
    }
    
    [UIView commitAnimations];
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideScores) object:nil];
    [self performSelector:@selector(hideScores)
               withObject:nil
               afterDelay:5.0];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetAllCategories) object:nil];
    [self performSelector:@selector(resetAllCategories)
               withObject:nil
               afterDelay:5.0];
    
    
    NSString *logEntry = [tabController generateLogEntryWith:@"\tInspected outcome category \tMaximum Flooded Area"];
    [tabController writeToLogFileString:logEntry];
    
}


- (void) waterDepthTapped {

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [waterFlowLegendLabel.layer setBorderWidth:2.0];
    
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    [waterFlowLegendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    [waterFlowLegendLabel setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.80]];
    
    for(UILabel *legendLabel in legendLabels) {
        if(![legendLabel isEqual:waterFlowLegendLabel]) {
            [legendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
            [legendLabel setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.25]];
            [legendLabel.layer setBorderWidth:0.0];
        }
    }
    
    [waterFlowLegendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    for(StackedBar *bar in _stackedBars) {
        [bar.waterFlow.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        [bar.waterFlow setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.8]];
        
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.waterFlow.frame.size.height/ barHeightMultiplier];
        [bar changeText:text];
        [bar changeTextColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.8]];
        
        if(bar.hasContainers) {
            [bar.waterFlow.layer setBorderWidth:0.0];
            [bar.waterFlowContainer.layer setBorderWidth:1.0];
        }
        else {
            [bar.waterFlow.layer setBorderWidth:1.0];
            [bar.waterFlowContainer.layer setBorderWidth:0.0];
        }
        
        for(UIView *category in bar.outcomeCategoryViews) {
            CGFloat hueB;
            CGFloat saturationB;
            CGFloat brightnessB;
            CGFloat alphaB;
            
            if(![category isEqual:bar.waterFlow]) {
                [category.layer setBorderWidth:0.0];
                [category.backgroundColor getHue:&hueB saturation:&saturationB brightness:&brightnessB alpha:&alphaB];
                [category setBackgroundColor:[UIColor colorWithHue:hueB saturation:saturationB brightness:brightnessB alpha:0.25]];
            }
        }
        
        for(UIView *categoryContainer in bar.outcomeCategoryContainers) {
            if(![categoryContainer  isEqual:bar.waterFlowContainer]) {
                [categoryContainer.layer setBorderWidth:0.0];
            }
        }
    }
    
    [UIView commitAnimations];
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideScores) object:nil];
    [self performSelector:@selector(hideScores)
               withObject:nil
               afterDelay:5.0];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetAllCategories) object:nil];
    [self performSelector:@selector(resetAllCategories)
               withObject:nil
               afterDelay:5.0];
    
    
    NSString *logEntry = [tabController generateLogEntryWith:@"\tInspected outcome category \tWater Flow"];
    [tabController writeToLogFileString:logEntry];
    
}


- (void) interventionCapTapped {

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [capacityLegendLabel.layer setBorderWidth:2.0];
    
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    [capacityLegendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    [capacityLegendLabel setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0]];
    
    for(UILabel *legendLabel in legendLabels) {
        if(![legendLabel isEqual:capacityLegendLabel]) {
            [legendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
            [legendLabel setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.25]];
            [legendLabel.layer setBorderWidth:0.0];
        }
    }
    
    [capacityLegendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    for(StackedBar *bar in _stackedBars) {
        [bar.capacity.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        [bar.capacity setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0]];
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.capacity.frame.size.height/ barHeightMultiplier];
        [bar changeText:text];
        [bar changeTextColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0]];
        
        if(bar.hasContainers) {
            [bar.capacity.layer setBorderWidth:0.0];
            [bar.capacityContainer.layer setBorderWidth:1.0];
        }
        else {
            [bar.capacity.layer setBorderWidth:1.0];
            [bar.capacityContainer.layer setBorderWidth:0.0];
        }
        
        for(UIView *category in bar.outcomeCategoryViews) {
            CGFloat hueB;
            CGFloat saturationB;
            CGFloat brightnessB;
            CGFloat alphaB;
            
            if(![category isEqual:bar.capacity]) {
                [category.layer setBorderWidth:0.0];
                [category.backgroundColor getHue:&hueB saturation:&saturationB brightness:&brightnessB alpha:&alphaB];
                [category setBackgroundColor:[UIColor colorWithHue:hueB saturation:saturationB brightness:brightnessB alpha:0.25]];
            }
        }
        
        
        for(UIView *categoryContainer in bar.outcomeCategoryContainers) {
            if(![categoryContainer  isEqual:bar.capacityContainer]) {
                [categoryContainer.layer setBorderWidth:0.0];
            }
        }
    }
    
    [UIView commitAnimations];
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideScores) object:nil];
    [self performSelector:@selector(hideScores)
               withObject:nil
               afterDelay:5.0];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetAllCategories) object:nil];
    [self performSelector:@selector(resetAllCategories)
               withObject:nil
               afterDelay:5.0];
    
    
    NSString *logEntry = [tabController generateLogEntryWith:@"\tInspected outcome category \tIntervention Capacity"];
    [tabController writeToLogFileString:logEntry];
    
}


- (void) efficiencyTapped {

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [efficiencyLegendLabel.layer setBorderWidth:2.0];
    
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    [efficiencyLegendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    [efficiencyLegendLabel setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.80]];
    
    for(UILabel *legendLabel in legendLabels) {
        if(![legendLabel isEqual:efficiencyLegendLabel]) {
            [legendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
            [legendLabel setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.25]];
            [legendLabel.layer setBorderWidth:0.0];
        }
    }
    [efficiencyLegendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    for(StackedBar *bar in _stackedBars) {
        [bar.efficiency.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        [bar.efficiency setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.8]];
        
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.efficiency.frame.size.height/ barHeightMultiplier];
        [bar.efficiency.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        [bar changeText:text];
        [bar changeTextColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.8]];
        
        if(bar.hasContainers) {
            [bar.efficiency.layer setBorderWidth:0.0];
            [bar.efficiencyContainer.layer setBorderWidth:1.0];
        }
        else {
            [bar.efficiency.layer setBorderWidth:1.0];
            [bar.efficiencyContainer.layer setBorderWidth:0.0];
        }
        
        for(UIView *category in bar.outcomeCategoryViews) {
            CGFloat hueB;
            CGFloat saturationB;
            CGFloat brightnessB;
            CGFloat alphaB;
            
            if(![category isEqual:bar.efficiency]) {
                [category.layer setBorderWidth:0.0];
                [category.backgroundColor getHue:&hueB saturation:&saturationB brightness:&brightnessB alpha:&alphaB];
                [category setBackgroundColor:[UIColor colorWithHue:hueB saturation:saturationB brightness:brightnessB alpha:0.25]];
            }
        }
        
        for(UIView *categoryContainer in bar.outcomeCategoryContainers) {
            if(![categoryContainer  isEqual:bar.efficiencyContainer]) {
                [categoryContainer.layer setBorderWidth:0.0];
            }
        }
    }
    
    [UIView commitAnimations];
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideScores) object:nil];
    [self performSelector:@selector(hideScores)
               withObject:nil
               afterDelay:5.0];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetAllCategories) object:nil];
    [self performSelector:@selector(resetAllCategories)
               withObject:nil
               afterDelay:5.0];
    
    
    NSString *logEntry = [tabController generateLogEntryWith:@"\tInspected outcome category \tEfficiency of Intervention"];
    [tabController writeToLogFileString:logEntry];
    
}


- (void) damageReducTapped {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    
    [damageReductionLegendLabel.layer setBorderWidth:2.0];
    
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    [damageReductionLegendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    [damageReductionLegendLabel setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0]];
    
    for(UILabel *legendLabel in legendLabels) {
        if(![legendLabel isEqual:damageReductionLegendLabel]) {
            [legendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
            [legendLabel setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.25]];
            [legendLabel.layer setBorderWidth:0.0];
        }
    }
    [damageReductionLegendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    for(StackedBar *bar in _stackedBars) {
        [bar.damageReduction.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        [bar.damageReduction setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.9]];
        
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.damageReduction.frame.size.height/ barHeightMultiplier];
        [bar changeText:text];
        [bar changeTextColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.9]];
        
        if(bar.hasContainers) {
            [bar.damageReduction.layer setBorderWidth:0.0];
            [bar.damageReductionContainer.layer setBorderWidth:1.0];
        }
        else {
            [bar.damageReduction.layer setBorderWidth:1.0];
            [bar.damageReductionContainer.layer setBorderWidth:0.0];
        }
        
        for(UIView *category in bar.outcomeCategoryViews) {
            if(![category isEqual:bar.damageReduction]) {
                CGFloat hueB;
                CGFloat saturationB;
                CGFloat brightnessB;
                CGFloat alphaB;
                
                [category.layer setBorderWidth:0.0];
                [category.backgroundColor getHue:&hueB saturation:&saturationB brightness:&brightnessB alpha:&alphaB];
                [category setBackgroundColor:[UIColor colorWithHue:hueB saturation:saturationB brightness:brightnessB alpha:0.25]];
            }
        }
        
        
        for(UIView *categoryContainer in bar.outcomeCategoryContainers) {
            if(![categoryContainer  isEqual:bar.damageReductionContainer]) {
                [categoryContainer.layer setBorderWidth:0.0];
            }
        }
    }
    
    [UIView commitAnimations];
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideScores) object:nil];
    [self performSelector:@selector(hideScores)
               withObject:nil
               afterDelay:5.0];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetAllCategories) object:nil];
    [self performSelector:@selector(resetAllCategories)
               withObject:nil
               afterDelay:5.0];
    
    
    NSString *logEntry = [tabController generateLogEntryWith:@"\tInspected outcome category \tDamage Reduction"];
    [tabController writeToLogFileString:logEntry];
    
}


- (void) investmentTapped {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [investmentLegendLabel.layer setBorderWidth:2.0];
    
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    [investmentLegendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    [investmentLegendLabel setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0]];
    
    for(UILabel *legendLabel in legendLabels) {
        if(![legendLabel isEqual:investmentLegendLabel]) {
            [legendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
            [legendLabel setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.25]];
            [legendLabel.layer setBorderWidth:0.0];
        }
    }
    [investmentLegendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    for(StackedBar *bar in _stackedBars) {
        [[scoreColors objectForKey:@"publicCost"] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        [bar.investment setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0]];
        
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.investment.frame.size.height/ barHeightMultiplier];
        [bar changeText:text];
        [bar changeTextColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0]];
        
        if(bar.hasContainers) {
            [bar.investment.layer setBorderWidth:0.0];
            [bar.investmentContainer.layer setBorderWidth:1.0];
        }
        else {
            [bar.investment.layer setBorderWidth:1.0];
            [bar.investmentContainer.layer setBorderWidth:0.0];
        }
    
    
        for(UIView *category in bar.outcomeCategoryViews) {
            CGFloat hueB;
            CGFloat saturationB;
            CGFloat brightnessB;
            CGFloat alphaB;
            
            if(![category isEqual:bar.investment]) {
                [category.layer setBorderWidth:0.0];
                [category.backgroundColor getHue:&hueB saturation:&saturationB brightness:&brightnessB alpha:&alphaB];
                [category setBackgroundColor:[UIColor colorWithHue:hueB saturation:saturationB brightness:brightnessB alpha:0.25]];
            }
        }
        
        for(UIView *categoryContainer in bar.outcomeCategoryContainers) {
            if(![categoryContainer  isEqual:bar.investmentContainer]) {
                [categoryContainer.layer setBorderWidth:0.0];
            }
        }
    }
    
    
    for(StackedBar *sb in _stackedBars) {
        [sb lineDown:sb.investment withContainer:sb.investmentContainer withEmpty:sb.investmentEmpty];
    }

    [UIView commitAnimations];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideScores) object:nil];
    [self performSelector:@selector(hideScores)
               withObject:nil
               afterDelay:5.0];

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetAllCategories) object:nil];
    [self performSelector:@selector(resetAllCategories)
               withObject:nil
               afterDelay:5.0];

    
    NSString *logEntry = [tabController generateLogEntryWith:@"\tInspected outcome category \tInvestment"];
    [tabController writeToLogFileString:logEntry];
    
}


- (void)resetAllCategories {
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetAllCategories) object:nil];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    for(StackedBar *bar in _stackedBars) {
        for(UIView *category in bar.outcomeCategoryViews) {
            CGFloat hue;
            CGFloat saturation;
            CGFloat brightness;
            CGFloat alpha;
            [category.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
            [category setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.5]];
            [category.layer setBorderWidth:0.0];
        }
        
        for(UIView *container in bar.outcomeCategoryContainers) {
            [container.layer setBorderWidth:0.0];
        }
        
        [self hideScores];
    }
    
    for(UILabel *legendLabel in legendLabels) {
        CGFloat hue;
        CGFloat saturation;
        CGFloat brightness;
        CGFloat alpha;
        [legendLabel.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        [legendLabel setBackgroundColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.5]];
        [legendLabel.layer setBorderWidth:0.0];
    }
    
    [UIView commitAnimations];
}

- (void) hideScores {
    for(StackedBar *bar in _stackedBars) {
        [bar changeText:@""];
        [bar changeTextColor:[UIColor clearColor]];
    }
}


@end

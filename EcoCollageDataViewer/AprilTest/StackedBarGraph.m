//
//  StackedBarGraph.m
//  AprilTest
//
//  Created by Ugrad Research on 11/5/15.
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
            
            StackedBar *bar = [[StackedBar alloc]initWithFrame:CGRectMake(x, y, width, - sumTierSizes) andProfile:[tabControl.profiles objectAtIndex:j] andScores:scores andScaleSize:1 andTierSizes:tierSizes withContainers:wC withHeightMultipler:barHeightMultiplier withScore:totalScore];
            
            [trialScores addObject:[NSNumber numberWithFloat:*totalScore]];
            free(totalScore);
            
            [bar.name setFrame:CGRectMake(x, yAxis.frame.origin.y + yAxis.frame.size.height, width, 20)];
            [_scoreBarsView addSubview:bar.name];
            
            
            
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
    
    int legendHeight = (highPriority.frame.origin.y - (lowPriority.frame.origin.y + lowPriority.frame.size.height)) * 2 / 3;
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
    int heightOfLegendLabels = (legend.frame.size.height - spaceBetweenLegendLabels * 8 - 30) / 8;
    int startHeight = 25;
    int heightMultiplier = spaceBetweenLegendLabels + heightOfLegendLabels;
    
    // labels for the legend to distinguish which color is which category
    UILabel *investmentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, startHeight + heightMultiplier * investmentIndex, legend_width, heightOfLegendLabels)];
    [investmentLabel setText:@"Investment"];
    [investmentLabel setFont:[UIFont systemFontOfSize:12.0]];
    [investmentLabel setBackgroundColor:[scoreColors objectForKey:@"publicCost"]];
    [investmentLabel setTextAlignment:NSTextAlignmentCenter];
    [legend addSubview:investmentLabel];
    
    UILabel *damageReductionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, startHeight + heightMultiplier * damageReductionIndex, legend_width, heightOfLegendLabels)];
    [damageReductionLabel setText:@"Damage Reduction"];
    [damageReductionLabel setFont:[UIFont systemFontOfSize:12.0]];
    [damageReductionLabel setBackgroundColor:[scoreColors objectForKey:@"privateCost"]];
    [damageReductionLabel setTextAlignment:NSTextAlignmentCenter];
    [legend addSubview:damageReductionLabel];
    
    UILabel *efficiencyLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, startHeight + heightMultiplier * efficiencyIndex, legend_width, heightOfLegendLabels)];
    [efficiencyLabel setText:@"Efficiency of Intervention"];
    [efficiencyLabel setFont:[UIFont systemFontOfSize:12.0]];
    [efficiencyLabel setBackgroundColor:[scoreColors objectForKey:@"efficiencyOfIntervention"]];
    [efficiencyLabel setTextAlignment:NSTextAlignmentCenter];
    [legend addSubview:efficiencyLabel];
    
    UILabel *capacityLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, startHeight + heightMultiplier * capacityIndex, legend_width, heightOfLegendLabels)];
    [capacityLabel setText:@"Intervention Capacity"];
    [capacityLabel setFont:[UIFont systemFontOfSize:12.0]];
    [capacityLabel setBackgroundColor:[scoreColors objectForKey:@"capacity"]];
    [capacityLabel setTextAlignment:NSTextAlignmentCenter];
    [legend addSubview:capacityLabel];
    
    UILabel *waterFlowLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, startHeight + heightMultiplier * waterFlowIndex, legend_width, heightOfLegendLabels)];
    [waterFlowLabel setText:@"Water Flow"];
    [waterFlowLabel setFont:[UIFont systemFontOfSize:12.0]];
    [waterFlowLabel setBackgroundColor:[scoreColors objectForKey:@"puddleTime"]];
    [waterFlowLabel setTextAlignment:NSTextAlignmentCenter];
    [legend addSubview:waterFlowLabel];
    
    UILabel *maxFloodLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, startHeight + heightMultiplier * maxFloodIndex, legend_width, heightOfLegendLabels)];
    [maxFloodLabel setText:@"Maximum Flooded Area"];
    [maxFloodLabel setFont:[UIFont systemFontOfSize:12.0]];
    [maxFloodLabel setBackgroundColor:[scoreColors objectForKey:@"puddleMax"]];
    [maxFloodLabel setTextAlignment:NSTextAlignmentCenter];
    [legend addSubview:maxFloodLabel];
    
    UILabel *groundwaterInfiltrationLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, startHeight + heightMultiplier * groundwaterInfiltrationIndex, legend_width, heightOfLegendLabels)];
    [groundwaterInfiltrationLabel setText:@"Groundwater Infiltration"];
    [groundwaterInfiltrationLabel setFont:[UIFont systemFontOfSize:12.0]];
    [groundwaterInfiltrationLabel setBackgroundColor:[scoreColors objectForKey:@"groundwaterInfiltration"]];
    [groundwaterInfiltrationLabel setTextAlignment:NSTextAlignmentCenter];
    [legend addSubview:groundwaterInfiltrationLabel];
    
    UILabel *impactLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, startHeight + heightMultiplier * impactIndex, legend_width, heightOfLegendLabels)];
    [impactLabel setText:@"Impact on my Neighbors"];
    [impactLabel setFont:[UIFont systemFontOfSize:12.0]];
    [impactLabel setBackgroundColor:[scoreColors objectForKey:@"impactingMyNeighbors"]];
    [impactLabel setTextAlignment:NSTextAlignmentCenter];
    [legend addSubview:impactLabel];
    
    
    
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
        }
        else { // otherwise, we need to shrink it
            [bar.score setHidden:YES];
            [bar shrink];
            bar.shrunk = 1;
            
            [bar setFrame:CGRectMake(bar.frame.origin.x - (widthOfBar - widthOfBar /resizeFactor) * i, bar.frame.origin.y, bar.frame.size.width, bar.frame.size.height)];
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
    }
}

- (void)shiftRight:(NSMutableArray*)mArray amount:(int)shiftAmount{
    for(StackedBar *bar in mArray) {
        [bar setFrame:CGRectMake(bar.frame.origin.x + shiftAmount, bar.frame.origin.y, bar.frame.size.width, bar.frame.size.height)];
        [bar.name setFrame:CGRectMake(bar.name.frame.origin.x + shiftAmount, bar.name.frame.origin.y, bar.name.frame.size.width, bar.name.frame.size.height)];
    }
}

- (void) impactTapped {
    for(StackedBar *bar in _stackedBars) {
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.impact.frame.size.height/barHeightMultiplier];
        [bar changeText:text];
        [bar changeTextColor:[scoreColors objectForKey:@"impactingMyNeighbors"]];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideScores) object:nil];
    [self performSelector:@selector(hideScores)
               withObject:nil
               afterDelay:3.0];
    
    
    NSString *logEntry = [tabController generateLogEntryWith:@"\tInspected outcome category \tImpact on my Neighbors"];
    [tabController writeToLogFileString:logEntry];
    
}


- (void) groundwaterTapped {
    for(StackedBar *bar in _stackedBars) {
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.groundwaterInfiltration.frame.size.height/ barHeightMultiplier];
        [bar changeText:text];
        [bar changeTextColor:[scoreColors objectForKey:@"groundwaterInfiltration"]];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideScores) object:nil];
    [self performSelector:@selector(hideScores)
               withObject:nil
               afterDelay:3.0];
    
    
    NSString *logEntry = [tabController generateLogEntryWith:@"\tInspected outcome category \tGroundwater Infiltration"];
    [tabController writeToLogFileString:logEntry];
    
}


- (void) maxFloodTapped {
    for(StackedBar *bar in _stackedBars) {
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.maxFlood.frame.size.height/ barHeightMultiplier];
        [bar changeText:text];
        [bar changeTextColor:[scoreColors objectForKey:@"puddleMax"]];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideScores) object:nil];
    [self performSelector:@selector(hideScores)
               withObject:nil
               afterDelay:3.0];
    
    
    NSString *logEntry = [tabController generateLogEntryWith:@"\tInspected outcome category \tMaximum Flooded Area"];
    [tabController writeToLogFileString:logEntry];
    
}


- (void) waterDepthTapped {
    for(StackedBar *bar in _stackedBars) {
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.waterFlow.frame.size.height/ barHeightMultiplier];
        [bar changeText:text];
        [bar changeTextColor:[scoreColors objectForKey:@"puddleTime"]];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideScores) object:nil];
    [self performSelector:@selector(hideScores)
               withObject:nil
               afterDelay:3.0];
    
    
    NSString *logEntry = [tabController generateLogEntryWith:@"\tInspected outcome category \tWater Flow"];
    [tabController writeToLogFileString:logEntry];
    
}


- (void) interventionCapTapped {
    for(StackedBar *bar in _stackedBars) {
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.capacity.frame.size.height/ barHeightMultiplier];
        [bar changeText:text];
        [bar changeTextColor:[scoreColors objectForKey:@"capacity"]];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideScores) object:nil];
    [self performSelector:@selector(hideScores)
               withObject:nil
               afterDelay:3.0];
    
    
    NSString *logEntry = [tabController generateLogEntryWith:@"\tInspected outcome category \tIntervention Capacity"];
    [tabController writeToLogFileString:logEntry];
    
}


- (void) efficiencyTapped {
    for(StackedBar *bar in _stackedBars) {
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.efficiency.frame.size.height/ barHeightMultiplier];
        [bar changeText:text];
        [bar changeTextColor:[scoreColors objectForKey:@"efficiencyOfIntervention"]];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideScores) object:nil];
    [self performSelector:@selector(hideScores)
               withObject:nil
               afterDelay:3.0];
    
    
    NSString *logEntry = [tabController generateLogEntryWith:@"\tInspected outcome category \tEfficiency of Intervention"];
    [tabController writeToLogFileString:logEntry];
    
}


- (void) damageReducTapped {
    for(StackedBar *bar in _stackedBars) {
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.damageReduction.frame.size.height/ barHeightMultiplier];
        [bar changeText:text];
        [bar changeTextColor:[scoreColors objectForKey:@"privateCost"]];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideScores) object:nil];
    [self performSelector:@selector(hideScores)
               withObject:nil
               afterDelay:3.0];
    
    
    NSString *logEntry = [tabController generateLogEntryWith:@"\tInspected outcome category \tDamage Reduction"];
    [tabController writeToLogFileString:logEntry];
    
}


- (void) investmentTapped {
    for(StackedBar *bar in _stackedBars) {
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.investment.frame.size.height/ barHeightMultiplier];
        [bar changeText:text];
        [bar changeTextColor:[scoreColors objectForKey:@"publicCost"]];
    }

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideScores) object:nil];
    [self performSelector:@selector(hideScores)
               withObject:nil
               afterDelay:3.0];
    
    
    NSString *logEntry = [tabController generateLogEntryWith:@"\tInspected outcome category \tInvestment"];
    [tabController writeToLogFileString:logEntry];
    
}

- (void) hideScores {
    for(StackedBar *bar in _stackedBars) {
        [bar changeText:@""];
        [bar changeTextColor:[UIColor clearColor]];
    }
}


@end

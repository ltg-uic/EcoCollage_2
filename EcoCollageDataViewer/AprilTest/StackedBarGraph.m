//
//  StackedBarGraph.m
//  AprilTest
//
//  Created by Ugrad Research on 11/5/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import "StackedBarGraph.h"

@implementation StackedBarGraph

@synthesize stackedBars = _stackedBars;

NSMutableArray *trialGroups;

int barHeightMultiplier = 4;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame andTabController:(AprilTestTabBarController *)tabControl withContainers:(int)wC{
    self = [super initWithFrame:frame];
    
    
    _stackedBars = [[NSMutableArray alloc]init];
    

    
    // fill this with the max scores for each outcome category over the span of all trials and all users
    NSMutableArray *maxScores = [[NSMutableArray alloc]init];
    
    int maxInvestment = 0, maxDamageReduction = 0, maxEfficiency = 0, maxCapacity = 0, maxWaterFlow = 0, maxMaxFlood = 0, maxGroundwaterInfiltration = 0, maxImpact = 0;
    
    
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
    
    int sumMaxScores = maxInvestment + maxDamageReduction + maxEfficiency + maxCapacity + maxWaterFlow + maxMaxFlood + maxGroundwaterInfiltration + maxImpact;
    sumMaxScores *= barHeightMultiplier;
    
    int x_initial = 125;
    int x = x_initial;
    int y = frame.size.height;
    int width = 40;
    int spaceBetweenTrials = 25;
    
    // draw lines for x and y axis
    int xAxisLength = (width * tabControl.profiles.count + spaceBetweenTrials) * tabControl.trialRuns.count + 100;
    UIView *xAxis = [[UIView alloc]initWithFrame:CGRectMake(x_initial, y, xAxisLength, 1)];
    [xAxis setBackgroundColor:[UIColor blackColor]];
    [self addSubview:xAxis];
    
    int yAxisHeight = (maxInvestment + maxDamageReduction + maxEfficiency + maxCapacity + maxWaterFlow + maxMaxFlood + maxGroundwaterInfiltration + maxImpact) * 4 + 70;
    UIView *yAxis = [[UIView alloc]initWithFrame:CGRectMake(x_initial, y - yAxisHeight, 1, yAxisHeight)];
    [yAxis setBackgroundColor:[UIColor blackColor]];
    [self addSubview:yAxis];
    
    trialGroups = [[NSMutableArray alloc]init];

    // create a stackedBar for each trial for each profile
    for(int i = 0; i < tabControl.trialNum; i++) {
        
        NSMutableArray *trialGroup = [[NSMutableArray alloc]init];
        
        for(int j = 0; j < tabControl.profiles.count; j++) {
            NSMutableArray* scores = [tabControl getScoreBarValuesForProfile:j forTrial:i isDynamicTrial:0];
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resize:)];
            tapRecognizer.numberOfTapsRequired = 1;
            
            StackedBar *bar = [[StackedBar alloc]initWithFrame:CGRectMake(x, y, width, -sumMaxScores) andProfile:[tabControl.profiles objectAtIndex:j] andScores:scores andScaleSize:1 andMaxScores:maxScores withContainers:wC withHeightMultipler:barHeightMultiplier];
            
            
            
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
            
            //[bar setUserInteractionEnabled:YES];
            //[bar addGestureRecognizer:tapRecognizer];
            
            [trialGroup addObject:bar];
            
            x += width+1;
        }
        [trialGroups addObject: trialGroup];
        x += spaceBetweenTrials;
    }
    
    // create UILabel for each trial
    int i = 0;
    for(NSMutableArray *mArray in trialGroups) {
        if(mArray.count == 0) break;
        StackedBar *fBar = [mArray objectAtIndex:0];
        StackedBar *lBar = [mArray objectAtIndex:mArray.count - 1];
        UILabel *trialLabel = [[UILabel alloc]initWithFrame:CGRectMake(fBar.frame.origin.x, fBar.frame.origin.y + fBar.frame.size.height + 50, lBar.frame.origin.x + lBar.frame.size.width - fBar.frame.origin.x, 20)];
        trialLabel.tag = i;
        [trialLabel setText:[NSString stringWithFormat:@"Trial %d", i+1]];
        [trialLabel setTextAlignment:NSTextAlignmentCenter];
        [trialLabel setUserInteractionEnabled:YES];
        UITapGestureRecognizer *trialTapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(trialTapped:)];
        trialTapped.numberOfTapsRequired = 1;
        [trialLabel addGestureRecognizer:trialTapped];
        
        [self addSubview:trialLabel];
        
        i++;
    }
    
    UILabel *yAxisLabel = [[UILabel alloc]init];
    [yAxisLabel setText:@"Performance"];
    [yAxisLabel setTextAlignment:NSTextAlignmentCenter];
    [yAxisLabel sizeToFit];
    [yAxisLabel setFrame:CGRectMake(x_initial - yAxisLabel.frame.size.width - 20, y - yAxisHeight, yAxisLabel.frame.size.width, yAxisHeight)];
    
    [self addSubview:yAxisLabel];
    
    
    // add all the bars to this view
    for(StackedBar *s in _stackedBars) {
        [self addSubview:s];
    }
    
    [self setContentSize:CGSizeMake(x + 40, self.frame.size.height + y)];
    [self setContentOffset:CGPointMake(0, y - self.frame.size.height)];
 
    return self;
}

- (void) trialTapped:(UITapGestureRecognizer *)gr {
    UILabel *trialLabel = (UILabel*)gr.view;
    
    NSMutableArray *mArray = [trialGroups objectAtIndex:trialLabel.tag];
    for(StackedBar *bar in mArray) {
        CGPoint center = bar.center;
        
        // if it is shrunk, we need to grow it
        if(bar.shrunk == 1) {
            [bar grow];
            [bar setCenter:center];
            bar.shrunk = 0;
        }
        else { // otherwise, we need to shrink it
            [bar shrink];
            [bar setCenter:center];
            bar.shrunk = 1;
        }
    }
}

- (void)resize:(UITapGestureRecognizer *)gr {
    StackedBar *sb = (StackedBar*)gr.view;
    
    CGPoint center = sb.center;
    
    // if it is shrunk, we need to grow it
    if(sb.shrunk == 1) {
        [sb grow];
        [sb setCenter:center];
        sb.shrunk = 0;
    }
    else { // otherwise, we need to shrink it
        [sb shrink];
        [sb setCenter:center];
        sb.shrunk = 1;
    }
}


- (void) impactTapped {
    for(StackedBar *bar in _stackedBars) {
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.impact.frame.size.height/barHeightMultiplier];
        [bar changeText:text];
    }
}


- (void) groundwaterTapped {
    for(StackedBar *bar in _stackedBars) {
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.groundwaterInfiltration.frame.size.height/ barHeightMultiplier];
        [bar changeText:text];
    }
}


- (void) maxFloodTapped {
    for(StackedBar *bar in _stackedBars) {
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.maxFlood.frame.size.height/ barHeightMultiplier];
        [bar changeText:text];
    }
}


- (void) waterDepthTapped {
    for(StackedBar *bar in _stackedBars) {
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.waterFlow.frame.size.height/ barHeightMultiplier];
        [bar changeText:text];
    }
}


- (void) interventionCapTapped {
    for(StackedBar *bar in _stackedBars) {
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.capacity.frame.size.height/ barHeightMultiplier];
        [bar changeText:text];
    }
}


- (void) efficiencyTapped {
    for(StackedBar *bar in _stackedBars) {
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.efficiency.frame.size.height/ barHeightMultiplier];
        [bar changeText:text];
    }
}


- (void) damageReducTapped {
    for(StackedBar *bar in _stackedBars) {
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.damageReduction.frame.size.height/ barHeightMultiplier];
        [bar changeText:text];
    }
}


- (void) investmentTapped {
    for(StackedBar *bar in _stackedBars) {
        NSString *text = [NSString stringWithFormat:@"%d", (int)bar.investment.frame.size.height/ barHeightMultiplier];
        [bar changeText:text];
    }
}


@end

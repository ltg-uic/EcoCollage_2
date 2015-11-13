//
//  StackedBar.m
//  AprilTest
//
//  Created by Ugrad Research on 11/5/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import "StackedBar.h"

@implementation StackedBar

// create a UIView for each outcome category
// also create a "container" for each outcome category
// this container serves to hold the view to allow for blank space between stacks on the bar
@synthesize investmentContainer = _investmentContainer;
@synthesize investment = _investment;

@synthesize damageReductionContainer = _damageReductionContainer;
@synthesize damageReduction = _damageReduction;

@synthesize efficiencyContainer = _efficiencyContainer;
@synthesize efficiency = _efficiency;

@synthesize capacityContainer = _capacityContainer;
@synthesize capacity = _capacity;

@synthesize waterFlowContainer = _waterFlowContainer;
@synthesize waterFlow = _waterFlow;

@synthesize maxFloodContainer = _maxFloodContainer;
@synthesize maxFlood = _maxFlood;

@synthesize groundwaterInfiltrationContainer = _groundwaterInfiltrationContainer;
@synthesize groundwaterInfiltration = _groundwaterInfiltration;

@synthesize impactContainer = _impactContainer;
@synthesize impact = _impact;

@synthesize score = _score;

@synthesize shrunk = _shrunk;


NSMutableDictionary *concernNames;
NSMutableDictionary *scoreColors;


int orderedStrictly;
int withContainers;
int scaledToScreen;
int heightMultiplier;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (id)initWithFrame:(CGRect)frame andProfile:(NSMutableArray *)profile andScores:(NSMutableArray *)scores andScaleSize:(float)scaleSize andMaxScores:(NSMutableArray *)maxScores withContainers:(int)wC withHeightMultipler:(int)hM
{
    self = [super initWithFrame:frame];
    
    _shrunk = 0;
    
    int width = frame.size.width;
 
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
    

    NSMutableArray* scoreVisVals = [scores objectAtIndex:0];
    NSMutableArray* scoreVisNames = [scores objectAtIndex:1];
    
    orderedStrictly = 1;
    withContainers = wC;
    scaledToScreen = 1;
    heightMultiplier = hM;
    
    
    // order the individual scores based on this users concerns
    NSMutableArray *userConcerns = [[NSMutableArray alloc]init];
    
    if(orderedStrictly) { // order the individual bars based on the concerns of this user
        for(int i = 3; i < profile.count; i++) {
            if([[profile objectAtIndex:i] isEqualToString:@"Damage Reduction"])
                [userConcerns addObject:@"privateCostD"];
            else
                [userConcerns addObject:[concernNames objectForKey:[profile objectAtIndex:i]]];
        }
    }
    
    _investmentContainer = [[UIView alloc]init];
    _investment = [[UIView alloc]init];
    _damageReductionContainer = [[UIView alloc]init];
    _damageReduction = [[UIView alloc]init];
    _efficiencyContainer = [[UIView alloc]init];
    _efficiency = [[UIView alloc]init];
    _capacityContainer = [[UIView alloc]init];
    _capacity = [[UIView alloc]init];
    _waterFlowContainer = [[UIView alloc]init];
    _waterFlow = [[UIView alloc]init];
    _maxFloodContainer = [[UIView alloc]init];
    _maxFlood = [[UIView alloc]init];
    _groundwaterInfiltrationContainer = [[UIView alloc]init];
    _groundwaterInfiltration = [[UIView alloc]init];
    _impactContainer = [[UIView alloc]init];
    _impact = [[UIView alloc]init];
    _score = [[UILabel alloc]init];
    
    // create a border around the containers
    _investmentContainer.layer.borderWidth = 1;
    _damageReductionContainer.layer.borderWidth = 1;
    _efficiencyContainer.layer.borderWidth = 1;
    _capacityContainer.layer.borderWidth = 1;
    _waterFlowContainer.layer.borderWidth = 1;
    _maxFloodContainer.layer.borderWidth = 1;
    _groundwaterInfiltrationContainer.layer.borderWidth = 1;
    _impactContainer.layer.borderWidth = 1;
    
    _investmentContainer.layer.borderColor = [UIColor grayColor].CGColor;
    _damageReductionContainer.layer.borderColor = [UIColor grayColor].CGColor;
    _efficiencyContainer.layer.borderColor = [UIColor grayColor].CGColor;
    _capacityContainer.layer.borderColor = [UIColor grayColor].CGColor;
    _waterFlowContainer.layer.borderColor = [UIColor grayColor].CGColor;
    _maxFloodContainer.layer.borderColor = [UIColor grayColor].CGColor;
    _groundwaterInfiltrationContainer.layer.borderColor = [UIColor grayColor].CGColor;
    _impactContainer.layer.borderColor = [UIColor grayColor].CGColor;

    
    int currHeight = self.superview.frame.size.height;
    
    if(!orderedStrictly) {
        [userConcerns removeAllObjects];
        for(int k = 3; k < [profile count]; k++) {
            [userConcerns addObject:[concernNames objectForKey:[profile objectAtIndex:k]]];
        }
    }
    
    // get the max values with which to make the container sizes
    int maxInvestment = [[maxScores objectAtIndex:0]integerValue];
    int maxDamageReduction = [[maxScores objectAtIndex:1]integerValue];
    int maxEfficiency = [[maxScores objectAtIndex:2]integerValue];
    int maxCapacity = [[maxScores objectAtIndex:3]integerValue];
    int maxWaterFlow = [[maxScores objectAtIndex:4]integerValue];
    int maxMaxFlood = [[maxScores objectAtIndex:5]integerValue];
    int maxGroundwaterInfiltration = [[maxScores objectAtIndex:6]integerValue];
    int maxImpact = [[maxScores objectAtIndex:7]integerValue];
    
    
    for(int k = 0; k < scoreVisNames.count; k++) {
        int heightOfThisCategory;
        int indexOfScore = 0;
        NSString *visName = [[NSString alloc]init];
        for(int l = 0; l < [userConcerns count]; l++) {
            if([[scoreVisNames objectAtIndex:l ]isEqualToString:[userConcerns objectAtIndex:k]]) {
                indexOfScore = l;
                visName = [scoreVisNames objectAtIndex:l];
                break;
            }
        }
        heightOfThisCategory = [[scoreVisVals objectAtIndex:indexOfScore]floatValue] * 100;
        heightOfThisCategory *= heightMultiplier;
        if(scaledToScreen) heightOfThisCategory = heightOfThisCategory * scaleSize;
        if (heightOfThisCategory < 0) heightOfThisCategory = 0;
        
        if([visName isEqualToString:@"publicCost"]) {
            if(withContainers) {
                if(scaledToScreen)
                    [_investmentContainer setFrame:CGRectMake(0, currHeight - scaleSize * (maxInvestment * heightMultiplier), width, scaleSize * maxInvestment * heightMultiplier + 1)];
                else
                    [_investmentContainer setFrame:CGRectMake(0, currHeight - (maxInvestment * heightMultiplier), width, maxInvestment * heightMultiplier + 1)];
            }
            [_investment setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_investment setBackgroundColor:[scoreColors objectForKey:@"publicCost"]];
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * maxInvestment * heightMultiplier + 2;
                else
                    currHeight -= maxInvestment * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"privateCostD"]) {
            if(withContainers) {
                if(scaledToScreen)
                    [_damageReductionContainer setFrame:CGRectMake(0, currHeight - scaleSize * (maxDamageReduction * heightMultiplier), width, scaleSize * maxDamageReduction * heightMultiplier + 1)];
                else
                    [_damageReductionContainer setFrame:CGRectMake(0, currHeight - (maxDamageReduction * heightMultiplier), width, maxDamageReduction * heightMultiplier + 1)];
            }
            [_damageReduction setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_damageReduction setBackgroundColor:[scoreColors objectForKey:@"privateCost"]];
            
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * maxDamageReduction * heightMultiplier + 2;
                else
                    currHeight -= maxDamageReduction * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"impactingMyNeighbors"]) {
            if(withContainers) {
                if(scaledToScreen)
                    [_impactContainer setFrame:CGRectMake(0, currHeight - scaleSize * (maxImpact * heightMultiplier), width, scaleSize * maxImpact * heightMultiplier + 1)];
                else
                    [_impactContainer setFrame:CGRectMake(0, currHeight - (maxImpact * heightMultiplier), width, maxImpact * heightMultiplier + 1)];
            }
            [_impact setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_impact setBackgroundColor:[scoreColors objectForKey:@"impactingMyNeighbors"]];
            
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * maxImpact * heightMultiplier + 2;
                else
                    currHeight -= maxImpact * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"groundwaterInfiltration"]) {
            if(withContainers) {
                if(scaledToScreen)
                    [_groundwaterInfiltrationContainer setFrame:CGRectMake(0, currHeight - scaleSize * (maxGroundwaterInfiltration * heightMultiplier), width, scaleSize * maxGroundwaterInfiltration * heightMultiplier + 1)];
                else
                    [_groundwaterInfiltrationContainer setFrame:CGRectMake(0, currHeight - (maxGroundwaterInfiltration * heightMultiplier), width, maxGroundwaterInfiltration * heightMultiplier + 1)];
            }
            [_groundwaterInfiltration setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_groundwaterInfiltration setBackgroundColor:[scoreColors objectForKey:@"groundwaterInfiltration"]];
            
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * maxGroundwaterInfiltration * heightMultiplier + 2;
                else
                    currHeight -= maxGroundwaterInfiltration * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"puddleTime"]) {
            if(withContainers) {
                if(scaledToScreen)
                    [_waterFlowContainer setFrame:CGRectMake(0, currHeight - scaleSize * (maxWaterFlow * heightMultiplier), width, scaleSize * maxWaterFlow * heightMultiplier + 1)];
                else
                    [_waterFlowContainer setFrame:CGRectMake(0, currHeight - (maxWaterFlow * heightMultiplier), width, maxWaterFlow * heightMultiplier + 1)];
            }
            [_waterFlow setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_waterFlow setBackgroundColor:[scoreColors objectForKey:@"puddleTime"]];
            
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * maxWaterFlow * heightMultiplier + 2;
                else
                    currHeight -= maxWaterFlow * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"puddleMax"]) {
            if(withContainers) {
                if(scaledToScreen)
                    [_maxFloodContainer setFrame:CGRectMake(0, currHeight - scaleSize * (maxMaxFlood * heightMultiplier), width, scaleSize * maxMaxFlood * heightMultiplier + 1)];
                else
                    [_maxFloodContainer setFrame:CGRectMake(0, currHeight - (maxMaxFlood * heightMultiplier), width, maxMaxFlood * heightMultiplier + 1)];
            }
            [_maxFlood setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_maxFlood setBackgroundColor:[scoreColors objectForKey:@"puddleMax"]];
            
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * maxMaxFlood * heightMultiplier + 2;
                else
                    currHeight -= maxMaxFlood * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"capacity"]) {
            if(withContainers) {
                if(scaledToScreen)
                    [_capacityContainer setFrame:CGRectMake(0, currHeight - scaleSize * (maxCapacity * heightMultiplier), width, scaleSize * maxCapacity * heightMultiplier + 1)];
                else
                    [_capacityContainer setFrame:CGRectMake(0, currHeight - (maxCapacity * heightMultiplier), width, maxCapacity * heightMultiplier + 1)];
            }
            [_capacity setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_capacity setBackgroundColor:[scoreColors objectForKey:@"capacity"]];
            
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * maxCapacity * heightMultiplier + 2;
                else
                    currHeight -= maxCapacity * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"efficiencyOfIntervention"]){
            if(withContainers) {
                if(scaledToScreen)
                    [_efficiencyContainer setFrame:CGRectMake(0, currHeight - scaleSize * (maxEfficiency * heightMultiplier), width, scaleSize * maxEfficiency * heightMultiplier + 1)];
                else
                    [_efficiencyContainer setFrame:CGRectMake(0, currHeight - (maxEfficiency * heightMultiplier), width, maxEfficiency * heightMultiplier + 1)];
            }
            [_efficiency setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_efficiency setBackgroundColor:[scoreColors objectForKey:@"efficiencyOfIntervention"]];
            
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * maxEfficiency * heightMultiplier + 2;
                else
                    currHeight -= maxEfficiency * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        }
    }
    _score.frame = CGRectMake(0, currHeight - 20, width, 20);
    _score.text = @"";
    _score.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    [_score setTextAlignment:NSTextAlignmentCenter];
    
    
/*
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
    
    
    if(withContainers) {
        _impactContainer.userInteractionEnabled = YES;
        _groundwaterInfiltrationContainer.userInteractionEnabled = YES;
        _maxFloodContainer.userInteractionEnabled = YES;
        _waterFlowContainer.userInteractionEnabled = YES;
        _capacityContainer.userInteractionEnabled = YES;
        _efficiencyContainer.userInteractionEnabled = YES;
        _damageReductionContainer.userInteractionEnabled = YES;
        _investmentContainer.userInteractionEnabled = YES;
        
        [_impactContainer addGestureRecognizer:impactRecognizer];
        [_groundwaterInfiltrationContainer addGestureRecognizer:groundwaterRecognizer];
        [_maxFloodContainer addGestureRecognizer:maxFloodRecognizer];
        [_waterFlowContainer addGestureRecognizer:waterFlowRecognizer];
        [_capacityContainer addGestureRecognizer:interventionCapRecognizer];
        [_efficiencyContainer addGestureRecognizer:efficiencyRecognizer];
        [_damageReductionContainer addGestureRecognizer:damageReducRecognizer];
        [_investmentContainer addGestureRecognizer:investmentRecognizer];
    }
    else {
        _impact.userInteractionEnabled = YES;
        _groundwaterInfiltration.userInteractionEnabled = YES;
        _maxFlood.userInteractionEnabled = YES;
        _waterFlow.userInteractionEnabled = YES;
        _capacity.userInteractionEnabled = YES;
        _efficiency.userInteractionEnabled = YES;
        _damageReduction.userInteractionEnabled = YES;
        _investment.userInteractionEnabled = YES;
        
        [_impact addGestureRecognizer:impactRecognizer];
        [_groundwaterInfiltration addGestureRecognizer:groundwaterRecognizer];
        [_maxFlood addGestureRecognizer:maxFloodRecognizer];
        [_waterFlow addGestureRecognizer:waterFlowRecognizer];
        [_capacity addGestureRecognizer:interventionCapRecognizer];
        [_efficiency addGestureRecognizer:efficiencyRecognizer];
        [_damageReduction addGestureRecognizer:damageReducRecognizer];
        [_investment addGestureRecognizer:investmentRecognizer];
    }
*/
    
    [self addSubview:_impact];
    [self addSubview:_impactContainer];
    [self addSubview:_groundwaterInfiltration];
    [self addSubview:_groundwaterInfiltrationContainer];
    [self addSubview:_maxFlood];
    [self addSubview:_maxFloodContainer];
    [self addSubview:_waterFlow];
    [self addSubview:_waterFlowContainer];
    [self addSubview:_capacity];
    [self addSubview:_capacityContainer];
    [self addSubview:_efficiency];
    [self addSubview:_efficiencyContainer];
    [self addSubview:_damageReduction];
    [self addSubview:_damageReductionContainer];
    [self addSubview:_investment];
    [self addSubview:_investmentContainer];
    [self addSubview:_score];

    
    return self;
}

- (void) changeText:(NSString *)text {
    _score.text = text;
}

- (void)shrink {
    int shrinkFactor = 2;
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width / shrinkFactor, self.frame.size.height)];
    [_impact setFrame:CGRectMake(_impact.frame.origin.x, _impact.frame.origin.y, _impact.frame.size.width / shrinkFactor, _impact.frame.size.height)];
    [_impactContainer setFrame:CGRectMake(_impactContainer.frame.origin.x, _impactContainer.frame.origin.y, _impactContainer.frame.size.width / shrinkFactor, _impactContainer.frame.size.height)];
    [_investment setFrame:CGRectMake(_investment.frame.origin.x, _investment.frame.origin.y, _investment.frame.size.width / shrinkFactor, _investment.frame.size.height)];
    [_investmentContainer setFrame:CGRectMake(_investmentContainer.frame.origin.x, _investmentContainer.frame.origin.y, _investmentContainer.frame.size.width / shrinkFactor, _investmentContainer.frame.size.height)];
    [_groundwaterInfiltration setFrame:CGRectMake(_groundwaterInfiltration.frame.origin.x, _groundwaterInfiltration.frame.origin.y, _groundwaterInfiltration.frame.size.width / shrinkFactor, _groundwaterInfiltration.frame.size.height)];
    [_groundwaterInfiltrationContainer setFrame:CGRectMake(_groundwaterInfiltrationContainer.frame.origin.x, _groundwaterInfiltrationContainer.frame.origin.y, _groundwaterInfiltrationContainer.frame.size.width / shrinkFactor, _groundwaterInfiltrationContainer.frame.size.height)];
    [_maxFlood setFrame:CGRectMake(_maxFlood.frame.origin.x, _maxFlood.frame.origin.y, _maxFlood.frame.size.width / shrinkFactor, _maxFlood.frame.size.height)];
    [_maxFloodContainer setFrame:CGRectMake(_maxFloodContainer.frame.origin.x, _maxFloodContainer.frame.origin.y, _maxFloodContainer.frame.size.width / shrinkFactor, _maxFloodContainer.frame.size.height)];
    [_efficiency setFrame:CGRectMake(_efficiency.frame.origin.x, _efficiency.frame.origin.y, _efficiency.frame.size.width / shrinkFactor, _efficiency.frame.size.height)];
    [_efficiencyContainer setFrame:CGRectMake(_efficiencyContainer.frame.origin.x, _efficiencyContainer.frame.origin.y, _efficiencyContainer.frame.size.width / shrinkFactor, _efficiencyContainer.frame.size.height)];
    [_damageReduction setFrame:CGRectMake(_damageReduction.frame.origin.x, _damageReduction.frame.origin.y, _damageReduction.frame.size.width / shrinkFactor, _damageReduction.frame.size.height)];
    [_damageReductionContainer setFrame:CGRectMake(_damageReductionContainer.frame.origin.x, _damageReductionContainer.frame.origin.y, _damageReductionContainer.frame.size.width / shrinkFactor, _damageReductionContainer.frame.size.height)];
    [_waterFlow setFrame:CGRectMake(_waterFlow.frame.origin.x, _waterFlow.frame.origin.y, _waterFlow.frame.size.width / shrinkFactor, _waterFlow.frame.size.height)];
    [_waterFlowContainer setFrame:CGRectMake(_waterFlowContainer.frame.origin.x, _waterFlowContainer.frame.origin.y, _waterFlowContainer.frame.size.width / shrinkFactor, _waterFlowContainer.frame.size.height)];
    [_capacity setFrame:CGRectMake(_capacity.frame.origin.x, _capacity.frame.origin.y, _capacity.frame.size.width / shrinkFactor, _capacity.frame.size.height)];
    [_capacityContainer setFrame:CGRectMake(_capacityContainer.frame.origin.x, _capacityContainer.frame.origin.y, _capacityContainer.frame.size.width / shrinkFactor, _capacityContainer.frame.size.height)];
    
    
    [_score setFrame:CGRectMake(_score.frame.origin.x, _score.frame.origin.y, _score.frame.size.width / shrinkFactor, _score.frame.size.height)];
}

- (void)grow {
    int growFactor = 2;
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width * growFactor, self.frame.size.height)];
    [_impact setFrame:CGRectMake(_impact.frame.origin.x, _impact.frame.origin.y, _impact.frame.size.width * growFactor, _impact.frame.size.height)];
    [_impactContainer setFrame:CGRectMake(_impactContainer.frame.origin.x, _impactContainer.frame.origin.y, _impactContainer.frame.size.width * growFactor, _impactContainer.frame.size.height)];
    [_investment setFrame:CGRectMake(_investment.frame.origin.x, _investment.frame.origin.y, _investment.frame.size.width * growFactor, _investment.frame.size.height)];
    [_investmentContainer setFrame:CGRectMake(_investmentContainer.frame.origin.x, _investmentContainer.frame.origin.y, _investmentContainer.frame.size.width * growFactor, _investmentContainer.frame.size.height)];
    [_groundwaterInfiltration setFrame:CGRectMake(_groundwaterInfiltration.frame.origin.x, _groundwaterInfiltration.frame.origin.y, _groundwaterInfiltration.frame.size.width * growFactor, _groundwaterInfiltration.frame.size.height)];
    [_groundwaterInfiltrationContainer setFrame:CGRectMake(_groundwaterInfiltrationContainer.frame.origin.x, _groundwaterInfiltrationContainer.frame.origin.y, _groundwaterInfiltrationContainer.frame.size.width * growFactor, _groundwaterInfiltrationContainer.frame.size.height)];
    [_maxFlood setFrame:CGRectMake(_maxFlood.frame.origin.x, _maxFlood.frame.origin.y, _maxFlood.frame.size.width * growFactor, _maxFlood.frame.size.height)];
    [_maxFloodContainer setFrame:CGRectMake(_maxFloodContainer.frame.origin.x, _maxFloodContainer.frame.origin.y, _maxFloodContainer.frame.size.width * growFactor, _maxFloodContainer.frame.size.height)];
    [_efficiency setFrame:CGRectMake(_efficiency.frame.origin.x, _efficiency.frame.origin.y, _efficiency.frame.size.width * growFactor, _efficiency.frame.size.height)];
    [_efficiencyContainer setFrame:CGRectMake(_efficiencyContainer.frame.origin.x, _efficiencyContainer.frame.origin.y, _efficiencyContainer.frame.size.width * growFactor, _efficiencyContainer.frame.size.height)];
    [_damageReduction setFrame:CGRectMake(_damageReduction.frame.origin.x, _damageReduction.frame.origin.y, _damageReduction.frame.size.width * growFactor, _damageReduction.frame.size.height)];
    [_damageReductionContainer setFrame:CGRectMake(_damageReductionContainer.frame.origin.x, _damageReductionContainer.frame.origin.y, _damageReductionContainer.frame.size.width * growFactor, _damageReductionContainer.frame.size.height)];
    [_waterFlow setFrame:CGRectMake(_waterFlow.frame.origin.x, _waterFlow.frame.origin.y, _waterFlow.frame.size.width * growFactor, _waterFlow.frame.size.height)];
    [_waterFlowContainer setFrame:CGRectMake(_waterFlowContainer.frame.origin.x, _waterFlowContainer.frame.origin.y, _waterFlowContainer.frame.size.width * growFactor, _waterFlowContainer.frame.size.height)];
    [_capacity setFrame:CGRectMake(_capacity.frame.origin.x, _capacity.frame.origin.y, _capacity.frame.size.width * growFactor, _capacity.frame.size.height)];
    [_capacityContainer setFrame:CGRectMake(_capacityContainer.frame.origin.x, _capacityContainer.frame.origin.y, _capacityContainer.frame.size.width * growFactor, _capacityContainer.frame.size.height)];
    
    [_score setFrame:CGRectMake(_score.frame.origin.x, _score.frame.origin.y, _score.frame.size.width * growFactor, _score.frame.size.height)];
}


@end

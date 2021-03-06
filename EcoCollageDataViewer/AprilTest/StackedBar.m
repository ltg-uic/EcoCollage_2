//
//  StackedBar.m
//  AprilTest
//
//  Created by Ryan Fogarty on 11/5/15.
//  Copyright (c) 2015 Joey Shelley. All rights reserved.
//

#import "StackedBar.h"

@implementation StackedBar

// create a UIView for each outcome category
// also create a "container" for each outcome category
// this container serves to hold the view to allow for blank space between stacks on the bar
@synthesize investmentContainer = _investmentContainer;
@synthesize investmentEmpty = _investmentEmpty;
@synthesize investment = _investment;

@synthesize damageReductionContainer = _damageReductionContainer;
@synthesize damageReductionEmpty = _damageReductionEmpty;
@synthesize damageReduction = _damageReduction;

@synthesize efficiencyContainer = _efficiencyContainer;
@synthesize efficiencyEmpty = _efficiencyEmpty;
@synthesize efficiency = _efficiency;

@synthesize capacityContainer = _capacityContainer;
@synthesize capacityEmpty = _capacityEmpty;
@synthesize capacity = _capacity;

@synthesize waterFlowContainer = _waterFlowContainer;
@synthesize waterFlowEmpty = _waterFlowEmpty;
@synthesize waterFlow = _waterFlow;

@synthesize maxFloodContainer = _maxFloodContainer;
@synthesize maxFloodEmpty = _maxFloodEmpty;
@synthesize maxFlood = _maxFlood;

@synthesize groundwaterInfiltrationContainer = _groundwaterInfiltrationContainer;
@synthesize groundwaterInfiltrationEmpty = _groundwaterInfiltrationEmpty;
@synthesize groundwaterInfiltration = _groundwaterInfiltration;

@synthesize impactContainer = _impactContainer;
@synthesize impactEmpty = _impactEmpty;
@synthesize impact = _impact;

@synthesize outcomeCategoryViews = _outcomeCategoryViews;
@synthesize outcomeCategoryContainers = _outcomeCategoryContainers;
@synthesize outcomeCategoryEmpties = _outcomeCategoryEmpties;

@synthesize score = _score;

@synthesize shrunk = _shrunk;
@synthesize name = _name;

@synthesize favorite = _favorite;
@synthesize leastFavorite = _leastFavorite;

@synthesize hasContainers = _hasContainers;

@synthesize investmentOriginalY = _investmentOriginalY;
@synthesize damageReductionOriginalY = _damageReductionOriginalY;
@synthesize impactOriginalY = _impactOriginalY;
@synthesize groundwaterInfiltrationOriginalY = _groundwaterInfiltrationOriginalY;
@synthesize waterFlowOriginalY = _waterFlowOriginalY;
@synthesize maxFloodOriginalY = _maxFloodOriginalY;
@synthesize capacityOriginalY = _capacityOriginalY;
@synthesize efficiencyOriginalY = _efficiencyOriginalY;


NSMutableDictionary *concernNames;
NSMutableDictionary *scoreColors;
NSMutableDictionary *scoreColorsDesaturated;

int orderedStrictly;
int withContainers;
int scaledToScreen;
int heightMultiplier;
int width;


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (id)initWithFrame:(CGRect)frame andProfile:(NSMutableArray *)profile andScores:(NSMutableArray *)scores andScaleSize:(float)scaleSize andTierSizes:(NSMutableArray *)tierSizes withContainers:(int)wC withHeightMultipler:(int)hM withScore:(float*)totalScore trialNum:(int)trialNumber
{
    self = [super initWithFrame:frame];
    
    _hasContainers = wC;
    
    _outcomeCategoryViews = [[NSMutableArray alloc]init];
    _outcomeCategoryContainers = [[NSMutableArray alloc]init];
    _outcomeCategoryEmpties = [[NSMutableArray alloc]init];
    
    _shrunk = 0;
    
    width = frame.size.width;
    
    _name = [[UILabel alloc]init];
    
    NSString *name = [profile objectAtIndex:2];
    [_name setText:[name substringWithRange:NSMakeRange(0, (name.length > 3) ? 3 : name.length)]];
    [_name setFont:[UIFont systemFontOfSize:12]];
    [_name sizeToFit];
    [_name setTextAlignment:NSTextAlignmentCenter];
 
    concernNames = [[NSMutableDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects: @"publicCost", @"privateCost", @"efficiencyOfIntervention", @"capacity", @"greatestDepthWater", @"totalAreaFlooded", @"groundwaterInfiltration", @"impactingMyNeighbors", nil] forKeys:[[NSArray alloc] initWithObjects:@"Investment", @"Damage Reduction", @"Efficiency of Intervention ($/Gallon)", @"Capacity Used", @"Water Flow Path", @"Max Depth of Flooding", @"Groundwater Infiltration", @"Impact on my Neighbors", nil]];
    
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
                    [UIColor colorWithHue:.55 saturation:.8 brightness:.9 alpha: 0.5], nil]  forKeys: [[NSArray alloc] initWithObjects: @"publicCost", @"publicCostI", @"publicCostM", @"publicCostD", @"privateCost", @"privateCostI", @"privateCostM", @"privateCostD",  @"efficiencyOfIntervention", @"greatestDepthWater", @"totalAreaFlooded", @"groundwaterInfiltration", @"impactingMyNeighbors", @"capacity", nil] ];
    
    scoreColorsDesaturated = [[NSMutableDictionary alloc] initWithObjects:
                   [NSArray arrayWithObjects:
                    [UIColor colorWithHue:.3 saturation:.6 brightness:.9 alpha: 0.25],
                    [UIColor colorWithHue:.31 saturation:.6 brightness:.91 alpha: 0.25],
                    [UIColor colorWithHue:.32 saturation:.6 brightness:.92 alpha: 0.25],
                    [UIColor colorWithHue:.33 saturation:.6 brightness:.93 alpha: 0.25],
                    [UIColor colorWithHue:.35 saturation:.8 brightness:.6 alpha: 0.25],
                    [UIColor colorWithHue:.36 saturation:.8 brightness:.61 alpha: 0.25],
                    [UIColor colorWithHue:.37 saturation:.8 brightness:.62 alpha: 0.25],
                    [UIColor colorWithHue:.38 saturation:.8 brightness:.63 alpha: 0.25],
                    [UIColor colorWithHue:.4 saturation:.8 brightness:.3 alpha: 0.25],
                    [UIColor colorWithHue:.65 saturation:.8 brightness:.6 alpha: 0.25],
                    [UIColor colorWithHue:.6 saturation:.8 brightness:.3 alpha: 0.25],
                    [UIColor colorWithHue:.6 saturation:.0 brightness:.3 alpha: 0.25],
                    [UIColor colorWithHue:.6 saturation:.0 brightness:.9 alpha: 0.25],
                    [UIColor colorWithHue:.55 saturation:.8 brightness:.9 alpha: 0.25], nil]  forKeys: [[NSArray alloc] initWithObjects: @"publicCost", @"publicCostI", @"publicCostM", @"publicCostD", @"privateCost", @"privateCostI", @"privateCostM", @"privateCostD",  @"efficiencyOfIntervention", @"greatestDepthWater", @"totalAreaFlooded", @"groundwaterInfiltration", @"impactingMyNeighbors", @"capacity", nil] ];
    

    NSMutableArray* scoreVisVals = [scores objectAtIndex:0];
    NSMutableArray* scoreVisNames = [scores objectAtIndex:1];
    
    orderedStrictly = 1;
    withContainers = wC;
    scaledToScreen = 1;
    heightMultiplier = hM;
    
    
    _favorite = [[FavoriteView alloc]initWithFrame:CGRectMake(0, 0, 40, 40) andTrialNumber:trialNumber];
    [_favorite setUserInteractionEnabled:NO];
    [_favorite setActive:NO];
    [_favorite setHidden:YES];
    
    _leastFavorite = [[LeastFavoriteView alloc]initWithFrame:CGRectMake(0, 0, 40, 40) andTrialNumber:trialNumber];
    [_leastFavorite setUserInteractionEnabled:NO];
    [_leastFavorite setActive:NO];
    [_leastFavorite setHidden:YES];
    
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
    _investmentEmpty = [[UIView alloc]init];
    _investment = [[UIView alloc]init];
    _damageReductionContainer = [[UIView alloc]init];
    _damageReductionEmpty = [[UIView alloc]init];
    _damageReduction = [[UIView alloc]init];
    _efficiencyContainer = [[UIView alloc]init];
    _efficiencyEmpty = [[UIView alloc]init];
    _efficiency = [[UIView alloc]init];
    _capacityContainer = [[UIView alloc]init];
    _capacityEmpty = [[UIView alloc]init];
    _capacity = [[UIView alloc]init];
    _waterFlowContainer = [[UIView alloc]init];
    _waterFlowEmpty = [[UIView alloc]init];
    _waterFlow = [[UIView alloc]init];
    _maxFloodContainer = [[UIView alloc]init];
    _maxFloodEmpty = [[UIView alloc]init];
    _maxFlood = [[UIView alloc]init];
    _groundwaterInfiltrationContainer = [[UIView alloc]init];
    _groundwaterInfiltrationEmpty = [[UIView alloc]init];
    _groundwaterInfiltration = [[UIView alloc]init];
    _impactContainer = [[UIView alloc]init];
    _impactEmpty = [[UIView alloc]init];
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
    
    
    for(int k = 0; k < scoreVisNames.count - 1; k++) {
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
        *totalScore += heightOfThisCategory;
        
        int containerSize = [[tierSizes objectAtIndex:k]integerValue];
        
        if([visName isEqualToString:@"publicCost"]) {
            if(withContainers) {
                if(scaledToScreen) {
                    [_investmentContainer setFrame:CGRectMake(0, currHeight - scaleSize * (containerSize * heightMultiplier), width, scaleSize * containerSize * heightMultiplier + 1)];
                    [_investmentEmpty setFrame:CGRectMake(0, _investmentContainer.frame.origin.y, width, scaleSize * (containerSize * heightMultiplier - heightOfThisCategory))];
                }
                else {
                    [_investmentContainer setFrame:CGRectMake(0, currHeight - (containerSize * heightMultiplier), width, containerSize * heightMultiplier + 1)];
                    [_investmentEmpty setFrame:CGRectMake(0, _investmentContainer.frame.origin.y, width, (containerSize  * heightMultiplier - heightOfThisCategory))];
                }
            }
            [_investment setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_investment setBackgroundColor:[scoreColors objectForKey:@"publicCost"]];
            [_investmentContainer setBackgroundColor:[scoreColorsDesaturated objectForKey:@"publicCost"]];
            _investmentOriginalY = _investment.frame.origin.y;
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * containerSize * heightMultiplier + 2;
                else
                    currHeight -= containerSize * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"privateCostD"]) {
            if(withContainers) {
                if(scaledToScreen) {
                    [_damageReductionContainer setFrame:CGRectMake(0, currHeight - scaleSize * (containerSize * heightMultiplier), width, scaleSize * containerSize * heightMultiplier + 1)];
                    [_damageReductionEmpty setFrame:CGRectMake(0, _damageReductionContainer.frame.origin.y, width, scaleSize * (containerSize * heightMultiplier - heightOfThisCategory))];
                }
                else {
                    [_damageReductionContainer setFrame:CGRectMake(0, currHeight - (containerSize * heightMultiplier), width, containerSize * heightMultiplier + 1)];
                    [_damageReductionEmpty setFrame:CGRectMake(0, _damageReductionContainer.frame.origin.y, width, (containerSize  * heightMultiplier - heightOfThisCategory))];
                }
            }
            [_damageReduction setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_damageReduction setBackgroundColor:[scoreColors objectForKey:@"privateCost"]];
            [_damageReductionContainer setBackgroundColor:[scoreColorsDesaturated objectForKey:@"privateCost"]];
            _damageReductionOriginalY = _damageReduction.frame.origin.y;
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * containerSize * heightMultiplier + 2;
                else
                    currHeight -= containerSize * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"impactingMyNeighbors"]) {
            if(withContainers) {
                if(scaledToScreen) {
                    [_impactContainer setFrame:CGRectMake(0, currHeight - scaleSize * (containerSize * heightMultiplier), width, scaleSize * containerSize * heightMultiplier + 1)];
                    [_impactEmpty setFrame:CGRectMake(0, _impactContainer.frame.origin.y, width, scaleSize * (containerSize * heightMultiplier - heightOfThisCategory))];
                }
                else {
                    [_impactContainer setFrame:CGRectMake(0, currHeight - (containerSize * heightMultiplier), width, containerSize * heightMultiplier + 1)];
                    [_impactEmpty setFrame:CGRectMake(0, _impactContainer.frame.origin.y, width, (containerSize  * heightMultiplier - heightOfThisCategory))];
                }
            }
            [_impact setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_impact setBackgroundColor:[scoreColors objectForKey:@"impactingMyNeighbors"]];
            [_impactContainer setBackgroundColor:[scoreColorsDesaturated objectForKey:@"impactingMyNeighbors"]];
            _impactOriginalY = _impact.frame.origin.y;
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * containerSize * heightMultiplier + 2;
                else
                    currHeight -= containerSize * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"groundwaterInfiltration"]) {
            if(withContainers) {
                if(scaledToScreen) {
                    [_groundwaterInfiltrationContainer setFrame:CGRectMake(0, currHeight - scaleSize * (containerSize * heightMultiplier), width, scaleSize * containerSize * heightMultiplier + 1)];
                    [_groundwaterInfiltrationEmpty setFrame:CGRectMake(0, _groundwaterInfiltrationContainer.frame.origin.y, width, scaleSize * (containerSize * heightMultiplier - heightOfThisCategory))];
                }
                else {
                    [_groundwaterInfiltrationContainer setFrame:CGRectMake(0, currHeight - (containerSize * heightMultiplier), width, containerSize * heightMultiplier + 1)];
                    [_groundwaterInfiltrationEmpty setFrame:CGRectMake(0, _groundwaterInfiltrationContainer.frame.origin.y, width, (containerSize  * heightMultiplier - heightOfThisCategory))];
                }
            }
            [_groundwaterInfiltration setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_groundwaterInfiltration setBackgroundColor:[scoreColors objectForKey:@"groundwaterInfiltration"]];
            [_groundwaterInfiltrationContainer setBackgroundColor:[scoreColorsDesaturated objectForKey:@"groundwaterInfiltration"]];
            _groundwaterInfiltrationOriginalY = _groundwaterInfiltration.frame.origin.y;
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * containerSize * heightMultiplier + 2;
                else
                    currHeight -= containerSize * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"greatestDepthWater"]) {
            if(withContainers) {
                if(scaledToScreen) {
                    [_waterFlowContainer setFrame:CGRectMake(0, currHeight - scaleSize * (containerSize * heightMultiplier), width, scaleSize * containerSize * heightMultiplier + 1)];
                    [_waterFlowEmpty setFrame:CGRectMake(0, _waterFlowContainer.frame.origin.y, width, scaleSize * (containerSize * heightMultiplier - heightOfThisCategory))];
                }
                else {
                    [_waterFlowContainer setFrame:CGRectMake(0, currHeight - (containerSize * heightMultiplier), width, containerSize * heightMultiplier + 1)];
                    [_waterFlowEmpty setFrame:CGRectMake(0, _waterFlowContainer.frame.origin.y, width, (containerSize  * heightMultiplier - heightOfThisCategory))];
                }
            }
            [_waterFlow setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_waterFlow setBackgroundColor:[scoreColors objectForKey:@"greatestDepthWater"]];
            [_waterFlowContainer setBackgroundColor:[scoreColorsDesaturated objectForKey:@"greatestDepthWater"]];
            _waterFlowOriginalY = _waterFlow.frame.origin.y;
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * containerSize * heightMultiplier + 2;
                else
                    currHeight -= containerSize * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"totalAreaFlooded"]) {
            if(withContainers) {
                if(scaledToScreen) {
                    [_maxFloodContainer setFrame:CGRectMake(0, currHeight - scaleSize * (containerSize * heightMultiplier), width, scaleSize * containerSize * heightMultiplier + 1)];
                    [_maxFloodEmpty setFrame:CGRectMake(0, _maxFloodContainer.frame.origin.y, width, scaleSize * (containerSize * heightMultiplier - heightOfThisCategory))];
                }
                else {
                    [_maxFloodContainer setFrame:CGRectMake(0, currHeight - (containerSize * heightMultiplier), width, containerSize * heightMultiplier + 1)];
                    [_maxFloodEmpty setFrame:CGRectMake(0, _maxFloodContainer.frame.origin.y, width, (containerSize  * heightMultiplier - heightOfThisCategory))];
                }
            }
            [_maxFlood setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_maxFlood setBackgroundColor:[scoreColors objectForKey:@"totalAreaFlooded"]];
            [_maxFloodContainer setBackgroundColor:[scoreColorsDesaturated objectForKey:@"totalAreaFlooded"]];
            _maxFloodOriginalY = _maxFlood.frame.origin.y;
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * containerSize * heightMultiplier + 2;
                else
                    currHeight -= containerSize * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"capacity"]) {
            if(withContainers) {
                if(scaledToScreen) {
                    [_capacityContainer setFrame:CGRectMake(0, currHeight - scaleSize * (containerSize * heightMultiplier), width, scaleSize * containerSize * heightMultiplier + 1)];
                    [_capacityEmpty setFrame:CGRectMake(0, _capacityContainer.frame.origin.y, width, scaleSize * (containerSize * heightMultiplier - heightOfThisCategory))];
                }
                else {
                    [_capacityContainer setFrame:CGRectMake(0, currHeight - (containerSize * heightMultiplier), width, containerSize * heightMultiplier + 1)];
                    [_capacityEmpty setFrame:CGRectMake(0, _capacityContainer.frame.origin.y, width, (containerSize  * heightMultiplier - heightOfThisCategory))];
                }
            }
            [_capacity setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_capacity setBackgroundColor:[scoreColors objectForKey:@"capacity"]];
            [_capacityContainer setBackgroundColor:[scoreColorsDesaturated objectForKey:@"capacity"]];
            _capacityOriginalY = _capacity.frame.origin.y;
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * containerSize * heightMultiplier + 2;
                else
                    currHeight -= containerSize * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"efficiencyOfIntervention"]){
            if(withContainers) {
                if(scaledToScreen) {
                    [_efficiencyContainer setFrame:CGRectMake(0, currHeight - scaleSize * (containerSize * heightMultiplier), width, scaleSize * containerSize * heightMultiplier + 1)];
                    [_efficiencyEmpty setFrame:CGRectMake(0, _efficiencyContainer.frame.origin.y, width, scaleSize * (containerSize * heightMultiplier - heightOfThisCategory))];
                }
                else {
                    [_efficiencyContainer setFrame:CGRectMake(0, currHeight - (containerSize * heightMultiplier), width, containerSize * heightMultiplier + 1)];
                    [_efficiencyEmpty setFrame:CGRectMake(0, _efficiencyContainer.frame.origin.y, width, (containerSize  * heightMultiplier - heightOfThisCategory))];
                }
            }
            [_efficiency setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_efficiency setBackgroundColor:[scoreColors objectForKey:@"efficiencyOfIntervention"]];
            [_efficiencyContainer setBackgroundColor:[scoreColorsDesaturated objectForKey:@"efficiencyOfIntervention"]];
            _efficiencyOriginalY = _efficiency.frame.origin.y;
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * containerSize * heightMultiplier + 2;
                else
                    currHeight -= containerSize * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        }
    }
    if(wC)
        _score.frame = CGRectMake(0, currHeight - 21, width, 20);
    else
        _score.frame = CGRectMake(0, currHeight - 25, width, 20);
    _score.text = @"";
    _score.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    [_score setTextAlignment:NSTextAlignmentCenter];
    
    [_outcomeCategoryViews addObject:_investment];
    [_outcomeCategoryViews addObject:_impact];
    [_outcomeCategoryViews addObject:_groundwaterInfiltration];
    [_outcomeCategoryViews addObject:_maxFlood];
    [_outcomeCategoryViews addObject:_waterFlow];
    [_outcomeCategoryViews addObject:_capacity];
    [_outcomeCategoryViews addObject:_efficiency];
    [_outcomeCategoryViews addObject:_damageReduction];
    
    [_outcomeCategoryContainers addObject:_investmentContainer];
    [_outcomeCategoryContainers addObject:_impactContainer];
    [_outcomeCategoryContainers addObject:_groundwaterInfiltrationContainer];
    [_outcomeCategoryContainers addObject:_maxFloodContainer];
    [_outcomeCategoryContainers addObject:_waterFlowContainer];
    [_outcomeCategoryContainers addObject:_capacityContainer];
    [_outcomeCategoryContainers addObject:_efficiencyContainer];
    [_outcomeCategoryContainers addObject:_damageReductionContainer];
    
    [_outcomeCategoryEmpties addObject:_investmentEmpty];
    [_outcomeCategoryEmpties addObject:_impactEmpty];
    [_outcomeCategoryEmpties addObject:_groundwaterInfiltrationEmpty];
    [_outcomeCategoryEmpties addObject:_maxFloodEmpty];
    [_outcomeCategoryEmpties addObject:_waterFlowEmpty];
    [_outcomeCategoryEmpties addObject:_capacityEmpty];
    [_outcomeCategoryEmpties addObject:_efficiencyEmpty];
    [_outcomeCategoryEmpties addObject:_damageReductionEmpty];
/*
    [_investmentEmpty setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"diag_hatch.jpg"]]];
    [_impactEmpty setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"diag_hatch.jpg"]]];
    [_groundwaterInfiltrationEmpty setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"diag_hatch.jpg"]]];
    [_maxFloodEmpty setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"diag_hatch.jpg"]]];
    [_waterFlowEmpty setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"diag_hatch.jpg"]]];
    [_capacityEmpty setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"diag_hatch.jpg"]]];
    [_efficiencyEmpty setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"diag_hatch.jpg"]]];
    [_damageReductionEmpty setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"diag_hatch.jpg"]]];
*/
    
    [self addSubview:_impact];
    [self addSubview:_groundwaterInfiltration];
    [self addSubview:_maxFlood];
    [self addSubview:_waterFlow];
    [self addSubview:_capacity];
    [self addSubview:_efficiency];
    [self addSubview:_damageReduction];
    [self addSubview:_investment];
    [self addSubview:_score];
    
    if(wC) {
        [self addSubview:_impactEmpty];
        [self addSubview:_impactContainer];
        [self addSubview:_groundwaterInfiltrationEmpty];
        [self addSubview:_groundwaterInfiltrationContainer];
        [self addSubview:_maxFloodEmpty];
        [self addSubview:_maxFloodContainer];
        [self addSubview:_waterFlowEmpty];
        [self addSubview:_waterFlowContainer];
        [self addSubview:_capacityEmpty];
        [self addSubview:_capacityContainer];
        [self addSubview:_efficiencyEmpty];
        [self addSubview:_efficiencyContainer];
        [self addSubview:_damageReductionEmpty];
        [self addSubview:_damageReductionContainer];
        [self addSubview:_investmentEmpty];
        [self addSubview:_investmentContainer];
    }

    
    return self;
}

- (void) reloadBar:(NSMutableArray *)profile andScores:(NSMutableArray *)scores andScaleSize:(float)scaleSize andTierSizes:(NSMutableArray *)tierSizes withContainers:(int)wC withHeightMultipler:(int)hM withScore:(float*)totalScore{

    NSString *name = [profile objectAtIndex:2];
    [_name setText:[name substringWithRange:NSMakeRange(0, (name.length > 3) ? 3 : name.length)]];
    [_name setFont:[UIFont systemFontOfSize:12]];
    [_name sizeToFit];
    [_name setTextAlignment:NSTextAlignmentCenter];
    
    
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
    
    int currHeight = self.superview.frame.size.height;
    
    if(!orderedStrictly) {
        [userConcerns removeAllObjects];
        for(int k = 3; k < [profile count]; k++) {
            [userConcerns addObject:[concernNames objectForKey:[profile objectAtIndex:k]]];
        }
    }
    
    for(int k = 0; k < scoreVisNames.count - 1; k++) {
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
        *totalScore += heightOfThisCategory;
        
        int containerSize = [[tierSizes objectAtIndex:k]integerValue];
        
        if([visName isEqualToString:@"publicCost"]) {
            if(withContainers) {
                if(scaledToScreen) {
                    [_investmentContainer setFrame:CGRectMake(0, currHeight - scaleSize * (containerSize * heightMultiplier), width, scaleSize * containerSize * heightMultiplier + 1)];
                    [_investmentEmpty setFrame:CGRectMake(0, _investmentContainer.frame.origin.y, width, scaleSize * (containerSize * heightMultiplier - heightOfThisCategory))];
                }
                else {
                    [_investmentContainer setFrame:CGRectMake(0, currHeight - (containerSize * heightMultiplier), width, containerSize * heightMultiplier + 1)];
                    [_investmentEmpty setFrame:CGRectMake(0, _investmentContainer.frame.origin.y, width, (containerSize  * heightMultiplier - heightOfThisCategory))];
                }
            }
            [_investment setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_investment setBackgroundColor:[scoreColors objectForKey:@"publicCost"]];
            [_investmentContainer setBackgroundColor:[scoreColorsDesaturated objectForKey:@"publicCost"]];
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * containerSize * heightMultiplier + 2;
                else
                    currHeight -= containerSize * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"privateCostD"]) {
            if(withContainers) {
                if(scaledToScreen) {
                    [_damageReductionContainer setFrame:CGRectMake(0, currHeight - scaleSize * (containerSize * heightMultiplier), width, scaleSize * containerSize * heightMultiplier + 1)];
                    [_damageReductionEmpty setFrame:CGRectMake(0, _damageReductionContainer.frame.origin.y, width, scaleSize * (containerSize * heightMultiplier - heightOfThisCategory))];
                }
                else {
                    [_damageReductionContainer setFrame:CGRectMake(0, currHeight - (containerSize * heightMultiplier), width, containerSize * heightMultiplier + 1)];
                    [_damageReductionEmpty setFrame:CGRectMake(0, _damageReductionContainer.frame.origin.y, width, (containerSize  * heightMultiplier - heightOfThisCategory))];
                }
            }
            [_damageReduction setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_damageReduction setBackgroundColor:[scoreColors objectForKey:@"privateCost"]];
            [_damageReductionContainer setBackgroundColor:[scoreColorsDesaturated objectForKey:@"privateCost"]];
            
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * containerSize * heightMultiplier + 2;
                else
                    currHeight -= containerSize * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"impactingMyNeighbors"]) {
            if(withContainers) {
                if(scaledToScreen) {
                    [_impactContainer setFrame:CGRectMake(0, currHeight - scaleSize * (containerSize * heightMultiplier), width, scaleSize * containerSize * heightMultiplier + 1)];
                    [_impactEmpty setFrame:CGRectMake(0, _impactContainer.frame.origin.y, width, scaleSize * (containerSize * heightMultiplier - heightOfThisCategory))];
                }
                else {
                    [_impactContainer setFrame:CGRectMake(0, currHeight - (containerSize * heightMultiplier), width, containerSize * heightMultiplier + 1)];
                    [_impactEmpty setFrame:CGRectMake(0, _impactContainer.frame.origin.y, width, (containerSize  * heightMultiplier - heightOfThisCategory))];
                }
            }
            [_impact setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_impact setBackgroundColor:[scoreColors objectForKey:@"impactingMyNeighbors"]];
            [_impactContainer setBackgroundColor:[scoreColorsDesaturated objectForKey:@"impactingMyNeighbors"]];
            
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * containerSize * heightMultiplier + 2;
                else
                    currHeight -= containerSize * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"groundwaterInfiltration"]) {
            if(withContainers) {
                if(scaledToScreen) {
                    [_groundwaterInfiltrationContainer setFrame:CGRectMake(0, currHeight - scaleSize * (containerSize * heightMultiplier), width, scaleSize * containerSize * heightMultiplier + 1)];
                    [_groundwaterInfiltrationEmpty setFrame:CGRectMake(0, _groundwaterInfiltrationContainer.frame.origin.y, width, scaleSize * (containerSize * heightMultiplier - heightOfThisCategory))];
                }
                else {
                    [_groundwaterInfiltrationContainer setFrame:CGRectMake(0, currHeight - (containerSize * heightMultiplier), width, containerSize * heightMultiplier + 1)];
                    [_groundwaterInfiltrationEmpty setFrame:CGRectMake(0, _groundwaterInfiltrationContainer.frame.origin.y, width, (containerSize  * heightMultiplier - heightOfThisCategory))];
                }
            }
            [_groundwaterInfiltration setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_groundwaterInfiltration setBackgroundColor:[scoreColors objectForKey:@"groundwaterInfiltration"]];
            [_groundwaterInfiltrationContainer setBackgroundColor:[scoreColorsDesaturated objectForKey:@"groundwaterInfiltration"]];
            
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * containerSize * heightMultiplier + 2;
                else
                    currHeight -= containerSize * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"greatestDepthWater"]) {
            if(withContainers) {
                if(scaledToScreen) {
                    [_waterFlowContainer setFrame:CGRectMake(0, currHeight - scaleSize * (containerSize * heightMultiplier), width, scaleSize * containerSize * heightMultiplier + 1)];
                    [_waterFlowEmpty setFrame:CGRectMake(0, _waterFlowContainer.frame.origin.y, width, scaleSize * (containerSize * heightMultiplier - heightOfThisCategory))];
                }
                else {
                    [_waterFlowContainer setFrame:CGRectMake(0, currHeight - (containerSize * heightMultiplier), width, containerSize * heightMultiplier + 1)];
                    [_waterFlowEmpty setFrame:CGRectMake(0, _waterFlowContainer.frame.origin.y, width, (containerSize  * heightMultiplier - heightOfThisCategory))];
                }
            }
            [_waterFlow setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_waterFlow setBackgroundColor:[scoreColors objectForKey:@"greatestDepthWater"]];
            [_waterFlowContainer setBackgroundColor:[scoreColorsDesaturated objectForKey:@"greatestDepthWater"]];
            
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * containerSize * heightMultiplier + 2;
                else
                    currHeight -= containerSize * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"totalAreaFlooded"]) {
            if(withContainers) {
                if(scaledToScreen) {
                    [_maxFloodContainer setFrame:CGRectMake(0, currHeight - scaleSize * (containerSize * heightMultiplier), width, scaleSize * containerSize * heightMultiplier + 1)];
                    [_maxFloodEmpty setFrame:CGRectMake(0, _maxFloodContainer.frame.origin.y, width, scaleSize * (containerSize * heightMultiplier - heightOfThisCategory))];
                }
                else {
                    [_maxFloodContainer setFrame:CGRectMake(0, currHeight - (containerSize * heightMultiplier), width, containerSize * heightMultiplier + 1)];
                    [_maxFloodEmpty setFrame:CGRectMake(0, _maxFloodContainer.frame.origin.y, width, (containerSize  * heightMultiplier - heightOfThisCategory))];
                }
            }
            [_maxFlood setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_maxFlood setBackgroundColor:[scoreColors objectForKey:@"totalAreaFlooded"]];
            [_maxFloodContainer setBackgroundColor:[scoreColorsDesaturated objectForKey:@"totalAreaFlooded"]];
            
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * containerSize * heightMultiplier + 2;
                else
                    currHeight -= containerSize * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"capacity"]) {
            if(withContainers) {
                if(scaledToScreen) {
                    [_capacityContainer setFrame:CGRectMake(0, currHeight - scaleSize * (containerSize * heightMultiplier), width, scaleSize * containerSize * heightMultiplier + 1)];
                    [_capacityEmpty setFrame:CGRectMake(0, _capacityContainer.frame.origin.y, width, scaleSize * (containerSize * heightMultiplier - heightOfThisCategory))];
                }
                else {
                    [_capacityContainer setFrame:CGRectMake(0, currHeight - (containerSize * heightMultiplier), width, containerSize * heightMultiplier + 1)];
                    [_capacityEmpty setFrame:CGRectMake(0, _capacityContainer.frame.origin.y, width, (containerSize  * heightMultiplier - heightOfThisCategory))];
                }
            }
            [_capacity setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_capacity setBackgroundColor:[scoreColors objectForKey:@"capacity"]];
            [_capacityContainer setBackgroundColor:[scoreColorsDesaturated objectForKey:@"capacity"]];
            
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * containerSize * heightMultiplier + 2;
                else
                    currHeight -= containerSize * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        } else if([visName isEqualToString:@"efficiencyOfIntervention"]){
            if(withContainers) {
                if(scaledToScreen) {
                    [_efficiencyContainer setFrame:CGRectMake(0, currHeight - scaleSize * (containerSize * heightMultiplier), width, scaleSize * containerSize * heightMultiplier + 1)];
                    [_efficiencyEmpty setFrame:CGRectMake(0, _efficiencyContainer.frame.origin.y, width, scaleSize * (containerSize * heightMultiplier - heightOfThisCategory))];
                }
                else {
                    [_efficiencyContainer setFrame:CGRectMake(0, currHeight - (containerSize * heightMultiplier), width, containerSize * heightMultiplier + 1)];
                    [_efficiencyEmpty setFrame:CGRectMake(0, _efficiencyContainer.frame.origin.y, width, (containerSize  * heightMultiplier - heightOfThisCategory))];
                }
            }
            [_efficiency setFrame:CGRectMake(0, currHeight - heightOfThisCategory, width, heightOfThisCategory)];
            [_efficiency setBackgroundColor:[scoreColors objectForKey:@"efficiencyOfIntervention"]];
            [_efficiencyContainer setBackgroundColor:[scoreColorsDesaturated objectForKey:@"efficiencyOfIntervention"]];
            
            if(withContainers) {
                if(scaledToScreen)
                    currHeight -= scaleSize * containerSize * heightMultiplier + 2;
                else
                    currHeight -= containerSize * heightMultiplier + 2;
            }
            else {
                if(scaledToScreen)
                    currHeight -= scaleSize * heightOfThisCategory;
                else
                    currHeight -= heightOfThisCategory;
            }
        }
    }
    
    if(wC)
        _score.frame = CGRectMake(0, currHeight - 21, width, 20);
    else
        _score.frame = CGRectMake(0, currHeight - 25, width, 20);
    _score.text = @"";
    _score.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    [_score setTextAlignment:NSTextAlignmentCenter];
}


- (void) changeText:(NSString *)text {
    _score.text = text;
}

- (void) changeTextColor:(UIColor *)color {
    _score.backgroundColor = color;
    if([color isEqual:[UIColor clearColor]]) [_score.layer setBorderWidth:0];
    else [_score.layer setBorderWidth:1];
}

- (void)revert {
    [_investment setFrame:CGRectMake(_investment.frame.origin.x, _investmentOriginalY, _investment.frame.size.width, _investment.frame.size.height)];
    [_damageReduction setFrame:CGRectMake(_damageReduction.frame.origin.x, _damageReductionOriginalY, _damageReduction.frame.size.width, _damageReduction.frame.size.height)];
    [_impact setFrame:CGRectMake(_impact.frame.origin.x, _impactOriginalY, _impact.frame.size.width, _impact.frame.size.height)];
    [_groundwaterInfiltration setFrame:CGRectMake(_groundwaterInfiltration.frame.origin.x, _groundwaterInfiltrationOriginalY, _groundwaterInfiltration.frame.size.width, _groundwaterInfiltration.frame.size.height)];
    [_waterFlow setFrame:CGRectMake(_waterFlow.frame.origin.x, _waterFlowOriginalY, _waterFlow.frame.size.width, _waterFlow.frame.size.height)];
    [_maxFlood setFrame:CGRectMake(_maxFlood.frame.origin.x, _maxFloodOriginalY, _maxFlood.frame.size.width, _maxFlood.frame.size.height)];
    [_capacity setFrame:CGRectMake(_capacity.frame.origin.x, _capacityOriginalY, _capacity.frame.size.width, _capacity.frame.size.height)];
    [_efficiency setFrame:CGRectMake(_efficiency.frame.origin.x, _efficiencyOriginalY, _efficiency.frame.size.width, _efficiency.frame.size.height)];
}

- (void)lineDown:(UIView *)score withContainer:(UIView *)container withEmpty:(UIView *)empty {
    int containerHeight = (container.frame.size.height == 0) ? score.frame.size.height: container.frame.size.height;
    
    
    for(UIView *otherScore in _outcomeCategoryViews) {
        if(![otherScore isEqual:score] && otherScore.frame.origin.y > score.frame.origin.y)
            [otherScore setFrame:CGRectMake(otherScore.frame.origin.x, otherScore.frame.origin.y - containerHeight, otherScore.frame.size.width, otherScore.frame.size.height)];
    }
    
    for(UIView *otherContainer in _outcomeCategoryContainers) {
        if(![otherContainer isEqual:container] && otherContainer.frame.origin.y > container.frame.origin.y)
            [otherContainer setFrame:CGRectMake(otherContainer.frame.origin.x, otherContainer.frame.origin.y - containerHeight, otherContainer.frame.size.width, otherContainer.frame.size.height)];
    }
    
    for(UIView *otherEmpty in _outcomeCategoryEmpties) {
        if(![otherEmpty isEqual:empty] && otherEmpty.frame.origin.y > empty.frame.origin.y)
            [otherEmpty setFrame:CGRectMake(otherEmpty.frame.origin.x, otherEmpty.frame.origin.y - containerHeight, otherEmpty.frame.size.width, otherEmpty.frame.size.height)];
    }
    
    // move to the bottom
    [score setFrame:CGRectMake(score.frame.origin.x, -score.frame.size.height, score.frame.size.width, score.frame.size.height)];
    [container setFrame:CGRectMake(container.frame.origin.x, -containerHeight, container.frame.size.width, container.frame.size.height)];
    [empty setFrame:CGRectMake(empty.frame.origin.x, -empty.frame.size.height, empty.frame.size.width, empty.frame.size.height)];
}


- (void)shrink {
    int shrinkFactor = 4;
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width / shrinkFactor, self.frame.size.height)];
    [_impact setFrame:CGRectMake(_impact.frame.origin.x, _impact.frame.origin.y, _impact.frame.size.width / shrinkFactor, _impact.frame.size.height)];
    [_impactEmpty setFrame:CGRectMake(_impactEmpty.frame.origin.x, _impactEmpty.frame.origin.y, _impactEmpty.frame.size.width / shrinkFactor, _impactEmpty.frame.size.height)];
    [_impactContainer setFrame:CGRectMake(_impactContainer.frame.origin.x, _impactContainer.frame.origin.y, _impactContainer.frame.size.width / shrinkFactor, _impactContainer.frame.size.height)];
    [_investment setFrame:CGRectMake(_investment.frame.origin.x, _investment.frame.origin.y, _investment.frame.size.width / shrinkFactor, _investment.frame.size.height)];
    [_investmentEmpty setFrame:CGRectMake(_investmentEmpty.frame.origin.x, _investmentEmpty.frame.origin.y, _investmentEmpty.frame.size.width / shrinkFactor, _investmentEmpty.frame.size.height)];
    [_investmentContainer setFrame:CGRectMake(_investmentContainer.frame.origin.x, _investmentContainer.frame.origin.y, _investmentContainer.frame.size.width / shrinkFactor, _investmentContainer.frame.size.height)];
    [_groundwaterInfiltration setFrame:CGRectMake(_groundwaterInfiltration.frame.origin.x, _groundwaterInfiltration.frame.origin.y, _groundwaterInfiltration.frame.size.width / shrinkFactor, _groundwaterInfiltration.frame.size.height)];
    [_groundwaterInfiltrationEmpty setFrame:CGRectMake(_groundwaterInfiltrationEmpty.frame.origin.x, _groundwaterInfiltrationEmpty.frame.origin.y, _groundwaterInfiltrationEmpty.frame.size.width / shrinkFactor, _groundwaterInfiltrationEmpty.frame.size.height)];
    [_groundwaterInfiltrationContainer setFrame:CGRectMake(_groundwaterInfiltrationContainer.frame.origin.x, _groundwaterInfiltrationContainer.frame.origin.y, _groundwaterInfiltrationContainer.frame.size.width / shrinkFactor, _groundwaterInfiltrationContainer.frame.size.height)];
    [_maxFlood setFrame:CGRectMake(_maxFlood.frame.origin.x, _maxFlood.frame.origin.y, _maxFlood.frame.size.width / shrinkFactor, _maxFlood.frame.size.height)];
    [_maxFloodEmpty setFrame:CGRectMake(_maxFloodEmpty.frame.origin.x, _maxFloodEmpty.frame.origin.y, _maxFloodEmpty.frame.size.width / shrinkFactor, _maxFloodEmpty.frame.size.height)];
    [_maxFloodContainer setFrame:CGRectMake(_maxFloodContainer.frame.origin.x, _maxFloodContainer.frame.origin.y, _maxFloodContainer.frame.size.width / shrinkFactor, _maxFloodContainer.frame.size.height)];
    [_efficiency setFrame:CGRectMake(_efficiency.frame.origin.x, _efficiency.frame.origin.y, _efficiency.frame.size.width / shrinkFactor, _efficiency.frame.size.height)];
    [_efficiencyEmpty setFrame:CGRectMake(_efficiencyEmpty.frame.origin.x, _efficiencyEmpty.frame.origin.y, _efficiencyEmpty.frame.size.width / shrinkFactor, _efficiencyEmpty.frame.size.height)];
    [_efficiencyContainer setFrame:CGRectMake(_efficiencyContainer.frame.origin.x, _efficiencyContainer.frame.origin.y, _efficiencyContainer.frame.size.width / shrinkFactor, _efficiencyContainer.frame.size.height)];
    [_damageReduction setFrame:CGRectMake(_damageReduction.frame.origin.x, _damageReduction.frame.origin.y, _damageReduction.frame.size.width / shrinkFactor, _damageReduction.frame.size.height)];
    [_damageReductionEmpty setFrame:CGRectMake(_damageReductionEmpty.frame.origin.x, _damageReductionEmpty.frame.origin.y, _damageReductionEmpty.frame.size.width / shrinkFactor, _damageReductionEmpty.frame.size.height)];
    [_damageReductionContainer setFrame:CGRectMake(_damageReductionContainer.frame.origin.x, _damageReductionContainer.frame.origin.y, _damageReductionContainer.frame.size.width / shrinkFactor, _damageReductionContainer.frame.size.height)];
    [_waterFlow setFrame:CGRectMake(_waterFlow.frame.origin.x, _waterFlow.frame.origin.y, _waterFlow.frame.size.width / shrinkFactor, _waterFlow.frame.size.height)];
    [_waterFlowEmpty setFrame:CGRectMake(_waterFlowEmpty.frame.origin.x, _waterFlowEmpty.frame.origin.y, _waterFlowEmpty.frame.size.width / shrinkFactor, _waterFlowEmpty.frame.size.height)];
    [_waterFlowContainer setFrame:CGRectMake(_waterFlowContainer.frame.origin.x, _waterFlowContainer.frame.origin.y, _waterFlowContainer.frame.size.width / shrinkFactor, _waterFlowContainer.frame.size.height)];
    [_capacity setFrame:CGRectMake(_capacity.frame.origin.x, _capacity.frame.origin.y, _capacity.frame.size.width / shrinkFactor, _capacity.frame.size.height)];
    [_capacityEmpty setFrame:CGRectMake(_capacityEmpty.frame.origin.x, _capacityEmpty.frame.origin.y, _capacityEmpty.frame.size.width / shrinkFactor, _capacityEmpty.frame.size.height)];
    [_capacityContainer setFrame:CGRectMake(_capacityContainer.frame.origin.x, _capacityContainer.frame.origin.y, _capacityContainer.frame.size.width / shrinkFactor, _capacityContainer.frame.size.height)];
    
    
    [_score setFrame:CGRectMake(_score.frame.origin.x, _score.frame.origin.y, _score.frame.size.width / shrinkFactor, _score.frame.size.height)];
}

- (void)grow {
    int growFactor = 4;
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width * growFactor, self.frame.size.height)];
    [_impact setFrame:CGRectMake(_impact.frame.origin.x, _impact.frame.origin.y, _impact.frame.size.width * growFactor, _impact.frame.size.height)];
    [_impactEmpty setFrame:CGRectMake(_impactEmpty.frame.origin.x, _impactEmpty.frame.origin.y, _impactEmpty.frame.size.width * growFactor, _impactEmpty.frame.size.height)];
    [_impactContainer setFrame:CGRectMake(_impactContainer.frame.origin.x, _impactContainer.frame.origin.y, _impactContainer.frame.size.width * growFactor, _impactContainer.frame.size.height)];
    [_investment setFrame:CGRectMake(_investment.frame.origin.x, _investment.frame.origin.y, _investment.frame.size.width * growFactor, _investment.frame.size.height)];
    [_investmentEmpty setFrame:CGRectMake(_investmentEmpty.frame.origin.x, _investmentEmpty.frame.origin.y, _investmentEmpty.frame.size.width * growFactor, _investmentEmpty.frame.size.height)];
    [_investmentContainer setFrame:CGRectMake(_investmentContainer.frame.origin.x, _investmentContainer.frame.origin.y, _investmentContainer.frame.size.width * growFactor, _investmentContainer.frame.size.height)];
    [_groundwaterInfiltration setFrame:CGRectMake(_groundwaterInfiltration.frame.origin.x, _groundwaterInfiltration.frame.origin.y, _groundwaterInfiltration.frame.size.width * growFactor, _groundwaterInfiltration.frame.size.height)];
    [_groundwaterInfiltrationEmpty setFrame:CGRectMake(_groundwaterInfiltrationEmpty.frame.origin.x, _groundwaterInfiltrationEmpty.frame.origin.y, _groundwaterInfiltrationEmpty.frame.size.width * growFactor, _groundwaterInfiltrationEmpty.frame.size.height)];
    [_groundwaterInfiltrationContainer setFrame:CGRectMake(_groundwaterInfiltrationContainer.frame.origin.x, _groundwaterInfiltrationContainer.frame.origin.y, _groundwaterInfiltrationContainer.frame.size.width * growFactor, _groundwaterInfiltrationContainer.frame.size.height)];
    [_maxFlood setFrame:CGRectMake(_maxFlood.frame.origin.x, _maxFlood.frame.origin.y, _maxFlood.frame.size.width * growFactor, _maxFlood.frame.size.height)];
    [_maxFloodEmpty setFrame:CGRectMake(_maxFloodEmpty.frame.origin.x, _maxFloodEmpty.frame.origin.y, _maxFloodEmpty.frame.size.width * growFactor, _maxFloodEmpty.frame.size.height)];
    [_maxFloodContainer setFrame:CGRectMake(_maxFloodContainer.frame.origin.x, _maxFloodContainer.frame.origin.y, _maxFloodContainer.frame.size.width * growFactor, _maxFloodContainer.frame.size.height)];
    [_efficiency setFrame:CGRectMake(_efficiency.frame.origin.x, _efficiency.frame.origin.y, _efficiency.frame.size.width * growFactor, _efficiency.frame.size.height)];
    [_efficiencyEmpty setFrame:CGRectMake(_efficiencyEmpty.frame.origin.x, _efficiencyEmpty.frame.origin.y, _efficiencyEmpty.frame.size.width * growFactor, _efficiencyEmpty.frame.size.height)];
    [_efficiencyContainer setFrame:CGRectMake(_efficiencyContainer.frame.origin.x, _efficiencyContainer.frame.origin.y, _efficiencyContainer.frame.size.width * growFactor, _efficiencyContainer.frame.size.height)];
    [_damageReduction setFrame:CGRectMake(_damageReduction.frame.origin.x, _damageReduction.frame.origin.y, _damageReduction.frame.size.width * growFactor, _damageReduction.frame.size.height)];
    [_damageReductionEmpty setFrame:CGRectMake(_damageReductionEmpty.frame.origin.x, _damageReductionEmpty.frame.origin.y, _damageReductionEmpty.frame.size.width * growFactor, _damageReductionEmpty.frame.size.height)];
    [_damageReductionContainer setFrame:CGRectMake(_damageReductionContainer.frame.origin.x, _damageReductionContainer.frame.origin.y, _damageReductionContainer.frame.size.width * growFactor, _damageReductionContainer.frame.size.height)];
    [_waterFlow setFrame:CGRectMake(_waterFlow.frame.origin.x, _waterFlow.frame.origin.y, _waterFlow.frame.size.width * growFactor, _waterFlow.frame.size.height)];
    [_waterFlowEmpty setFrame:CGRectMake(_waterFlowEmpty.frame.origin.x, _waterFlowEmpty.frame.origin.y, _waterFlowEmpty.frame.size.width * growFactor, _waterFlowEmpty.frame.size.height)];
    [_waterFlowContainer setFrame:CGRectMake(_waterFlowContainer.frame.origin.x, _waterFlowContainer.frame.origin.y, _waterFlowContainer.frame.size.width * growFactor, _waterFlowContainer.frame.size.height)];
    [_capacity setFrame:CGRectMake(_capacity.frame.origin.x, _capacity.frame.origin.y, _capacity.frame.size.width * growFactor, _capacity.frame.size.height)];
    [_capacityEmpty setFrame:CGRectMake(_capacityEmpty.frame.origin.x, _capacityEmpty.frame.origin.y, _capacityEmpty.frame.size.width * growFactor, _capacityEmpty.frame.size.height)];
    [_capacityContainer setFrame:CGRectMake(_capacityContainer.frame.origin.x, _capacityContainer.frame.origin.y, _capacityContainer.frame.size.width * growFactor, _capacityContainer.frame.size.height)];
    
    [_score setFrame:CGRectMake(_score.frame.origin.x, _score.frame.origin.y, _score.frame.size.width * growFactor, _score.frame.size.height)];
}


@end

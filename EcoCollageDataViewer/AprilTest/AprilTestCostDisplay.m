//
//  AprilTestCostDisplay.m
//  AprilTest
//
//  Created by Tia on 3/30/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import "AprilTestCostDisplay.h"

@implementation AprilTestCostDisplay
@synthesize cost = _cost;
@synthesize normScore = _normScore;
@synthesize budget = _budget;
@synthesize valueLabel = _valueLabel;
@synthesize budgetUsed = _budgetUsed;
@synthesize budgetOver = _budgetOver;

/*
- (id) initWithCost: (float) cost andMaxBudget: (float) max andbudgetLimit: (float) budgetLimit andScore: (float) normScore andFrame: (CGRect) frame
{
    self = [super initWithFrame:frame];
    
    _cost = cost;
    _normScore = normScore;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    _valueLabel = [[UILabel alloc] init];
    _valueLabel.text = [NSString stringWithFormat:@"Installation Cost $%@", [formatter stringFromNumber: [NSNumber numberWithInt:cost] ]];
    _valueLabel.frame =CGRectMake(0, 0, 0, 0);
    [_valueLabel sizeToFit ];
    _valueLabel.font = [UIFont systemFontOfSize:14.0];
    _valueLabel.textColor = [UIColor blackColor];
    [self addSubview:_valueLabel];
    
    _budget = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, frame.size.width, 20)];
    _budget.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:_budget];
    
    float widthBudgetUsed;
    if(normScore < 1)
        widthBudgetUsed = normScore;
    else
        widthBudgetUsed = 1;
    
    int budgetWidth = frame.size.width;
    
    _budgetUsed = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, widthBudgetUsed*budgetWidth , 20)];
    _budgetUsed.backgroundColor = [UIColor colorWithRed:.3 green:.8 blue:.3 alpha:1.0];
    [self addSubview:_budgetUsed];
    
    
    if(normScore > 1){
        normScore = (cost - max)/ (budgetLimit - max);
        
        //cap off the percentage at 100% if it happens to surpass it 
        if(normScore > 1)
            normScore = 1;
        
        _budgetOver = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width, 20, (normScore) * (160 - frame.size.width) , 20)];
        _budgetOver.backgroundColor = [UIColor redColor];
        [self addSubview:_budgetOver];
    }
    
    return self;
}

- (id) updateCDWithScore: (float) normScore andCost: (float) cost andMaxBudget: (float) max andbudgetLimit: (float) budgetLimit andFrame: (CGRect) frame
{
    _budget = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, frame.size.width, 20)];
    _budget.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:_budget];
    float widthBudgetUsed;
    if(normScore < 1)
        widthBudgetUsed = normScore;
    else
        widthBudgetUsed = 1;
    
    int budgetWidth = frame.size.width;
    
    _budgetUsed = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, widthBudgetUsed*budgetWidth , 20)];
    _budgetUsed.backgroundColor = [UIColor colorWithRed:.3 green:.8 blue:.3 alpha:1.0];
    [self addSubview:_budgetUsed];
    
    
    if(normScore > 1){
        normScore = (cost - max)/ (budgetLimit - max);
        
        //cap off the percentage at 100% if it happens to surpass it 
        if(normScore > 1)
            normScore = 1;
        
        _budgetOver = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width, 20, (normScore) * (160 - frame.size.width), 20)];
        _budgetOver.backgroundColor = [UIColor redColor];
        [self addSubview:_budgetOver];
    }
    
    return self;
}*/
 
 

- (id) initWithCost: (float)cost highestCost:(float) highestCost MaxBudget: (float) max MinLimit: (float) minLimit MaxLimit:(float) maxLimit Score: (float) normScore andFrame: (CGRect) frame
{
    self = [super initWithFrame:frame];
    
    _cost = cost;
    _normScore = normScore;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    _valueLabel = [[UILabel alloc] init];
    _valueLabel.text = [NSString stringWithFormat:@"Installation Cost $%@", [formatter stringFromNumber: [NSNumber numberWithInt:cost] ]];
    _valueLabel.frame =CGRectMake(0, 0, 0, 0);
    [_valueLabel sizeToFit ];
    _valueLabel.font = [UIFont systemFontOfSize:14.0];
    _valueLabel.textColor = [UIColor blackColor];
    [self addSubview:_valueLabel];
    
    float widthBudgetUsed;
    int budgetWidth;
    
    //static
    if (highestCost == -1){
        _budget = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, frame.size.width, 20)];
        _budget.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_budget];
        
        if(normScore < 1)
            widthBudgetUsed = normScore;
        else
            widthBudgetUsed = 1;
        
        budgetWidth = frame.size.width;
        
        _budgetUsed = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, widthBudgetUsed*budgetWidth , 20)];
        _budgetUsed.backgroundColor = [UIColor colorWithRed:.3 green:.8 blue:.3 alpha:1.0];
        [self addSubview:_budgetUsed];
        
        if(normScore > 1){
            normScore = (cost - max)/ (maxLimit - max);
            
            //cap off the percentage at 100% if it happens to surpass it
            if(normScore > 1)
                normScore = 1;
            
            _budgetOver = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width, 20, (normScore) * (160 - frame.size.width), 20)];
            _budgetOver.backgroundColor = [UIColor redColor];
            [self addSubview:_budgetOver];
        }
        
    }
    //Dynamic
    else{
         //set visualization for overall budget
        _budget = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, frame.size.width, 20)];
        
        _budget.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_budget];
        
        //budget used in respect to max budget set
        budgetWidth = normScore * frame.size.width;
        _budgetUsed = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, budgetWidth , 20)];
        _budgetUsed.backgroundColor = [UIColor colorWithRed:.3 green:.8 blue:.3 alpha:1.0];
        [self addSubview:_budgetUsed];
        
        //add red label if over budget
        if (cost > max){
            normScore = (cost - budgetWidth)/ (maxLimit - budgetWidth);
            
            if(normScore > 1)
                normScore = 1;
            
            _budgetOver = [[UILabel alloc] initWithFrame:CGRectMake(budgetWidth, 20, (normScore) * (160 - frame.size.width), 20)];
            _budgetOver.backgroundColor = [UIColor redColor];
            [self addSubview:_budgetOver];
        }
    }
    
    return self;
}

- (id) updateWithCost: (float)cost highestCost:(float) highestCost MaxBudget: (float) max MinLimit: (float) minLimit MaxLimit:(float) maxLimit Score: (float) normScore andFrame: (CGRect) frame
{
    float widthBudgetUsed;
    int budgetWidth;
    
    //static
    if (highestCost == -1){
        _budget = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, frame.size.width, 20)];
        _budget.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_budget];
        
        if(normScore < 1)
            widthBudgetUsed = normScore;
        else
            widthBudgetUsed = 1;
        
        budgetWidth = frame.size.width;
        
        _budgetUsed = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, widthBudgetUsed*budgetWidth , 20)];
        _budgetUsed.backgroundColor = [UIColor colorWithRed:.3 green:.8 blue:.3 alpha:1.0];
        [self addSubview:_budgetUsed];
        
        if(normScore > 1){
            normScore = (cost - max)/ (maxLimit - max);
            
            //cap off the percentage at 100% if it happens to surpass it
            if(normScore > 1)
                normScore = 1;
            
            _budgetOver = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width, 20, (normScore) * (160 - frame.size.width), 20)];
            _budgetOver.backgroundColor = [UIColor redColor];
            [self addSubview:_budgetOver];
        }
        
    }
    //Dynamic
    else{
        //set visualization for overall budget
        _budget = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, frame.size.width, 20)];
        
        _budget.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_budget];
        
        //budget used in respect to max budget set
         budgetWidth = normScore * frame.size.width;
        _budgetUsed = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, budgetWidth , 20)];
        _budgetUsed.backgroundColor = [UIColor colorWithRed:.3 green:.8 blue:.3 alpha:1.0];
        [self addSubview:_budgetUsed];
        
        //add red label if over budget
        if (cost > max){
            normScore = (cost - budgetWidth)/ (maxLimit - budgetWidth);
            
            if(normScore > 1)
                normScore = 1;
            
            _budgetOver = [[UILabel alloc] initWithFrame:CGRectMake(budgetWidth, 20, (normScore) * (160 - frame.size.width), 20)];
            _budgetOver.backgroundColor = [UIColor redColor];
            [self addSubview:_budgetOver];
        }
    }
    
    return self;
}

@end

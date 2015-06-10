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

- (id) initWithCost: (float) cost andScore: (float) normScore andFrame: (CGRect) frame
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
    _budgetUsed = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, widthBudgetUsed*frame.size.width , 20)];
    _budgetUsed.backgroundColor = [UIColor colorWithRed:.3 green:.8 blue:.3 alpha:1.0];
    [self addSubview:_budgetUsed];
    /*
    if(normScore > 1){
        UILabel *budgetOver = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width*.75, 20, (normScore - 1) * frame.size.width *.75, 20)];
        budgetOver.backgroundColor = [UIColor redColor];
        [self addSubview:budgetOver];
    }*/
    
    return self;
}

- (id) updateCDWithScore: (float) normScore andFrame: (CGRect) frame
{
    _budget = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, frame.size.width, 20)];
    _budget.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:_budget];
    float widthBudgetUsed;
    if(normScore < 1)
        widthBudgetUsed = normScore;
    else
        widthBudgetUsed = 1;
    _budgetUsed = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, widthBudgetUsed*frame.size.width , 20)];
    _budgetUsed.backgroundColor = [UIColor colorWithRed:.3 green:.8 blue:.3 alpha:1.0];
    [self addSubview:_budgetUsed];
    
    /*if(normScore > 1){
        UILabel *budgetOver = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width*.75, 20, (normScore - 1) * frame.size.width *.75, 20)];
        budgetOver.backgroundColor = [UIColor redColor];
        [self addSubview:budgetOver];
    }*/
    
    return self;
}


@end

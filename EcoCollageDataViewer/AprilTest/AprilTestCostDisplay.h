//
//  AprilTestCostDisplay.h
//  AprilTest
//
//  Created by Joey Shelley on 3/30/15.
//  Copyright (c) 2015 Joey Shelley. All rights reserved.
//

@interface AprilTestCostDisplay : UIView
@property UIView *view;
@property float cost;
@property float normScore;
@property UILabel *budget;
@property UILabel *valueLabel;
@property UILabel *budgetUsed;
@property UILabel *budgetOver;

/*
- (id) initWithCost: (float) cost andMaxBudget: (float) max andbudgetLimit: (float) budgetLimit andScore: (float) normScore andFrame: (CGRect) frame;
- (id) updateCDWithScore: (float) normScore andCost: (float) cost andMaxBudget: (float) budget andbudgetLimit: (float) budgetLimit andFrame: (CGRect) frame;
*/
- (id) initWithCost: (float)cost normScore:(float) normscore costWidth:(float) costWidth maxBudgetWidth:(float) MaxWidth andFrame: (CGRect) frame;
- (id) updateWithCost: (float)cost normScore:(float) normscore costWidth:(float) costWidth maxBudgetWidth:(float) MaxWidth andFrame: (CGRect) frame;
@end

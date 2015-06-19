//
//  AprilTestCostDisplay.h
//  AprilTest
//
//  Created by Tia on 3/30/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

@interface AprilTestCostDisplay : UIView
@property UIView *view;
@property float cost;
@property float normScore;
@property UILabel *budget;
@property UILabel *valueLabel;
@property UILabel *budgetUsed;
@property UILabel *budgetOver;


- (id) initWithCost: (float) cost andMaxBudget: (float) max andbudgetLimit: (float) budgetLimit andScore: (float) normScore andFrame: (CGRect) frame;
- (id) updateCDWithScore: (float) normScore andCost: (float) cost andMaxBudget: (float) budget andbudgetLimit: (float) budgetLimit andFrame: (CGRect) frame;
- (id) initWithCost: (float)cost highestCost:(float) highestCost MaxBudget: (float) max MinLimit: (float) minLimit MaxLimit:(float) maxLimit Score: (float) normScore andFrame: (CGRect) frame;
- (id) updateWithCost: (float)cost highestCost:(float) highestCost MaxBudget: (float) max MinLimit: (float) minLimit MaxLimit:(float) maxLimit Score: (float) normScore andFrame: (CGRect) frame;
@end

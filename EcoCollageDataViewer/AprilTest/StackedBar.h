//
//  StackedBar.h
//  AprilTest
//
//  Created by Ugrad Research on 11/5/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StackedBar : UIView

@property UIView *investmentContainer;
@property UIView *investment;

@property UIView *damageReductionContainer;
@property UIView *damageReduction;

@property UIView *efficiencyContainer;
@property UIView *efficiency;

@property UIView *capacityContainer;
@property UIView *capacity;

@property UIView *waterFlowContainer;
@property UIView *waterFlow;

@property UIView *maxFloodContainer;
@property UIView *maxFlood;

@property UIView *groundwaterInfiltrationContainer;
@property UIView *groundwaterInfiltration;

@property UIView *impactContainer;
@property UIView *impact;

@property UILabel *score;

@property int shrunk;


- (id)initWithFrame:(CGRect)frame andProfile:(NSMutableArray *)profile andScores:(NSMutableArray *)scores andScaleSize:(float)scaleSize andMaxScores:(NSMutableArray *)maxScores withContainers:(int)wC withHeightMultipler:(int)hM;

- (void)changeText:(NSString *)text;

- (void)shrink;

- (void)grow;

@end

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
@property UIView *investmentEmpty;
@property UIView *investment;

@property UIView *damageReductionContainer;
@property UIView *damageReductionEmpty;
@property UIView *damageReduction;

@property UIView *efficiencyContainer;
@property UIView *efficiencyEmpty;
@property UIView *efficiency;

@property UIView *capacityContainer;
@property UIView *capacityEmpty;
@property UIView *capacity;

@property UIView *waterFlowContainer;
@property UIView *waterFlowEmpty;
@property UIView *waterFlow;

@property UIView *maxFloodContainer;
@property UIView *maxFloodEmpty;
@property UIView *maxFlood;

@property UIView *groundwaterInfiltrationContainer;
@property UIView *groundwaterInfiltrationEmpty;
@property UIView *groundwaterInfiltration;

@property UIView *impactContainer;
@property UIView *impactEmpty;
@property UIView *impact;

@property UILabel *score;
@property UILabel *name;

@property int shrunk;


- (id)initWithFrame:(CGRect)frame andProfile:(NSMutableArray *)profile andScores:(NSMutableArray *)scores andScaleSize:(float)scaleSize andTierSizes:(NSMutableArray *)tierSizes withContainers:(int)wC withHeightMultipler:(int)hM;

- (void) reloadBar:(NSMutableArray *)profile andScores:(NSMutableArray *)scores andScaleSize:(float)scaleSize andTierSizes:(NSMutableArray *)tierSizes withContainers:(int)wC withHeightMultipler:(int)hM;
    

- (void)changeText:(NSString *)text;

- (void) changeTextColor:(UIColor *)color;

- (void)shrink;

- (void)grow;

@end

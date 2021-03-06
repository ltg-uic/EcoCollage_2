//
//  StackedBar.h
//  AprilTest
//
//  Created by Ryan Fogarty on 11/5/15.
//  Copyright (c) 2015 Joey Shelley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoriteView.h"
#import "LeastFavoriteView.h"

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

@property NSMutableArray *outcomeCategoryViews;
@property NSMutableArray *outcomeCategoryContainers;
@property NSMutableArray *outcomeCategoryEmpties;

@property UILabel *score;
@property UILabel *name;

@property FavoriteView *favorite;
@property LeastFavoriteView *leastFavorite;

@property float investmentOriginalY;
@property float damageReductionOriginalY;
@property float impactOriginalY;
@property float groundwaterInfiltrationOriginalY;
@property float waterFlowOriginalY;
@property float maxFloodOriginalY;
@property float capacityOriginalY;
@property float efficiencyOriginalY;

@property BOOL hasContainers;

@property int shrunk;

- (void)revert;

- (void)lineDown:(UIView *)score withContainer:(UIView *)container withEmpty:(UIView *)empty;

- (id)initWithFrame:(CGRect)frame andProfile:(NSMutableArray *)profile andScores:(NSMutableArray *)scores andScaleSize:(float)scaleSize andTierSizes:(NSMutableArray *)tierSizes withContainers:(int)wC withHeightMultipler:(int)hM withScore:(float*)totalScore trialNum:(int)trialNumber;

- (void) reloadBar:(NSMutableArray *)profile andScores:(NSMutableArray *)scores andScaleSize:(float)scaleSize andTierSizes:(NSMutableArray *)tierSizes withContainers:(int)wC withHeightMultipler:(int)hM withScore:(float*)totalScore;
    

- (void)changeText:(NSString *)text;

- (void) changeTextColor:(UIColor *)color;

- (void)shrink;

- (void)grow;

@end

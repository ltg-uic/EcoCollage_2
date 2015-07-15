//
//  FebTestWaterDisplay.h
//  FebTest
//
//  Created by Tia on 2/18/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FebTestWaterDisplay : UIView
@property NSArray *waterHeights;
@property UIView *view;
@property float thresholdValue;
@property bool threshold;
@property NSMutableArray * blocks;
- (id)initWithFrame:(CGRect)frame andContent: (NSString *)content;
- (void) updateView: (int) hoursAfterStorm;
- (void) fastUpdateView: (int) hoursAfterStorm;
- (UIImage*)viewToImage;
@end

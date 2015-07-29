//
//  LeastFavoriteView.h
//  AprilTest
//
//  Created by Ryan Fogarty on 7/29/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeastFavoriteView : UIImageView

@property BOOL isActive;
@property int  trialNum;

- (LeastFavoriteView *)initWithFrame:(CGRect)frame andTrialNumber:(int)trial;
- (BOOL)isTouched;
- (void)setFrame:(CGRect)frame andTrialNumber:(int)trial;
- (void)setActive:(BOOL)active;

@end

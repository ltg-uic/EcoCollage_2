//
//  FavoriteView.h
//  AprilTest
//
//  Created by Ryan Fogarty on 7/29/15.
//  Copyright (c) 2015 Joey Shelley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteView : UIImageView

@property BOOL isActive;
@property int  trialNum;

- (FavoriteView *)initWithFrame:(CGRect)frame andTrialNumber:(int)trial;
- (BOOL)isTouched;
- (void)setFrame:(CGRect)frame andTrialNumber:(int)trial;
- (void)setActive:(BOOL)active;

@end

//
//  LeastFavoriteView.m
//  AprilTest
//
//  Created by Ryan Fogarty on 7/29/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//
//  least_favorite_active.png and least_favorite_inactive.png images made by http://www.flaticon.com/authors/freepik from www.flaticon.com

#import "LeastFavoriteView.h"

@implementation LeastFavoriteView


@synthesize isActive = _isActive;

UIImage *leastFavoriteActive;
UIImage *leastFavoriteInactive;

- (LeastFavoriteView *)initWithFrame:(CGRect)frame andTrialNumber:(int)trial{
    self = [super initWithFrame:frame];
    
    self.trialNum = trial;
    
    leastFavoriteActive = [UIImage imageNamed: @"least_favorite_active_large.png"];
    leastFavoriteInactive = [UIImage imageNamed:@"least_favorite_inactive_large.png"];
    
    self.image = leastFavoriteInactive;
    
    _isActive = NO;
    
    return self;
}

- (BOOL)isTouched {
    if (_isActive == YES) {
        _isActive = NO;
        self.image = leastFavoriteInactive;
    }
    else {
        _isActive = YES;
        self.image = leastFavoriteActive;
    }
    
    return _isActive;
}

- (void)setFrame:(CGRect)frame andTrialNumber:(int)trial{
    [super setFrame:frame];
    
    if (_isActive != YES && _isActive != NO) {
        _isActive = NO;
        self.image = leastFavoriteInactive;
    }
    
    _trialNum = trial;
}

- (void)setActive:(BOOL)active {
    self.isActive = active;
    
    if(active == YES)
        self.image = leastFavoriteActive;
    else
        self.image = leastFavoriteInactive;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

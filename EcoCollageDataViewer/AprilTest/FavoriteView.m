//
//  FavoriteView.m
//  AprilTest
//
//  Created by Ryan Fogarty on 7/29/15.
//  Copyright (c) 2015 Joey Shelley. All rights reserved.
//
//  favorite_active.png and favorite_inactive.png images made by http://www.flaticon.com/authors/sarfraz-shoukat from www.flaticon.com

#import "FavoriteView.h"


@implementation FavoriteView

@synthesize isActive = _isActive;
@synthesize trialNum = _trialNum;

UIImage *favoriteActive;
UIImage *favoriteInactive;

- (FavoriteView *)initWithFrame:(CGRect)frame andTrialNumber:(int)trial{
    self = [super initWithFrame:frame];
    
    self.trialNum = trial;
    
    favoriteActive = [UIImage imageNamed: @"favorite_active_large.png"];
    favoriteInactive = [UIImage imageNamed:@"favorite_inactive_large.png"];
    
    self.image = favoriteInactive;
    
    _isActive = NO;
    
    return self;
}

- (BOOL)isTouched {
    if (_isActive == YES) {
        _isActive = NO;
        self.image = favoriteInactive;
    }
    else {
        _isActive = YES;
        self.image = favoriteActive;
    }
    
    return _isActive;
}

- (void)setFrame:(CGRect)frame andTrialNumber:(int)trial{
    [super setFrame:frame];
    
    if (_isActive != YES && _isActive != NO) {
        _isActive = NO;
        self.image = favoriteInactive;
    }
    
    _trialNum = trial;
}

- (void)setActive:(BOOL)active {
    self.isActive = active;
    
    if(active == YES)
        self.image = favoriteActive;
    else
        self.image = favoriteInactive;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  BabyBirdProfile.m
//  AprilTest
//
//  Created by Ryan Fogarty on 4/22/16.
//  Copyright (c) 2016 Joey Shelley. All rights reserved.
//

#import "BabyBirdProfile.h"

@implementation BabyBirdProfile

@synthesize concerns = _concerns;
@synthesize refreshConnection = _refreshConnection;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithConcerns:(NSString*)concerns {
    _concerns = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 50, 100)];
    _concerns.text = concerns;
    
    _refreshConnection = [[UIView alloc]initWithFrame:CGRectMake(70, 0, 30, 20)];
    [_refreshConnection setBackgroundColor:[UIColor redColor]];
    
    [self addSubview:_concerns];
    [self addSubview:_refreshConnection];
    
    return self;
}

@end

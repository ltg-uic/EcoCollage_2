//
//  BabyBird.m
//  AprilTest
//
//  Created by Ryan Fogarty on 9/8/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import "BabyBird.h"

@implementation BabyBird

@synthesize concernRanking = _concernRanking;
@synthesize trialScores = _trialScores;

@synthesize username = _username;
@synthesize deviceName = _deviceName;

AprilTestTabBarController *tabControl;

- (BabyBird*) initWithConcernRanking:(NSArray*)concernRanking username:(NSString*)username deviceName:(NSString*)deviceName tabControl:(AprilTestTabBarController**)tabController {
    int indexOffset = (int)concernRanking.count - 8;
    
    _concernRanking = [[NSMutableArray alloc]initWithObjects:[concernRanking objectAtIndex:indexOffset], [concernRanking objectAtIndex:indexOffset+1], [concernRanking objectAtIndex:indexOffset+2], [concernRanking objectAtIndex:indexOffset+3], [concernRanking objectAtIndex:indexOffset+4], [concernRanking objectAtIndex:indexOffset+5], [concernRanking objectAtIndex:indexOffset+6], [concernRanking objectAtIndex:indexOffset+7], nil];
    _username = username;
    _deviceName = deviceName;
    tabControl = *tabController;
    
    return self;
}

- (void)changeConcernRanking:(NSArray *)concernRanking {
    int indexOffset = (int)concernRanking.count - 8;
    
    [_concernRanking replaceObjectAtIndex:0 withObject:[concernRanking objectAtIndex:indexOffset]];
    [_concernRanking replaceObjectAtIndex:1 withObject:[concernRanking objectAtIndex:indexOffset+1]];
    [_concernRanking replaceObjectAtIndex:2 withObject:[concernRanking objectAtIndex:indexOffset+2]];
    [_concernRanking replaceObjectAtIndex:3 withObject:[concernRanking objectAtIndex:indexOffset+3]];
    [_concernRanking replaceObjectAtIndex:4 withObject:[concernRanking objectAtIndex:indexOffset+4]];
    [_concernRanking replaceObjectAtIndex:5 withObject:[concernRanking objectAtIndex:indexOffset+5]];
    [_concernRanking replaceObjectAtIndex:6 withObject:[concernRanking objectAtIndex:indexOffset+6]];
    [_concernRanking replaceObjectAtIndex:7 withObject:[concernRanking objectAtIndex:indexOffset+7]];
    
}

// calculate trial scores based on concerns
- (void)calculateScores {
    NSLog(@"trial num: %d\n", tabControl.trialNum);
}

@end

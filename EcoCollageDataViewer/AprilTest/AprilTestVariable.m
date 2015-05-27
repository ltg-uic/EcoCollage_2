//
//  AprilTestVariableClass.m
//  AprilTest
//
//  Created by Tia on 4/10/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import "AprilTestVariable.h"

@implementation AprilTestVariable

@synthesize name = _name;
@synthesize widthOfVisualization = _widthOfVisualization;
@synthesize currentConcernRanking = _currentConcernRanking;
@synthesize baseRating = _baseRating;
@synthesize baseRatings = _baseRatings;

-(id) initWith:(NSString *)name withDisplayName: (NSString *) displayName withNumVar: (int) numVar withWidth:(int)widthOfVisualization withRank:(int)currentConcernRanking{
    _name = name;
    _widthOfVisualization = widthOfVisualization;
    _currentConcernRanking = currentConcernRanking;
    _displayName = displayName;
    _baseRating = 0;
    _baseRatings = [[NSMutableArray alloc] initWithCapacity:numVar];
    for(int i = 0; i < numVar; i++){
        [_baseRatings insertObject:[NSNumber numberWithInt:0] atIndex:i];
    }

    return self;
}

- (NSString *) description{
    NSString * desc = [NSString stringWithFormat: @"%@, %d", _name, _currentConcernRanking];
    return desc;
}

- (bool) equals: (AprilTestVariable *) other{
    return [_name isEqualToString:other.name] ;
}

- (void) updateCurrentRanking: (int) newRating{
    _currentConcernRanking = newRating;
}

- (void) updateBaseLikert: (int) newRating withIndex: (int) index{
    //NSLog(@"%@ : %d - %d = %d", _name, newRating, _baseRating, (newRating - _baseRating));
    _currentConcernRanking += (newRating - [[_baseRatings objectAtIndex:index] intValue]);
    [_baseRatings removeObjectAtIndex:index];
    [_baseRatings insertObject:[NSNumber numberWithInt:newRating] atIndex:index];
}


@end

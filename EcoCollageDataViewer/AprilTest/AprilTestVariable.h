//
//  AprilTestVariableClass.h
//  AprilTest
//
//  Created by Tia on 4/10/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AprilTestVariable : NSObject
@property NSString *name;
@property NSString *displayName;
@property int widthOfVisualization;
@property int currentConcernRanking;
@property int baseRating;
@property int numVar;
@property NSMutableArray * baseRatings;

-(id) initWith: (NSString *)name withDisplayName: (NSString *) displayName withNumVar: (int) numVar withWidth:(int) widthOfVisualization withRank: (int) currentConcernRanking;
-(void) updateBaseLikert: (int) newRating withIndex: (int) index;
- (void) updateCurrentRanking: (int) newRating;
@end

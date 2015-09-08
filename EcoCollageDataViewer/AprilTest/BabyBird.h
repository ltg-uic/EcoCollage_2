//
//  BabyBird.h
//  AprilTest
//
//  Created by Ryan Fogarty on 9/8/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BabyBird : NSObject

@property NSMutableArray *concernRanking;
@property NSMutableArray *trialScores;

@property NSString       *username;
@property NSString       *deviceName;

- (void)changeConcernRanking:(NSArray*)concernRanking;

- (void)calculateScores;

@end

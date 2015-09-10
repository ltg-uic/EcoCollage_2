//
//  BabyBird.h
//  AprilTest
//
//  Created by Ryan Fogarty on 9/8/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AprilTestTabBarController.h"

@interface BabyBird : NSObject

@property NSMutableArray *concernRanking;
@property NSMutableArray *trialScores;

@property NSString       *username;
@property NSString       *deviceName;

- (BabyBird*) initWithConcernRanking:(NSArray*)concernRanking username:(NSString*)username deviceName:(NSString*)deviceName tabControl:(AprilTestTabBarController**)tabController;

- (void)changeConcernRanking:(NSArray*)concernRanking;

- (void)calculateScores;

@end

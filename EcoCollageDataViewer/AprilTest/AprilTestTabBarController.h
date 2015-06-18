//
//  AprilTestTabBarController.h
//  AprilTest
//
//  Created by Tia on 4/10/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface AprilTestTabBarController : UITabBarController <GKSessionDelegate>
@property NSMutableArray * currentConcernRanking;
@property NSMutableArray * trials;
@property NSMutableArray * profiles;
@property NSMutableArray * ownProfile;
@property NSString * url;
@property int studyNum;
@property (nonatomic, strong) GKSession * session;
@property NSString * peerIDForMomma;
@end

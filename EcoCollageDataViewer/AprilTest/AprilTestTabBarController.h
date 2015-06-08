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
@property NSString * url;
@property int studyNum;
@property NSString *dataReceived;
@property (nonatomic, strong) GKSession *session;
@end

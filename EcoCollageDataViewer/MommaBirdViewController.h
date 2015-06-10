//
//  MommaBirdViewController.h
//  AprilTest
//
//  Created by Ryan Fogarty on 5/26/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface MommaBirdViewController : UIViewController <GKSessionDelegate>
@property NSMutableArray *currentConcernRanking;
@property NSString *url;
@property int studyNum;
@property (strong, nonatomic) IBOutlet UITextView *textView;


@end

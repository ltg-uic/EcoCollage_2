//
//  MommaBirdViewController.h
//  AprilTest
//
//  Created by Ryan Fogarty on 5/26/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface MommaBirdViewController : UIViewController {
    GKSession *currentSession;
}

@property GKSession *currentSession;
@property NSMutableArray *currentConcernRanking;
@property NSString *url;
@property int studyNum;
@property (strong, nonatomic) IBOutlet UITextView *textView;

-(IBAction) btnSend:(id) sender;
-(IBAction) btnConnect:(id) sender;

@end

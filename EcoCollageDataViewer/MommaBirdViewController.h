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
    IBOutlet UIButton *connect;
    IBOutlet UIButton *discconect;
}

@property NSMutableArray *currentConcernRanking;
@property NSString *url;
@property int studyNum;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property GKSession *currentSession;


@property (nonatomic, retain) UIButton *connect;
@property (nonatomic, retain) UIButton *disconnect;

- (IBAction)connectToGK:(UIButton *)sender;
- (IBAction)disconnectFromGK:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UITextField *textField;

@end

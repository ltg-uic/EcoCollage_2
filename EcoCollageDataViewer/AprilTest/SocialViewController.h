//
//  SocialViewController.h
//  AprilTest
//
//  Created by Ryan Fogarty on 6/2/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface SocialViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *textField;
- (IBAction)sendText:(UIButton *)sender;
@property int studyNum;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

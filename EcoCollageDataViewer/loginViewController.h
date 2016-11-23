//
//  loginViewController.h
//  Trial_1
//
//  Created by Jamie Auza on 5/12/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface loginViewController : UIViewController

- (IBAction)begin:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *serverIP;
@property (weak, nonatomic) IBOutlet UITextField *groupNumber;

@property NSString * grpNumber;
@property NSString *IPAddress;


@end

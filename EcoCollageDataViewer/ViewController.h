//
//  ViewController.h
//  Trial_1
//
//  Created by Jamie Auza on 4/18/16.
//  Copyright © 2016 Jamie Auz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic,strong) UIImage * userImage_T;
@property (nonatomic,strong) UIImage * currentImage_T;
@property (nonatomic,strong) UIImage * warpedGlobal;
@property NSString * groupNumber;
@property NSString *IPAddress;
@property NSMutableArray *profiles;

- (IBAction)toTAP:(id)sender;


@end


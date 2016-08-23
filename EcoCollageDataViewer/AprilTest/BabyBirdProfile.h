//
//  BabyBirdProfile.h
//  AprilTest
//
//  Created by Ryan Fogarty on 4/22/16.
//  Copyright (c) 2016 Joey Shelley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BabyBirdProfile : UIView

- (id)initWithConcerns:(NSString*)concerns;

@property UITextField *concerns;
@property UIView *refreshConnection;

@end

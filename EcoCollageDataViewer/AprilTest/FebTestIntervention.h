//
//  FebTestIntervention.h
//  FebTest
//
//  Created by Joey Shelley on 2/19/14.
//  Copyright (c) 2014 Joey Shelley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FebTestIntervention : UIView
@property UIView *view;
@property bool whole;
- (id) initWithPositionArray: (NSString *) content andFrame: (CGRect) frame;
- (void) updateView;
- (UIImage *)viewToImage;
@end

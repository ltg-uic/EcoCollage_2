//
//  StackedBarGraph.h
//  AprilTest
//
//  Created by Ryan Fogarty on 11/5/15.
//  Copyright (c) 2015 Joey Shelley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AprilTestTabBarController.h"
#import "StackedBar.h"

@interface StackedBarGraph : UIScrollView

@property NSMutableArray *stackedBars;
@property UIView *legendView;
@property UIScrollView *scoreBarsView;
@property UIView *slideDown;
@property NSMutableArray *trialGroups;

- (id)initWithFrame:(CGRect)frame andTabController:(AprilTestTabBarController *)tabControl withContainers:(int)wC;

- (void) reloadGraph:(AprilTestTabBarController *)tabControl withContainers:(int)wC;

- (void) trialTappedByIndex:(int)index;

@end

//
//  StackedBarGraph.h
//  AprilTest
//
//  Created by Ugrad Research on 11/5/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AprilTestTabBarController.h"
#import "StackedBar.h"

@interface StackedBarGraph : UIScrollView

@property NSMutableArray *stackedBars;

- (id)initWithFrame:(CGRect)frame andTabController:(AprilTestTabBarController *)tabControl withContainers:(int)wC;

- (void) reloadGraph:(AprilTestTabBarController *)tabControl withContainers:(int)wC;

@end

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

@interface StackedBarGraph : UIView

@property NSMutableArray *stackedBars;

- (id)initWithFrame:(CGRect)frame andTabController:(AprilTestTabBarController *)tabControl;

@end

//
//  GraphView.h
//  AprilTest
//
//  Created by Ryan Fogarty on 9/10/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kGraphHeight 300
#define kDefaultGraphWidth 900
#define kOffsetX 10
#define kStepX 50
#define kGraphBottom 300
#define kGraphTop 0
#define kStepY 50
#define kOffsetY 10

@interface GraphView : UIView

- (void)reloadGraphWithData:(float[])data height:(int)height width:(int)width;


@end
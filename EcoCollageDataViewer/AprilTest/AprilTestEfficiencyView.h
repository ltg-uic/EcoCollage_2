//
//  AprilTestEfficiencyView.h
//  AprilTest
//
//  Created by Tia on 4/16/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AprilTestEfficiencyView : UIView
@property NSArray * efficiencyLevels;
@property UIView * view;
@property int trialNum;
@property NSMutableArray *blocks;
@property float maxHour;

-(id) initWithFrame: (CGRect) frame withContent: (NSString *) content;
-(void) updateViewForHour: (int) hoursAfterStorm;
@end

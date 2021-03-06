//
//  AprilTestEfficiencyView.h
//  AprilTest
//
//  Created by Joey Shelley on 4/16/14.
//  Copyright (c) 2014 Joey Shelley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface AprilTestEfficiencyView : UIView
@property NSArray * efficiencyLevels;
@property UIView * view;
@property int trialNum;
@property NSMutableArray *blocks;
@property float maxHour;

-(id) initWithFrame: (CGRect) frame withContent: (NSString *) content;
-(void) updateViewForHour: (int) hoursAfterStorm;
- (UIImage *)viewforEfficiencyToImage;
@end

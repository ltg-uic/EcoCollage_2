//
//  UIViewWithTitle.m
//  AprilTest
//
//  Created by Ryan Fogarty on 6/23/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import "UIViewWithTitle.h"

@implementation UIViewWithTitle

@synthesize title = _title;

-(id) initWithTitle:(NSString *)title {
    self = [super init];
    _title = title;
    return self;
}

@end

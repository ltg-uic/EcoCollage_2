//
//  Coordinate.m
//  Trial_1
//
//  Created by Jamie Auza on 6/2/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import "Coordinate.h"

@implementation Coordinate
@synthesize x;
@synthesize y;

-(id)initWithXCoord:(NSInteger)X YCoord:(NSInteger)Y{
    self = [super init];
    
    x = X;
    y = Y;
    
    return self;
}



- (NSInteger) getX{
    return x;
}

- (NSInteger) getY{
    return y;
}

- (BOOL) isEqualToOther:(Coordinate*)otherCoord{
    return x == [otherCoord getX] && y == [otherCoord getY];
}


@end

//
//  Coordinate.h
//  Trial_1
//
//  Created by Jamie Auza on 6/2/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Coordinate : NSObject

- (void)initialize;

- (instancetype)initWithXCoord:(NSInteger)X YCoord:(NSInteger)Y;

- (NSInteger) getX;
- (NSInteger) getY;

@property (assign, nonatomic) NSInteger x;
@property (assign, nonatomic) NSInteger y;
- (BOOL) isEqualToOther:(Coordinate*)otherCoord;

@end

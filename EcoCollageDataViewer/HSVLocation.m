//
//  savedHSVLocation.m
//  Trial_1
//
//  Created by Jamie Auza on 6/24/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import "HSVLocation.h"

@implementation HSVLocation{
    NSString* name;
    NSMutableArray* HSVValues; // 30 integers
}

//nitWithXCoord:(NSInteger)X YCoord:(NSInteger)Y{
-(id) initWithName:(NSString*)Name Values:(NSMutableArray*)Values{
    self = [super init];
    
    name = Name;
    HSVValues = Values;
    
    return self;
}

-(NSString*) getName{
    return name;
}

-(NSString*) getValuesAsString{
    NSString * allValues = @"";
    for( NSString * value in HSVValues){
        allValues = [allValues stringByAppendingFormat:@" %@", value];
    }
    return allValues;
}

/*
 ** colorCases: 0 = green
 **             1 = red
 **             2 = wood
 **             3 = blue
 **             4 = dark green (corner markers)
 */
-(NSMutableArray*) getSwaleValues{
    return [self getValuesFromIcon:0];
}

-(NSMutableArray*) getRainBarrelValues{
    return [self getValuesFromIcon:1];
}

-(NSMutableArray*) getGreenRoofValues{
    return [self getValuesFromIcon:2];
}

-(NSMutableArray*) getPermeablePaverValues{
    return [self getValuesFromIcon:3];
}

-(NSMutableArray*) getCornerValues{
    return [self getValuesFromIcon:4];
}

-(NSMutableArray*) getValuesFromIcon:(NSInteger) caseNum{
    NSMutableArray * values = [[NSMutableArray alloc] init];
    for( int i  = 0; i  < 6 ; i++){
        [values addObject:[HSVValues objectAtIndex:caseNum*6 + i]];
    }
    return values;
}

-(NSMutableArray*) getAllValues{
    NSMutableArray * values = [HSVValues copy];
    return values;
}
@end

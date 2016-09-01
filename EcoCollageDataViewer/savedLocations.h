//
//  savedLocations.h
//  Trial_1
//
//  Created by Jamie Auza on 6/24/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSVLocation.h"

@interface savedLocations : NSObject{
    NSMutableArray*allSavedLocations;
}

@property (retain, nonatomic) NSMutableArray*allSavedLocations;

+(id)sharedSavedLocations;
- (int) count;
- (NSString*) nameOfObjectAtIndex:(int)index;
- (NSMutableArray*) getHSVForSavedLocationAtIndex:(NSInteger)index Icon:(NSInteger)caseNum;
- (int) saveEntryWithName: (NSString*) name Values:(NSMutableArray*) values;
- (void) writeToFile;
- (savedLocations*) changeFromFile;
- (Boolean) isOverwriting: (NSString*) name;
- (NSMutableArray*) getAllHSVForSavedLocationAtIndex:(NSInteger)index;
@end

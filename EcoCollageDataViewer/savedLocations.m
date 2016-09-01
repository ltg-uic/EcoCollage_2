//
//  savedLocations.m
//  Trial_1
//
//  Created by Jamie Auza on 6/24/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import "savedLocations.h"
#import "HSVLocation.h"

@implementation savedLocations

#pragma mark Singleton Methods
@synthesize allSavedLocations;

+ (id)sharedSavedLocations {
    static savedLocations *sharedsavedLocations = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedsavedLocations = [[self alloc] init];
    });
    return sharedsavedLocations;
}

- (id)init {
    allSavedLocations = [[NSMutableArray alloc] init];
    if (self = [super init]) {
        // Where we actually intialize the array of HSVLocations from the file
        
        // Opening File savedHsvValues.txt
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"savedHsvValues"];
        fileName = [fileName stringByAppendingPathExtension:@"txt"];
        
        // If file not found, create one
        if(![[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
            NSLog(@"We didn't find the file, so we're creating one");
            [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
            
            // Add Default HSV values to file
            NSString* defaultHSV = @"Default:10 80 50 200 50 255 115 120 97 226 112 240 90 110 40 100 120 225 0 15 30 220 50 210 15 90 35 200 35 130\n";
            NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
            [file writeData:[defaultHSV dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        // Get all of the file
        NSString* content = [NSString stringWithContentsOfFile:fileName
                                                      encoding:NSUTF8StringEncoding
                                                         error:NULL];
        
        // Break up by line
        NSMutableArray * savedLines = [content componentsSeparatedByString:@"\n"];
        
        // Each line has format
        //      (string):(int) (int) (int) .....(eol)
        //      (name):(HSV Values seperated by spaces)(\n)
        // Break up and save in HSVLocation object
        for( NSString* line in savedLines){
            if( ![line isEqualToString:@""]){ // gets rid of the extra line with nothing in it
                NSArray * oneHSV = [line componentsSeparatedByString:@":"];
                NSArray * stringValues = [oneHSV[1] componentsSeparatedByString:@" "];
                
                HSVLocation * HSV;
                HSV = [[HSVLocation alloc] initWithName:oneHSV[0] Values: stringValues];
            
                [allSavedLocations addObject:HSV];
            }
        }
    }
    //[self printAll];
    return self;
}

- (savedLocations*) changeFromFile{
    // Where we actually intialize the array of HSVLocations from the file
    [allSavedLocations removeAllObjects];
    
    // Opening File savedHsvValues.txt
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"savedHsvValues"];
    fileName = [fileName stringByAppendingPathExtension:@"txt"];
    
    // If file not found, create one
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        NSLog(@"We didn't find the file, so we're creating one");
        [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
        
        // Add Default HSV values to file
        // < New Color Palette >:255 0 255 0 255 0 255 0 255 0 255 0 255 0 255 0 255 0 255 0 255 0 255 0 255 0 255 0 255 0\n 
        NSString* defaultHSV = @"Default:10 80 50 200 50 255 115 120 97 226 112 240 90 110 40 100 120 225 0 15 30 220 50 210 15 90 35 200 35 130\n";
        
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
        [file writeData:[defaultHSV dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // Get all of the file
    NSString* content = [NSString stringWithContentsOfFile:fileName
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    // Break up by line
    NSMutableArray * savedLines = [content componentsSeparatedByString:@"\n"];
    
    // Each line has format
    //      (string):(int) (int) (int) .....(eol)
    //      (name):(HSV Values seperated by spaces)(\n)
    // Break up and save in HSVLocation object
    for( NSString* line in savedLines){
        if( ![line isEqualToString:@""]){ // gets rid of the extra line with nothing in it
            NSArray * oneHSV = [line componentsSeparatedByString:@":"];
            NSArray * stringValues = [oneHSV[1] componentsSeparatedByString:@" "];
            
            HSVLocation * HSV;
            HSV = [[HSVLocation alloc] initWithName:oneHSV[0] Values: stringValues];
            
            [allSavedLocations addObject:HSV];
        }
    }
    return self;
}

- (Boolean) isOverwriting: (NSString*) name{
    HSVLocation * newEntry = [[HSVLocation alloc] initWithName:name Values:nil];
    
    for( int i = 0 ; i < [allSavedLocations count]; i++){
        if([[self nameOfObjectAtIndex:i] isEqualToString:name] ){
            // They are overwriting
            return true;
        }
    }
    return false;
}


// Create save to file
- (int) saveEntryWithName: (NSString*) name Values:(NSMutableArray*) values{
    HSVLocation * newEntry = [[HSVLocation alloc] initWithName:name Values:values];
    
    int index = [allSavedLocations count];
    HSVLocation * entry = [HSVLocation alloc];
    for( int i = 0 ; i < [allSavedLocations count]; i++){
         entry = [allSavedLocations objectAtIndex:i];
        if([[entry getName] isEqualToString:name] ){
            // They are overwriting
            index = i;
            break;
        }
    }
    
    if( index != [allSavedLocations count] ){
        [allSavedLocations replaceObjectAtIndex:index withObject:newEntry];
    }else{
        [allSavedLocations addObject:newEntry];
    }
    
    [self writeToFile];
    return index;
}

- (void) writeToFile{
    // Overwrite the whole text file
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"savedHsvValues"];
    fileName = [fileName stringByAppendingPathExtension:@"txt"];
    NSLog(@"Writing over exiting one, or making a new one");
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    
    NSString* content = @"";
    
    for( HSVLocation * entry in allSavedLocations){
        NSString * values = [entry getValuesAsString];
        values = [values stringByTrimmingCharactersInSet:
         [NSCharacterSet whitespaceCharacterSet]];
        NSString * oneEntry = [[entry getName] stringByAppendingFormat:@":%@\n",values];
        content = [content stringByAppendingString: oneEntry];
    }

    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    [file writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@" We are writing this to file: \n%@", content);
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (NSMutableArray*) getHSVForSavedLocationAtIndex:(NSInteger)index Icon:(NSInteger)caseNum{
    NSMutableArray* result = [[NSMutableArray alloc]init];
    result = [[allSavedLocations objectAtIndex: index ] getValuesFromIcon:caseNum];
    return result;
}

- (NSMutableArray*) getAllHSVForSavedLocationAtIndex:(NSInteger)index {
    NSMutableArray* result = [[NSMutableArray alloc]init];
    result = [[allSavedLocations objectAtIndex: index ] getAllValues];
    return result;
}

- (int) count{
    return [allSavedLocations count];
}

- (NSString*) nameOfObjectAtIndex:(int)index{
    return [[allSavedLocations objectAtIndex:index] getName];
}

- (void) printAll{
    for( HSVLocation * location in allSavedLocations){
        NSLog(@"PRINTING OUT allSavedLocations");
        NSLog(@"NAME: %@ FIRST VALUE: %@", [location getName] , location.getSwaleValues[0]);
    }
}



@end

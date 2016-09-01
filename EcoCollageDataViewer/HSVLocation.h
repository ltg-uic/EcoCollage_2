//
//  savedHSVLocation.h
//  Trial_1
//
//  Created by Jamie Auza on 6/24/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HSVLocation : NSObject

@property (assign, nonatomic) NSString* name;
@property (assign, nonatomic) NSMutableArray*HSVValues;
-(instancetype) initWithName:(NSString*)Name Values:(NSMutableArray*)Values;

-(NSString*) getName;
-(NSString*) getValuesAsString;

-(NSMutableArray*) getSwaleValues;
-(NSMutableArray*) getRainBarrelValues;
-(NSMutableArray*) getGreenRoofValues;
-(NSMutableArray*) getPermeablePaverValues;
-(NSMutableArray*) getCornerValues;
-(NSMutableArray*) getValuesFromIcon:(NSInteger) caseNum;
-(NSMutableArray*) getAllValues;

@end

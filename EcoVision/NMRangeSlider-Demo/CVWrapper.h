//
//  CVWrapper.h
//  CVOpenTemplate
//
//  Created by Washe on 02/01/2013.
//  Copyright (c) 2013 foundry. All rights reserved.
//

//  EcoCollage 2015
//  Ryan Fogarty
//  Salvador Ariza

#import <Foundation/Foundation.h>

@interface CVWrapper : NSObject

+ (UIImage*) warp:(UIImage*)src destination_image:(UIImage*) dst;

+ (UIImage*) thresh:(UIImage*) src colorCase:(int) colorCase;

+ (int) detectContours:(UIImage*) src corners:(int[]) corners;

+ (int) analysis:(UIImage*) src studyNumber: (int) studyNumber trialNumber: (int) trialNumber results: (char[]) results;

+ (void) getHSV_Values:(int[]) input;

+ (void) setHSV_Values:(int[]) input;

+ (UIImage*) getCurrentImage;

+ (void) setCurrentImage:(UIImage*) img;

+ (UIImage*) getCurrentThreshedImage;

+ (void) setCurrentThreshedImage:(UIImage*) img;

+ (void) setSegmentIndex:(int) index;

+ (int) getSegmentIndex;

+ (void) getHSVValuesfromRed:(double)r Green:(double)g Blue:(double)b H:(int*)H S:(int*)S V:(int*)V;

+ (UIImage *) ApplyMedianFilter: (UIImage *) img;

@end

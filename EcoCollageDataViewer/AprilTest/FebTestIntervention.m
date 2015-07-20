//
//  FebTestIntervention.m
//  FebTest
//
//  Created by Tia on 2/19/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import "FebTestIntervention.h"

@implementation FebTestIntervention
@synthesize view = _view;
@synthesize whole = _whole;
NSArray *interventionPos;
UIImage *greenAlley;
UIImage *greenRoof;
UIImage *swale;
UIImage *rainBarrel;
UIImage *sewer;
NSMutableArray *imageViews;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
//    NSString *content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]
//                                                            pathForResource: @"outputFile" ofType: @"txt"] encoding:NSUTF8StringEncoding error:NULL];
//    interventionPos = [content componentsSeparatedByString:@"\n"];
//    NSMutableArray *interventionPosTemp = [[NSMutableArray alloc] initWithObjects: nil];
//    
//    for (int i = 0; i < interventionPos.count; i++){
//        [interventionPosTemp insertObject: [[interventionPos objectAtIndex:i] componentsSeparatedByString:@" "] atIndex: i];
//    }
//    //NSLog(@"%@", interventionPosTemp);
//    interventionPos = interventionPosTemp;
    greenAlley = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"greenalley" ofType:@"png"]];
    greenRoof = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"greenroof" ofType: @"png"]];
    rainBarrel = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource: @"rainbarrel" ofType:@"png"]];
    swale = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"swale" ofType:@".png"]];
    sewer = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"sewer" ofType:@".png"]];
    _whole = true;
    return self;
}

-(id) initWithPositionArray:(NSString *)content andFrame:(CGRect)frame{
    self = [super initWithFrame: frame];
        interventionPos = [content componentsSeparatedByString:@"\n"];
        NSMutableArray *interventionPosTemp = [[NSMutableArray alloc] initWithObjects: nil];
    
        for (int i = 0; i < interventionPos.count; i++){
            [interventionPosTemp insertObject: [[interventionPos objectAtIndex:i] componentsSeparatedByString:@" "] atIndex: i];
        }
        //NSLog(@"%@", interventionPosTemp);
    interventionPos = interventionPosTemp;
    greenAlley = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"greenalley" ofType:@"png"]];
    greenRoof = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"greenroof" ofType: @"png"]];
    rainBarrel = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource: @"rainbarrel" ofType:@"png"]];
    swale = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"swale" ofType:@".png"]];
    sewer = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"sewer" ofType:@".png"]];
    _whole = true;
    
    return self;
}

- (void) updateView {
    for(int i=0; i< imageViews.count; i++){
        [[imageViews objectAtIndex:i] removeFromSuperview];
    }
    [imageViews removeAllObjects];
    UILabel *background = [[UILabel alloc] initWithFrame:CGRectMake ( self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height )];
    background.backgroundColor = [UIColor grayColor];
    [_view addSubview: background];
    
    for (int i =0 ; i < interventionPos.count; i++){
        NSArray *temp = [interventionPos objectAtIndex:i];
        if(temp.count < 3) break;
        UIImageView *uv;
        switch ([[temp objectAtIndex:2] intValue]) {
            case 0:
                    uv = [[UIImageView alloc] initWithImage:rainBarrel];
                break;
            case 1:
                    uv = [[UIImageView alloc] initWithImage:swale];
                break;
            case 2:
                    uv = [[UIImageView alloc] initWithImage:greenAlley];
                break;
            case 3:
                    uv = [[UIImageView alloc] initWithImage:greenRoof];
                break;
            case 4:
                    uv = [[UIImageView alloc] initWithImage:sewer];
                break;
                
        }
        uv.frame = CGRectMake(self.frame.origin.x + [[temp objectAtIndex:0] intValue] * 5, self.frame.origin.y + (120 - [[temp objectAtIndex:1] intValue] * 5), 5, 5);
        if(uv.image.CGImage != NULL){
            [imageViews addObject:uv];
            [_view addSubview: uv];
        }
        
    }
    //NSLog(@"update view run");
    
}

- (UIImage *)viewToImage {
    UIImage *img = [[UIImage alloc]init];
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0.0f);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

@end

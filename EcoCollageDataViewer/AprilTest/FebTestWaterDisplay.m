//
//  FebTestWaterDisplay.m
//  FebTest
//
//  Created by Tia on 2/18/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import "FebTestWaterDisplay.h"


@implementation FebTestWaterDisplay
@synthesize waterHeights = _waterHeights;
@synthesize view = _view;
@synthesize thresholdValue = _thresholdValue;
@synthesize blocks = _blocks;
@synthesize hours = _hours;
UILabel *bg;

- (id)initWithFrame:(CGRect)frame andContent: (NSString *)content;
{
    self = [super initWithFrame:frame];
    _waterHeights = [content componentsSeparatedByString:@"\n"];
    NSMutableArray *waterHeightsTemp = [[NSMutableArray alloc] initWithObjects: nil];
    //NSLog(@"%@", _waterHeights);
    for (int i = 0; i < _waterHeights.count; i++){
        [waterHeightsTemp insertObject: [[_waterHeights objectAtIndex:i] componentsSeparatedByString:@" "] atIndex: i];
    }
    
    _hours = 0;
    
    //NSLog(@"%@", waterHeightsTemp);
    _waterHeights = waterHeightsTemp;
    
    _thresholdValue = 0.25;
    _threshold = TRUE;
    //[self updateView:0.25];
    _blocks = [[NSMutableArray alloc] initWithObjects: nil];
    return self;
}

- (NSString *) description{
    return [NSString stringWithFormat:@"%@", [_waterHeights objectAtIndex:0]];
}

- (void) updateView: (int) hoursAfterStorm {
    for(int i = 0; i < _blocks.count; i++){
        [[_blocks objectAtIndex:i] removeFromSuperview];
    }
    [_blocks removeAllObjects];
    
    _hours = hoursAfterStorm;
    float hoursAfterStormCatch = hoursAfterStorm;
    float maxSaturation = 0;
    if(hoursAfterStorm == 0) hoursAfterStormCatch = (float)1/(float)60;
    UILabel *bg = [[UILabel alloc] initWithFrame:self.frame];
    bg.backgroundColor = [UIColor grayColor];
    [_blocks addObject:bg];
    [_view addSubview:bg];
    
    for(int i = 0; i < _waterHeights.count; i++){
        NSArray *temp = [_waterHeights objectAtIndex:i];
        if( temp.count < 4) break;
        if ( [[temp objectAtIndex:0] floatValue] == hoursAfterStormCatch || i == _waterHeights.count){
            //NSLog(@"hours: %f, hours after storm on bar: %f", [[temp objectAtIndex:0] floatValue], hoursAfterStormCatch );
            UILabel *ux = [[UILabel alloc] initWithFrame: CGRectMake(self.frame.origin.x + [[temp objectAtIndex:1] intValue]*5, self.frame.origin.y +(120-[[temp objectAtIndex:2] intValue]*5), 5, 5)];
            float waterHeight = [[temp objectAtIndex:3] floatValue];
            if( [[temp objectAtIndex:1] intValue] % 8 == 0 || [[temp objectAtIndex:2] intValue] % 14 == 0){
                waterHeight = waterHeight - 127;
            }
            if(  waterHeight >= _thresholdValue){
                //NSLog(@"waterHeight: %f, thresholdValue: %f", waterHeight, _thresholdValue);
                ux.backgroundColor = [UIColor redColor];
            } else if ([[temp objectAtIndex:3] floatValue] < _thresholdValue && [[temp objectAtIndex:3] floatValue] != 0){
                float saturation = [[temp objectAtIndex:3] floatValue]/40.0 +.1;
                if (saturation > maxSaturation) maxSaturation = saturation;
                ux.backgroundColor = [UIColor colorWithHue:0.7 saturation: saturation brightness:.55 alpha:1];
            } else if ([[temp objectAtIndex:3] floatValue]==0){
                ux.backgroundColor = [UIColor grayColor];
            }
            [_blocks addObject:ux];
            [_view addSubview:ux];
            
        } else if ( [[temp objectAtIndex:0] floatValue] > hoursAfterStormCatch) break;
    }
}

- (void) fastUpdateView: (int) hoursAfterStorm {
    
    _hours = hoursAfterStorm;
    float hoursAfterStormCatch = hoursAfterStorm;
    float maxSaturation = 0;
    if(hoursAfterStorm == 0) hoursAfterStormCatch = (float)1/(float)60;
    
    //sets background
    if (_blocks.count == 0){
        bg = [[UILabel alloc] initWithFrame:self.frame];
        bg.backgroundColor = [UIColor grayColor];
        [_view addSubview:bg];
        
        
        for(int i = 0; i < _waterHeights.count; i++){
            NSArray *temp = [_waterHeights objectAtIndex:i];
            if( temp.count < 4) break;
            if ( [[temp objectAtIndex:0] floatValue] == hoursAfterStormCatch || i == _waterHeights.count){
                //NSLog(@"hours: %f, hours after storm on bar: %f", [[temp objectAtIndex:0] floatValue], hoursAfterStormCatch );
                UILabel *ux = [[UILabel alloc] initWithFrame: CGRectMake(self.frame.origin.x + [[temp objectAtIndex:1] intValue]*5, self.frame.origin.y +(120-[[temp objectAtIndex:2] intValue]*5), 5, 5)];
                float waterHeight = [[temp objectAtIndex:3] floatValue];
                if( [[temp objectAtIndex:1] intValue] % 8 == 0 || [[temp objectAtIndex:2] intValue] % 14 == 0){
                    waterHeight = waterHeight - 127;
                }
                if(  waterHeight >= _thresholdValue){
                    //NSLog(@"waterHeight: %f, thresholdValue: %f", waterHeight, _thresholdValue);
                    ux.backgroundColor = [UIColor redColor];
                } else if ([[temp objectAtIndex:3] floatValue] < _thresholdValue && [[temp objectAtIndex:3] floatValue] != 0){
                    float saturation = [[temp objectAtIndex:3] floatValue]/40;
                    if (saturation > maxSaturation) maxSaturation = saturation;
                    ux.backgroundColor = [UIColor colorWithHue:0.7 saturation: saturation brightness:.55 alpha:1];
                } else if ([[temp objectAtIndex:3] floatValue]==0){
                    ux.backgroundColor = [UIColor grayColor];
                }
                [_blocks addObject:ux];
                [_view addSubview:ux];
                
            } else if ( [[temp objectAtIndex:0] floatValue] > hoursAfterStormCatch) break;
        }
        
    } else{
        
        bg.frame = self.frame;
        [_view addSubview:bg];
        for(int i = 0; i < _waterHeights.count; i++){
            NSArray *temp = [_waterHeights objectAtIndex:i];
            if( temp.count < 4) break;
            
            if ( [[temp objectAtIndex:0] floatValue] == hoursAfterStormCatch){
                //NSLog(@"hours: %f, hours after storm on bar: %f", [[temp objectAtIndex:0] floatValue], hoursAfterStormCatch );
                
                UILabel *ux = [_blocks objectAtIndex:i % 575];
                ux.frame = CGRectMake(self.frame.origin.x + [[temp objectAtIndex:1] intValue]*5, self.frame.origin.y +(120-[[temp objectAtIndex:2] intValue]*5), 5, 5);
                float waterHeight = [[temp objectAtIndex:3] floatValue];
                if( [[temp objectAtIndex:1] intValue] % 8 == 0 || [[temp objectAtIndex:2] intValue] % 14 == 0){
                    waterHeight = waterHeight - 127;
                }
                if(  waterHeight >= _thresholdValue){
                    //NSLog(@"waterHeight: %f, thresholdValue: %f", waterHeight, _thresholdValue);
                    ux.backgroundColor = [UIColor redColor];
                } else if ([[temp objectAtIndex:3] floatValue] < _thresholdValue && [[temp objectAtIndex:3] floatValue] != 0){
                    float saturation = [[temp objectAtIndex:3] floatValue]/40;
                    if (saturation > maxSaturation) maxSaturation = saturation;
                    ux.backgroundColor = [UIColor colorWithHue:0.7 saturation: saturation brightness:.55 alpha:1];
                } else if ([[temp objectAtIndex:3] floatValue]==0){
                    ux.backgroundColor = [UIColor grayColor];
                }
                [_view addSubview:ux];
                
            } else if ( [[temp objectAtIndex:0] floatValue] > hoursAfterStormCatch) break;
        }
        
        
    }
    
    
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

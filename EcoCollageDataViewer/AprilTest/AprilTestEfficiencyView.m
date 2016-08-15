//
//  AprilTestEfficiencyView.m
//  AprilTest
//
//  Created by Joey Shelley on 4/16/14.
//  Copyright (c) 2014 Joey Shelley. All rights reserved.
//

#import "AprilTestEfficiencyView.h"

@implementation AprilTestEfficiencyView
@synthesize efficiencyLevels = _efficiencyLevels;
@synthesize view = _view;
@synthesize blocks = _blocks;


- (id)initWithFrame:(CGRect)frame withContent:(NSString *)content
{
    self = [super initWithFrame:frame];
    _efficiencyLevels = [content componentsSeparatedByString:@"\n"];
    _maxHour = 0;
    NSMutableArray *efficiencyLevelsTemp = [[NSMutableArray alloc] initWithObjects: nil];
    for (int i = 0; i < _efficiencyLevels.count; i++){
        NSString *removeExcessWhiteSpace = [[_efficiencyLevels objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *separated = [removeExcessWhiteSpace componentsSeparatedByString:@" "];
        [efficiencyLevelsTemp insertObject: separated  atIndex: i];
        if( [[separated objectAtIndex:1] floatValue] > _maxHour) _maxHour = [[separated objectAtIndex:1] floatValue];
    }
    //NSLog(@"%f", _maxHour);
    _efficiencyLevels = efficiencyLevelsTemp;
    _blocks = [[NSMutableArray alloc] initWithObjects: [[UILabel alloc] init], [[UILabel alloc] init], [[UILabel alloc] init], [[UILabel alloc] init], nil ];
    //[self updateViewForHour: 10];

    return self;
}

-(NSString *) description{
    [NSString stringWithFormat:@"%d %@", _trialNum, _efficiencyLevels ];
    return @"";
}

-(void) updateViewForHour: (int) hoursAfterStorm{
    for(int i = 0; i < _blocks.count; i++){
        [[_blocks objectAtIndex:i] removeFromSuperview];
    }
    [_blocks removeAllObjects];
    float hoursAfterStormCatch = hoursAfterStorm;
    if(hoursAfterStorm == 0) hoursAfterStormCatch = (float)1/(float)60;
    if(hoursAfterStormCatch >= _maxHour) hoursAfterStormCatch = _maxHour;
    //NSLog(@"Efficiency Levels for Hour: %f; maxHour %f", hoursAfterStormCatch, _maxHour );
    for(int i = 0; i < _efficiencyLevels.count; i++){
        NSArray *temp = [_efficiencyLevels objectAtIndex:i];
        if( temp.count < 3) break;
        if ( [[temp objectAtIndex:1] floatValue] == hoursAfterStormCatch){
            //NSLog(@"%@", temp);
            UILabel *fullValue = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.origin.x + 10, self.frame.origin.y + (25 * [[temp objectAtIndex:0] integerValue]),  self.frame.size.width - 40, 20)];
            fullValue.backgroundColor = [UIColor lightGrayColor];
            UILabel * test = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.origin.x + 10, self.frame.origin.y + (25 * [[temp objectAtIndex:0] integerValue]),  (self.frame.size.width - 40) * (1-[[temp objectAtIndex:2] floatValue]), 20)];
            [self.view addSubview:fullValue];
            [self.view addSubview:test];
            switch ([[temp objectAtIndex:0] integerValue]){
                case 0: test.backgroundColor = [UIColor redColor];
                    break;
                case 1: test.backgroundColor = [UIColor colorWithRed:.3 green:.8 blue:.3 alpha:1.0];
                    break;
                case 2: test.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.9 alpha:1.0];
                    break;
                case 3: test.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.6 alpha:1.0];
                    break;
            }
            [_blocks addObject:fullValue];
            [_blocks addObject:test];


        } else if ( [[temp objectAtIndex:1] floatValue] > hoursAfterStormCatch) break;
    }
    UILabel *rB = [[UILabel alloc] init];
    rB.text = @"Rain Barrels";
    rB.font = [UIFont systemFontOfSize:13.0];
    rB.textAlignment = NSTextAlignmentRight;
    rB.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y , self.frame.size.width+55, 20);
    [self.view addSubview:rB];
    [_blocks addObject:rB];
    
    UILabel *swales = [[UILabel alloc] init];
    swales.text=@"Swales";
    swales.font = [UIFont systemFontOfSize:13.0];
    swales.textAlignment = NSTextAlignmentRight;
    swales.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y +25, self.frame.size.width+55, 20);
    [self.view addSubview:swales];
    [_blocks addObject:swales];
    
    UILabel *pP = [[UILabel alloc] init];
    pP.text=@"Perm. Pavers";
    pP.font = [UIFont systemFontOfSize:13.0];
    pP.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y +50, self.frame.size.width+55, 20);
    pP.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:pP];
    [_blocks addObject:pP];
    
    UILabel *gR = [[UILabel alloc] init];
    gR.text=@"Green Roofs";
    gR.font = [UIFont systemFontOfSize:13.0];
    gR.textAlignment = NSTextAlignmentRight;
    gR.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y +75 , self.frame.size.width+55, 20);
    [self.view addSubview:gR];
    [_blocks addObject:gR];

}

- (UIImage *)viewforEfficiencyToImage {

    UIImage *img;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.frame.size.width+55, self.frame.size.height), NO, 0.0f);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

@end

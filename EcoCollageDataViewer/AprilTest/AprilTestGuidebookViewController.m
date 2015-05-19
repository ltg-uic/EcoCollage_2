//
//  AprilTestGuidebookViewController.m
//  AprilTest
//
//  Created by Tia on 8/7/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import "AprilTestGuidebookViewController.h"

@interface AprilTestGuidebookViewController ()

@end
NSArray * elevations;
NSMutableArray * blocks;

@implementation AprilTestGuidebookViewController
@synthesize elevationSwitch = _elevationSwitch;
@synthesize irving = _irving;
@synthesize washington = _washington;
@synthesize longwood = _longwood;
@synthesize streetView = _streetView;
@synthesize aerialView = _aerialView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (id) init {
    self = [super init];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"initing");
    NSError * err;
    NSString *qs = [[NSBundle mainBundle] pathForResource: @"baseElevation" ofType: @"txt"];
    NSString * content = [[NSString alloc] initWithContentsOfFile:qs encoding:NSUTF8StringEncoding error: &err];
    elevations = [[NSArray alloc] init];
    elevations = [content componentsSeparatedByString:@"\n"];
    NSMutableArray *elevationsTemp = [[NSMutableArray alloc] initWithObjects: nil];
    //NSLog(@"%@", _waterHeights);
    for (int i = 0; i < elevations.count; i++){
        [elevationsTemp insertObject: [[elevations objectAtIndex:i] componentsSeparatedByString:@" "] atIndex: i];
    }
    
    //NSLog(@"%@", waterHeightsTemp);
    elevations = elevationsTemp;
    //NSLog(@"%@", elevations);
    blocks = [[NSMutableArray alloc] initWithObjects: nil];
    // Do any additional setup after loading the view.
    
    
    for(int i = 0; i < elevations.count; i++){
        NSArray *temp = [elevations objectAtIndex:i];
        if( temp.count < 3) break;
            UILabel *ux = [[UILabel alloc] initWithFrame: CGRectMake(20 + [[temp objectAtIndex:0] intValue]*25, 90 +(600-[[temp objectAtIndex:1] intValue]*25), 25, 25)];
            float elevation_value = ([[temp objectAtIndex:2] floatValue] - 200 ) / 450;
            ux.backgroundColor = [UIColor colorWithHue:0.0 saturation: 0.0 brightness: elevation_value alpha:0.25];
        [ux setHidden:TRUE];
        [blocks addObject:ux];
        [self.view addSubview:ux];
    }
    
    //rotates labels
    _irving.transform = CGAffineTransformMakeRotation(3*M_PI /2);
    _longwood.transform = CGAffineTransformMakeRotation(3*M_PI /2);
    _washington.transform = CGAffineTransformMakeRotation(3*M_PI /2);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)switchElevation:(id)sender {
    if( _elevationSwitch.isOn){
        for ( UILabel * x in blocks){
            [x setHidden:FALSE];
        }
        
    } else {
        for ( UILabel * x in blocks){
            [x setHidden:TRUE];
        }
    }

}
- (IBAction)switchAerial:(id)sender {
    UISwitch *aerialSwitch = (UISwitch *)sender;
    if(aerialSwitch.isOn){
        [_aerialView setHidden:FALSE];
    } else {
        [_aerialView setHidden:TRUE];
    }
}
- (IBAction)switchStreetNames:(id)sender {
    UISwitch *streetSwitch = (UISwitch *)sender;
    if (streetSwitch.isOn){
        [_streetView setHidden:FALSE];
    } else {
        [_streetView setHidden:TRUE];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

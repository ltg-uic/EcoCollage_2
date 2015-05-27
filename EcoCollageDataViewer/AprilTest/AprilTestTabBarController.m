//
//  AprilTestTabBarController.m
//  AprilTest
//
//  Created by Tia on 4/10/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import "AprilTestTabBarController.h"
#import "AprilTestVariable.h"

@interface AprilTestTabBarController ()


@end


@implementation AprilTestTabBarController
@synthesize currentConcernRanking = _currentConcernRanking;
@synthesize url = _url;
@synthesize studyNum = _studyNum;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //manually derived list of variables that are going to be implemented in this test. Eventually, should be replaced with a access to database, such that width, etc, are all documented as such.

    //_currentConcernRanking = [[NSMutableArray alloc] initWithObjects: [[AprilTestVariable alloc] initWith: @"publicCost" withDisplayName:@"Public Costs" withNumVar: 1 withWidth: 220 withRank:3], [[AprilTestVariable alloc] initWith: @"privateCost" withDisplayName:@"Private Costs" withNumVar: 3 withWidth: 220 withRank:1], [[AprilTestVariable alloc] initWith: @"efficiencyOfIntervention" withDisplayName:@"Efficiency of Intervention ($/Gallon)" withNumVar: 1 withWidth: 220 withRank:1], [[AprilTestVariable alloc] initWith:@"puddleTime" withDisplayName:@"Water Depth over Storm" withNumVar: 1 withWidth:220 withRank:1], [[AprilTestVariable alloc] initWith:@"impactingMyNeighbors" withDisplayName:@"Impact on my Neighbors" withNumVar: 1 withWidth: 220 withRank:1], [[AprilTestVariable alloc] initWith:@"groundwaterInfiltration" withDisplayName:@"Groundwater Infiltration" withNumVar: 1 withWidth:220 withRank:1], [[AprilTestVariable alloc] initWith:@"puddleMax" withDisplayName:@"Maximum Water Extent" withNumVar: 1 withWidth:220 withRank:1], nil];
    
//    Public Costs	publicCost
//    Private Costs	privateCost
//    Efficiency of Intervention ($/Gallon)	efficiencyOfIntervention
//    Water Depth over Storm	puddleTime
//    Maximum Water Extent	puddleMax
//    Groundwater Infiltration	groundwaterInfiltration
//    Impact on my Neighbors	impactingMyNeighbors
    
    _currentConcernRanking = [[NSMutableArray alloc] initWithObjects: [
                              [AprilTestVariable alloc] initWith:@"publicCost" withDisplayName:@"Investment" withNumVar:1 withWidth:220 withRank:1],
                              [[AprilTestVariable alloc] initWith:@"privateCost" withDisplayName:@"Damage Reduction" withNumVar:1 withWidth:220 withRank:1],
                              [[AprilTestVariable alloc] initWith:@"efficiencyOfIntervention" withDisplayName:@"Efficiency of Intervention ($/Gallon)" withNumVar:1 withWidth:220 withRank:1],
                              [[AprilTestVariable alloc] initWith:@"capacity" withDisplayName:@"Capacity Used" withNumVar:1 withWidth:220 withRank:1],
                              [[AprilTestVariable alloc] initWith:@"puddleTime" withDisplayName:@"Water Depth Over Time" withNumVar:1 withWidth:220 withRank:1],
                              [[AprilTestVariable alloc] initWith:@"puddleMax" withDisplayName:@"Maximum Flooded Area" withNumVar:1 withWidth:220 withRank:1],
                              [[AprilTestVariable alloc] initWith:@"groundwaterInfiltration" withDisplayName:@"Groundwater Infiltration" withNumVar:1 withWidth:220 withRank:1],
                              [[AprilTestVariable alloc] initWith:@"impactingMyNeighbors" withDisplayName:@"Impact on my Neighbors" withNumVar:1 withWidth:220 withRank:1],
                              nil];
    
    /* prints initial concern ranking from top down
    for(int i = 0; i < _currentConcernRanking.count; i++) {
        NSLog(@"Ranking at %d: %@\n", i, [_currentConcernRanking objectAtIndex:i]);
    }
    */
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end

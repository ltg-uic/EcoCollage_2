//
//  SocialViewController.m
//  AprilTest
//
//  Created by Ryan Fogarty on 6/2/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import "SocialViewController.h"
#import "AprilTestTabBarController.h"

@interface SocialViewController ()
@end

@implementation SocialViewController

@synthesize textView = _textView;
@synthesize studyNum = _studyNum;
@synthesize profilesWindow = _profilesWindow;

NSMutableDictionary *concernColors;




- (void)viewDidLoad {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    _studyNum = tabControl.studyNum;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleChatUpdate:)
                                                 name:@"chatUpdated"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleProfileUpdate)
                                                 name:@"profileUpdate"
                                               object:nil];
    
    
    
    concernColors = [[NSMutableDictionary alloc] initWithObjects:
                   [NSArray arrayWithObjects:
                    [UIColor colorWithHue:.3 saturation:.6 brightness:.9 alpha: 0.5],
                    [UIColor colorWithHue:.31 saturation:.6 brightness:.91 alpha: 0.5],
                    [UIColor colorWithHue:.32 saturation:.6 brightness:.92 alpha: 0.5],
                    [UIColor colorWithHue:.33 saturation:.6 brightness:.93 alpha: 0.5],
                    [UIColor colorWithHue:.35 saturation:.8 brightness:.6 alpha: 0.5],
                    [UIColor colorWithHue:.36 saturation:.8 brightness:.61 alpha: 0.5],
                    [UIColor colorWithHue:.37 saturation:.8 brightness:.62 alpha: 0.5],
                    [UIColor colorWithHue:.38 saturation:.8 brightness:.63 alpha: 0.5],
                    [UIColor colorWithHue:.4 saturation:.8 brightness:.3 alpha: 0.5],
                    [UIColor colorWithHue:.65 saturation:.8 brightness:.6 alpha: 0.5],
                    [UIColor colorWithHue:.6 saturation:.8 brightness:.3 alpha: 0.5],
                    [UIColor colorWithHue:.6 saturation:.0 brightness:.3 alpha: 0.5],
                    [UIColor colorWithHue:.6 saturation:.0 brightness:.9 alpha: 0.5],
                    [UIColor colorWithHue:.55 saturation:.8 brightness:.9 alpha: 0.5], nil]  forKeys: [[NSArray alloc] initWithObjects: @"Investment", @"publicCostI", @"publicCostM", @"publicCostD", @"Damage Reduction", @"privateCostI", @"privateCostM", @"privateCostD",  @"Efficiency of Intervention ($/Gallon)", @"Water Depth Over Time", @"Maximum Flooded Area", @"Groundwater Infiltration", @"Impact on my Neighbors", @"Capacity Used", nil] ];
    
    _profilesWindow.delegate = self;
    
}


-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// release notification if view is unloaded for memory purposes
- (void) viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




- (void)handleChatUpdate:(NSNotification *)note {
    NSDictionary *dictData = [note userInfo];
    
    NSString *received = [dictData objectForKey:@"chatUpdate"];
    _textView.text = received;
}


- (void)handleProfileUpdate {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    
    int amountOfProfilesLoaded = 0;
    
    for (UIView *view in [_profilesWindow subviews]){
        [view removeFromSuperview];
    }
    
    
    for (NSArray *profileArray in tabControl.profiles) {
        amountOfProfilesLoaded++;
        int width = 0;
        int widthOfVisualization = 200;
        
        // load name of profile
        UILabel *nameLabel = [[UILabel alloc]init];
        nameLabel.backgroundColor = [UIColor whiteColor];
        nameLabel.frame = CGRectMake(width, amountOfProfilesLoaded * 120 + 2, widthOfVisualization, 40);
        nameLabel.font = [UIFont boldSystemFontOfSize:15.3];
        nameLabel.text = [profileArray objectAtIndex:2];
        if(nameLabel != NULL) {
            [_profilesWindow addSubview:nameLabel];
        }
        width += widthOfVisualization;
        
        // load concerns in order
        for (int i = 3; i < profileArray.count; i++) {
            NSLog(@"Adding %@ to profilesWindow", [profileArray objectAtIndex:i]);
            UILabel *currentLabel = [[UILabel alloc]init];
            currentLabel.backgroundColor = [concernColors objectForKey:[profileArray objectAtIndex:i]];
            currentLabel.frame = CGRectMake(width, amountOfProfilesLoaded * 120 + 2, widthOfVisualization, 40);
            currentLabel.font = [UIFont boldSystemFontOfSize:15.3];
        
            if([[profileArray objectAtIndex:i] isEqualToString:@"Investment"])
                currentLabel.text = @"  Investment";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Damage Reduction"])
                currentLabel.text = @" Damage Reduction";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Efficiency of Intervention ($/Gallon)"])
                currentLabel.text = @" Efficiency of Intervention";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Capacity Used"])
                currentLabel.text = @" Intervention Capacity";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Water Depth Over Time"])
                currentLabel.text = @" Water Depth Over Storm";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Maximum Flooded Area"])
                currentLabel.text = @" Maximum Flooded Area";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Groundwater Infiltration"])
                currentLabel.text = @" Groundwater Infiltration";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Impact on my Neighbors"])
                currentLabel.text = @" Impact on my Neighbors";
            else {
                currentLabel.text = @" Invalid label";
            }
        
            if(currentLabel != NULL){
                [_profilesWindow addSubview:currentLabel];
            }
            width+= widthOfVisualization;
        }
    
        [_profilesWindow setContentSize: CGSizeMake(width + 10, _profilesWindow.contentSize.height)];
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
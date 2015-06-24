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

@synthesize studyNum = _studyNum;
@synthesize profilesWindow = _profilesWindow;
@synthesize usernamesWindow = _usernamesWindow;

NSMutableDictionary *concernColors;
int widthOfTitleVisualization = 220;
int heightOfVisualization = 270;



- (void)viewDidLoad {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    _studyNum = tabControl.studyNum;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleProfileUpdate)
                                                 name:@"profileUpdate"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadUsernames)
                                                 name:@"usernameUpdate"
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
    _usernamesWindow.delegate = self;
    
    _profilesWindow.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _profilesWindow.layer.borderWidth = 1.0;
    
}


-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// release notification if view is unloaded for memory purposes
- (void) viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleProfileUpdate)
                                                 name:@"profileUpdate"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadUsernames)
                                                 name:@"usernameUpdate"
                                               object:nil];
    
    [self handleProfileUpdate];
}


- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)handleProfileUpdate {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];

    // then load other user profiles
    for (UIView *view in [_profilesWindow subviews]){
        [view removeFromSuperview];
    }
    
    // load profile usernames
    [self loadUsernames];
    
    // first load the devices profile
    [self loadOwnProfile];
    
    int amountOfProfilesLoaded = 1;
    int height = heightOfVisualization;
    int overallWidth = widthOfTitleVisualization * 8;
    
    for (NSArray *profileArray in tabControl.profiles) {
        int width = 0;
        // load concerns in order
        for (int i = 3; i < profileArray.count; i++) {
            UILabel *currentLabel = [[UILabel alloc]init];
            currentLabel.backgroundColor = [concernColors objectForKey:[profileArray objectAtIndex:i]];
            currentLabel.frame = CGRectMake(width, amountOfProfilesLoaded * heightOfVisualization + 2, widthOfTitleVisualization, 40);
            currentLabel.font = [UIFont boldSystemFontOfSize:15.3];
        
            if([[profileArray objectAtIndex:i] isEqualToString:@"Investment"])
                currentLabel.text = @"  Investment";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Damage Reduction"])
                currentLabel.text = @"  Damage Reduction";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Efficiency of Intervention ($/Gallon)"])
                currentLabel.text = @"  Efficiency of Intervention";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Capacity Used"])
                currentLabel.text = @"  Intervention Capacity";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Water Depth Over Time"])
                currentLabel.text = @"  Water Depth Over Storm";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Maximum Flooded Area"])
                currentLabel.text = @"  Maximum Flooded Area";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Groundwater Infiltration"])
                currentLabel.text = @"  Groundwater Infiltration";
            else if([[profileArray objectAtIndex:i] isEqualToString:@"Impact on my Neighbors"])
                currentLabel.text = @"  Impact on my Neighbors";
            else {
                currentLabel = NULL;
            }
        
            if(currentLabel != NULL){
                [_profilesWindow addSubview:currentLabel];
                width += widthOfTitleVisualization;
            }
        }
            
        amountOfProfilesLoaded++;
        height += heightOfVisualization;
    }
    
    [_profilesWindow setContentSize: CGSizeMake(overallWidth + 10, height)];
    
}


- (void)loadOwnProfile {
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    int width = 0;

    // load concerns in order
    for (int i = 1; i < tabControl.ownProfile.count; i++) {
        UILabel *currentLabel = [[UILabel alloc]init];
        currentLabel.backgroundColor = [concernColors objectForKey:[tabControl.ownProfile objectAtIndex:i]];
        currentLabel.frame = CGRectMake(width, 2, widthOfTitleVisualization, 40);
        currentLabel.font = [UIFont boldSystemFontOfSize:15.3];
        
        if([[tabControl.ownProfile objectAtIndex:i] isEqualToString:@"Investment"])
            currentLabel.text = @"  Investment";
        else if([[tabControl.ownProfile objectAtIndex:i] isEqualToString:@"Damage Reduction"])
            currentLabel.text = @"  Damage Reduction";
        else if([[tabControl.ownProfile objectAtIndex:i] isEqualToString:@"Efficiency of Intervention ($/Gallon)"])
            currentLabel.text = @"  Efficiency of Intervention";
        else if([[tabControl.ownProfile objectAtIndex:i] isEqualToString:@"Capacity Used"])
            currentLabel.text = @"  Intervention Capacity";
        else if([[tabControl.ownProfile objectAtIndex:i] isEqualToString:@"Water Depth Over Time"])
            currentLabel.text = @"  Water Depth Over Storm";
        else if([[tabControl.ownProfile objectAtIndex:i] isEqualToString:@"Maximum Flooded Area"])
            currentLabel.text = @"  Maximum Flooded Area";
        else if([[tabControl.ownProfile objectAtIndex:i] isEqualToString:@"Groundwater Infiltration"])
            currentLabel.text = @"  Groundwater Infiltration";
        else if([[tabControl.ownProfile objectAtIndex:i] isEqualToString:@"Impact on my Neighbors"])
            currentLabel.text = @"  Impact on my Neighbors";
        else {
            currentLabel = NULL;
        }
        
        if(currentLabel != NULL){
            [_profilesWindow addSubview:currentLabel];
            width += widthOfTitleVisualization;
        }
    }

}


- (void)loadUsernames {
    // remove all labels
    for (UIView *view in [_usernamesWindow subviews]) {
        [view removeFromSuperview];
    }
    
    int height = 0;
    
    // load name of own profile
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.backgroundColor = [UIColor whiteColor];
    nameLabel.frame = CGRectMake(0, 2, _usernamesWindow.frame.size.width, 40);
    nameLabel.font = [UIFont boldSystemFontOfSize:15.3];
    nameLabel.text = [NSString stringWithFormat:@"  %@ (You)", [tabControl.ownProfile objectAtIndex:0]];
    if(nameLabel != NULL) {
        [_usernamesWindow addSubview:nameLabel];
        height += heightOfVisualization;
    }

    int numberOfUsernames = 1;
    
    // loop through other profiles and load their name labels
    for (NSArray *profile in tabControl.profiles) {
        UILabel *nameLabel = [[UILabel alloc]init];
        nameLabel.backgroundColor = [UIColor whiteColor];
        nameLabel.frame = CGRectMake(0, numberOfUsernames * heightOfVisualization + 2, _usernamesWindow.frame.size.width, 40);
        nameLabel.font = [UIFont boldSystemFontOfSize:15.3];
        nameLabel.text = [NSString stringWithFormat:@"  %@", [profile objectAtIndex:2]];
        if(nameLabel != NULL) {
            [_usernamesWindow addSubview:nameLabel];
            numberOfUsernames++;
            height += heightOfVisualization;
        }
    }
    
    [_usernamesWindow setContentSize: CGSizeMake(_usernamesWindow.contentSize.width, height)];
}


// synchronizes vertical scrolling between usersnamesWindow and profilesWindow
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:_usernamesWindow]) {
        float verticalOffset = _usernamesWindow.contentOffset.y;
        CGPoint contentOffset;
        contentOffset.y = verticalOffset;
        contentOffset.x = _profilesWindow.contentOffset.x;
        [_profilesWindow setContentOffset:contentOffset];
    }
    else if ([scrollView isEqual:_profilesWindow]) {
        float verticalOffset = _profilesWindow.contentOffset.y;
        CGPoint contentOffset;
        contentOffset.y = verticalOffset;
        contentOffset.x = _usernamesWindow.contentOffset.x;
        [_usernamesWindow setContentOffset:contentOffset];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
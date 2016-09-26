//
//  ViewController.m
//  Trial_1
//
//  Created by Jamie Auza on 4/18/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import "ViewController.h"
#import "takeAPictureViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([[segue identifier] isEqualToString:@"toTAP"])
    {
        takeAPictureViewController *takeAPictureViewController = [segue destinationViewController];
        takeAPictureViewController.warpedGlobal = _currentImage_T;
        takeAPictureViewController.groupNumber= _groupNumber;
        takeAPictureViewController.IPAddress = _IPAddress;
        takeAPictureViewController.currentImage_TAP = _currentImage_T;
        takeAPictureViewController.userImage_TAP = _userImage_T;
    }
    
}


- (IBAction)toTAP:(id)sender {
    [self performSegueWithIdentifier:@"toTAP" sender:sender];
}
@end

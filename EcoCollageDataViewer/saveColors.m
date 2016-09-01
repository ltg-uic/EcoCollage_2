//
//  saveColors.m
//  Trial_1
//
//  Created by Jamie Auza on 7/4/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import "saveColors.h"
#import "Swale.h"
#import "HSVLocation.h"
#import "savedLocations.h"
#import "CVWrapper.h"
#import "analysisViewController.h"

@implementation saveColors
@synthesize clickedSegment_SC;
@synthesize rainBarrelColors;
@synthesize swaleColors;
@synthesize permeablePaverColors;
@synthesize greenRoofColors;
@synthesize greenCornerColors;

savedLocations* savedLocationsFromFile_SC;
double R_low;
double G_low;
double B_low;
double R_high;
double G_high;
double B_high;
Boolean noChoiceMade;
NSString * nameOfEntry;


- (void)viewDidLoad {
    [super viewDidLoad];

    _Swale = [self.tabBarController.childViewControllers objectAtIndex:0];
    _PermeablePaver = [self.tabBarController.childViewControllers objectAtIndex:1];
    _GreenRoof = [self.tabBarController.childViewControllers objectAtIndex:2];
    _RainBarrel = [self.tabBarController.childViewControllers objectAtIndex:3];
    _GreenCorners = [self.tabBarController.childViewControllers objectAtIndex:4];
    
    
    savedLocationsFromFile_SC = [[savedLocations alloc] init];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    nameOfEntry = [savedLocationsFromFile_SC nameOfObjectAtIndex:clickedSegment_SC];
    _profileText.text = nameOfEntry;
    
    for(int i = 0; i < 5; i++){
            switch(i){
                case 0:
                    if( [_Swale seguedFromTileDetection] == true){
                        swaleColors = [savedLocationsFromFile_SC getHSVForSavedLocationAtIndex:clickedSegment_SC Icon:0];
                        _low_S.backgroundColor = [self getDarkest: swaleColors];
                        _high_S.backgroundColor = [self getBrightest:swaleColors];
                        _LH_S.text = [swaleColors objectAtIndex:0];
                        _LS_S.text = [swaleColors objectAtIndex:2];
                        _LB_S.text = [swaleColors objectAtIndex:4];
                        _HH_S.text = [swaleColors objectAtIndex:1];
                        _HS_S.text = [swaleColors objectAtIndex:3];
                        _HB_S.text = [swaleColors objectAtIndex:5];
                    }else{
                        [self updateSwaleLabels];
                    }
                    break;
                case 1:
                    if( [_RainBarrel seguedFromTileDetection] == true){
                        rainBarrelColors = [savedLocationsFromFile_SC getHSVForSavedLocationAtIndex:clickedSegment_SC Icon:1];
                        _low_RB.backgroundColor = [self getDarkest: rainBarrelColors];
                        _high_RB.backgroundColor = [self getBrightest:rainBarrelColors];
                        _LH_RB.text = [rainBarrelColors objectAtIndex:0];
                        _LS_RB.text = [rainBarrelColors objectAtIndex:2];
                        _LB_RB.text = [rainBarrelColors objectAtIndex:4];
                        _HH_RB.text = [rainBarrelColors objectAtIndex:1];
                        _HS_RB.text = [rainBarrelColors objectAtIndex:3];
                        _HB_RB.text = [rainBarrelColors objectAtIndex:5];
                    }else{
                        [self updateRainBarrelLabels];
                    }
                    break;
                case 2:
                    if( [_GreenRoof seguedFromTileDetection] == true){
                        greenRoofColors = [savedLocationsFromFile_SC getHSVForSavedLocationAtIndex:clickedSegment_SC Icon:2];
                        _low_GR.backgroundColor = [self getDarkest: greenRoofColors];
                        _high_GR.backgroundColor = [self getBrightest:greenRoofColors];
                        _LH_GR.text = [greenRoofColors objectAtIndex:0];
                        _LS_GR.text = [greenRoofColors objectAtIndex:2];
                        _LB_GR.text = [greenRoofColors objectAtIndex:4];
                        _HH_GR.text = [greenRoofColors objectAtIndex:1];
                        _HS_GR.text = [greenRoofColors objectAtIndex:3];
                        _HB_GR.text = [greenRoofColors objectAtIndex:5];
                    }else{
                        [self updateGreenRoofLabels];
                    }
                    break;
                case 3:
                    if( [_PermeablePaver seguedFromTileDetection] == true){
                        permeablePaverColors = [savedLocationsFromFile_SC getHSVForSavedLocationAtIndex:clickedSegment_SC Icon:3];
                        _low_PP.backgroundColor = [self getDarkest: permeablePaverColors];
                        _high_PP.backgroundColor = [self getBrightest:permeablePaverColors];
                        _LH_PP.text = [permeablePaverColors objectAtIndex:0];
                        _LS_PP.text = [permeablePaverColors objectAtIndex:2];
                        _LB_PP.text = [permeablePaverColors objectAtIndex:4];
                        _HH_PP.text = [permeablePaverColors objectAtIndex:1];
                        _HS_PP.text = [permeablePaverColors objectAtIndex:3];
                        _HB_PP.text = [permeablePaverColors objectAtIndex:5];
                    }else{
                        [self updatePermeablePaverLabels];
                    }
                    break;
                case 4: ;
                    if( [_GreenCorners seguedFromTileDetection] == true){
                        greenCornerColors = [savedLocationsFromFile_SC getHSVForSavedLocationAtIndex:clickedSegment_SC Icon:4];
                        _low_GC.backgroundColor = [self getDarkest: greenCornerColors];
                        _high_GC.backgroundColor = [self getBrightest:greenCornerColors];
                        _LH_GC.text = [greenCornerColors objectAtIndex:0];
                        _LS_GC.text = [greenCornerColors objectAtIndex:2];
                        _LB_GC.text = [greenCornerColors objectAtIndex:4];
                        _HH_GC.text = [greenCornerColors objectAtIndex:1];
                        _HS_GC.text = [greenCornerColors objectAtIndex:3];
                        _HB_GC.text = [greenCornerColors objectAtIndex:5];
                    }else{
                        [self updateGreenCornerLabels];
                    }
                    break;

            }
    }
    
}

-(void) updateSwaleLabels{
    swaleColors = [_Swale getHighLowVals];
    
    _LH_S.text = [swaleColors objectAtIndex:0];
    _LS_S.text = [swaleColors objectAtIndex:2];
    _LB_S.text = [swaleColors objectAtIndex:4];
    _HH_S.text = [swaleColors objectAtIndex:1];
    _HS_S.text = [swaleColors objectAtIndex:3];
    _HB_S.text = [swaleColors objectAtIndex:5];
    
    
    [CVWrapper getRGBValuesFromH:[_LH_S.text intValue]
                               S:[_LS_S.text intValue]
                               V:[_LB_S.text intValue]
                               R:&R_low
                               G:&G_low
                               B:&B_low];
    
    [CVWrapper getRGBValuesFromH:[_HH_S.text intValue]
                               S:[_HS_S.text intValue]
                               V:[_HB_S.text intValue]
                               R:&R_high
                               G:&G_high
                               B:&B_high];
    
    _low_S.backgroundColor = [[UIColor alloc] initWithRed:R_low/255.0
                                                    green:G_low/255.0
                                                     blue:B_low/255.0
                                                    alpha:1];
    
    _high_S.backgroundColor = [[UIColor alloc] initWithRed:R_high/255.0
                                                     green:G_high/255.0
                                                      blue:B_high/255.0
                                                     alpha:1];
    
}

-(void) updateRainBarrelLabels{
    //NSLog(@"%@", [_RainBarrel getColorPaletteLabel]);
    //NSLog(@"%@", [_RainBarrel getHighLowVals]);
    

    rainBarrelColors = [_RainBarrel getHighLowVals];
    
    _LH_RB.text = [rainBarrelColors objectAtIndex:0];
    _LS_RB.text = [rainBarrelColors objectAtIndex:2];
    _LB_RB.text = [rainBarrelColors objectAtIndex:4];
    _HH_RB.text = [rainBarrelColors objectAtIndex:1];
    _HS_RB.text = [rainBarrelColors objectAtIndex:3];
    _HB_RB.text = [rainBarrelColors objectAtIndex:5];
    
    [CVWrapper getRGBValuesFromH:[_LH_RB.text intValue]
                               S:[_LS_RB.text intValue]
                               V:[_LB_RB.text intValue]
                               R:&R_low
                               G:&G_low
                               B:&B_low];
    
    [CVWrapper getRGBValuesFromH:[_HH_RB.text intValue]
                               S:[_HS_RB.text intValue]
                               V:[_HB_RB.text intValue]
                               R:&R_high
                               G:&G_high
                               B:&B_high];
    
    
    
    _low_RB.backgroundColor = [[UIColor alloc] initWithRed:R_low/255.0
                                                    green:G_low/255.0
                                                     blue:B_low/255.0
                                                    alpha:1];
    
    _high_RB.backgroundColor = [[UIColor alloc] initWithRed:R_high/255.0
                                                     green:G_high/255.0
                                                      blue:B_high/255.0
                                                     alpha:1];
    

}

-(void) updatePermeablePaverLabels{
    //NSLog(@"%@", [_PermeablePaver getColorPaletteLabel]);
    //NSLog(@"%@", [_PermeablePaver getHighLowVals]);
    

    permeablePaverColors = [_PermeablePaver getHighLowVals];
    
    _LH_PP.text = [permeablePaverColors objectAtIndex:0];
    _LS_PP.text = [permeablePaverColors objectAtIndex:2];
    _LB_PP.text = [permeablePaverColors objectAtIndex:4];
    _HH_PP.text = [permeablePaverColors objectAtIndex:1];
    _HS_PP.text = [permeablePaverColors objectAtIndex:3];
    _HB_PP.text = [permeablePaverColors objectAtIndex:5];
    
    [CVWrapper getRGBValuesFromH:[_LH_PP.text intValue]
                               S:[_LS_PP.text intValue]
                               V:[_LB_PP.text intValue]
                               R:&R_low
                               G:&G_low
                               B:&B_low];
    
    [CVWrapper getRGBValuesFromH:[_HH_PP.text intValue]
                               S:[_HS_PP.text intValue]
                               V:[_HB_PP.text intValue]
                               R:&R_high
                               G:&G_high
                               B:&B_high];
    
    _low_PP.backgroundColor = [[UIColor alloc] initWithRed:R_low/255.0
                                                    green:G_low/255.0
                                                     blue:B_low/255.0
                                                    alpha:1];
    
    _high_PP.backgroundColor = [[UIColor alloc] initWithRed:R_high/255.0
                                                     green:G_high/255.0
                                                      blue:B_high/255.0
                                                     alpha:1];

}

-(void) updateGreenRoofLabels{
    //NSLog(@"%@", [reenRoof getColorPaletteLabel]);
    //NSLog(@"%@", [_GreenRoof getHighLowVals]);
    

    greenRoofColors = [_GreenRoof getHighLowVals];
    
    _LH_GR.text = [greenRoofColors objectAtIndex:0];
    _LS_GR.text = [greenRoofColors objectAtIndex:2];
    _LB_GR.text = [greenRoofColors objectAtIndex:4];
    _HH_GR.text = [greenRoofColors objectAtIndex:1];
    _HS_GR.text = [greenRoofColors objectAtIndex:3];
    _HB_GR.text = [greenRoofColors objectAtIndex:5];
    
    [CVWrapper getRGBValuesFromH:[_LH_GR.text intValue]
                               S:[_LS_GR.text intValue]
                               V:[_LB_GR.text intValue]
                               R:&R_low
                               G:&G_low
                               B:&B_low];
    
    [CVWrapper getRGBValuesFromH:[_HH_GR.text intValue]
                               S:[_HS_GR.text intValue]
                               V:[_HB_GR.text intValue]
                               R:&R_high
                               G:&G_high
                               B:&B_high];
    
    _low_GR.backgroundColor = [[UIColor alloc] initWithRed:R_low/255.0
                                                     green:G_low/255.0
                                                      blue:B_low/255.0
                                                     alpha:1];
    
    _high_GR.backgroundColor = [[UIColor alloc] initWithRed:R_high/255.0
                                                      green:G_high/255.0
                                                       blue:B_high/255.0
                                                      alpha:1];
    
}

-(void) updateGreenCornerLabels{
    //NSLog(@"%@", [_GreenRoof getColorPaletteLabel]);
    //NSLog(@"%@", [_GreenRoof getHighLowVals]);
    

    greenCornerColors = [_GreenCorners getHighLowVals];
    
    _LH_GC.text = [greenCornerColors objectAtIndex:0];
    _LS_GC.text = [greenCornerColors objectAtIndex:2];
    _LB_GC.text = [greenCornerColors objectAtIndex:4];
    _HH_GC.text = [greenCornerColors objectAtIndex:1];
    _HS_GC.text = [greenCornerColors objectAtIndex:3];
    _HB_GC.text = [greenCornerColors objectAtIndex:5];
    
    [CVWrapper getRGBValuesFromH:[_LH_GC.text intValue]
                               S:[_LS_GC.text intValue]
                               V:[_LB_GC.text intValue]
                               R:&R_low
                               G:&G_low
                               B:&B_low];
    
    [CVWrapper getRGBValuesFromH:[_HH_GC.text intValue]
                               S:[_HS_GC.text intValue]
                               V:[_HB_GC.text intValue]
                               R:&R_high
                               G:&G_high
                               B:&B_high];
    
    _low_GC.backgroundColor = [[UIColor alloc] initWithRed:R_low/255.0
                                                     green:G_low/255.0
                                                      blue:B_low/255.0
                                                     alpha:1];
    
    _high_GC.backgroundColor = [[UIColor alloc] initWithRed:R_high/255.0
                                                      green:G_high/255.0
                                                       blue:B_high/255.0
                                                      alpha:1];
    
}

- (IBAction)saveAs:(id)sender {
    [self writeToFile:_profileText.text];
    
    /*
    if( noChoiceMade == true){
        NSString * info = [NSString stringWithFormat: @"Choose a Saved Color Palette for all Icons before saving"];
        UIAlertView * alertNull = [[UIAlertView alloc] initWithTitle:@"Error!" message: info delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertNull show];
        return;
    }
    
    NSString * info = [NSString stringWithFormat: @"We suggest naming this color set based on the location/condition of the room it was taken.\n e.g. 'Lab - Flourescent Lighting'"];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Saving Color Set" message: info delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 0;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.placeholder = @"Insert name here";
    [alert show];
     */
}

-(void) writeToFile: (NSString*) name{
    NSMutableArray * saveValues = [[NSMutableArray alloc] init];
    
    [saveValues addObjectsFromArray:swaleColors];
    [saveValues addObjectsFromArray:rainBarrelColors];
    [saveValues addObjectsFromArray:greenRoofColors];
    [saveValues addObjectsFromArray:permeablePaverColors];
    [saveValues addObjectsFromArray:greenCornerColors];
    
    int index = [savedLocationsFromFile_SC saveEntryWithName:name Values:saveValues];
    clickedSegment_SC = index;
    
    // Adds the new or modified HSVLocation for the drop down
    [savedLocationsFromFile_SC changeFromFile];
    [_Swale changeFromFile];
    [_Swale changeColorSetToIndex: index];
    [_RainBarrel changeFromFile];
    [_RainBarrel changeColorSetToIndex: index];
    [_GreenRoof changeFromFile];
    [_GreenRoof changeColorSetToIndex: index];
    [_PermeablePaver changeFromFile];
    [_PermeablePaver changeColorSetToIndex: index];
    [_GreenCorners changeFromFile];
    [_GreenCorners changeColorSetToIndex: index];
    // Go back to tile detection
    [self performSegueWithIdentifier:@"backToAnalysis" sender:self];
    // Any action can be performed here
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"backToAnalysis"])
    {
        analysisViewController *analysisViewController = [segue destinationViewController];
        analysisViewController.currentImage_A = _currentImage_SC;
        analysisViewController.userImage_A = _originalImage_SC;
        analysisViewController.clickedSegment_A = clickedSegment_SC;
    }
}


// Gets called after we enter from the alert view
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    /*
    if (buttonIndex == 0 )
    {
        // User Clicked Cancel
    }
    else if( [alertView tag] == 0)
    {
        NSLog(@"user pressed Button Indexed 1");
        
        NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
        nameOfEntry = [[alertView textFieldAtIndex:0] text];
        
        // Checking if user is overwriting
        if([savedLocationsFromFile_SC isOverwriting:nameOfEntry]){
            NSString * info = [NSString stringWithFormat: @"There is already a Color Pallette called '%@' would you like to over write it?", [[alertView textFieldAtIndex:0]text]];
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Over Writing Color Palette" message: info delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
            alert.tag = 1;
            [alert show];
            return;
        }else
            [self writeToFile:nameOfEntry];
    }else{
        // if the user chooses to overwrite
        [self writeToFile:[[alertView textFieldAtIndex:0]text]];
    }
     */
}



- (UIColor*) getDarkest:(NSMutableArray*)HSVValues{
    [CVWrapper getRGBValuesFromH:[[HSVValues objectAtIndex:0] integerValue]
                               S:[[HSVValues objectAtIndex:2] integerValue]
                               V:[[HSVValues objectAtIndex:4] integerValue]
                               R:&R_high
                               G:&G_high
                               B:&B_high];
    
    
    return [[UIColor alloc] initWithRed:R_high/255.0
                                  green:G_high/255.0
                                   blue:B_high/255.0
                                  alpha:1];
}

- (UIColor*) getBrightest:(NSMutableArray*)HSVValues{
    
    [CVWrapper getRGBValuesFromH:[[HSVValues objectAtIndex:1] integerValue]
                               S:[[HSVValues objectAtIndex:3] integerValue]
                               V:[[HSVValues objectAtIndex:5] integerValue]
                               R:&R_low
                               G:&G_low
                               B:&B_low];

    
    return [[UIColor alloc] initWithRed:R_low/255.0
                                  green:G_low/255.0
                                   blue:B_low/255.0
                                  alpha:1];
}
@end

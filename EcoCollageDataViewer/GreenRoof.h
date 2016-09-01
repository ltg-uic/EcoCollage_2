//
//  GreenRoof.h
//  Trial_1
//
//  Created by Jamie Auza on 5/27/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "savedLocations.h"

@interface GreenRoof : UIViewController <UIScrollViewDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISwitch *threshSwitch;

@property (nonatomic,strong) UIImage * currentImage_GR;
@property (nonatomic,strong) UIImage * originalImage_GR;

@property (strong, nonatomic) IBOutlet UIImageView *sample1;
@property (strong, nonatomic) IBOutlet UIImageView *sample2;
@property (weak, nonatomic) IBOutlet UIImageView *sample3;
@property (weak, nonatomic) IBOutlet UIImageView *sample4;
@property (weak, nonatomic) IBOutlet UIImageView *sample5;
@property (weak, nonatomic) IBOutlet UIImageView *sample6;
//@property (weak, nonatomic) IBOutlet UIImageView *sample7;
@property (weak, nonatomic) IBOutlet UIImageView *lightest_GR;
@property (weak, nonatomic) IBOutlet UIImageView *darkest_GR;

@property (nonatomic, strong) UIColor * brightestColor_GR;
@property (nonatomic, strong) UIColor * darkestColor_GR;

@property (weak, nonatomic) IBOutlet UISwitch *viewIconSwitch;
@property (weak, nonatomic) IBOutlet UIButton *dropDown;
//@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)removeAll:(id)sender;
- ( IBAction) dropDownButton:(id)sender;
- (IBAction)backButton:(id)sender;

@property (nonatomic,strong) NSMutableArray *SwaleSamples;
@property (nonatomic,strong) NSString *savedColorPalette_GR;
@property (strong, nonatomic) NSMutableArray*highLowVals_GR;
@property savedLocations* savedLocationsFromFile_GR;
@property long int clickedSegment_GR;
@property Boolean seguedFromTileDetection;

- (void) handleSingleTapFrom: (UITapGestureRecognizer *)recognizer;
- (NSString*) getColorPaletteLabel;
- (NSMutableArray*) getHighLowVals;
- (void) changeFromFile;
- (void) changeColorSetToIndex: (int)index;
-(void) updateBrightAndDark;
- ( void) updateFirstTwoSamples;

@end

/*
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic,strong) UIImage * currentImage_GR;
@property (nonatomic,strong) UIImage * originalImage_GR;

@property (weak, nonatomic) IBOutlet UIImageView *sample1;
@property (weak, nonatomic) IBOutlet UIImageView *sample2;
@property (weak, nonatomic) IBOutlet UIImageView *sample3;
@property (weak, nonatomic) IBOutlet UIImageView *sample4;
@property (weak, nonatomic) IBOutlet UIImageView *sample5;
@property (weak, nonatomic) IBOutlet UIImageView *sample6;
//@property (weak, nonatomic) IBOutlet UIImageView *sample7;
@property (weak, nonatomic) IBOutlet UIImageView *brightest_GR;
@property (weak, nonatomic) IBOutlet UIImageView *darkest_GR;

@property (weak, nonatomic) IBOutlet UISwitch *viewIconSwitch;
@property (weak, nonatomic) IBOutlet UIButton *dropDown;
//@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSString *savedColorPalette_GR;
@property (strong, nonatomic) NSMutableArray*highLowVals_GR;

- (NSString*) getColorPaletteLabel;
- (NSMutableArray*) getHighLowVals;
- (void) changeFromFile;


- (IBAction)removeAll:(id)sender;
- (IBAction)backButton:(id)sender;
- (IBAction)dropDownButton:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *threshSwitch;
- (void) changeColorSetToIndex: (int)index;


- (void) changeHSVVals;

@end
 */

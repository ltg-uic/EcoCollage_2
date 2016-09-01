//
//  RainBarrel.h
//  Trial_1
//
//  Created by Jamie Auza on 5/31/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RainBarrel : UIViewController <UINavigationControllerDelegate, UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISwitch *threshSwitch;

@property (nonatomic,strong) UIImage * currentImage_RB;
@property (nonatomic,strong) UIImage * originalImage_RB;

@property (strong, nonatomic) IBOutlet UIImageView *sample1;
@property (strong, nonatomic) IBOutlet UIImageView *sample2;
@property (weak, nonatomic) IBOutlet UIImageView *sample3;
@property (weak, nonatomic) IBOutlet UIImageView *sample4;
@property (weak, nonatomic) IBOutlet UIImageView *sample5;
@property (weak, nonatomic) IBOutlet UIImageView *sample6;
//@property (weak, nonatomic) IBOutlet UIImageView *sample7;
@property (weak, nonatomic) IBOutlet UIImageView *lightest_RB;
@property (weak, nonatomic) IBOutlet UIImageView *darkest_RB;

@property (nonatomic, strong) UIColor * brightestColor_RB;
@property (nonatomic, strong) UIColor * darkestColor_RB;

@property (weak, nonatomic) IBOutlet UISwitch *viewIconSwitch;
@property (weak, nonatomic) IBOutlet UIButton *dropDown;
//@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)removeAll:(id)sender;
- (IBAction)dropDownButton:(id)sender;
- (IBAction)backButton:(id)sender;

@property (nonatomic,strong) NSMutableArray *SwaleSamples;
@property (nonatomic,strong) NSString *savedColorPalette_RB;
@property (strong, nonatomic) NSMutableArray*highLowVals_RB;
@property savedLocations* savedLocationsFromFile_RB;
@property long int clickedSegment_RB;
@property Boolean seguedFromTileDetection;

- (void) handleSingleTapFrom: (UITapGestureRecognizer *)recognizer;
- (NSString*) getColorPaletteLabel;
- (NSMutableArray*) getHighLowVals;
- (void) changeFromFile;
- (void) changeColorSetToIndex: (int)index;
- (void) updateBrightAndDark;
- (void) updateFirstTwoSamples;

@end

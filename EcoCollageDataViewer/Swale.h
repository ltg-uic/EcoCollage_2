//
//  Swale.h
//  Trial_1
//
//  Created by Jamie Auza on 5/20/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "savedLocations.h"

@interface Swale : UIViewController <UINavigationControllerDelegate, UIScrollViewDelegate,UIGestureRecognizerDelegate >
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISwitch *threshSwitch;

@property (nonatomic,strong) UIImage * currentImage_S;
@property (nonatomic,strong) UIImage * originalImage_S;

@property (strong, nonatomic) IBOutlet UIImageView *sample1;
@property (strong, nonatomic) IBOutlet UIImageView *sample2;
@property (weak, nonatomic) IBOutlet UIImageView *sample3;
@property (weak, nonatomic) IBOutlet UIImageView *sample4;
@property (weak, nonatomic) IBOutlet UIImageView *sample5;
@property (weak, nonatomic) IBOutlet UIImageView *sample6;
//@property (weak, nonatomic) IBOutlet UIImageView *sample7;
@property (weak, nonatomic) IBOutlet UIImageView *lightest_S;
@property (weak, nonatomic) IBOutlet UIImageView *darkest_S;

@property (nonatomic, strong) UIColor * brightestColor_S;
@property (nonatomic, strong) UIColor * darkestColor_S;

@property (weak, nonatomic) IBOutlet UISwitch *viewIconSwitch;
@property (weak, nonatomic) IBOutlet UIButton *dropDown;
//@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)removeAll:(id)sender;
- ( IBAction) dropDownButton:(id)sender;
- (IBAction)backButton:(id)sender;

@property (nonatomic,strong) NSMutableArray *SwaleSamples;
@property (nonatomic,strong) NSString *savedColorPalette_S;
@property (strong, nonatomic) NSMutableArray*highLowVals_S;
@property savedLocations* savedLocationsFromFile_S;
@property long int clickedSegment_S;
@property Boolean seguedFromTileDetection;

- (void) handleSingleTapFrom: (UITapGestureRecognizer *)recognizer;
- (NSString*) getColorPaletteLabel;
- (NSMutableArray*) getHighLowVals;
- (void) changeFromFile;
- (void) changeColorSetToIndex: (int)index;
-(void) updateBrightAndDark;
- ( void) updateFirstTwoSamples;

@end

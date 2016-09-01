//
//  GreenCorners.h
//  Trial_1
//
//  Created by Jamie Auza on 7/11/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GreenCorners : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *sample1;
@property (weak, nonatomic) IBOutlet UIImageView *sample2;
@property (weak, nonatomic) IBOutlet UIImageView *sample3;
@property (weak, nonatomic) IBOutlet UIImageView *sample4;
@property (weak, nonatomic) IBOutlet UIImageView *sample5;
@property (weak, nonatomic) IBOutlet UIImageView *sample6;
@property (weak, nonatomic) IBOutlet UIImageView *lightest_GC;
@property (weak, nonatomic) IBOutlet UIImageView *darkest_GC;

@property (nonatomic, strong) UIColor * brightestColor_GC;
@property (nonatomic, strong) UIColor * darkestColor_GC;

@property (weak, nonatomic) IBOutlet UIButton *dropDown;
//@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISwitch *threshSwitch;

@property (nonatomic,strong) NSString *savedColorPalette_GC;
@property (strong, nonatomic) NSMutableArray*highLowVals_GC;

- (IBAction)removeAll:(id)sender;
- (IBAction)dropDownButton:(id)sender;
- (IBAction)backButton:(id)sender;
- (NSString*) getColorPaletteLabel;
- (NSMutableArray*) getHighLowVals;
- (void) changeFromFile;
- (void) changeColorSetToIndex: (int)index;
@property Boolean seguedFromTileDetection;
@property long int clickedSegment_GC;


@property (nonatomic,strong) NSMutableArray * GreenCornerSamples;
@property (nonatomic,strong) UIImage * originalImage;
@property (nonatomic,strong) UIImage * processedImage;

@end

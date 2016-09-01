//
//  saveColors.h
//  Trial_1
//
//  Created by Jamie Auza on 7/4/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Swale.h"
#import "RainBarrel.h"
#import "GreenRoof.h"
#import "PermeablePaver.h"
#import "GreenCorners.h"

@interface saveColors : UIViewController <UIImagePickerControllerDelegate>

@property long int clickedSegment_SC;
@property Boolean seguedFromTileDetection;
@property (nonatomic,strong) UIImage * currentImage_SC;
@property (nonatomic,strong) UIImage * originalImage_SC;

@property (strong, nonatomic) NSMutableArray*swaleColors;
@property (strong, nonatomic) NSMutableArray*rainBarrelColors;
@property (strong, nonatomic) NSMutableArray*permeablePaverColors;
@property (strong, nonatomic) NSMutableArray*greenRoofColors;
@property (strong, nonatomic) NSMutableArray*greenCornerColors;
@property (weak, nonatomic) IBOutlet UITextField *profileText;


@property (strong, nonatomic) Swale * Swale;
@property (strong, nonatomic) RainBarrel * RainBarrel;
@property (strong, nonatomic) GreenRoof * GreenRoof;
@property (strong, nonatomic) PermeablePaver * PermeablePaver;
@property (strong, nonatomic) GreenCorners * GreenCorners;


@property (weak, nonatomic) NSString * swaleLabel;
@property (weak, nonatomic) NSString * rainBarrelLabel;
@property (weak, nonatomic) NSString * permeablePaverLabel;
@property (weak, nonatomic) NSString * greenRoofLabel;


// Save Button
- (IBAction)saveAs:(id)sender;

// Image Views

@property (weak, nonatomic) IBOutlet UIImageView *low_S;
@property (weak, nonatomic) IBOutlet UIImageView *high_S;

@property (weak, nonatomic) IBOutlet UIImageView *high_RB;
@property (weak, nonatomic) IBOutlet UIImageView *low_RB;

@property (weak, nonatomic) IBOutlet UIImageView *high_PP; // giggity
@property (weak, nonatomic) IBOutlet UIImageView *low_PP;

@property (weak, nonatomic) IBOutlet UIImageView *high_GR;
@property (weak, nonatomic) IBOutlet UIImageView *low_GR;

@property (weak, nonatomic) IBOutlet UIImageView *high_GC;
@property (weak, nonatomic) IBOutlet UIImageView *low_GC;

// Labels

// Swale
@property (weak, nonatomic) IBOutlet UILabel *HH_S; // High Hue Swale
@property (weak, nonatomic) IBOutlet UILabel *HS_S;
@property (weak, nonatomic) IBOutlet UILabel *HB_S;

@property (weak, nonatomic) IBOutlet UILabel *LH_S;
@property (weak, nonatomic) IBOutlet UILabel *LS_S;
@property (weak, nonatomic) IBOutlet UILabel *LB_S;

// Rain Barrel
@property (weak, nonatomic) IBOutlet UILabel *HH_RB; // High Hue Rain Barrel
@property (weak, nonatomic) IBOutlet UILabel *HS_RB;
@property (weak, nonatomic) IBOutlet UILabel *HB_RB;

@property (weak, nonatomic) IBOutlet UILabel *LH_RB;
@property (weak, nonatomic) IBOutlet UILabel *LS_RB;
@property (weak, nonatomic) IBOutlet UILabel *LB_RB;

// Permeable Paver
@property (weak, nonatomic) IBOutlet UILabel *HH_PP; // High Hue Permeable Paver
@property (weak, nonatomic) IBOutlet UILabel *HS_PP;
@property (weak, nonatomic) IBOutlet UILabel *HB_PP;

@property (weak, nonatomic) IBOutlet UILabel *LH_PP;
@property (weak, nonatomic) IBOutlet UILabel *LS_PP;
@property (weak, nonatomic) IBOutlet UILabel *LB_PP;

// Green Roof
@property (weak, nonatomic) IBOutlet UILabel *HH_GR; // High Hue Green Roof
@property (weak, nonatomic) IBOutlet UILabel *HS_GR;
@property (weak, nonatomic) IBOutlet UILabel *HB_GR;

@property (weak, nonatomic) IBOutlet UILabel *LH_GR;
@property (weak, nonatomic) IBOutlet UILabel *LS_GR;
@property (weak, nonatomic) IBOutlet UILabel *LB_GR;


// Green Roof
@property (weak, nonatomic) IBOutlet UILabel *HH_GC; // High Hue Green Roof
@property (weak, nonatomic) IBOutlet UILabel *HS_GC;
@property (weak, nonatomic) IBOutlet UILabel *HB_GC;

@property (weak, nonatomic) IBOutlet UILabel *LH_GC;
@property (weak, nonatomic) IBOutlet UILabel *LS_GC;
@property (weak, nonatomic) IBOutlet UILabel *LB_GC;



@end

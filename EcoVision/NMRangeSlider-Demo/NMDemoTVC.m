//
//  NMDemoTVC.m
//  NMRangeSlider
//
//  Created by Murray Hughes on 04/08/2012
//  Copyright 2011 Null Monkey Pty Ltd. All rights reserved.
//


#import "NMDemoTVC.h"
#import "CVWrapper.h"

@interface NMDemoTVC ()

@end

@implementation NMDemoTVC

int segmentIndex = 0;

- (void)scrollViewDidScroll: (UIScrollView*)scroll {
    [self configureLabelSliders];
    [self updateSliderLabels];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLabelSliderConfiguration];
    [self configureLabelSliders];
    [self updateSliderLabels];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureLabelSliders];
    [self updateSliderLabels];
    
    if([self.view respondsToSelector:@selector(setTintColor:)])
    {
        self.view.tintColor = [UIColor blueColor];
    }
    
}

- (void) initLabelSliderConfiguration {
    int minimumRangeBetweenSliders = 10; // make sure to change same variable in configureLabelSliders function
    
    self.labelSlider.minimumValue = 0;
    self.labelSlider.maximumValue = 255;
    self.labelSlider.minimumRange = minimumRangeBetweenSliders;
    self.labelSlider2.minimumValue = 0;
    self.labelSlider2.maximumValue = 255;
    self.labelSlider2.minimumRange = minimumRangeBetweenSliders;
    self.labelSlider3.minimumValue = 0;
    self.labelSlider3.maximumValue = 255;
    self.labelSlider3.minimumRange = minimumRangeBetweenSliders;
}

- (void) configureLabelSliders
{
    int minimumRangeBetweenSliders = 10; // make sure to change same variable in initLabelSliderConfiguration function

    int hsvValues[30];
    [CVWrapper getHSV_Values:hsvValues];
    
    
    // labelSlider values have to be updated in specfic order
    
    // labelSlider update ordering
    if (self.labelSlider.lowerValue + minimumRangeBetweenSliders >= hsvValues[1 + (segmentIndex*6)]) {
        self.labelSlider.lowerValue = hsvValues[0 + (segmentIndex*6)];
        self.labelSlider.upperValue = hsvValues[1 + (segmentIndex*6)];
    }
    else {
        self.labelSlider.upperValue = hsvValues[1 + (segmentIndex*6)];
        self.labelSlider.lowerValue = hsvValues[0 + (segmentIndex*6)];
    }

    // labelSlider2 update ordering
    if (self.labelSlider2.lowerValue + minimumRangeBetweenSliders >= hsvValues[3 + (segmentIndex*6)]) {
        self.labelSlider2.lowerValue = hsvValues[2 + (segmentIndex*6)];
        self.labelSlider2.upperValue = hsvValues[3 + (segmentIndex*6)];
    }
    else {
        self.labelSlider2.upperValue = hsvValues[3 + (segmentIndex*6)];
        self.labelSlider2.lowerValue = hsvValues[2 + (segmentIndex*6)];
    }

    // labelSlider3 update ordering
    if (self.labelSlider3.lowerValue + minimumRangeBetweenSliders >= hsvValues[5 + (segmentIndex*6)]) {
        self.labelSlider3.lowerValue = hsvValues[4 + (segmentIndex*6)];
        self.labelSlider3.upperValue = hsvValues[5 + (segmentIndex*6)];
    }
    else {
        self.labelSlider3.upperValue = hsvValues[5 + (segmentIndex*6)];
        self.labelSlider3.lowerValue = hsvValues[4 + (segmentIndex*6)];
    }
}

- (void) updateSliderLabels {
    int hsvValues[30];
    [CVWrapper getHSV_Values:hsvValues];
    
    hsvValues[0 + segmentIndex*6] = (int)self.labelSlider.lowerValue;
    hsvValues[1 + segmentIndex*6] = (int)self.labelSlider.upperValue;
    hsvValues[2 + segmentIndex*6] = (int)self.labelSlider2.lowerValue;
    hsvValues[3 + segmentIndex*6] = (int)self.labelSlider2.upperValue;
    hsvValues[4 + segmentIndex*6] = (int)self.labelSlider3.lowerValue;
    hsvValues[5 + segmentIndex*6] = (int)self.labelSlider3.upperValue;
    
    [CVWrapper setHSV_Values:hsvValues];
    
    CGPoint lowerCenter;
    CGPoint upperCenter;
    
    lowerCenter.x = (self.labelSlider.lowerCenter.x + self.labelSlider.frame.origin.x);
    lowerCenter.y = (self.labelSlider.center.y - 30.0f);
    self.lowerLabel.center = lowerCenter;
    self.lowerLabel.text = [NSString stringWithFormat:@"%d", (int)self.labelSlider.lowerValue];

    upperCenter.x = (self.labelSlider.upperCenter.x + self.labelSlider.frame.origin.x);
    upperCenter.y = (self.labelSlider.center.y - 30.0f);
    self.upperLabel.center = upperCenter;
    self.upperLabel.text = [NSString stringWithFormat:@"%d", (int)self.labelSlider.upperValue];
    
    lowerCenter.x = (self.labelSlider2.lowerCenter.x + self.labelSlider2.frame.origin.x);
    lowerCenter.y = (self.labelSlider2.center.y - 30.0f);
    self.lowerLabel2.center = lowerCenter;
    self.lowerLabel2.text = [NSString stringWithFormat:@"%d", (int)self.labelSlider2.lowerValue];
    
    upperCenter.x = (self.labelSlider2.upperCenter.x + self.labelSlider2.frame.origin.x);
    upperCenter.y = (self.labelSlider2.center.y - 30.0f);
    self.upperLabel2.center = upperCenter;
    self.upperLabel2.text = [NSString stringWithFormat:@"%d", (int)self.labelSlider2.upperValue];
    
    lowerCenter.x = (self.labelSlider3.lowerCenter.x + self.labelSlider3.frame.origin.x);
    lowerCenter.y = (self.labelSlider3.center.y - 30.0f);
    self.lowerLabel3.center = lowerCenter;
    self.lowerLabel3.text = [NSString stringWithFormat:@"%d", (int)self.labelSlider3.lowerValue];

    upperCenter.x = (self.labelSlider3.upperCenter.x + self.labelSlider3.frame.origin.x);
    upperCenter.y = (self.labelSlider3.center.y - 30.0f);
    self.upperLabel3.center = upperCenter;
    self.upperLabel3.text = [NSString stringWithFormat:@"%d", (int)self.labelSlider3.upperValue];
}

// Handle control value changed events just like a normal slider
- (IBAction)labelSliderChanged:(NMRangeSlider*)sender
{
    [self updateSliderLabels];
}

- (IBAction)segmentedControl:(UISegmentedControl *)sender {
    [self performSelector:@selector(labelPositioningHack) withObject:(self) afterDelay:(0.01)]; //hack to get labels into correct position
    segmentIndex = (int)sender.selectedSegmentIndex;
    [CVWrapper setSegmentIndex:segmentIndex];
    [self configureLabelSliders];
    [self updateSliderLabels];
}

- (void) labelPositioningHack {
    [self configureLabelSliders];
    [self updateSliderLabels];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView cellForRowAtIndexPath:indexPath].tag==1)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

@end

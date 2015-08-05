//
//  SecondViewController.m
//  EcoVision
//
//  Created by LTG-Guest on 4/8/15.
//  Copyright (c) 2015 EcoCollage. All rights reserved.
//

#import "SecondViewController.h" 
#import "CVWrapper.h"
#import <math.h>
#import <stdlib.h>

@interface SecondViewController ()

@end

@implementation SecondViewController
UITapGestureRecognizer *singleTap; // tap that recognizes color extraction
UITapGestureRecognizer *doubleTap; // tap that recognizes switching to original image
UIImage* plainImage = nil;
UIImage* threshedImage = nil;
UIImage *Coloured;                 // image that displays the inspected colour extracted from a pixel
UIImage *mean_image;               // median filtered original image
UIImageView *img;



/** Struct used to keep track of BGR values **/
typedef struct BGR_List
{
    double b;
    double g;
    double r;
    double a;
    struct BGR_List* next;
}BGR_List;

BGR_List *RedSample   = NULL;
BGR_List *GreenSample = NULL;
BGR_List *BlueSample  = NULL;
BGR_List *BrownSample = NULL;
BGR_List *CornerMarkers = NULL;

/** Struct used to keep track of BGR values **/

//A pair of Low and High Min and Max HSV Values used for Thresholding
typedef struct HSV
{
    int h;
    int s;
    int v;
}HSV;

typedef struct MinMaxHSV
{
    HSV *low;
    HSV *high;
}MinMaxHSV;


long int clickedSegment;

//inserts a new BGR Value to a  sample list
void insertNewBGR2(BGR_List* *list, double B, double G, double R, double A)
{
    if ( (*list) == NULL)
    {
        *list = (BGR_List*)malloc(sizeof(BGR_List));
        (*list)->b = B;
        (*list)->g = G;
        (*list)->r = R;
        (*list)->a = A;
        (*list)->next = NULL;
    }
    else
    {
        BGR_List *newColor = (BGR_List*)malloc(sizeof(BGR_List));
        newColor->b = B;
        newColor->g = G;
        newColor->r = R;
        newColor->a = A;
        newColor->next = (*list);
        (*list) = newColor;
    }
}

//deallocates the BGR Samples
void deallocateList(BGR_List* *list)
{
    while (*list != NULL)
    {
        printf("R - %lf, G - %lf, B - %lf, A - %lf\n\n",(*list)->r, (*list)->g, (*list)->b, (*list)->a);
        
        BGR_List* temp = *list;
        (*list) = (*list)->next;
        free(temp);
    }
    
    printf("\n");
}

void RemoveBGR(BGR_List* *list)
{
    if (*list == NULL)
    {
        return;
    }
    BGR_List* temp = *list;
    (*list) = (*list)->next;
    free(temp);
}

HSV *getHSVVal(BGR_List *list)
{
    //SIDE TRACK...
    //Obtain HSV values from OpenCV Mat equivalent image with changed colorspace
    int H;
    int S;
    int V;
    
    //UIColor *color = [UIColor colorWithRed:list->r green:list->g blue:list->b alpha:list->a];
    //UIImage *colouredImg = [OpenCVMethods imageWithColor:color andSize:CGSizeMake(8, 8)];
    
    
    HSV *entry = (HSV*) malloc(sizeof(HSV));
    [CVWrapper getHSVValuesfromRed:list->r Green:list->g Blue:list->b H:&H S:&S V:&V];
    entry->h = H;
    entry->s = S;
    entry->v = V;
    
    printf("Extracted-----\nH - %d\nS - %d\nV - %d \n\n", entry->h, entry->s, entry->v);
    
    return entry;
}

MinMaxHSV *GetMinMaxHSVfromSample(BGR_List* list)
{
    if (list == NULL)
    {
        printf("Given an empty list... nothing to sample\n");
        return NULL;
    }
    int BGR_entries = 1;
    
    //allocating space for the Min Max HSV combination
    MinMaxHSV *vals = (MinMaxHSV*) malloc(sizeof(MinMaxHSV));
    vals->high = (HSV*)malloc(sizeof(HSV));
    vals->low = (HSV*)malloc(sizeof(HSV));
    
    //Sampling only one entry and converting it to HSV format
    HSV *entry = getHSVVal(list);
    int l_h = entry->h;
    int l_s = entry->s;
    int l_v = entry->v;
    
    int h_h = entry->h;
    int h_s = entry->s;
    int h_v = entry->v;
    
    
    free(entry);
    list = list->next;
    
    //Continuing process if there are more BGR's in the List
    while (list != NULL)
    {
        entry = getHSVVal(list);
        
        //Determine if the new sampling has higher HSV values than the current max HSV value
        if  (h_h < entry->h)
        {
            h_h = entry->h;
            h_s = entry->s;
            h_v = entry->v;
        }
        
        //Determine if the new sampling has lower HSV values than the current min HSV value
        if  (l_h > entry->h)
        {
            
            l_h = entry->h;
            l_s = entry->s;
            l_v = entry->v;
        }
        
        //move on to the next value
        list = list->next;
        BGR_entries++;
        free(entry);
    }
    
    
    //if there was only one sampling, create a standard min and max bound
    if (BGR_entries == 1)
    {
        printf("I only have one value\n");
        vals->high->h = h_h;
        vals->high->s = 255;
        vals->high->v = 255;
        
        vals->low->h = l_h;
        vals->low->s = 0;
        vals->low->v = 0;
    }
    else
    {
        //swap the lower boundaries of the saturation and value values in case the lower bounds value is greater
        //than the upper bounds value (no real need to but gives an ok estimate range for sat and val)
        if (l_s >= h_s)
        {
            int temp_s = l_s;
            l_s = h_s;
            h_s = temp_s;
            
        }
        
        if (l_v >= h_v)
        {
            int temp_v = l_v;
            l_v = h_v;
            h_v = temp_v;
        }
        
        //logic that sets the high Saturation and Value values to midpoint(EDIT: expanded range) from the recorded value and 255
        vals->high->h = h_h;
        vals->high->s = 255 - ((255 - h_s)/3);
        vals->high->v = 255 - ((255 - h_v)/3);;
        
        //logic that sets the low Saturation and Value values to midpoint(EDIT: expanded range) from the recorded value and 0
        vals->low->h = l_h;
        vals->low->s = 0 + (l_s/3);
        vals->low->v = 0 + (l_v/3);
        
    }
    return vals;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    [self setHSVValues];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    plainImage = [CVWrapper getCurrentImage];
    if(plainImage != nil)
        [self updateScrollView:[CVWrapper getCurrentImage]];
}


- (UIColor *) GetCurrentPixelColorAtPoint:(CGPoint)point
{
    // Extract Colour
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    CGContextTranslateCTM(context, -point.x, -point.y);
    [self.scrollView.layer renderInContext:context];
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    //Save the BGR values of the pixel coordinates
    clickedSegment = [CVWrapper getSegmentIndex];
    
    switch (clickedSegment) {
        case 1:
            printf("Extracting Sample for the colour red!!!\n");
            insertNewBGR2(&RedSample,(double)pixel[2], (double)pixel[1], (double)pixel[0], (double)pixel[3]);
            break;
        case 0:
            printf("Extracting Sample for the colour green!!!\n");
            insertNewBGR2(&GreenSample,(double)pixel[2], (double)pixel[1], (double)pixel[0], (double)pixel[3]);
            break;
        case 3:
            printf("Extracting Sample for the colour blue!!!\n");
            insertNewBGR2(&BlueSample,(double)pixel[2], (double)pixel[1], (double)pixel[0], (double)pixel[3]);
            break;
        case 2:
            printf("Extracting Sample for the colour brown!!!\n");
            insertNewBGR2(&BrownSample,(double)pixel[2], (double)pixel[1], (double)pixel[0], (double)pixel[3]);
            break;
        case 4:
            printf("Extracting Sample for a Corner Marker!!!\n");
            insertNewBGR2(&CornerMarkers,(double)pixel[2], (double)pixel[1], (double)pixel[0], (double)pixel[3]);
            break;
        default:
            break;
    }
    
    return color;
}



- (void) handleSingleTapFrom: (UITapGestureRecognizer *)recognizer
{
    printf("I am single tapping...\n");
    
    CGPoint point =[singleTap locationInView:self.scrollView];
    
    UIColor * color = [self GetCurrentPixelColorAtPoint:point];
    self.InspectedColour.backgroundColor = color;
    Coloured = self.InspectedColour.image;
}

- (void) handleDoubleTapFrom: (UITapGestureRecognizer *) recognizer
{
    if (img != nil)
    {
        printf("Reseting to unthreshed image\n");
        [self updateScrollView:plainImage];
    }
}

#pragma mark - scroll view delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return img;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


- (void) updateScrollView:(UIImage *) newImg {
    //MAKE SURE THAT IMAGE VIEW IS REMOVED IF IT EXISTS ON SCROLLVIEW!!
    if (img != nil)
    {
        [img removeFromSuperview];
        
    }
    
    img = [[UIImageView alloc] initWithImage:newImg];
    
    //handle pinching in/ pinching out to zoom
    img.userInteractionEnabled = YES;
    img.backgroundColor = [UIColor clearColor];
    img.contentMode =  UIViewContentModeCenter;
    //img.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    //add a tap gesture recognizer for extracting colour
    singleTap = [[UITapGestureRecognizer alloc]
                 initWithTarget:self
                 action:@selector(handleSingleTapFrom:)];
    singleTap.numberOfTapsRequired = 1;
    [img addGestureRecognizer:singleTap];
    singleTap.delegate = self;
    
    
    //add a tap gesture recognizer for zooming in
    doubleTap = [[UITapGestureRecognizer alloc]
                 initWithTarget:self
                 action:@selector(handleDoubleTapFrom:)];
    doubleTap.numberOfTapsRequired = 2;
    [img addGestureRecognizer:doubleTap];
    doubleTap.delegate = self;
    //Fail to implement single tap if double tap is met
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    
    self.scrollView.minimumZoomScale=0.5;
    self.scrollView.maximumZoomScale=15.0;
    self.scrollView.contentSize = CGSizeMake(img.frame.size.width+100, img.frame.size.height+100);
    self.scrollView.clipsToBounds = YES;
    self.scrollView.delegate = self;
    //self.TouchableImage.contentSize=CGSizeMake(1280, 960);
    
    //Set image on the scrollview
    [self.scrollView addSubview:img];}


- (IBAction)threshold_image:(UIButton *)sender {
    if (plainImage == nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"No image to threshold!" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        return;
    }

    threshedImage = [CVWrapper thresh:plainImage colorCase: [CVWrapper getSegmentIndex]];
    
    [self updateScrollView:threshedImage];
}

- (IBAction)saveHSVValues:(UIButton *)sender {
    int values[30];
    [CVWrapper getHSV_Values:values];
    
    NSString *str = @"";
    
    int i;
    for(i = 0; i < 30; i++) {
        str = [str stringByAppendingFormat:@"%d ", values[i]];
    }
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"hsvValues"];
    fileName = [fileName stringByAppendingPathExtension:@"txt"];
    
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    
    [file writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
    
}

- (void) setHSVValues {
    int hsvValues[30];
    [CVWrapper getHSV_Values:hsvValues];
    
    NSError *error;
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"hsvValues"];
    fileName = [fileName stringByAppendingPathExtension:@"txt"];
    
    NSString* content = [NSString stringWithContentsOfFile:fileName
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    
    // if file reading creates an error, set values to default
    if(error) {
        NSLog(@"File reading error: default hsv values loaded");
        int hsvDefault[] = {10, 80, 50, 200, 50, 255, 80, 175, 140, 255, 100, 255, 90, 110, 40, 100, 120, 225, 0, 15, 30, 220, 50, 210, 15, 90, 35, 200, 35, 130};
        [CVWrapper setHSV_Values:hsvDefault];
        return;
    }
    
    NSArray *arr = [content componentsSeparatedByString:@" "];
    
    int i;
    for(i = 0; i < 30; i++) {
        // loss of precision is fine since all numbers stored in arr will have only zeroes after the decimal
        hsvValues[i] = [[arr objectAtIndex:i]integerValue];
    }
    
    [CVWrapper setHSV_Values:hsvValues];
}
- (IBAction)UndoTap:(UIButton *)sender {
    clickedSegment = [CVWrapper getSegmentIndex];
    
    switch (clickedSegment) {
        case 1:
            printf("Removing Last Red Sample!!!\n");
            RemoveBGR(&RedSample);
            break;
        case 0:
            printf("Removing Last Green Sample!!!\n");
            RemoveBGR(&GreenSample);
            break;
        case 3:
            printf("Removing Last Blue Sample!!!\n");
            RemoveBGR(&BlueSample);
            break;
        case 2:
            printf("Removing Last Brown Sample!!!\n");
            RemoveBGR(&BrownSample);
            break;
        case 4:
            printf("Removing Last Corner Marker Sample!!!\n");
            RemoveBGR(&CornerMarkers);
            break;
        default:
            break;
    }
}

- (IBAction)ClearSamples:(UIButton *)sender {
    clickedSegment = [CVWrapper getSegmentIndex];
    
    switch (clickedSegment)
    {
        case 1:
            deallocateList(&RedSample);
            break;
        case 0:
            deallocateList(&GreenSample);
            break;
        case 3:
            deallocateList(&BlueSample);
            break;
        case 2:
            deallocateList(&BrownSample);
            break;
        case 4:
            deallocateList(&CornerMarkers);
            break;
        default:
            break;
    }

}

- (IBAction)SendHSVVals:(UIButton *)sender {
    
    clickedSegment = [CVWrapper getSegmentIndex];
    int vals[30] = {0};
    [CVWrapper getHSV_Values:vals];
    
    switch (clickedSegment) {
        case 1:{
            if (RedSample == NULL)
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Samples of red pieces not found: Please pick some samples" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
                [alert show];
            }
            
            MinMaxHSV *Red = GetMinMaxHSVfromSample(RedSample);
            
            //Only if there exists values to sample
            if (Red != NULL){
                printf("Red  -> Obtained a min HSV value of: (%d, %d,%d)\nObtained a max HSV value of: (%d, %d,%d)\n\n", Red->low->h, Red->low->s, Red->low->v, Red->high->h, Red->high->s, Red->high->v);
                
                
                
                //send HSV values to double sliders
                [self changeValues:1 MinMaxHSV:Red];
                
                
                free(Red->low);
                free(Red->high);
                free(Red);
            }
            break;
        }
        case 0:
        {
            if (GreenSample == NULL)
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Samples of green pieces not found: Please pick some samples" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
                [alert show];
            }
            
            MinMaxHSV *Green = GetMinMaxHSVfromSample(GreenSample);
            
            if (Green != NULL)
            {
                printf("Green -> Obtained a min HSV value of: (%d, %d,%d)\nObtained a max HSV value of: (%d, %d,%d)\n\n", Green->low->h, Green->low->s, Green->low->v, Green->high->h, Green->high->s, Green->high->v);
                
                
                //send HSV values to double sliders
                [self changeValues:0 MinMaxHSV:Green];
                
                
                free(Green->low);
                free(Green->high);
                free(Green);
            }
            break;
        }
            
        case 3:
        {
            if (BlueSample == NULL)
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Samples of blue pieces not found: Please pick some samples" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
                [alert show];
            }
            
            MinMaxHSV *Blue = GetMinMaxHSVfromSample(BlueSample);
            
            if (Blue != NULL)
            {
                printf("Blue -> Obtained a min HSV value of: (%d, %d,%d)\nObtained a max HSV value of: (%d, %d,%d)\n\n", Blue->low->h, Blue->low->s, Blue->low->v, Blue->high->h, Blue->high->s, Blue->high->v);
                
                
                //send HSV values to double sliders
                [self changeValues:3 MinMaxHSV:Blue];
                
                
                free(Blue->low);
                free(Blue->high);
                free(Blue);
            }
            break;
        }
        case 2:
        {
            if (BrownSample == NULL)
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Samples of brown pieces not found: Please pick some samples" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
                [alert show];
            }
            
            MinMaxHSV *Brown = GetMinMaxHSVfromSample(BrownSample);
            
            if (Brown != NULL)
            {
                printf("Brown -> Obtained a min HSV value of: (%d, %d,%d)\nObtained a max HSV value of: (%d, %d,%d)\n\n", Brown->low->h, Brown->low->s, Brown->low->v, Brown->high->h, Brown->high->s, Brown->high->v);
                
                //send HSV values to double sliders
                [self changeValues:2 MinMaxHSV:Brown];
                
                free(Brown->low);
                free(Brown->high);
                free(Brown);
            }
            break;
        }
            
        case 4:
        {
            if (CornerMarkers == NULL){
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Samples for corner marker pieces not found: Please pick some samples" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
                [alert show];
            }
            
            MinMaxHSV *cornerMarker = GetMinMaxHSVfromSample(CornerMarkers);
            
            if (CornerMarkers != NULL)
            {
                printf("Corner Markers -> Obtained a min HSV value of: (%d, %d,%d)\nObtained a max HSV value of: (%d, %d,%d)\n\n", cornerMarker->low->h, cornerMarker->low->s, cornerMarker->low->v, cornerMarker->high->h, cornerMarker->high->s, cornerMarker->high->v);
                
                //send HSV values to double sliders
                [self changeValues:4 MinMaxHSV:cornerMarker];
                
                free(cornerMarker->low);
                free(cornerMarker->high);
                free(cornerMarker);
            }
            break;
        }
        default:
            break;
    }
    

}

- (void) changeValues:(int) caseNum MinMaxHSV: (MinMaxHSV*) MinMaxHSV {
    int vals[30] = {0};
    [CVWrapper getHSV_Values:vals];
    
    vals[caseNum * 6] = MinMaxHSV->low->h;
    vals[caseNum * 6 + 1] = MinMaxHSV->high->h;
    vals[caseNum * 6 + 2] = MinMaxHSV->low->s;
    vals[caseNum * 6 + 3] = MinMaxHSV->high->s;
    vals[caseNum * 6 + 4] = MinMaxHSV->low->v;
    vals[caseNum * 6 + 5] = MinMaxHSV->high->v;
    
    [CVWrapper setHSV_Values:vals];
}

@end

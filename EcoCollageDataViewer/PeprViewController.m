//
//  PeprTestFirstViewController.m
//  PeprTest
//
//  Created by Tia on 10/1/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import "PeprViewController.h"
#import "AprilTestTabBarController.h"
#import "AprilTestVariable.h"
#import <CoreBluetooth/CoreBluetooth.h>


@interface PeprViewController ()

@end

@implementation PeprViewController
@synthesize surveyType = _surveyType;
@synthesize cpVisible = _cpVisible;
@synthesize typeCP = _typeCP;
@synthesize pie = _pie;
@synthesize slices = _slices;
@synthesize sliceColors = _sliceColors;
@synthesize currentConcernRanking = _currentConcernRanking;




NSMutableDictionary * segConToVar;
NSMutableDictionary * labelNames;
UIPanGestureRecognizer *drag;
NSInteger lastExpQ = 0;
NSMutableArray *surveyItems;
NSMutableArray *likerts;
UILabel *activeTag;
UILabel *pointer;
UILabel *title;
NSString * variableDescriptions;
NSArray * importQuestions;




// called everytime tab is switched to this view
// necessary in case currentSession changes, i.e. is disconnected and reconnected again
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set up
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    _currentConcernRanking = tabControl.currentConcernRanking;
    
    
    // enable touch delivery
    drag = [[UIPanGestureRecognizer alloc] initWithTarget:self action: @selector(handleDrag:)];
    
    //load in the questions
    NSString* path = [[NSBundle mainBundle] pathForResource:@"questions2" ofType:@"txt"];
    NSString *importanceQuestions = [NSString stringWithContentsOfFile:path encoding: NSUTF8StringEncoding error:nil];
    importQuestions = [importanceQuestions componentsSeparatedByString:@"\n"];
    //NSLog(@"%@", importQuestions);
    //load in the descriptions of the variables
    NSString* pathD = [[NSBundle mainBundle] pathForResource:@"descriptions" ofType:@"txt"];
    variableDescriptions = [NSString stringWithContentsOfFile:pathD encoding: NSUTF8StringEncoding error: nil];
    _descriptionView.text = variableDescriptions;
    _descriptionView.editable = FALSE;
    
    //initialize number of slices in the pie chart based on the number of questions
    self.slices = [[NSMutableArray alloc] initWithCapacity:importQuestions.count];
    for(int i = 0; i < importQuestions.count; i++){
        //NSLog(@"i: %d, importQuestion: %@", i, [importQuestions objectAtIndex:i]);
        [self.slices addObject: [NSNumber numberWithInt:1]];
    }
    
    //initiates title label so the text can just be changed to match the explicit or implicit task
    title = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 10, 40)];
    [self.view addSubview:title];
    
    segConToVar = [[NSMutableDictionary alloc] init];
    labelNames = [[NSMutableDictionary alloc] init];
    likerts = [[NSMutableArray alloc] init];
    surveyItems = [[NSMutableArray alloc] init];
    
    self.sliceColors =[NSArray arrayWithObjects:
                       [UIColor colorWithHue:.3 saturation:.6 brightness:.9 alpha: 0.5],
                       [UIColor colorWithHue:.35 saturation:.8 brightness:.6 alpha: 0.5],
                       [UIColor colorWithHue:.4 saturation:.8 brightness:.3 alpha: 0.5],
                       [UIColor colorWithHue:.55 saturation:.8 brightness:.9 alpha: 0.5],
                       [UIColor colorWithHue:.65 saturation:.8 brightness:.6 alpha: 0.5],
                       [UIColor colorWithHue:.6 saturation:.8 brightness:.6 alpha: 0.5],
                       [UIColor colorWithHue:.6 saturation:.0 brightness:.3 alpha: 0.5],
                       [UIColor colorWithHue:.65 saturation:.0 brightness:.9 alpha: 0.5],
                       [UIColor colorWithHue:.7 saturation: 0.6 brightness:.3 alpha: 0.5],
                       [UIColor colorWithHue:.75 saturation: 0.6 brightness:.6 alpha: 0.5], nil];
    
    
    //initialize the pie chart
    
    [_pie setDataSource:self];
    [_pie setStartPieAngle:M_PI_2];
    [_pie setAnimationSpeed:1.0];
    [_pie setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
    [_pie setUserInteractionEnabled:NO];
    _pie.showLabel = false;
    [_pie setLabelShadowColor:[UIColor blackColor]];
    
    [self displayExplicitSurvey];
    [_pie reloadData];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendProfile)
                                                 name:@"sendProfile"
                                               object:nil];
}



/*
 
 - (void)sendProfile {
 
 //if(_currentSession) {
 NSData* data;
 NSString *str = [[NSString alloc] initWithFormat:@"%@|%@|%@|%@|%@|%@|%@|%@", [[surveyItems objectAtIndex:0]text], [[surveyItems objectAtIndex:1]text], [[surveyItems objectAtIndex:2]text], [[surveyItems objectAtIndex:3]text], [[surveyItems objectAtIndex:4]text], [[surveyItems objectAtIndex:5]text], [[surveyItems objectAtIndex:6]text], [[surveyItems objectAtIndex:7]text]];
 data = [str dataUsingEncoding: NSASCIIStringEncoding];
 //[self mySendDataToPeers:data];
 //}
 
 }
 
 */


// profile data setup by indexes of mutablearray
// 0 : type of data being sent (profileToMomma)
// 1 : username (defaults to devices name if no username selected)
// 2 - 9 : concerns in order of most important to least important

- (void)sendProfile {
    
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    if(tabControl.session) {
        NSMutableArray *profile = [[NSMutableArray alloc]init];
        // add type of data
        [profile addObject:@"profileToMomma"];
        // add devices name
        [profile addObject:[[UIDevice currentDevice]name]];
        for (int i = 0; i < 8; i++) {
            // add each surveyItem and remove /t
            [profile addObject:[[[surveyItems objectAtIndex:i]text] stringByReplacingOccurrencesOfString:@"\t" withString:@""]];
        }
        NSDictionary *profileToSendToMomma = [NSDictionary dictionaryWithObject:profile
                                                                         forKey:@"data"];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:profileToSendToMomma];
        [tabControl.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
    }
}




#pragma mark - Switch Methods




-(void) viewWillDisappear:(BOOL)animated{
    
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    tabControl.currentConcernRanking = _currentConcernRanking;
    //create time stamp
    NSDate *myDate = [[NSDate alloc] init];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    NSString *prettyVersion = [dateFormat stringFromDate:myDate];
    
    
    
    NSMutableString * content = [[NSMutableString alloc] init];
    NSString *test  = [NSString stringWithFormat:@"%@", _currentConcernRanking];
    [content appendFormat: @"%@\t", prettyVersion];
    [content appendString:test];
    [content appendString:@"\n\n"];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"logfile_survey.txt"];
    
    //create file if it doesn't exist
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileName])
        [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    [file seekToEndOfFile];
    [file writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
    
    //NSLog(@"%@", tabControl.currentConcernRanking);
    
    documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    fileName = [documentsDirectory stringByAppendingPathComponent:@"surveySave.txt"];
    
    //NSLog (@"%@", content);
    
    //delete file if it does exist -- then create it
    if([[NSFileManager defaultManager] fileExistsAtPath:fileName]){
        [[NSFileManager defaultManager] removeItemAtPath:fileName error: NULL];
        
    }
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    [file writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
    
    [super viewWillDisappear:animated];
}

- (void) displayExplicitSurvey {
    //set the title text to reflect the task
    [self.slices removeAllObjects];
    title.text = @"Sort the items based on how important they are to you";
    [title setFont: [UIFont boldSystemFontOfSize:17.0]];
    [title sizeToFit];
    
    //for each question, assign a label to match the color array.
    for (int i = 0; i < importQuestions.count; i++){
        if ([[[importQuestions objectAtIndex:i] componentsSeparatedByString:@"\t"] count] > 1){
            UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, ( 40) + (i * 40), 400, 40)];
            questionLabel.backgroundColor = [self.sliceColors objectAtIndex:i];
            questionLabel.text = [NSString stringWithFormat:@"\t%@", [[[importQuestions objectAtIndex:i] componentsSeparatedByString:@"\t"] objectAtIndex:0] ];
            [questionLabel setFont: [UIFont systemFontOfSize:14]];
            [questionLabel setUserInteractionEnabled:YES];
            [questionLabel setGestureRecognizers:[NSArray arrayWithObject: drag]];
            [_surveyView addSubview:questionLabel];
            [surveyItems addObject:questionLabel];
            [self.slices addObject: [NSNumber numberWithInt:(importQuestions.count-i)]];
            [labelNames setObject:[self.slices objectAtIndex:i] forKey:questionLabel.text];
        }
    }
    [_pie reloadData];
}


- (void) displayImplicitSurvey {
    title.text = @"How important are the following to you?";
    [title setFont: [UIFont boldSystemFontOfSize:17.0]];
    [title sizeToFit];
    int questionNumber = 0;
    for (int i = 0; i < importQuestions.count; i++){
        
        if ([[[importQuestions objectAtIndex:i] componentsSeparatedByString:@"\t"] count] > 1){
            
            UILabel *background = [[UILabel alloc] initWithFrame:CGRectMake(10, 40 + (i * 60), 460, 60)];
            background.backgroundColor = [self.sliceColors objectAtIndex:i];
            [_surveyView addSubview:background];
            [surveyItems addObject:background];
            UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35 + (i * 60), 400, 30)];
            questionLabel.text = [NSString stringWithFormat:@"\t%@", [[[importQuestions objectAtIndex:i] componentsSeparatedByString:@"\t"] objectAtIndex:0] ];
            [questionLabel setFont: [UIFont systemFontOfSize:14]];
            [_surveyView addSubview:questionLabel];
            [surveyItems addObject:questionLabel];
            
            UISegmentedControl *controlForQuestion = [[UISegmentedControl alloc]initWithItems: [[NSArray alloc] initWithObjects: @"Don't Know", @"Not At All", @"Somewhat", @"Moderately", @"Very", nil]];
            UIFont *font = [UIFont systemFontOfSize:12.0f];
            NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                                   forKey:NSFontAttributeName];
            [controlForQuestion setTitleTextAttributes:attributes
                                              forState:UIControlStateNormal];
            [controlForQuestion addTarget:self action:@selector(likertChanged:) forControlEvents:UIControlEventValueChanged];
            [controlForQuestion setSelected: false];
            [controlForQuestion setFrame: CGRectMake(10, 65 + (i * 60), 450, 28)];
            [controlForQuestion setTintColor:[UIColor blackColor]];
            UIColor *invisibleVersion = [self.sliceColors objectAtIndex:i];
            invisibleVersion = [invisibleVersion colorWithAlphaComponent:0.0];
            [controlForQuestion setBackgroundColor:invisibleVersion];
            
            [_surveyView addSubview:controlForQuestion];
            [surveyItems addObject:controlForQuestion];
            [likerts addObject:controlForQuestion];
            NSString *keyValue = [[[importQuestions objectAtIndex:i] componentsSeparatedByString:@"\t"] objectAtIndex:1];
            [segConToVar setValue:controlForQuestion forKey:keyValue];
            questionNumber++;
            [self.slices addObject: [NSNumber numberWithInt:(importQuestions.count-i)]];
        }
    }
    [_pie reloadData];
    
}

- (void) displayKey {
    title.text = @"Key                                                           Ranking";
    [title setFont: [UIFont boldSystemFontOfSize:17.0]];
    [title sizeToFit];
    UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 380, 250, 20)];
    subTitle.text = @"More important items are represented with larger slices on the pie chart";
    subTitle.font = [UIFont systemFontOfSize:12];
    [subTitle sizeToFit];
    [_surveyView addSubview:subTitle];
    [surveyItems addObject:subTitle];
    for (int i = 0; i < importQuestions.count; i++){
        if ([[[importQuestions objectAtIndex:i] componentsSeparatedByString:@"\t"] count] > 1){
            UILabel *keyColor = [[UILabel alloc] initWithFrame:CGRectMake(35, 50 + (i*40), 20, 20)];
            keyColor.backgroundColor = [self.sliceColors objectAtIndex:i];
            UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, ( 40) + (i * 40), 250, 38)];
            questionLabel.text = [NSString stringWithFormat:@"\t%@", [[[importQuestions objectAtIndex:i] componentsSeparatedByString:@"\t"] objectAtIndex:0] ];
            [questionLabel setFont: [UIFont systemFontOfSize:14]];
            UILabel *rankingLabel = [[UILabel alloc] initWithFrame:CGRectMake(310, 40 + i *40, 40, 40)];
            AprilTestVariable *currentVar = (AprilTestVariable *)[_currentConcernRanking objectAtIndex:i];
            NSString *rankText = [[NSString alloc] initWithFormat:@"%d", 9-currentVar.currentConcernRanking ];
            rankingLabel.text =rankText;
            [rankingLabel setFont:[UIFont systemFontOfSize:14]];
            [_surveyView addSubview:keyColor];
            [_surveyView addSubview:questionLabel];
            [_surveyView addSubview:rankingLabel];
            [surveyItems addObject:questionLabel];
            [surveyItems addObject:keyColor];
            [surveyItems addObject:rankingLabel];
            
        }
    }
    
    
    
}

- (IBAction)likertChanged:(id)sender {
    
    likerts = [[likerts sortedArrayUsingComparator:^NSComparisonResult(UISegmentedControl *label1, UISegmentedControl *label2) {
        if (label1.selectedSegmentIndex > label2.selectedSegmentIndex) return NSOrderedAscending;
        else if (label1.selectedSegmentIndex < label2.selectedSegmentIndex) return NSOrderedDescending;
        else return NSOrderedSame;
    }] mutableCopy];
    
    for(int i=0; i < likerts.count; i++){
        UIColor * visibleBackground = [[likerts objectAtIndex:i] backgroundColor];
        visibleBackground = [visibleBackground colorWithAlphaComponent:0.5];
        int sliceIndex = [_sliceColors indexOfObject: visibleBackground ];
        [_slices replaceObjectAtIndex:sliceIndex withObject:[NSNumber numberWithInt:(importQuestions.count-i)]];
        NSString *varName = [[segConToVar allKeysForObject:[likerts objectAtIndex:i]] objectAtIndex:0];
        for(int j=0; j< _currentConcernRanking.count; j++){
            AprilTestVariable *var = [_currentConcernRanking objectAtIndex:j];
            //NSLog(@"%@, %@", varName, var.name);
            if([varName rangeOfString:var.name options:NSCaseInsensitiveSearch].location != NSNotFound){
                [var updateCurrentRanking:8-i];
                break;
            }
        }
    }
    [_pie reloadData];
    
}
- (IBAction)surveyTypeChanged:(id)sender {
    
    if(_cpVisible.on){
        for( UILabel *item in surveyItems){
            [item removeFromSuperview];
        }
        [surveyItems removeAllObjects];
        [_slices removeAllObjects];
        if(_surveyType.on){
            [self displayExplicitSurvey];
        } else {
            [likerts removeAllObjects];
            [self displayImplicitSurvey];
            
        }
    }
    [title setNeedsDisplay];
    
}

-(IBAction) changeCPDisplay: (id) sender{
    
    if(_cpVisible.on){
        if(_typeCP.selectedSegmentIndex == 0) {
            //update pie chart visualization
            
            
        } else if (_typeCP.selectedSegmentIndex == 1){
            //update stacked graph visualization
            
        } else if (_typeCP.selectedSegmentIndex == 2){
            //update wordle visualization
            
            
        }
    }
}
- (IBAction)removeVisible:(id)sender {
    title.text = @" ";
    [title setNeedsDisplay];
    for( UILabel *item in surveyItems){
        [item removeFromSuperview];
    }
    if(_cpVisible.on){
        if(_surveyType.on){
            [self displayExplicitSurvey];
        } else {
            [likerts removeAllObjects];
            [self displayImplicitSurvey];
            
        }
        
    } else {
        [self displayKey];
    }
    
}

-(void) handleDrag: (UIPanGestureRecognizer *)sender{
    //NSLog(@"drag detected at: %@, state: %d", NSStringFromCGPoint([sender locationInView:_surveyView]), [sender state]);
    bool activeTagSelected = FALSE;
    surveyItems = [[surveyItems sortedArrayUsingComparator:^NSComparisonResult(id label1, id label2) {
        if ([label1 frame].origin.y < [label2 frame].origin.y) return NSOrderedAscending;
        else if ([label1 frame].origin.y > [label2 frame].origin.y) return NSOrderedDescending;
        else return NSOrderedSame;
    }] mutableCopy];
    if ([sender state] == UIGestureRecognizerStateBegan){
        for(UILabel *label in surveyItems){
            if( CGRectContainsPoint([label frame], [sender locationInView:_surveyView]) && activeTagSelected == FALSE){
                //NSLog(@"selected a label: %@", label);
                activeTag = label;
                //[_surveyView addSubview:activeTag];
                [sender setTranslation:CGPointZero inView:self.view];
                activeTagSelected = TRUE;
            } else if (activeTagSelected){
                label.center = CGPointMake(label.center.x, label.center.y - 40);
            }
            
        }
    } else if ([sender state] == UIGestureRecognizerStateChanged){
        //user still has label and is adjusting its positions
        
        CGPoint translation = [sender translationInView:self.view];
        if(activeTag != NULL) activeTag.center = CGPointMake(activeTag.center.x, activeTag.center.y + translation.y);
        [sender setTranslation:CGPointZero inView:self.view];
    } else if([sender state] == UIGestureRecognizerStateEnded){
        
        //user has dropped the label
        CGPoint translation = [sender translationInView:self.view];
        activeTag.center = CGPointMake(activeTag.center.x, activeTag.center.y + translation.y);
        CGRect activeFrame = CGRectMake(activeTag.frame.origin.x, activeTag.frame.origin.y, activeTag.frame.size.width, activeTag.frame.size.height);
        CGPoint activeCenter = CGPointMake(activeTag.center.x, activeTag.center.y);
        CGPoint lastCenter = CGPointMake(10+activeTag.frame.size.width/2, 40 + activeTag.frame.size.height/2);
        
        bool activeTagPlaced = FALSE;
        //for(UILabel *label in surveyItems){
        for(int i =0; i < surveyItems.count; i++){
            UILabel *label = [surveyItems objectAtIndex:i];
            
            //if the currently moving tag is situated
            if(label.center.y < activeTag.center.y && CGRectIntersectsRect(label.frame, activeFrame)){
                if(!activeTagPlaced){
                    //user has placed the moving label somewhere in the middle of the list -- shifts the tag it is half-over to it's current position, leaves current label in its place
                    activeTag.center = CGPointMake(lastCenter.x,  (i+1) * 40 + 60);
                    label.center = CGPointMake(label.center.x, (i+1) *40 +20);
                    activeTagPlaced = true;
                }
            } else if (label.center.y >= activeTag.center.y && CGRectIntersectsRect(label.frame, activeFrame) && !activeTagPlaced){
                //user has placed the moving label above the existing list, making it the new top
                activeTag.center = CGPointMake(lastCenter.x, (i+1) *40 + 20);
                activeTagPlaced = true;
            } else if (label.center.y >= activeCenter.y){
                //all labels after the swapped positions
                label.center = CGPointMake(label.center.x, (i + 1) * 40 + 20);
            }
        }
        
        activeTag = NULL;
        surveyItems = [[surveyItems sortedArrayUsingComparator:^NSComparisonResult(id label1, id label2) {
            if ([label1 frame].origin.y < [label2 frame].origin.y) return NSOrderedAscending;
            else if ([label1 frame].origin.y > [label2 frame].origin.y) return NSOrderedDescending;
            else return NSOrderedSame;
        }] mutableCopy];
        for(int i=0; i < surveyItems.count; i++){
            int sliceIndex = [_sliceColors indexOfObject: [(UILabel *)[surveyItems objectAtIndex:i] backgroundColor] ];
            [_slices replaceObjectAtIndex:sliceIndex withObject:[NSNumber numberWithInt:(importQuestions.count-i)]];
            for(int j=0; j < _currentConcernRanking.count; j++){
                AprilTestVariable *var = [_currentConcernRanking objectAtIndex:j];
                //NSLog(@"%@, %@", [[surveyItems objectAtIndex:i] text], var.displayName);
                if([[(UILabel *)[surveyItems objectAtIndex:i] text] rangeOfString:var.displayName options:NSCaseInsensitiveSearch].location != NSNotFound){
                    [var updateCurrentRanking:7-i];
                    break;
                }
                
            }
        }
        
        /*
         for(int i = 0; i < surveyItems.count; i++) {
         NSLog(@"%@", [[surveyItems objectAtIndex:i] text]);
         }
         */
        
        [_pie reloadData];
        [self sendProfile];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return importQuestions.count;
}

- (CGFloat) pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    return [[self.slices objectAtIndex:index] intValue];
}
- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    return [self.sliceColors objectAtIndex:(index % self.sliceColors.count)];
}



@end

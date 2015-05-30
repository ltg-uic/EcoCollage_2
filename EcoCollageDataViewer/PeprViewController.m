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


@interface PeprViewController () <CBPeripheralManagerDelegate, UITextViewDelegate>
@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@property (strong, nonatomic) NSData                    *dataToSend;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;

@end

@implementation PeprViewController
@synthesize surveyType = _surveyType;
@synthesize cpVisible = _cpVisible;
@synthesize typeCP = _typeCP;
@synthesize pie = _pie;
@synthesize slices = _slices;
@synthesize sliceColors = _sliceColors;
@synthesize currentConcernRanking = _currentConcernRanking;

#define TRANSFER_SERVICE_UUID           @"E20A39F4-73F5-4BC4-A12F-17D1AD07A961"
#define TRANSFER_CHARACTERISTIC_UUID    @"08590F7E-DB05-467E-8757-72F6FAEB13D4"
#define NOTIFY_MTU      20


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
    
    // Start up the CBPeripheralManager
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];

}

#pragma mark - Peripheral Methods



/** Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    // We're in CBPeripheralManagerStatePoweredOn state...
    NSLog(@"self.peripheralManager powered on.");
    
    // ... so build our service.
    
    // Start with the CBMutableCharacteristic
    self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]
                                                                     properties:CBCharacteristicPropertyNotify
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsReadable];
    
    // Then the service
    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                                                       primary:YES];
    
    // Add the characteristic to the service
    transferService.characteristics = @[self.transferCharacteristic];
    
    // And add it to the peripheral manager
    [self.peripheralManager addService:transferService];
}


/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic");

    
    NSString *package = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@|%@", [[surveyItems objectAtIndex:0]text], [[surveyItems objectAtIndex:1]text], [[surveyItems objectAtIndex:2]text], [[surveyItems objectAtIndex:3]text], [[surveyItems objectAtIndex:4]text], [[surveyItems objectAtIndex:5]text], [[surveyItems objectAtIndex:6]text], [[surveyItems objectAtIndex:7]text]];
    NSData *data = [package dataUsingEncoding:NSASCIIStringEncoding];
    assert(data); // this is critical don't remove!
    
    NSLog(@"Package:\n%@", package);
    
    
    // Get the data
    //self.dataToSend = [self.textView.text dataUsingEncoding:NSUTF8StringEncoding];
    self.dataToSend = data;
    
    
    // Reset the index
    self.sendDataIndex = 0;
    
    // Start sending
    [self sendData];
    
    [self.peripheralManager stopAdvertising];
}


/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
}


/** Sends the next amount of data to the connected central
 */
- (void)sendData
{
    // First up, check if we're meant to be sending an EOM
    static BOOL sendingEOM = NO;
    
    if (sendingEOM) {
        
        // send it
        BOOL didSend = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // Did it send?
        if (didSend) {
            
            // It did, so mark it as sent
            sendingEOM = NO;
            
            NSLog(@"Sent: EOM");
        }
        
        // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
        return;
    }
    
    // We're not sending an EOM, so we're sending data
    
    // Is there any left to send?
    
    if (self.sendDataIndex >= self.dataToSend.length) {
        
        // No data left.  Do nothing
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    
    BOOL didSend = YES;
    
    while (didSend) {
        
        // Make the next chunk
        
        // Work out how big it should be
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
        
        // Send it
        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // If it didn't work, drop out and wait for the callback
        if (!didSend) {
            return;
        }
        
        NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
        NSLog(@"Sent: %@", stringFromData);
        
        // It did send, so update our index
        self.sendDataIndex += amountToSend;
        
        // Was it the last one?
        if (self.sendDataIndex >= self.dataToSend.length) {
            
            // It was - send an EOM
            
            // Set this so if the send fails, we'll send it next time
            sendingEOM = YES;
            
            // Send it
            BOOL eomSent = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
            
            if (eomSent) {
                // It sent, we're all done
                sendingEOM = NO;
                
                NSLog(@"Sent: EOM");
            }
            
            return;
        }
    }
}


/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    // Start sending again
    [self sendData];
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
        
        // All we advertise is our service's UUID
        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
        [_pie reloadData];
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

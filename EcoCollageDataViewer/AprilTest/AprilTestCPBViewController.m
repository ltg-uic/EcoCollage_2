//
//  AprilTestCPBViewController.m
//  AprilTest
//
//  Created by Tia on 4/7/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import "AprilTestCPBViewController.h"
#import "AprilTestTabBarController.h"
#import "AprilTestVariable.h"

@interface AprilTestCPBViewController ()

@end

@implementation AprilTestCPBViewController
@synthesize currentConcernRanking = _currentConcernRanking;
int currentQuestion = 1;
UITextView * scenarioIntro;
UITextView * scenarioA;
UITextView * scenarioB;
UITextView * scenarioC;
NSMutableArray * variablesOfInterest;
NSMutableArray * aprilTestVariables;
NSMutableArray * labels;
NSMutableArray * checkboxes;
NSMutableArray * modelView;
NSString * url;


- (void)viewDidLoad
{

    [super viewDidLoad];
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    _currentConcernRanking = tabControl.currentConcernRanking;
    url = tabControl.url;
    checkboxes = [[NSMutableArray alloc] init];
    modelView = [[NSMutableArray alloc] init];
    
    //UITextView for supporting the text from the intro
    scenarioIntro = [[UITextView alloc] initWithFrame:CGRectMake(20, 40, 650, 80)];
    scenarioIntro.scrollEnabled = FALSE;
    scenarioIntro.editable = FALSE;
    scenarioIntro.backgroundColor = [UIColor clearColor];
    [scenarioIntro setFont: [UIFont systemFontOfSize:15.0]];
    [self.view addSubview:scenarioIntro];
    
    scenarioA = [[UITextView alloc] initWithFrame:CGRectMake(20, 120, 650, 80)];
    scenarioA.scrollEnabled = FALSE;
    scenarioA.editable = FALSE;
    scenarioA.backgroundColor = [UIColor clearColor];
    [scenarioA setFont: [UIFont systemFontOfSize:15.0]];
    [self.view addSubview:scenarioA];
    
    scenarioB = [[UITextView alloc] initWithFrame:CGRectMake(20, 200, 650, 80)];
    scenarioB.scrollEnabled = FALSE;
    scenarioB.editable = FALSE;
    scenarioB.backgroundColor = [UIColor clearColor];
    [scenarioB setFont: [UIFont systemFontOfSize:15.0]];
    [self.view addSubview:scenarioB];
    
    scenarioC = [[UITextView alloc] initWithFrame:CGRectMake(20, 280, 650, 120)];
    scenarioC.scrollEnabled = FALSE;
    scenarioC.editable = FALSE;
    scenarioC.backgroundColor = [UIColor clearColor];
    [scenarioC setFont: [UIFont systemFontOfSize:15.0]];
    [self.view addSubview:scenarioC];
    
    
    [self loadNewQuestion: currentQuestion];
    [self updateModelView];
}

-(void) viewWillDisappear:(BOOL)animated{
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    tabControl.currentConcernRanking = _currentConcernRanking;
    NSString *content = [_currentConcernRanking description];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"logfile_Model.txt"];
    
    //create file if it doesn't exist
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileName])
        [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    
    //append text to file (you'll probably want to add a newline every write)
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    [file seekToEndOfFile];
    [file writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadNewQuestion: (int) qNum{
    for(int i=0; i <labels.count; i++){
        [[labels objectAtIndex:i] removeFromSuperview];
        [[checkboxes objectAtIndex:i] removeFromSuperview];
    }
    [labels removeAllObjects];
    [variablesOfInterest removeAllObjects];
    [checkboxes removeAllObjects];
    //url = @"http://127.0.0.1";
    //url = @"192.168.2.12";
    url=@"http://192.168.1.42";
    NSString * urlPlusFile = [NSString stringWithFormat:@"%@/%@", url, @"test2.php"];
    
    NSString *myRequestString = [[NSString alloc] initWithFormat:@"qNum=%d", qNum ];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString: urlPlusFile ] ];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    //NSLog(@"%@", request);
    NSString *content;
    while( !content){
        NSURLResponse *response;
        NSError *err;
        NSData *returnData = [ NSURLConnection sendSynchronousRequest: request returningResponse:&response error:&err];
        //NSLog(@"error: %@", err);
        
        if( [returnData bytes]) content = [NSString stringWithUTF8String:[returnData bytes]];
        //NSLog(@"responseData: %@", content);
    }
    if(content.length > 100 ){
    NSMutableArray *scenariosAndVariables = [[content componentsSeparatedByString:@"\n"] mutableCopy];
    scenarioIntro.text=[scenariosAndVariables objectAtIndex:0];
    scenarioA.text = [scenariosAndVariables objectAtIndex:1];
    scenarioB.text = [scenariosAndVariables objectAtIndex:2];
    scenarioC.text = [scenariosAndVariables objectAtIndex:3];
    variablesOfInterest = [[[scenariosAndVariables objectAtIndex:4] componentsSeparatedByString:@"\t"] mutableCopy];
    aprilTestVariables = [[[scenariosAndVariables objectAtIndex:5] componentsSeparatedByString:@"\t"] mutableCopy];
    //NSLog(@"%@", variablesOfInterest);
    for(int i = 0; i < variablesOfInterest.count; i++){
        UILabel *temp = [[UILabel alloc] init];
        temp.text= [variablesOfInterest objectAtIndex:i];
        temp.center = CGPointMake(40, 460 + i *31 );
        [labels addObject:temp];
        [temp setFont:[UIFont systemFontOfSize:14.0]];
        [temp sizeToFit];
        [self.view addSubview:temp];
//        UIButton *checkbox = [UIButton buttonWithType:0];
//        checkbox.frame = CGRectMake(630, 455 + i *25, 25, 25);
//        [checkbox setImage:[UIImage imageNamed:@"onCheckbox.png"] forState:UIControlStateSelected];
//        [checkbox addTarget:self action:@selector(setButtonHighlight:) forControlEvents:UIControlEventTouchUpInside];
//        [checkbox setImage:[UIImage imageNamed:@"offCheckBox.png"] forState:UIControlStateNormal];
//        checkbox.selected = FALSE;
        UISwitch *checkbox = [[UISwitch alloc] initWithFrame:CGRectMake(600, 455+ i* 31, 60, 25)];
        [checkbox setOn:FALSE];
        [checkbox addTarget:self action:@selector(setButtonHighlight:) forControlEvents:UIControlEventTouchUpInside];
        [checkbox setOnTintColor:[UIColor colorWithRed:0.0 green:.48 blue:1.0 alpha:1.0]];
        //[checkbox setTintColor:[UIColor colorWithRed:0.0 green:.48 blue:1.0 alpha:1.0]];
        [self.view addSubview:checkbox];
        [checkboxes addObject:checkbox];
        //NSLog(@"%@", temp);
    }
    [self updateModelView];
    }
}

- (IBAction)setButtonHighlight:(id)sender {
    UISwitch *button = sender;

    NSUInteger variableAffected = [checkboxes indexOfObject:button];
    //NSLog(@"%d", variableAffected);
    NSString *testVariable =  [aprilTestVariables objectAtIndex:variableAffected];
    AprilTestVariable * var;
    for(int i=0; i < _currentConcernRanking.count; i++){
        var = [_currentConcernRanking objectAtIndex:i];
        NSString * forComp = var.name;
        if ([forComp isEqualToString:testVariable]){
            break;
        }
        var = NULL;
    }
    if(button.isOn){
        var.currentConcernRanking++;
    } else {
        var.currentConcernRanking--;
        //decrement related variable
    }
    //NSLog(@"%@", _currentConcernRanking);
    //button.selected = !button.selected;
    [self updateModelView];
}

- (void) updateModelView{
    for(int i=0; i <modelView.count; i++){
       // NSLog(@"Removing object: %@", [modelView objectAtIndex:i]);
        [[modelView objectAtIndex:i] removeFromSuperview];
    }
    [modelView removeAllObjects];
    
    NSArray * sortedCopy = [_currentConcernRanking sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSInteger first = [(AprilTestVariable*)a currentConcernRanking];
        NSInteger second = [(AprilTestVariable*)b currentConcernRanking];
        if(first < second) return NSOrderedAscending;
        else return NSOrderedDescending;
    }];
    //print top 5 highest ranked items
    int j= 0;
    for ( NSInteger i = sortedCopy.count -1; i > sortedCopy.count - 6; i--){
        UILabel * newModelLabel = [[UILabel alloc] init];
        newModelLabel.text= [NSString stringWithFormat: @"%@ : %d", [(AprilTestVariable*)[sortedCopy objectAtIndex:i] displayName], [(AprilTestVariable*)[sortedCopy objectAtIndex:i] currentConcernRanking]];
        newModelLabel.center = CGPointMake(700, 80 + j * 20 );
        [newModelLabel setFont:[UIFont systemFontOfSize:14.0]];
        [newModelLabel sizeToFit];
        //NSLog(@"%@", newModelLabel);
        [modelView addObject: newModelLabel];
        [self.view addSubview: newModelLabel];
        j++;
    }
}

@end

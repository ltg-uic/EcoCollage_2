//
//  AprilTestFirstViewController.m
//  AprilTest
//
//  Created by Tia on 4/7/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import "AprilTestFirstViewController.h"
#import "AprilTestTabBarController.h"
#import "AprilTestVariable.h"

@interface AprilTestFirstViewController ()

@end

@implementation AprilTestFirstViewController

NSMutableDictionary * segConToVar;

- (void)viewDidLoad
{
    [super viewDidLoad];
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    _currentConcernRanking = tabControl.currentConcernRanking;
    segConToVar = [[NSMutableDictionary alloc] init];

//load in and set up experiential questions
    NSString* path = [[NSBundle mainBundle] pathForResource:@"questions1"
                                                     ofType:@"txt"];
    NSString *experienceQuestions = [NSString stringWithContentsOfFile:path encoding: NSUTF8StringEncoding error:nil];
    UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 15, 0, 30)];
    questionLabel.text = @"How many times have you you experienced the following in your home or business?";
    [questionLabel setFont: [UIFont boldSystemFontOfSize:17.0]];
    [questionLabel sizeToFit];
    [_surveyView addSubview:questionLabel];
    NSArray * expQuestions = [experienceQuestions componentsSeparatedByString:@"\n"];
    for (int i = 0; i < expQuestions.count; i++){
        if( i % 2 == 1){
            UILabel *discriminatoryAssist = [[UILabel alloc]initWithFrame:CGRectMake( 0, 34 + (i*30), _surveyView.frame.size.width, 30 )];
            discriminatoryAssist.backgroundColor = [UIColor colorWithRed:.7 green:.9 blue:.9 alpha:.3];
            [_surveyView addSubview: discriminatoryAssist];
        }
        UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40 + (i * 30), 0, 30)];
        questionLabel.text = [[[expQuestions objectAtIndex:i] componentsSeparatedByString:@"\t"] objectAtIndex:0];
        [questionLabel setFont: [UIFont systemFontOfSize:14]];
        [questionLabel sizeToFit];
        [_surveyView addSubview:questionLabel];

        UISegmentedControl *controlForQuestion = [[UISegmentedControl alloc]initWithItems: [[NSArray alloc] initWithObjects: @"Never", @"Once", @"2-5 times", @"5-10 times", @"10+ times", nil]];
        [controlForQuestion addTarget:self action:@selector(likertChanged:) forControlEvents:UIControlEventTouchUpInside];
        [controlForQuestion setSelected: false];
        [controlForQuestion setFrame: CGRectMake(670, 35 + (i * 30), 350, 28)];

        [_surveyView addSubview:controlForQuestion];
        NSString *keyValue = [[[expQuestions objectAtIndex:i] componentsSeparatedByString:@"\t"] objectAtIndex:1];
        [segConToVar setValue:controlForQuestion forKey:keyValue];
    }
    
    NSInteger lastExpQ = 50 + (expQuestions.count * 30);
    //load in and set up experiential questions
    path = [[NSBundle mainBundle] pathForResource:@"questions2"
                                                     ofType:@"txt"];
    NSString *importanceQuestions = [NSString stringWithContentsOfFile:path encoding: NSUTF8StringEncoding error:nil];
    UILabel *importLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, lastExpQ, 0, 30)];
    importLabel.text = @"How important are the following to you?";
    [importLabel setFont: [UIFont boldSystemFontOfSize:17.0]];
    [importLabel sizeToFit];
    [_surveyView addSubview:importLabel];
    lastExpQ += 25;
    NSArray * importQuestions = [importanceQuestions componentsSeparatedByString:@"\n"];
    int questionNumber = 0;
    for (int i = 0; i < importQuestions.count; i++){
        if ([[[importQuestions objectAtIndex:i] componentsSeparatedByString:@"\t"] count] > 1){
            if( questionNumber % 2 == 1){
                UILabel *discriminatoryAssist = [[UILabel alloc]initWithFrame:CGRectMake( 0, (lastExpQ - 6) + (i*30), _surveyView.frame.size.width, 30 )];
                discriminatoryAssist.backgroundColor = [UIColor colorWithRed:.7 green:.9 blue:.9 alpha:.3];
                [_surveyView addSubview: discriminatoryAssist];
            }
        UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, lastExpQ + (i * 30), 0, 30)];
        questionLabel.text = [[[importQuestions objectAtIndex:i] componentsSeparatedByString:@"\t"] objectAtIndex:0];
        [questionLabel setFont: [UIFont systemFontOfSize:14]];
        [questionLabel sizeToFit];
        [_surveyView addSubview:questionLabel];
        
        UISegmentedControl *controlForQuestion = [[UISegmentedControl alloc]initWithItems: [[NSArray alloc] initWithObjects: @"Don't Know", @"Not At All", @"Somewhat", @"Moderately", @"Very", nil]];
        UIFont *font = [UIFont systemFontOfSize:12.0f];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                               forKey:NSFontAttributeName];
        [controlForQuestion setTitleTextAttributes:attributes
                                        forState:UIControlStateNormal];
        [controlForQuestion addTarget:self action:@selector(likertChanged:) forControlEvents:UIControlEventValueChanged];
        [controlForQuestion setSelected: false];
        [controlForQuestion setFrame: CGRectMake(670, lastExpQ - 5 + (i * 30), 350, 28)];
        
        [_surveyView addSubview:controlForQuestion];
        NSString *keyValue = [[[importQuestions objectAtIndex:i] componentsSeparatedByString:@"\t"] objectAtIndex:1];
        [segConToVar setValue:controlForQuestion forKey:keyValue];
            questionNumber++;
        } else {
            UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, lastExpQ + (i * 30)+5, 0, 30)];
            questionLabel.text = [[[importQuestions objectAtIndex:i] componentsSeparatedByString:@"\t"] objectAtIndex:0];
            [questionLabel setFont: [UIFont boldSystemFontOfSize:15.5]];
            [questionLabel sizeToFit];
            [_surveyView addSubview:questionLabel];
        }
    }
    
    [_surveyView setContentSize:CGSizeMake(_surveyView.contentSize.width, lastExpQ + 20 + (30 * importQuestions.count))];
}

-(void) viewWillDisappear:(BOOL)animated{
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    tabControl.currentConcernRanking = _currentConcernRanking;
    //Get the file path
    NSMutableString * content = [[NSMutableString alloc] init];
    
    for (NSString * key in segConToVar){
        //NSLog(@"%@", key);
        UISegmentedControl *sc = [segConToVar objectForKey:key];
        NSInteger selected = sc.selectedSegmentIndex;
        NSString *test  = [NSString stringWithFormat:@"%@, %ld \n", key, (long)selected];
        //NSLog(@"%@", test);
        [content appendString:test];
        }
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)likertChanged:(id)sender {
    NSString * variableAffected = [[segConToVar allKeysForObject:sender] objectAtIndex:0];
    NSArray * test = [variableAffected  componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    variableAffected = [test objectAtIndex:0];
    int index = 0;
    NSArray * checkIfUsing = [variableAffected componentsSeparatedByString:@"_"];
    if(checkIfUsing.count == 1){
    if( test.count > 1) index = [[test objectAtIndex:1] intValue];
    
    AprilTestVariable *var;
    for(int i=0; i < _currentConcernRanking.count; i++){
        var = [_currentConcernRanking objectAtIndex:i];
        NSString * forComp = var.name;
        if ([forComp isEqualToString:variableAffected]){
            break;
        }
        var = NULL;
    }
    NSInteger selected = [(UISegmentedControl *) sender selectedSegmentIndex] + 1;
    
    [var updateBaseLikert: (int) selected withIndex: index];
    }
}

- (IBAction)loadAnswers:(id)sender {
    //NSLog(@"Button pressed");
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"surveySave.txt"];

    //NSLog(@"%@", path);
    NSString *experienceQuestions = [NSString stringWithContentsOfFile:path encoding: NSUTF8StringEncoding error:nil];
    //NSLog(@"%@", experienceQuestions);
    if (experienceQuestions.length > 0){
        
        NSArray * expQuestions = [experienceQuestions componentsSeparatedByString:@"\n"];
        for (int i = 0; i < expQuestions.count; i++){
            if([[[expQuestions objectAtIndex:i] componentsSeparatedByString:@","] count ] > 1){
            NSString * key = [[[expQuestions objectAtIndex:i] componentsSeparatedByString:@","] objectAtIndex:0];
            UISegmentedControl * sc = [segConToVar objectForKey: key];
            sc.selectedSegmentIndex = [[[[[expQuestions objectAtIndex:i] componentsSeparatedByString:@","] objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ] intValue ];
            }
        }
    }
    
}

- (IBAction)resetSegment:(id)sender {
    for ( NSString * key in segConToVar ){
        UISegmentedControl *sc =[segConToVar objectForKey: key];
        [sc setSelectedSegmentIndex: UISegmentedControlNoSegment];
    }
}

@end

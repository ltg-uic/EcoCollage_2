//
//  ViewController.m
//  mysqlWriteTest
//
//  Created by Tia on 3/12/15.
//  Copyright (c) 2015 Tia. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

NSString *fileContents;
NSURL *server;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"Results" ofType:@"txt"];
    NSError *error;
    
    //this is the url you need to set to the output of the program
    fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];

    server = [NSURL URLWithString:@"http://131.193.79.217"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendData:(id)sender {
    int studyID = 0;
    int trialID = 0;
    
    NSString *escapedFileContents = [fileContents stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSLog(@"%@", escapedFileContents);

    NSString *content;
    while (!content){
        NSString *stringText = [NSString stringWithFormat:@"mapInput.php?studyID=%d&trialID=%d&map=%@", studyID, trialID, escapedFileContents];
        content = [NSString stringWithContentsOfURL:[NSURL URLWithString: stringText relativeToURL:server] encoding:NSUTF8StringEncoding error:nil];
    }
    NSLog(@"%@", content);
}

@end

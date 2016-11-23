//
//  dropDownTest.h
//  Trial_1
//
//  Created by Jamie Auza on 6/22/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface dropDownTest : UIViewController <UITableViewDataSource, UITableViewDelegate>;

@property (weak, nonatomic) IBOutlet UIButton *btnOutlet;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray * data;
- (IBAction)btnAction:(id)sender;
- (IBAction)readFromFile:(id)sender;
- (IBAction)writeTest:(id)sender;
- (IBAction)readTest:(id)sender;
- (IBAction)clearAll:(id)sender;

@end

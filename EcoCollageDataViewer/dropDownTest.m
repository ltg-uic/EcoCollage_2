//
//  dropDownTest.m
//  Trial_1
//
//  Created by Jamie Auza on 6/22/16.
//  Copyright © 2016 Jamie Auza. All rights reserved.
//

#import "dropDownTest.h"
#import "CVWrapper.h"

@implementation dropDownTest
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // Create the array that holds the stuff in the drop down
    self.data = [[NSArray alloc] initWithObjects:@"Value1", @"Value2",@"Value3",@"Value4",@"Value5", nil];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Number of thins shown in the drop down
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section{
    
    return [self.data count];
    
}

/*
 * Returns the table cell at the specified index path.
 *
 * Return Value
 * An object representing a cell of the table, or nil if the cell is not visible or indexPath is out of range.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        
    }
    
    
    // cell.textLabel.text = @"";
    // indexPath.row -- I'm guessing this gets called multiple times to initialize all the cells
    cell.textLabel.text = [self.data objectAtIndex:indexPath.row];


    return cell;
    
}	

/*
 * Tells the delegate that the specified row is now selected.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableView * cell = [self.tableView cellForRowAtIndexPath:indexPath];

    [self.btnOutlet setTitle: [self.data objectAtIndex:indexPath.row]  forState:UIControlStateNormal];
    
    self.tableView.hidden =  TRUE;
    
}
- (IBAction)btnAction:(id)sender {
    if( self.tableView.hidden == TRUE )
        self.tableView.hidden =  FALSE;
    else
        self.tableView.hidden = TRUE;
}

- (IBAction)readFromFile:(id)sender {
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"hsvValues"];
    fileName = [fileName stringByAppendingPathExtension:@"txt"];
    NSLog(@"fileName is %@", fileName);
    //create file if it doesn't exist and fill with default values
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        NSLog(@"We didn't find the file, so we're creating one");
        [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
        
        int hsvDefault[] = {10, 80, 50, 200, 50, 255, 80, 175, 140, 255, 100, 255, 90, 110, 40, 100, 120, 225, 0, 15, 30, 220, 50, 210, 15, 90, 35, 200, 35, 130};
        [CVWrapper setHSV_Values:hsvDefault];
        
        
        NSString *str = @"";
        
        for(int i = 0; i < 30; i++) {
            str = [str stringByAppendingFormat:@"%d ", hsvDefault[i]];
        }
        
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
        
        [file writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        [file closeFile];
    }else{
        NSLog(@"RESETTING HSV FILE");
        int hsvDefault[] = {10, 80, 50, 200, 50, 255, 80, 175, 140, 255, 100, 255, 90, 110, 40, 100, 120, 225, 0, 15, 30, 220, 50, 210, 15, 90, 35, 200, 35, 130};
        [CVWrapper setHSV_Values:hsvDefault];
        
        
        NSString *str = @"";
        
        for(int i = 0; i < 30; i++) {
            str = [str stringByAppendingFormat:@"%d ", hsvDefault[i]];
        }
        
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
        
        [file writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        NSString* content = [NSString stringWithContentsOfFile:fileName
                                            encoding:NSUTF8StringEncoding
                                               error:NULL];
        NSLog(@"AFTER RESETTING HSV FILE: READING...%@", content);
        [file closeFile];
        /*
        NSLog(@"We found the file");
        NSString* content = [NSString stringWithContentsOfFile:fileName
                                                      encoding:NSUTF8StringEncoding
                                                         error:NULL];
        NSLog(@"Reading from text file %@", content);
        NSLog(@"BEFORE ADDING");

        NSString *str = @"";
        
        for(int i = 0; i < 30; i++) { /// 30 CHARACTERS
            str = [str stringByAppendingFormat:@" " ];
        }
        
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
        
        [file writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"AFTER ADDING");
        content = [NSString stringWithContentsOfFile:fileName
                                            encoding:NSUTF8StringEncoding
                                               error:NULL];
         NSLog(@"Reading from text file %@", content);
        [file closeFile];
         */
    }

}

- (IBAction)writeTest:(id)sender {
    // Make an array
    int test[] = {10, 80, 50, 200, 50, 255, 80, 175, 140, 255, 100, 255, 90, 110, 40, 100, 120, 225, 0, 15, 30, 220, 50, 210, 15, 90, 35, 200, 35, 130};   // Corner Markers
    
    NSString *str = @"";
    
    for(int i = 0; i < 30; i++) {
        str = [str stringByAppendingFormat:@"%d ", test[i]];
    }
    
    NSArray *items = [str componentsSeparatedByString:@" "];
    
    for( int x = 0; x < items.count ; x++)
        NSLog(@"%@\n", [items objectAtIndex:x]);
    
    // str should be the string that we get when we read HSVValue.txt
    // We can also always get the high and low values from the individual view controllers
    NSString * fromUser = @"Default";
    NSString * trimmedFromUser = [fromUser stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    trimmedFromUser = [trimmedFromUser stringByAppendingFormat:@"%@", @":"];
    // Remember to add a space at the end
    // When adding a new name for a location, remove the trailing spaces
    /*
    NSString * toSend = [fromUser stringByAppendingFormat:@"%@", @","];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@","];
    toSend = [toSend stringByAppendingString: str];
    NSLog(@"%@", toSend);
    */
    NSString * toSend = [trimmedFromUser stringByAppendingString: str];
    toSend = [toSend stringByTrimmingCharactersInSet:
              [NSCharacterSet whitespaceCharacterSet]];
    toSend = [toSend stringByAppendingFormat:@"%@", @"\n"]; //Add at the end to distinguish

    NSLog(@"%@", toSend);
    
    
    /// Actually writing
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"savedHsvValues"];
    fileName = [fileName stringByAppendingPathExtension:@"txt"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        NSLog(@"We didn't find the file, so we're creating one");
        [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    }
    NSString* content = [NSString stringWithContentsOfFile:fileName
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    toSend = [content stringByAppendingString: toSend];
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    [file writeData:[toSend dataUsingEncoding:NSUTF8StringEncoding]];
    content = [NSString stringWithContentsOfFile:fileName
                                        encoding:NSUTF8StringEncoding
                                           error:NULL];
    NSLog(@"Content that was written -- WRITE TEST ----%@", content);
    [file closeFile];
    
    
}

- (IBAction)readTest:(id)sender {
    //// READING FROM FILE TEST
    /*
    NSArray *userNameAndHSVVals = [toSend componentsSeparatedByString:@":"];
    NSLog(@"the name of the line is: %@", userNameAndHSVVals[0]);
    NSArray *HSVVals = [userNameAndHSVVals[1] componentsSeparatedByString:@" "];
    for( int y = 0 ; y < HSVVals.count ; y++){
        NSLog(@"HSV VALS: %@\n", HSVVals[y]);
    }
    */
    
    // Reading from File
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"savedHsvValues"];
    fileName = [fileName stringByAppendingPathExtension:@"txt"];
    
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    NSString* content = [NSString stringWithContentsOfFile:fileName
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    NSArray *items = [content componentsSeparatedByString:@"\n"];
    
    for( int i = 0; i < items.count ;i++){
        NSLog(@"lines from file: %@",items[i]);
        NSArray * oneHSV = [content componentsSeparatedByString:@":"];
        NSLog(@"Name: %@", oneHSV[0]);
        NSArray * values =[oneHSV[1] componentsSeparatedByString:@" "];
        for( int y = 0; y < values.count ; y++)
             NSLog(@"Values: %@", values[y]);
    }
    NSLog(@"Content that was written -- READ TEST ----%@", content);
    [file closeFile];
}

- (IBAction)clearAll:(id)sender {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"savedHsvValues"];
    fileName = [fileName stringByAppendingPathExtension:@"txt"];
    NSLog(@"Writing over exiting one, or making a new one");
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
}
@end

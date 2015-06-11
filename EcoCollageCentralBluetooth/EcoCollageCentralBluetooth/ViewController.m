//
//  ViewController.m
//  EcoCollageCentralBluetooth
//
//  Created by Ryan Fogarty on 6/11/15.
//  Copyright (c) 2015 Ryan Fogarty. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager      *myCentralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong) IBOutlet NSTextFieldCell *textView;
@property (strong) IBOutlet NSTextField *studyNumberTextField;


@end


@implementation ViewController

@synthesize myCentralManager = _myCentralManager;
@synthesize discoveredPeripheral = _discoveredPeripheral;

int studyNumber;

- (IBAction)trialNumberButton:(NSButton *)sender {
    [sender setEnabled:NO];
    studyNumber = (int)self.studyNumberTextField.integerValue;
    
    NSLog(@"Initializing myCentralManager for trial %d", studyNumber);
    self.textView.stringValue = [NSString stringWithFormat:@"Initializing myCentralManager for trial %d", studyNumber];
    self.myCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

# pragma mark Core Bluetooth Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // Determine the state of the peripheral
    if ([central state] == CBCentralManagerStatePoweredOff) {
        NSLog(@"CoreBluetooth BLE hardware is powered off");
        self.textView.stringValue = [self.textView.stringValue stringByAppendingString:@"\nCoreBluetooth BLE hardware is powered off"];
    }
    else if ([central state] == CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
        self.textView.stringValue = [self.textView.stringValue stringByAppendingString:@"\nCoreBluetooth BLE hardware is powered on and ready"];
        NSLog(@"Scanning for advertising peripheral devices..");
        self.textView.stringValue = [self.textView.stringValue stringByAppendingString:@"\nScanning for advertising peripheral devices.."];
        //Will scan for peripheral devices that are advertising
        [_myCentralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"4732CA16-1009-4E0A-AC8E-9E8CC2A68A24"]] options:nil];
    }
    else if ([central state] == CBCentralManagerStateUnauthorized) {
        NSLog(@"CoreBluetooth BLE state is unauthorized");
        self.textView.stringValue = [self.textView.stringValue stringByAppendingString:@"\nCoreBluetooth BLE state is unauthorized"];
    }
    else if ([central state] == CBCentralManagerStateUnknown) {
        NSLog(@"CoreBluetooth BLE state is unknown");
        self.textView.stringValue = [self.textView.stringValue stringByAppendingString:@"\nCoreBluetooth BLE state is unknown"];
    }
    else if ([central state] == CBCentralManagerStateUnsupported) {
        NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
        self.textView.stringValue = [self.textView.stringValue stringByAppendingString:@"\nCoreBluetooth BLE hardware is unsupported on this platform"];
    }
}

-(void)centralManager:(CBCentralManager *)central
didDiscoverPeripheral:(CBPeripheral *)peripheral
    advertisementData:(NSDictionary *)advertisementData
                 RSSI:(NSNumber *)RSSI
{
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    self.textView.stringValue = [self.textView.stringValue stringByAppendingString:[NSString stringWithFormat:@"\nDiscovered %@", peripheral.name]];
    
    [_myCentralManager stopScan];
    NSLog(@"Scanning Stopped, iPad air was found!");
    self.textView.stringValue = [self.textView.stringValue stringByAppendingString:@"\nScanning Stopped, iPad air was found!"];
    
    if (self.discoveredPeripheral != peripheral) {
        
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        self.discoveredPeripheral = peripheral;
        
        // And connect
        NSLog(@"Connecting to peripheral %@", peripheral);
        self.textView.stringValue = [self.textView.stringValue stringByAppendingString:[NSString stringWithFormat:@"\nConnecting to peripheral %@", peripheral]];
        
        
        [self.myCentralManager connectPeripheral:peripheral options:nil];
    }
    
}

/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
}

/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:@[[CBUUID UUIDWithString:@"4732CA16-1009-4E0A-AC8E-9E8CC2A68A24"]]];
}


/** The Service was discovered
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        return;
    }
    
    // Discover the characteristic we want...
    NSLog(@"Discovered some service");
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"E4AE0854-E6F7-46BD-99DE-51A9B9049E8B"]] forService:service];
    }
}

/** The characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"Discovering characteristics");
    
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        // And check if it's the right one
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"E4AE0854E6F7-46BD-99DE-51A9B9049E8B"]])
        {
            NSLog(@"Found a desired Characteristic!");
            // subscribe to characteristic
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    // Once this is complete, we just need to wait for the data to come in.
}


# pragma mark Update Notification Methods

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    
    if (error) {
        NSLog(@"Error changing notification state: %@",
              [error localizedDescription]);
    }
    else {
        NSLog(@"Updated notification state for characteristic %@", characteristic);
    }
    
}


// this method is called whenever a subscribed characteristic updates on the peripheral side
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    NSData *data = characteristic.value;
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    NSLog(@"Received data: %@", dataString);
}



@end

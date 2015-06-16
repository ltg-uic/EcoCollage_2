//
//  ViewController.m
//  EcoCollageMacPeripheralSide
//
//  Created by Ryan Fogarty on 6/13/15.
//  Copyright (c) 2015 Ryan Fogarty. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController () <CBPeripheralManagerDelegate>
@property (strong, nonatomic) CBPeripheralManager *myPeripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic* trialsCharacteristic;

@property (strong, nonatomic) NSData *trialsData;
@property (strong, nonatomic) NSMutableString *trialsStringData;
@property (strong) IBOutlet NSTextField *trialDataTextField;
@property (strong) IBOutlet NSTextField *trialDataTextField2;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;
@end

#define MAX_TRANSFER_AMOUNT             20
#define SERVICE_UUID                    @"4732CA16-1009-4E0A-AC8E-9E8CC2A68A24"
#define CHARACTERISTIC_UUID             @"E4AE0854-E6F7-46BD-99DE-51A9B9049E8B"
#define SEPARATOR_FOR_TRIAL_DATA        @"$(TRIAL_DATA)$"


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    _trialsData = [[NSData alloc]init];
    _trialsStringData = [[NSMutableString alloc]initWithString:@""];
    
    
    // calls peripheralManagerDidUpdateState with state CBPeripheralManagerStatePoweredOn
    _myPeripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
}


- (void) setupCoreBluetoothSession {
    // Start with the CBMutableCharacteristic
    self.trialsCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
    
    // Then the service
    CBMutableService *service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:SERVICE_UUID] primary:YES];
    
    // Add the characteristic to the service
    service.characteristics = @[self.trialsCharacteristic];
    
    // And add it to the peripheral manager
    [self.myPeripheralManager addService:service];
    
    [_myPeripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[service.UUID] }];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}



# pragma mark CoreBluetooth Peripheral Methods

- (void) peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if([peripheral state] == CBPeripheralManagerStateUnknown)
    {
        NSLog(@"CoreBluetooth BLE state is unknown");
    }
    else if([peripheral state] == CBPeripheralManagerStateResetting)
    {
        NSLog(@"CoreBluetooth BLE state is resetting");
    }
    else if([peripheral state] == CBPeripheralManagerStateUnsupported)
    {
        NSLog(@"CoreBluetooth BLE state is unsupported");
    }
    else if([peripheral state] == CBPeripheralManagerStateUnauthorized)
    {
        NSLog(@"CoreBluetooth BLE state is unauthorized");
    }
    else if([peripheral state] == CBPeripheralManagerStatePoweredOff)
    {
        NSLog(@"CoreBluetooth BLE state is powered off");
    }
    else if([peripheral state] == CBPeripheralManagerStatePoweredOn)
    {
        NSLog(@"CoreBluetooth BLE state is powered on and ready");
        [self setupCoreBluetoothSession];
    }
    else {}
}


-(void)peripheralManager:(CBPeripheralManager *)peripheral
           didAddService:(CBService *)service
                   error:(NSError *)error
{
    if(error)
    {
        NSLog(@"Error publishing service: %@", [error localizedDescription]);
    }
    else
    {
        NSLog(@"Success adding service!");
    }
}

-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                      error:(NSError *)error
{
    if(error)
    {
        NSLog(@"Error advertising: %@", [error localizedDescription]);
    }
    else
    {
        NSLog(@"Advertising successfully!");
    }
}



# pragma mark CoreBluetooth subscribers methods

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    
    NSLog(@"Central subscribed to characteristic %@", characteristic);
    
    // Reset the index
    self.sendDataIndex = 0;
    
    [self sendData];


}


- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    
    if([request.characteristic.UUID isEqual:_trialsCharacteristic.UUID]) {
        // make sure read request is within bounds of characteristic value
        if (request.offset > _trialsCharacteristic.value.length) {
            [_myPeripheralManager respondToRequest:request
                                       withResult:CBATTErrorInvalidOffset];
            return;
        }
        else {
            // if within bounds, set value of requested characteristic, taking into account offset of read request
            request.value = [_trialsCharacteristic.value
                         subdataWithRange:NSMakeRange(request.offset,
                                                      _trialsCharacteristic.value.length - request.offset)];
            [_myPeripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        }
    }
}



// called when queue is full and cannot transmit data at that time
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    [self sendDataR];
}



# pragma mark Non-Bluetooth methods

- (IBAction)updateCharacteristic:(id)sender {
    // Reset the index
    self.sendDataIndex = 0;
    
    [self sendData];
}


- (void)sendData {
    NSString *dataString = [[NSString alloc]initWithFormat:@"%@%@%@", self.trialDataTextField.stringValue, SEPARATOR_FOR_TRIAL_DATA, self.trialDataTextField2.stringValue];
    
    _trialsData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    [self sendDataR];
}


- (void)sendDataR
{
    // First up, check if we're meant to be sending an EOM
    static BOOL sendingEOM = NO;
    
    if (sendingEOM) {
        
        // send it
        BOOL didSend = [self.myPeripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.trialsCharacteristic onSubscribedCentrals:nil];
        
        // Did it send?
        if (didSend) {
            
            // It did, so mark it as sent
            sendingEOM = NO;
            
            NSLog(@"Sent: EOM");
        }
        
        // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendDataR again
        return;
    }
    
    // We're not sending an EOM, so we're sending data
    
    // Is there any left to send?
    
    if (self.sendDataIndex >= self.trialsData.length) {
        
        // No data left.  Do nothing
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    
    BOOL didSend = YES;
    
    while (didSend) {
        
        // Make the next chunk
        
        // Work out how big it should be
        NSInteger amountToSend = self.trialsData.length - self.sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > MAX_TRANSFER_AMOUNT) amountToSend = MAX_TRANSFER_AMOUNT;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.trialsData.bytes+self.sendDataIndex length:amountToSend];
        
        // Send it
        didSend = [self.myPeripheralManager updateValue:chunk forCharacteristic:self.trialsCharacteristic onSubscribedCentrals:nil];
        
        // If it didn't work, drop out and wait for the callback
        if (!didSend) {
            return;
        }
        
        NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
        NSLog(@"Sent: %@", stringFromData);
        
        // It did send, so update our index
        self.sendDataIndex += amountToSend;
        
        // Was it the last one?
        if (self.sendDataIndex >= self.trialsData.length) {
            
            // It was - send an EOM
            
            // Set this so if the send fails, we'll send it next time
            sendingEOM = YES;
            
            // Send it
            BOOL eomSent = [self.myPeripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.trialsCharacteristic onSubscribedCentrals:nil];
            
            if (eomSent) {
                // It sent, we're all done
                sendingEOM = NO;
                
                NSLog(@"Sent: EOM");
            }
            
            return;
        }
    }
}




@end

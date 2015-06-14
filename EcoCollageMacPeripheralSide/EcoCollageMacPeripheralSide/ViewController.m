//
//  ViewController.m
//  EcoCollageMacPeripheralSide
//
//  Created by Ryan Fogarty on 6/13/15.
//  Copyright (c) 2015 Ryan Fogarty. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController () <CBPeripheralManagerDelegate, CBPeripheralDelegate>
@property (strong, nonatomic) CBPeripheralManager *myPeripheralManager;
@property (strong, nonatomic) CBUUID* serviceUUID;         //4732CA16-1009-4E0A-AC8E-9E8CC2A68A24
@property (strong, nonatomic) CBUUID* trialsCharacteristicUUID; //E4AE0854-E6F7-46BD-99DE-51A9B9049E8B
@property (strong, nonatomic) CBMutableService* service;
@property (strong, nonatomic) CBMutableCharacteristic* trialsCharacteristic;

@property (strong, nonatomic) NSData *trialsData;
@property (strong) IBOutlet NSTextField *textField;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    _trialsData = [@"Hello" dataUsingEncoding:NSASCIIStringEncoding];
    [self setupCoreBluetoothSession];
}


- (void) setupCoreBluetoothSession {
    // setup peripheral manager
    _myPeripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    
    _serviceUUID = [CBUUID UUIDWithString:@"4732CA16-1009-4E0A-AC8E-9E8CC2A68A24"];
    _trialsCharacteristicUUID = [CBUUID UUIDWithString:@"E4AE0854-E6F7-46BD-99DE-51A9B9049E8B"];
    _trialsCharacteristic = [[CBMutableCharacteristic alloc] initWithType:_trialsCharacteristicUUID properties:CBCharacteristicPropertyRead value:_trialsData permissions:CBAttributePermissionsReadable];
    
    _service = [[CBMutableService alloc] initWithType:_serviceUUID primary:YES];
    _service.characteristics = @[_trialsCharacteristic];
    [_myPeripheralManager addService:_service];
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
        //Will start advertising
        NSLog(@"Advertising Data..");
        [_myPeripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[_service.UUID] }];
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

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    
    NSLog(@"Central subscribed to characteristic %@", characteristic);


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
    NSData *updatedValue = [self.textField.stringValue dataUsingEncoding:NSASCIIStringEncoding];
    
    // if there is not enough room in the queue, updateValue calls peripheralManagerIsReadToUpdateSubscribers
    // and this method will send an update when there is enough room in the queue
    [_myPeripheralManager updateValue:updatedValue
                    forCharacteristic:_trialsCharacteristic onSubscribedCentrals:nil];
}



# pragma mark Non-Bluetooth methods

- (IBAction)updateCharacteristic:(id)sender {
    NSData *updatedValue = [self.textField.stringValue dataUsingEncoding:NSASCIIStringEncoding];
    
    // if there is not enough room in the queue, updateValue calls peripheralManagerIsReadToUpdateSubscribers
    // and this method will send an update when there is enough room in the queue
    if (![_myPeripheralManager updateValue:updatedValue
                   forCharacteristic:_trialsCharacteristic onSubscribedCentrals:nil])
    
        NSLog(@"Not enough room on queue to send update");
}




@end

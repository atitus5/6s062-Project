//
//  PeripheralModel.m
//  SureLockPeripheral
//
//  Created by Austin Freel on 4/11/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "PeripheralModel.h"

@interface PeripheralModel () <CBPeripheralManagerDelegate>

@property(nonatomic, strong) CBPeripheralManager *peripheralManager;
@property(nonatomic, strong) CBMutableCharacteristic *characteristic;
@property(nonatomic, assign) BOOL serviceRequiresRegistration;
@property(nonatomic, strong) CBMutableService *service;
@property(nonatomic, strong) NSData *pendingData;

@end

#define LOCK_PASSWORD "sayplease"

@implementation PeripheralModel

+ (BOOL) isBluetoothSupported {
    if (NSClassFromString(@"CBPeripheralManager") == nil) {
        return NO;
    }
    return YES;
}

- (id) init {
    return [self initWithDelegate:nil];
}

- (id) initWithDelegate:(id<PeripheralModelDelegate>)delegate {
    self = [super init];
    if (self) {
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
        self.delegate = delegate;
    }
    return self;
}

#pragma mark -

- (void) enableService {
    // If the service is already registered, we need to re-register it again.
    if (self.service) {
        [self.peripheralManager removeService:self.service];
    }
    
    // Create a BLE Peripheral Service and set it to be the primary. If it is not set to the primary, it will not be found when the app is in the background.
    self.service = [[CBMutableService alloc]
                    initWithType:self.serviceUUID primary:YES];
    
    // Set up the characteristic in the service. This characteristic is only readable through subscription (CBCharacteristicsPropertyNotify) and has no default value set. There is no need to set the permission on characteristic.
    self.characteristic =
        [[CBMutableCharacteristic alloc]
         initWithType:self.characteristicUUID
         properties:CBCharacteristicPropertyNotify
         value:nil
         permissions:0];
    
    // Assign the characteristic.
    self.service.characteristics =
        [NSArray arrayWithObject:self.characteristic];
    
    // Add the service to the peripheral manager.
    [self.peripheralManager addService:self.service];
}

- (void) disableService {
    [self.peripheralManager removeService:self.service];
    self.service = nil;
    [self stopAdvertising];
}


// Called when the BTLE advertisments should start. We don't take down
// the advertisments unless the user switches us off.
- (void) startAdvertising {
    if (self.peripheralManager.isAdvertising) {
        [self.peripheralManager stopAdvertising];
    }
    
    NSDictionary *advertisment = @{
                                   CBAdvertisementDataServiceUUIDsKey : @[self.serviceUUID],
                                   CBAdvertisementDataLocalNameKey: self.serviceName
                                   };
    [self.peripheralManager startAdvertising:advertisment];
}

- (void) stopAdvertising {
    [self.peripheralManager stopAdvertising];
}

- (BOOL) isAdvertising {
    return [self.peripheralManager isAdvertising];
}

#pragma mark -

- (void)sendToSubscribers:(NSData *)data {
    if (self.peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@"sendToSubscribers: peripheral not ready for sending state: %ld", (long)self.peripheralManager.state);
        return;
    }
    
    BOOL success = [self.peripheralManager updateValue:data
                              forCharacteristic:self.characteristic
                           onSubscribedCentrals:nil];
    if (!success) {
        NSLog(@"Failed to send data, buffering data for retry once ready.");
        self.pendingData = data;
        return;
    }
}

- (void)applicationDidEnterBackground {
    NSLog(@"applicationDidEnterBackground");
    // Deliberately continue advertising so that it still remains discoverable.
}

- (void)applicationWillEnterForeground {
    NSLog(@"applicationWillEnterForeground");
    // Deliberately avoid re-enabling or re-advertising the service.
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service
                    error:(NSError *)error {
    // As soon as the service is added, we should start advertising.
    [self startAdvertising];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"peripheralStateChange: Powered On");
            // As soon as the peripheral/bluetooth is turned on, start initializingthe the service.
            [self enableService];
            break;
        case CBPeripheralManagerStatePoweredOff: {
            NSLog(@"peripheralStateChange: Powered Off");
            [self disableService];
            self.serviceRequiresRegistration = YES;
            break;
        }
        case CBPeripheralManagerStateResetting: {
            NSLog(@"peripheralStateChange: Resetting");
            self.serviceRequiresRegistration = YES;
            break;
        }
        case CBPeripheralManagerStateUnauthorized: {
            NSLog(@"peripheralStateChange: Deauthorized");
            [self disableService];
            self.serviceRequiresRegistration = YES;
            break;
        }
        case CBPeripheralManagerStateUnsupported: {
            NSLog(@"peripheralStateChange: Unsupported");
            self.serviceRequiresRegistration = YES;
            break;
        }
        case CBPeripheralManagerStateUnknown:
            NSLog(@"peripheralStateChange: Unknown");
            break;
        default:
            break;
    }
}

- (void) peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"didSubscribe: %@", characteristic.UUID);
    NSLog(@"didSubscribe: - Central: %@", central.identifier);
    [self.delegate peripheralModel:self centralDidSubscribe:central];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"didUnsubscribe: %@", central.identifier);
    [self.delegate peripheralModel:self centralDidUnsubscribe:central];
}

- (void) peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    
    if ([request.characteristic.UUID isEqual:self.characteristic.UUID]) {
        if (request.offset > self.characteristic.value.length) {
            [self.peripheralManager respondToRequest:request withResult:CBATTErrorInvalidOffset];
            return;
        }
        // TODO: if we want to allow some sort of reading, just need to set request.value to that value so it gets returned to central
        request.value = [self.characteristic.value subdataWithRange:NSMakeRange(request.offset, self.characteristic.value.length - request.offset)];
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }
}

- (void) peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    
    for (int i=0; i<[requests count]; i++) {
        if ([[requests objectAtIndex:i].value isEqual:@LOCK_PASSWORD]) {
            // trigger unlock
            [self.delegate peripheralModel:self centralDidAuthenticate:[requests objectAtIndex:i].central];
            [self.peripheralManager respondToRequest:[requests objectAtIndex:i] withResult:CBATTErrorSuccess];
            return;
        }
    }
    [self.peripheralManager respondToRequest:[requests objectAtIndex:0] withResult:CBATTErrorInsufficientAuthentication];
}

- (void) peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if (error) {
        NSLog(@"didStartAdvertising: Error: %@", error);
    } else {
        NSLog(@"didStartAdvertising");
    }
}

- (void) peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    NSLog(@"isReadyToUpdateSubscribers");
    if (self.pendingData) {
        NSData *data = [self.pendingData copy];
        self.pendingData = nil;
        [self sendToSubscribers:data];
    }
}

@end


//
//  BLEManager.m
//  SureLockCentral
//
//  Created by Andrew Titus on 4/9/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import "BLEManager.h"

@implementation BLEManager

@synthesize delegate;
@synthesize currentLock;

- (id)initWithDelegate:(id)d {
    self = [super init];
    
    if (self) {
        // Set delegate
        [self setDelegate:d];
        
        // Add option to tell user to enable Bluetooth
        NSDictionary *cmOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                              forKey:CBCentralManagerOptionShowPowerAlertKey];
        cm = [[CBCentralManager alloc] initWithDelegate:self
                                                  queue:nil
                                                options:cmOptions];
    }
    
    return self;
}

#pragma mark - CBCentralManagerDelegate methods -

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if ([central state] == CBCentralManagerStatePoweredOn) {
        [central scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@SL_SERVICE_UUID]]
                                        options:nil];
        [[self delegate] bleManagerDidUpdateStatus:self
                                     updateMessage:@"Scanning for peripherals..."];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    [[self delegate] bleManagerDidUpdateStatus:self
                                 updateMessage:[NSString stringWithFormat:@"Discovered peripheral with name %@ - signal strength is %@dB. Connecting...", peripheral.name, RSSI]];
    [cm cancelPeripheralConnection:peripheral];
    [peripheral setDelegate:self];
    [self setCurrentLock:peripheral];
    [cm connectPeripheral:peripheral
                  options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    if (peripheral != currentLock) {
        NSLog(@"Attempted connection with unknown peripheral");
    } else {
        [[self delegate] bleManagerDidUpdateStatus:self
                                     updateMessage:[NSString stringWithFormat:@"Connected to peripheral with name %@. Discovering services...", peripheral.name]];
        [peripheral discoverServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@SL_SERVICE_UUID]]];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [[self delegate] bleManagerDidUpdateStatus:self
                                 updateMessage:[NSString stringWithFormat:@"Disconnected from peripheral with name %@ - scanning for peripherals...", currentLock.name]];
    [self setCurrentLock:nil];
}

#pragma mark - CBPeripheralDelegate Methods -

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (peripheral != currentLock) {
        NSLog(@"Attempted connection with unknown peripheral");
    } else {
        for (CBService *cs in [peripheral services]) {
            if ([[[cs UUID] UUIDString] isEqualToString:@SL_SERVICE_UUID]) {
                [[self delegate] bleManagerDidUpdateStatus:self
                                         updateMessage:[NSString stringWithFormat:@"Discovered service %@ on peripheral with name %@. Discovering characteristics...", [[cs UUID] UUIDString], peripheral.name]];
                [peripheral discoverCharacteristics:[NSArray arrayWithObject:[CBUUID UUIDWithString:@SL_CHAR_TX_UUID]]
                                         forService:cs];
            } else {
                NSLog(@"Discovered unknown service with UUID %@", [[cs UUID] UUIDString]);
            }
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error {
    if (peripheral != currentLock) {
        NSLog(@"Attempted connection with unknown peripheral");
    } else {
        if ([[[service UUID] UUIDString] isEqualToString:@SL_SERVICE_UUID]) {
            for (CBCharacteristic *c in service.characteristics) {
                if ([[[c UUID] UUIDString] isEqualToString:@SL_CHAR_TX_UUID]) {
                    [[self delegate] bleManagerDidUpdateStatus:self
                                                 updateMessage:[NSString stringWithFormat:@"Discovered characteristic %@. Sending password...", [[c UUID] UUIDString]]];
                    NSString *password = @"sayplease";
                    [peripheral writeValue:[password dataUsingEncoding:NSUTF8StringEncoding]
                         forCharacteristic:c
                                      type:CBCharacteristicWriteWithResponse];
                } else {
                    NSLog(@"Discovered unknown characteristic");
                }
            }
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (peripheral != currentLock) {
        NSLog(@"Attempted connection with unknown peripheral");
    } else {
        if (error) {
            NSLog(@"Error writing to characteristic: %@", [error description]);
        } else {
            if ([[[characteristic UUID] UUIDString] isEqualToString:@SL_CHAR_TX_UUID]) {
                [[self delegate] bleManagerDidUpdateStatus:self
                                             updateMessage:[NSString stringWithFormat:@"Successfully wrote password to characteristic %@", [[characteristic UUID] UUIDString]]];
            } else {
                NSLog(@"Wrote to invalid characteristic %@", [[characteristic UUID] UUIDString]);
            }
        }
    }
}

@end

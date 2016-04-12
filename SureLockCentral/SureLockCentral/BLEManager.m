//
//  BLEManager.m
//  SureLockCentral
//
//  Created by Andrew Titus on 4/9/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import "BLEManager.h"

@implementation BLEManager

- (id)initWithDelegate:(id)delegate {
    self = [super init];
    
    if (self) {
        // Set delegate
        [self setDelegate:delegate];
        
        // Add option to tell user to enable Bluetooth
        NSDictionary *cmOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                              forKey:CBCentralManagerOptionShowPowerAlertKey];
        cm = [[CBCentralManager alloc] initWithDelegate:self
                                                  queue:nil
                                                options:cmOptions];
    }
    
    return self;
}

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
    currentLock = peripheral;
    [cm connectPeripheral:currentLock
                  options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    if (peripheral != currentLock) {
        NSLog(@"Attempted connection with unknown peripheral");
    } else {
        [[self delegate] bleManagerDidUpdateStatus:self
                                     updateMessage:[NSString stringWithFormat:@"Connected to peripheral with name %@. Discovering services...", peripheral.name]];
        [currentLock discoverServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@SL_SERVICE_UUID]]];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (peripheral != currentLock) {
        NSLog(@"Attempted connection with unknown peripheral");
    } else {
        for (CBService *cs in [peripheral services]) {
            if ([[[cs UUID] UUIDString] isEqualToString:@SL_SERVICE_UUID]) {
                [[self delegate] bleManagerDidUpdateStatus:self
                                         updateMessage:[NSString stringWithFormat:@"Discovered service %@ on peripheral with name %@. Discovering characteristics...", [[cs UUID] UUIDString], peripheral.name]];
                [currentLock discoverCharacteristics:[NSArray arrayWithObject:[CBUUID UUIDWithString:@SL_CHAR_TX_UUID]]
                                      forService:cs];
            } else {
                NSLog(@"Discovered unknown service");
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
                                                 updateMessage:[NSString stringWithFormat:@"Discovered characteristic %@ on peripheral with name %@. Waiting for notifications...", [[c UUID] UUIDString], peripheral.name]];
                    [peripheral setNotifyValue:YES
                             forCharacteristic:c];
                } else {
                    NSLog(@"Discovered unknown characteristic");
                }
            }
        }
    }
}

@end

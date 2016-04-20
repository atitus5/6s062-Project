//
//  BLEManager.m
//  SureLockCentral
//
//  Created by Andrew Titus on 4/9/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import "BLEManager.h"

@implementation BLEManager {
    CMMotionManager *accelManager;
    CMDeviceMotionHandler accelHandler;
}

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
        
        // Set up CoreMotion manager
        accelManager = [[CMMotionManager alloc] init];
        [accelManager setDeviceMotionUpdateInterval:UPDATE_INTERVAL];
        
        __weak typeof(self) weakSelf = self; // Create weak reference to self to prevent retain cycle
        accelHandler = ^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error handling motion: %@", [error localizedDescription]);
            } else {
                [weakSelf evalAccel:motion];
            }
        };

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
    [self setCurrentLock:peripheral];
    [cm cancelPeripheralConnection:peripheral];
    [peripheral setDelegate:self];
    [cm connectPeripheral:peripheral
                  options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [[self delegate] bleManagerDidUpdateStatus:self
                                 updateMessage:[NSString stringWithFormat:@"Connected to peripheral with name %@. Discovering services...", peripheral.name]];
    [peripheral readRSSI]; // Request new RSSI estimate
    [peripheral discoverServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@SL_SERVICE_UUID]]];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [[self delegate] bleManagerDidUpdateStatus:self
                                 updateMessage:[NSString stringWithFormat:@"Disconnected from peripheral with name %@ - scanning for peripherals...", [self currentLock].name]];
    [self setCurrentLock:nil];
    [central scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@SL_SERVICE_UUID]]
                                    options:nil];
}

#pragma mark - CBPeripheralDelegate Methods -

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (peripheral != [self currentLock]) {
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

-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    if (error) {
        NSLog(@"Error while reading RSSI: %@", [error localizedDescription]);
    } else {
        [self setCurrentRSSI:RSSI];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error {
    if (peripheral != [self currentLock]) {
        NSLog(@"Attempted connection with unknown peripheral");
    } else {
        if ([[[service UUID] UUIDString] isEqualToString:@SL_SERVICE_UUID]) {
            for (CBCharacteristic *c in service.characteristics) {
                if ([[[c UUID] UUIDString] isEqualToString:@SL_CHAR_TX_UUID]) {
                    [[self delegate] bleManagerDidUpdateStatus:self
                                                 updateMessage:[NSString stringWithFormat:@"Discovered characteristic %@. Sending password once ready...", [[c UUID] UUIDString]]];
                    [self setCurrentCharacteristic:c];
                    [accelManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical
                                                                      toQueue:[NSOperationQueue mainQueue]
                                                                  withHandler:accelHandler];
                    
                } else {
                    NSLog(@"Discovered unknown characteristic");
                }
            }
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (peripheral != [self currentLock]) {
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

-(void)evalAccel: (CMDeviceMotion *)motion {
    // Check if signal strong enough (i.e. close enough to peripheral)
    if ([[self currentRSSI] doubleValue] >= RSSI_THRESHOLD) {
        float accelMag = sqrt(pow([motion userAcceleration].x, 2.0) + pow([motion userAcceleration].y, 2.0) + pow([motion userAcceleration].z, 2.0));
        if (accelMag <= ACCEL_MAG_THRESHOLD) {
            NSString *password = @"sayplease";
            [[self currentLock] writeValue:[password dataUsingEncoding:NSUTF8StringEncoding]
                 forCharacteristic:[self currentCharacteristic]
                              type:CBCharacteristicWriteWithResponse];
            [accelManager stopDeviceMotionUpdates];
        }
    }
    [[self currentLock] readRSSI]; // Request new RSSI estimate
}

@end

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
        // Add option to tell user to enable Bluetooth
        NSDictionary *cmOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                              forKey:CBCentralManagerOptionShowPowerAlertKey];
        cm = [[CBCentralManager alloc] initWithDelegate:delegate
                                                  queue:nil
                                                options:cmOptions];
    }
    
    return self;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if ([central state] == CBCentralManagerStatePoweredOn) {
        [central scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@SL_SERVICE_UUID]]
                                        options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"Discovered peripheral with name %@ - signal strength is %@dB", peripheral.name, RSSI);
}

@end

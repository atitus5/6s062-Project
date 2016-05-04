//
//  ViewController.m
//  SureLockCentral
//
//  Created by Andrew Titus on 4/4/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import "ViewController.h"
#import "PeripheralModel.h"

@interface ViewController ()

@end

@implementation ViewController {
    NSTimer *relockTimer;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setPeripheralModel:[[PeripheralModel alloc] initWithDelegate:self]];
    [[self peripheralModel] setServiceName:@"SureLock"];
    [[self peripheralModel] setServiceUUID:[CBUUID UUIDWithString:@SL_SERVICE_UUID]];
    [[self peripheralModel] setCharacteristicUUID:[CBUUID UUIDWithString:@SL_CHAR_TX_UUID]];
    [[self peripheralModel] startAdvertising];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)lockPeripheral:(NSTimer *)timer {
    self.lockLabel.text = @"Locked";
    [[self view] setBackgroundColor:[UIColor redColor]];
}

- (void)unlockPeripheral {
    self.lockLabel.text = @"Unlocked";
    [[self view] setBackgroundColor:[UIColor greenColor]];
}

#pragma mark - PeripheralModelDelegate

- (void)peripheralModel:(PeripheralModel *)peripheral centralDidAuthenticate:(CBCentral *)central {
    [self unlockPeripheral];
    
    [relockTimer invalidate]; // Stop current timer
    relockTimer = nil;  // Clear timer
    relockTimer = [NSTimer scheduledTimerWithTimeInterval:RELOCK_INTERVAL
                                                   target:self
                                                 selector:@selector(lockPeripheral:)
                                                 userInfo:nil
                                                  repeats:NO];
}

@end

//
//  PeripheralModel.h
//  SureLockPeripheral
//
//  Created by Austin Freel on 4/11/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol PeripheralModelDelegate;

@interface PeripheralModel : NSObject

@property(nonatomic, assign) id<PeripheralModelDelegate> delegate;

@property(nonatomic, strong) NSString *serviceName;
@property(nonatomic, strong) CBUUID *serviceUUID;
@property(nonatomic, strong) CBUUID *characteristicUUID;

// Returns YES if Bluetooth 4 LE is supported on this operation system.
+ (BOOL)isBluetoothSupported;

- (id)initWithDelegate:(id<PeripheralModelDelegate>)delegate;

- (void)sendToSubscribers:(NSData *)data;

// Called by the application if it enters the background.
- (void)applicationDidEnterBackground;

// Called by the application if it enters the foregroud.
- (void)applicationWillEnterForeground;

// Allows turning on or off the advertisments.
- (void)startAdvertising;
- (void)stopAdvertising;
- (BOOL)isAdvertising;

@end

// Simplified protocol to respond to subscribers.
@protocol PeripheralModelDelegate <NSObject>

// Called when the peripheral receives a new subscriber.
- (void)peripheralModel:(PeripheralModel *)peripheral centralDidSubscribe:(CBCentral *)central;

- (void)peripheralModel:(PeripheralModel *)peripheral centralDidUnsubscribe:(CBCentral *)central;

- (void)peripheralModel:(PeripheralModel *)peripheral centralDidAuthenticate:(CBCentral *)central;

@end


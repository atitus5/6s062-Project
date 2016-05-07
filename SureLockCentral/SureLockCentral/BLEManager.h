//
//  BLEManager.h
//  SureLockCentral
//
//  Created by Andrew Titus on 4/9/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreBluetooth;
@import CoreLocation;
@import CoreMotion;

#define SL_SERVICE_UUID "774763C4-0278-4722-91FC-ED1B71365BD4"
#define SL_CHAR_TX_UUID "55F34A89-B450-48CF-9C14-6BE729856ABF"
#define DATA_COLLECTION 0
#define UPDATE_INTERVAL 0.1
#define RSSI_THRESHOLD -61.0
#define ACCEL_MAG_THRESHOLD 0.10
#define EWMA_WINDOW 20.0
#define EWMA_ALPHA (2.0 / (EWMA_WINDOW + 1.0))
#define ACCEL_WINDOW 10.0
#define ACCEL_ALPHA (2.0 / (ACCEL_WINDOW + 1.0))

@class BLEManager;
@protocol BLEManagerDelegate <NSObject>
@optional
- (void)bleManagerDidUpdateStatus:(BLEManager *)manager updateMessage:(NSString *)msg;
- (void)bleManagerDidReceiveUpdate:(BLEManager *)manager updateMessage:(NSString *)msg;
@end

@interface BLEManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate> {
    CBCentralManager *cm;
    CLLocationManager *lm;
}

@property (nonatomic, weak) id<BLEManagerDelegate> delegate;
@property (atomic, strong) CBPeripheral *currentLock;
@property (nonatomic, weak) CBCharacteristic *currentCharacteristic;
@property (nonatomic, strong) NSNumber *currentRSSI;
@property (nonatomic, strong) NSNumber *currentSmoothedRSSI;
@property (nonatomic, strong) NSNumber *currentSmoothedXAccel;
@property (nonatomic, strong) NSNumber *currentSmoothedYAccel;
@property (nonatomic, strong) NSNumber *currentSmoothedZAccel;


// The designated initializer
- (id)initWithDelegate:(id)d;

@end

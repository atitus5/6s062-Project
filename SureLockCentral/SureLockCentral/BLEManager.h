//
//  BLEManager.h
//  SureLockCentral
//
//  Created by Andrew Titus on 4/9/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreBluetooth;

#define SL_SERVICE_UUID "774763C4-0278-4722-91FC-ED1B71365BD4"
#define SL_CHAR_TX_UUID "55F34A89-B450-48CF-9C14-6BE729856ABF"
#define DATA_COLLECTION 1

@class BLEManager;
@protocol BLEManagerDelegate <NSObject>
@optional
- (void)bleManagerDidUpdateStatus:(BLEManager *)manager updateMessage:(NSString *)msg;
@end

@interface BLEManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate> {
    CBCentralManager *cm;
}

@property (nonatomic, weak) id<BLEManagerDelegate> delegate;
@property (atomic, strong) CBPeripheral *currentLock;

// The designated initializer
- (id)initWithDelegate:(id)d;

@end

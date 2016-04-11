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

@class BLEManager;
@protocol BLEManagerDelegate <NSObject>
@optional
- (void)bleManagerDidUpdateStatus:(BLEManager *)manager updateMessage:(NSString *)msg;
@end

@interface BLEManager : NSObject <CBCentralManagerDelegate> {
    CBCentralManager *cm;
}

// The designated initializer
- (id)initWithDelegate:(id)delegate;

@end

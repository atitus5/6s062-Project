//
//  SLLogger.h
//  SureLockCentral
//
//  Created by Andrew Titus on 4/16/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreBluetooth;

@interface SLLogger : NSObject

// The designated initializer
- (id)initWithLogFile:(NSFileHandle *)lf peripheral:(CBPeripheral *)p;

- (void)startLogging;
- (void)stopLogging;

@property (nonatomic, assign, getter=isLogging) BOOL logging;
@property (nonatomic, assign, getter=isUnlockRequested) BOOL unlockRequested;

@end

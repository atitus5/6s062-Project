//
//  SLLogger.h
//  SureLockCentral
//
//  Created by Andrew Titus on 4/16/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLEManager.h"

#define SAMPLE_INTERVAL 0.1

@interface SLLogger : NSObject

// The designated initializer
- (id)initWithLogFile:(NSFileHandle *)lf manager:(BLEManager *)m;

- (void)startLogging;
- (void)stopLogging;

@property (nonatomic, assign, getter=isLogging) BOOL logging;
@property (nonatomic, assign, getter=isUnlockRequested) BOOL unlockRequested;

@end

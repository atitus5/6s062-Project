//
//  SLLogger.m
//  SureLockCentral
//
//  Created by Andrew Titus on 4/16/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import "SLLogger.h"

@import CoreMotion;

@implementation SLLogger {
    NSFileHandle *logFile;
    CMMotionManager *motionManager;
    CMDeviceMotionHandler motionHandler;
    BLEManager *currentManager;
}

@synthesize unlockRequested;
@synthesize logging;

- (id)initWithLogFile:(NSFileHandle *)lf manager:(BLEManager *)m {
    self = [super init];
    
    if (self) {
        // Set log file
        logFile = lf;
        currentManager = m;
        
        [self setUnlockRequested:NO];
        [self setLogging:NO];
        
        motionManager = [[CMMotionManager alloc] init];
        [motionManager setDeviceMotionUpdateInterval:SAMPLE_INTERVAL];
        
        __weak typeof(self) weakSelf = self; // Create weak reference to self to prevent retain cycle
        motionHandler = ^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error handling motion: %@", [error localizedDescription]);
            } else {
                [weakSelf logEntry:motion];
            }
        };
    }
    
    return self;
}

- (void)startLogging {
    [self setLogging:YES];
    
    NSLog(@"Log started");
    [self logLineToDataFile:@"Time,Acc_X,Acc_Y,Acc_Z,RSSI,Unlock Requested\n"];
    
    [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical
                                                       toQueue:[NSOperationQueue mainQueue]
                                                   withHandler:motionHandler];
    
    return;
}

- (void)stopLogging {
    [self setLogging:NO];
    NSLog(@"Log ended");
    [motionManager stopDeviceMotionUpdates];
    return;
}

- (void)logEntry:(CMDeviceMotion *)motion {
    // Must have a connected peripheral
    if ([currentManager currentLock]) {
        [[currentManager currentLock] readRSSI]; // Request new RSSI estimate
        double currentRSSIEstimate = [[currentManager currentSmoothedRSSI] doubleValue];
        [self logLineToDataFile:[NSString stringWithFormat:@"%f,%f,%f,%f,%f,%d\n", [motion timestamp], [motion userAcceleration].x, [motion userAcceleration].y, [motion userAcceleration].z, currentRSSIEstimate, [self isUnlockRequested]]];
    }
}

- (void)logLineToDataFile:(NSString *)line {
    [logFile writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
}

@end

//
//  SLLogger.m
//  SureLockCentral
//
//  Created by Andrew Titus on 4/16/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import "SLLogger.h"

@implementation SLLogger {
    CBPeripheral *currentPeripheral;
    NSFileHandle *logFile;
}

@synthesize unlockRequested;
@synthesize logging;

- (id)initWithLogFile:(NSFileHandle *)lf peripheral:(CBPeripheral *)p {
    self = [super init];
    
    if (self) {
        // Set log file and current peripheral
        logFile = lf;
        currentPeripheral = p;
        
        [self setUnlockRequested:NO];
        [self setLogging:NO];
    }
    
    return self;
}

- (void)startLogging {
    // TODO: periodic logging
    [self setLogging:YES];
    NSLog(@"Log started");
    return;
}

- (void)stopLogging {
    // TODO: stop periodic logging
    [self setLogging:NO];
    NSLog(@"Log ended");
    return;
}

-(void)logLineToDataFile:(NSString *)line {
    [logFile writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
}

@end

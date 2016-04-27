//
//  AppDelegate.m
//  SureLockCentral
//
//  Created by Andrew Titus on 4/4/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import "AppDelegate.h"

#define SL_SERVICE_UUID "774763C4-0278-4722-91FC-ED1B71365BD4"
#define SL_CHAR_TX_UUID "55F34A89-B450-48CF-9C14-6BE729856ABF"

@interface AppDelegate ()
@end

@implementation AppDelegate {
    NSTimer *relockTimer;
}

    
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.peripheralModel = [[PeripheralModel alloc] initWithDelegate:self];
    self.peripheralModel.serviceName = @"SureLock";
    self.peripheralModel.serviceUUID = [CBUUID UUIDWithString:@SL_SERVICE_UUID];
    self.peripheralModel.characteristicUUID = [CBUUID UUIDWithString:@SL_CHAR_TX_UUID];
    [self.peripheralModel startAdvertising];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - PeripheralModelDelegate

- (void)peripheralModel:(PeripheralModel *)peripheral centralDidAuthenticate:(CBCentral *)central {
    [(ViewController *)self.window.rootViewController unlockPeripheral];
    
    [relockTimer invalidate]; // Stop current timer
    relockTimer = nil;  // Clear timer
    relockTimer = [NSTimer scheduledTimerWithTimeInterval:RELOCK_INTERVAL
                                                   target:self
                                                 selector:@selector(lockPeripheral:)
                                                 userInfo:nil
                                                  repeats:NO];
}

- (void)lockPeripheral:(NSTimer *)timer {
    [(ViewController *)self.window.rootViewController lockPeripheral];
}

@end

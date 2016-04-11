//
//  AppDelegate.m
//  SureLockCentral
//
//  Created by Andrew Titus on 4/4/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

CGFloat BLERED = 11.0/255.0;
CGFloat BLEGREEN = 74.0/255.0;
CGFloat BLEBLUE = 143.0/255.0;

@interface AppDelegate ()

@end

@implementation AppDelegate

    
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Set up window
    CGRect windowFrame = [[UIScreen mainScreen] bounds];
    UIWindow *mainWindow = [[UIWindow alloc] initWithFrame:windowFrame];
    [self setWindow:mainWindow];
    
    // Finalize window and display
    [[self window] setRootViewController:[[ViewController alloc] init]];
    [[self window] setBackgroundColor:[UIColor colorWithRed:BLERED
                                                      green:BLEGREEN
                                                       blue:BLEBLUE
                                                      alpha:1.0]];
    [[self window] makeKeyAndVisible];
    
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

@end

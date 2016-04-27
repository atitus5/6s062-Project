//
//  AppDelegate.h
//  SureLockCentral
//
//  Created by Andrew Titus on 4/4/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "PeripheralModel.h"

#define RELOCK_INTERVAL 3.0

@interface AppDelegate : UIResponder <UIApplicationDelegate,  PeripheralModelDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) PeripheralModel *peripheralModel;
@property (nonatomic, strong) ViewController *viewController;

- (void)lockPeripheral:(NSTimer *)timer;

@end


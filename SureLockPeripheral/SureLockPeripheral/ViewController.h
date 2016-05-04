//
//  ViewController.h
//  SureLockCentral
//
//  Created by Andrew Titus on 4/4/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeripheralModel.h"

@import CoreBluetooth;

#define RELOCK_INTERVAL 3.0

@interface ViewController : UIViewController <PeripheralModelDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lockLabel;
@property (nonatomic, strong) PeripheralModel *peripheralModel;

- (void)lockPeripheral:(NSTimer *)timer;
- (void) unlockPeripheral;

@end
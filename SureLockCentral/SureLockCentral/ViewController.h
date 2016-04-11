//
//  ViewController.h
//  SureLockCentral
//
//  Created by Andrew Titus on 4/4/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEManager.h"


@interface ViewController : UIViewController <BLEManagerDelegate> {
    UILabel *greetingMessage, *statusMessage;
}


@end


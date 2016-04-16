//
//  ViewController.h
//  SureLockCentral
//
//  Created by Andrew Titus on 4/4/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BLEManager.h"
#import "AppDelegate.h"
#import "SLLogger.h"

@interface ViewController : UIViewController <BLEManagerDelegate, MFMailComposeViewControllerDelegate> {
    UILabel *greetingMessage, *statusMessage;
    UIButton *unlockRequestButton, *startLogButton;
    SLLogger *logger;
}


@end


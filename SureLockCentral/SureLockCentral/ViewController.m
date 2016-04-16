//
//  ViewController.m
//  SureLockCentral
//
//  Created by Andrew Titus on 4/4/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end


@implementation ViewController {
    BLEManager *manager;
    NSFileHandle *logFile;
    UIAlertController *alert;
    SLLogger *currentLogger;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Start up BLE manager
    manager = [[BLEManager alloc] initWithDelegate:self];
    
    // Set up greeting message
    CGFloat fontSize = 20.0;
    CGFloat padding = 30.0;
    CGRect greetingFrame = CGRectMake(padding, ([[UIScreen mainScreen] bounds].size.height * 0.2) - (fontSize / 2.0), [[UIScreen mainScreen] bounds].size.width - 2.0 * padding, fontSize);
    greetingMessage = [[UILabel alloc] initWithFrame:greetingFrame];
    [greetingMessage setText:@"Welcome to SureLock!"];
    [greetingMessage setTextColor:[UIColor whiteColor]];
    [greetingMessage setTextAlignment:NSTextAlignmentCenter];
    [greetingMessage setFont:[UIFont systemFontOfSize:fontSize]];
    [[self view] addSubview:greetingMessage];
    
    // Set up status message
    CGFloat statusHeight = 6.0 * fontSize;
    CGRect statusFrame = CGRectMake(padding, ([[UIScreen mainScreen] bounds].size.height * 0.8) - (statusHeight / 2.0), [[UIScreen mainScreen] bounds].size.width - 2.0 * padding, statusHeight);
    statusMessage = [[UILabel alloc] initWithFrame:statusFrame];
    [statusMessage setNumberOfLines:0]; // Unlimited lines
    [statusMessage setText:@"Ready to scan for peripheral locks"];
    [statusMessage setTextColor:[UIColor whiteColor]];
    [statusMessage setTextAlignment:NSTextAlignmentCenter];
    [statusMessage setFont:[UIFont systemFontOfSize:fontSize]];
    [[self view] addSubview:statusMessage];

    // Set up data collection
#if DATA_COLLECTION
    // Set up unlock request button
    CGFloat buttonWidth = 150.0;
    CGRect unlockRequestFrame = CGRectMake([[UIScreen mainScreen] bounds].size.width / 2.0 - (buttonWidth / 2.0) - padding, [[UIScreen mainScreen] bounds].size.height * 0.4 - (fontSize / 2.0) - padding, buttonWidth + 2.0 * padding, fontSize + 2.0 * padding);
    unlockRequestButton = [[UIButton alloc] initWithFrame:unlockRequestFrame];
    [unlockRequestButton setBackgroundColor:[UIColor whiteColor]];
    [unlockRequestButton setTitle:@"Request Unlock"
                         forState:UIControlStateNormal];
    [unlockRequestButton setTitleColor:[UIColor redColor]
                              forState:UIControlStateNormal];
    [unlockRequestButton addTarget:self
                            action:@selector(unlockStateChanged:)
                  forControlEvents:UIControlEventTouchUpInside];
    [unlockRequestButton setEnabled:NO]; // Disable until logging starts
    [[self view] addSubview:unlockRequestButton];
    
    // Set up start log button
    CGRect startLogFrame = CGRectMake([[UIScreen mainScreen] bounds].size.width / 2.0 - (buttonWidth / 2.0) - padding, [[UIScreen mainScreen] bounds].size.height * 0.6 - (fontSize / 2.0) - padding, buttonWidth + 2.0 * padding, fontSize + 2.0 * padding);
    startLogButton = [[UIButton alloc] initWithFrame:startLogFrame];
    [startLogButton setBackgroundColor:[UIColor whiteColor]];
    [startLogButton setTitle:@"Start logging"
                    forState:UIControlStateNormal];
    [startLogButton setTitleColor:[UIColor redColor]
                            forState:UIControlStateNormal];
    [startLogButton addTarget:self
                       action:@selector(loggingStateChanged:)
             forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:startLogButton];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// LOG FILE OPERATIONS

int logCount = 1;   // Track number of log files written

-(void)unlockStateChanged:(id)sender {
    // Toggle unlock requested state
    BOOL unlockState = ![currentLogger isUnlockRequested];
    
    [currentLogger setUnlockRequested:unlockState];
    if (unlockState) {
        [unlockRequestButton setTitle:@"Unlock requested"
                             forState:UIControlStateNormal];
        [unlockRequestButton setTitleColor:[UIColor greenColor]
                                  forState:UIControlStateNormal];
    } else {
        [unlockRequestButton setTitle:@"Request unlock"
                             forState:UIControlStateNormal];
        [unlockRequestButton setTitleColor:[UIColor redColor]
                                  forState:UIControlStateNormal];
    }
}

-(void)loggingStateChanged:(id)sender {
    BOOL loggingState = [currentLogger isLogging];
    
    if (loggingState) {
        [currentLogger stopLogging];
        
        [unlockRequestButton setEnabled:NO]; // Disable unlock requests
        [currentLogger setUnlockRequested:NO];
        [unlockRequestButton setTitle:@"Request unlock"
                             forState:UIControlStateNormal];
        [unlockRequestButton setTitleColor:[UIColor redColor]
                                  forState:UIControlStateNormal];
        [startLogButton setTitle:@"Start logging"
                        forState:UIControlStateNormal];
        [startLogButton setTitleColor:[UIColor redColor]
                             forState:UIControlStateNormal];
        
        [self emailLogFile];
    } else {
        [self resetLogFile];
        currentLogger = [[SLLogger alloc] initWithLogFile:logFile
                                               peripheral:[manager currentLock]];
        [currentLogger startLogging];
        [unlockRequestButton setEnabled:YES]; // Enable unlock requests
        
        [startLogButton setTitle:@"Logging..."
                        forState:UIControlStateNormal];
        [startLogButton setTitleColor:[UIColor greenColor]
                             forState:UIControlStateNormal];
    }
}

-(NSString *)getPathToLogFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"log%d.csv", logCount]];
    return filePath;
}


-(NSFileHandle *)openFileForWriting {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSFileHandle *f;
    [fileManager createFileAtPath:[self getPathToLogFile]
                         contents:nil
                       attributes:nil];
    f = [NSFileHandle fileHandleForWritingAtPath:[self getPathToLogFile]];
    return f;
}

-(void)resetLogFile {
    if (logFile) {
        [logFile closeFile];
    }
    logFile = [self openFileForWriting];
    if (!logFile) {
        NSAssert(logFile,@"Couldn't open file for writing.");
    }
}

- (void)emailLogFile {
    if (![MFMailComposeViewController canSendMail]) {
        alert = [UIAlertController alertControllerWithTitle:@"Can't send mail"
                                                    message:@"Please set up an email account on this phone to send mail"
                                             preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action)
                             {
                                 [self dismissViewControllerAnimated:YES
                                                          completion:nil];
                             }];
        [alert addAction:ok]; // add action to uialertcontroller
        [self presentViewController:alert
                           animated:YES
                         completion:nil];
        return;
    }
    NSData *fileData = [NSData dataWithContentsOfFile:[self getPathToLogFile]];
    
    NSLog(@"%@", fileData);
    
    if (!fileData || [fileData length] == 0)
        return;
    NSString *emailTitle = [NSString stringWithFormat:@"Log File %d", logCount];
    NSString *messageBody = @"Data from SureLock Central";
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody
                isHTML:NO];
    
    // Determine the MIME type
    NSString *mimeType = @"text/plain";
    
    // Add attachment
    [mc addAttachmentData:fileData
                 mimeType:mimeType
                 fileName:[NSString stringWithFormat:@"log%d.csv", logCount]];
    
    // Present mail view controller on screen
    [self presentViewController:mc
                       animated:YES
                     completion:NULL];
}

#pragma mark - MFMailComposeViewControllerDelegate Methods -

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            logCount++;
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            logCount++;
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - BLEManagerDelegate Methods -

- (void)bleManagerDidUpdateStatus:(BLEManager *)manager updateMessage:(NSString *)msg {
    [statusMessage setText:msg];
}

@end

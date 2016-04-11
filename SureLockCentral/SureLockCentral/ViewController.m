//
//  ViewController.m
//  SureLockCentral
//
//  Created by Andrew Titus on 4/4/16.
//  Copyright © 2016 Drew Titus. All rights reserved.
//

#import "ViewController.h"
#import "BLEManager.h"


@interface ViewController ()

@end


@implementation ViewController {
    BLEManager *manager;
}

CGFloat fontSize = 20.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Start up BLE manager
    manager = [[BLEManager alloc] initWithDelegate:self];
    
    // Set up greeting message
    CGRect greetingFrame = CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height * 0.25) - (fontSize / 2.0), [[UIScreen mainScreen] bounds].size.width, fontSize);
    greetingMessage = [[UILabel alloc] initWithFrame:greetingFrame];
    [greetingMessage setText:@"Welcome to SureLock!"];
    [greetingMessage setTextColor:[UIColor whiteColor]];
    [greetingMessage setTextAlignment:NSTextAlignmentCenter];
    [greetingMessage setFont:[UIFont systemFontOfSize:fontSize]];
    [[self view] addSubview:greetingMessage];
    
    // Set up status message
    CGRect statusFrame = CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height * 0.75) - (fontSize / 2.0), [[UIScreen mainScreen] bounds].size.width, fontSize);
    statusMessage = [[UILabel alloc] initWithFrame:statusFrame];
    [statusMessage setText:@"Ready to scan for peripheral locks"];
    [statusMessage setTextColor:[UIColor whiteColor]];
    [statusMessage setTextAlignment:NSTextAlignmentCenter];
    [statusMessage setFont:[UIFont systemFontOfSize:fontSize]];
    [[self view] addSubview:statusMessage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)bleManagerDidUpdateStatus:(BLEManager *)manager updateMessage:(NSString *)msg {
    [statusMessage setText:msg];
}

@end

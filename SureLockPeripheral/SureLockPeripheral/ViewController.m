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

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)lock {
    self.lockLabel.text = @"Locked";
    self.lockLabel.textColor = [UIColor redColor];
}

- (void)unlock {
    self.lockLabel.text = @"Unlocked";
    self.lockLabel.textColor = [UIColor greenColor];
}

@end

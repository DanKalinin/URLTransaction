//
//  ViewController.m
//  App
//
//  Created by Dan Kalinin on 15/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "ViewController.h"
#import <URLTransaction/URLTransaction.h>



@interface ViewController ()

@end



@implementation ViewController

- (IBAction)onLoad:(UIButton *)sender {
    NSURL *appleURL = [NSURL URLWithString:@"https://apple.com"];
    NSURLRequest *appleRequest = [NSURLRequest requestWithURL:appleURL];
    [appleRequest success:^(NSURLRequest *request) {
        NSLog(@"completed - 1");
    }];
    
    NSURL *googleURL = [NSURL URLWithString:@"http://content-server.readyforsky.com/backend"];
    NSURLRequest *googleRequest = [NSURLRequest requestWithURL:googleURL];
    [googleRequest completion:^(NSURLRequest *request) {
        NSLog(@"completed - 2");
    }];
    
    URLTransaction *transaction = [URLTransaction new];
    [[[transaction addRequest:appleRequest] addRequest:googleRequest] resume];
}

@end

//
//  ViewController.m
//  AppInWebview
//
//  Created by Teodor Dermendzhiev on 28.09.21.
//  Copyright © 2021 Progress. All rights reserved.
//

#import "ViewController.h"
#import <NativeScript/NativeScript.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    NSURL *targetURL = [NSURL URLWithString:@"http://google.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [_webview loadRequest:request];
    [_webview.configuration.userContentController addScriptMessageHandler:self name:@"postMessageListener"];
    
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (message.name == @"postMessageListener") {
        [NativeScript runScriptString: message.body];
    }
}


@end

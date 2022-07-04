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

@property (nonatomic, strong) NativeScript* ns;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    Config* config = [[Config alloc] init];
    config.IsDebug = true;
    config.LogToSystemConsole = true;
//    config.BaseDir = @".";
//    config.ArgumentsCount = argc;
//    config.Arguments = argv;

//        [NativeScript initialize:config];
    _ns = [[NativeScript alloc] initWithConfig: config];
    
    [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(messagePosted:)
            name:@"ns-message-posted"
            object:nil];
    
    _webview.navigationDelegate = self;
//    NSURL *targetURL = [NSURL URLWithString:@"https://www.google.com"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
//    [_webview loadRequest:request];
//
    [_webview.configuration.userContentController addScriptMessageHandler:self name:@"executor"];
    [_webview.configuration.userContentController addScriptMessageHandler:self name:@"terminator"];
    [_webview.configuration.userContentController addScriptMessageHandler:self name:@"postMessageListener"];
    
    [_ns runScriptString:@"console.log('Hello from NativeScript')" runLoop:false];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    URLTextFieldViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"url-textfield"];
    vc.urlLoader = self;

    [self presentViewController:vc animated:YES completion:^{}];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if (message.name == @"executor") {
        [_ns runScriptString:message.body runLoop:false];
    }
    
    if (message.name == @"postMessageListener") {
        NSString* scr = [NSString stringWithFormat:@"onmessage(%@)", message.body];
        [_ns runScriptString:scr runLoop:false];
    }
}

- (void) messagePosted:(NSNotification*)notification {
    if ([notification.object isKindOfClass:[NSString class]]) {
        [_webview evaluateJavaScript:[NSString stringWithFormat:@"onNativeMessage(%@)", notification.object] completionHandler:NULL];
    }

}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [_webview evaluateJavaScript:[self getWorkerScript] completionHandler:^(id _Nullable res, NSError * _Nullable error) {
        if (error) {
            NSLog([error debugDescription]);
        }
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
        removeObserver:self];
}

-(NSString*) getWorkerScript {
    return @"class NSWorker {\r\n\r\n    constructor(script) {\r\n        this.script = script;\r\n        this.onerror = null;\r\n        this.onmessage = null;\r\n        this.onmessageerror = null;\r\n        this.execute();\r\n    }\r\n\r\n    postMessage(msg) {\r\n        if (window && window.webkit) {\r\n            window.webkit.messageHandlers.postMessageListener.postMessage(msg);\r\n        } else {\r\n            console.log(\"No webkit\")\r\n        }\r\n    }\r\n\r\n    execute() {\r\n        if (window && window.webkit) {\r\n            window.webkit.messageHandlers.executor.postMessage(this.script);\r\n        } else {\r\n            console.log(\"No webkit\")\r\n        }\r\n    }\r\n\r\n    terminate() {\r\n        if (window && window.webkit) {\r\n            window.webkit.messageHandlers.terminator.postMessage(this.script);\r\n        } else {\r\n            console.log(\"No webkit\")\r\n        }\r\n    }\r\n\r\n}\r\n\r\nlet onNativeMessage = function(msg) {\r\n    console.log(\"Message from native: \" + msg)\r\n}";
}

- (void)loadURL:(NSString *)urlString {
//    NSURL *targetURL = [NSURL URLWithString:@"https://angular-button-habmnm.stackblitz.io"];
    NSURL *targetURL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [_webview loadRequest:request];
}

@end

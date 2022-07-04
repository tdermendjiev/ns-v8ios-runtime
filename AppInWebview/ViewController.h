//
//  ViewController.h
//  AppInWebview
//
//  Created by Teodor Dermendzhiev on 28.09.21.
//  Copyright © 2021 Progress. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "URLTextFieldViewController.h"
#import "URLLoader.h""

@interface ViewController : UIViewController <WKScriptMessageHandler, WKNavigationDelegate, URLLoader>
@property (weak, nonatomic) IBOutlet WKWebView *webview;


@end


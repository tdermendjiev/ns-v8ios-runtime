//
//  URLTextFieldViewController.h
//  AppInWebview
//
//  Created by Dermendzhiev, Teodor (external - Project) on 3.07.22.
//  Copyright © 2022 Progress. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLLoader.h"

NS_ASSUME_NONNULL_BEGIN

@interface URLTextFieldViewController : UIViewController

@property (weak) id<URLLoader> urlLoader;

@end

NS_ASSUME_NONNULL_END

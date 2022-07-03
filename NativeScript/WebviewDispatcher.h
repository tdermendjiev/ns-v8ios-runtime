//
//  WebviewDispatcher.h
//  NativeScript
//
//  Created by Teodor Dermendzhiev on 28.09.21.
//  Copyright © 2021 Progress. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebviewDispatcher : NSObject 

+ (id)shared;
- (void) postMessage: (NSString*)msg;

@end

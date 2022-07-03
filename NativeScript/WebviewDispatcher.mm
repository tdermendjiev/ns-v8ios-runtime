//
//  WebviewDispatcher.cpp
//  NativeScript
//
//  Created by Teodor Dermendzhiev on 28.09.21.
//  Copyright © 2021 Progress. All rights reserved.
//

#import "WebviewDispatcher.h"

@implementation WebviewDispatcher


#pragma mark Singleton Methods

+ (id)shared {
    static WebviewDispatcher *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init {
  return self;
}

- (void) postMessage: (NSString*) msg {
    [[NSNotificationCenter defaultCenter]
            postNotificationName:@"ns-message-posted"
            object: msg];
}




@end

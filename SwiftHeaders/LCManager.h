//
//  LCManager.h
//  v8ios
//
//  Created by Teodor Dermendzhiev on 31.05.23.
//  Copyright © 2023 Progress. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCManager
@property (assign) bool isVisible;
-(void)print: (id)params;
+(instancetype)shared;
@end

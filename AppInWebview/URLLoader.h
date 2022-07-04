//
//  URLLoader.h
//  AppInWebview
//
//  Created by Dermendzhiev, Teodor (external - Project) on 4.07.22.
//  Copyright © 2022 Progress. All rights reserved.
//

#ifndef URLLoader_h
#define URLLoader_h

@protocol URLLoader
    -(void)loadURL:(NSString*)urlString;
@end


#endif /* URLLoader_h */

//
//  VoivodaServer.hpp
//  NativeScript
//
//  Created by Dermendzhiev, Teodor (external - Project) on 31.01.22.
//  Copyright © 2022 Progress. All rights reserved.
//

#ifndef VoivodaServer_hpp
#define VoivodaServer_hpp

#include <stdio.h>
#include <functional>
#include <string>
#include <sys/types.h>
#include <dispatch/dispatch.h>

namespace voivoda {

class VoivodaServer {
public:
    static in_port_t Init(std::function<void (std::function<void (std::string)>)> onClientConnected, std::function<void (std::string)> onMessage);
private:
    static void Send(dispatch_io_t channel, dispatch_queue_t queue, std::string message);
};

}

#endif /* VoivodaServer_hpp */

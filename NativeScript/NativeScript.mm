#include <Foundation/Foundation.h>
#include "NativeScript.h"
#include "inspector/JsV8InspectorClient.h"
#include "runtime/RuntimeConfig.h"
#include "runtime/Helpers.h"
#include "runtime/Runtime.h"
#include "runtime/Tasks.h"
#include "VoivodaServer.h"
#include <iostream>

using namespace v8;
using namespace tns;

@implementation Config

@synthesize BaseDir;
@synthesize ApplicationPath;
@synthesize MetadataPtr;
@synthesize IsDebug;

@end


@implementation NativeScript

extern char defaultStartOfMetadataSection __asm("section$start$__DATA$__TNSMetadata");

std::unique_ptr<Runtime> runtime_;


//static void __attribute__((constructor)) initialize(void){
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"==== Code Injection in Action====");
//        
//        in_port_t listenPort = voivoda::VoivodaServer::Init([](std::function<void (std::string)> sender) {
//            //on connected
//        },[&] (std::string message) {
//            std::cout << "Follow this command: " << message;
//            Config* config = [[Config alloc] init];
//            config.IsDebug = true;
//            config.LogToSystemConsole = true;
//            NSString *objcmessage = [NSString stringWithCString:message.c_str()
//                                               encoding:[NSString defaultCStringEncoding]];
////            NSString* script = [NSString stringWithFormat:@"let v = 5; console.log(v);"];
//            NativeScript* _ns = [[NativeScript alloc] initWithConfig: config];
//            try {
//                [_ns runScriptString:objcmessage runLoop:false];
//            } catch (NSError* err) {
//                NSLog(@"%@", [err description]);
//            }
//        });
//        
//        NSLog(@"%d", listenPort);
//    });
//    
//    
//}

- (void)runScriptString: (NSString*) script runLoop: (BOOL) runLoop {

    std::string cppString = std::string([script UTF8String]);
    runtime_->RunScript(cppString);
    
    if (runLoop) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true);
    }


    tns::Tasks::Drain();

}

- (instancetype)initWithConfig:(Config*)config {
    
    if (self = [super init]) {
        if (config.BaseDir != nil) {
            RuntimeConfig.BaseDir = [config.BaseDir UTF8String];
            if (config.ApplicationPath != nil) {
                RuntimeConfig.ApplicationPath = [[config.BaseDir stringByAppendingPathComponent:config.ApplicationPath] UTF8String];
            } else {
                RuntimeConfig.ApplicationPath = [[config.BaseDir stringByAppendingPathComponent:@"app"] UTF8String];
            }
        }
        
        if (config.MetadataPtr != nil) {
            RuntimeConfig.MetadataPtr = [config MetadataPtr];
        } else {
            RuntimeConfig.MetadataPtr = &defaultStartOfMetadataSection;
        }
        
        RuntimeConfig.IsDebug = [config IsDebug];
        RuntimeConfig.LogToSystemConsole = [config LogToSystemConsole];

        Runtime::Initialize();
        runtime_ = std::make_unique<Runtime>();

        std::chrono::high_resolution_clock::time_point t1 = std::chrono::high_resolution_clock::now();
        Isolate* isolate = runtime_->CreateIsolate();
        v8::Locker locker(isolate);
        runtime_->Init(isolate, false);
        std::chrono::high_resolution_clock::time_point t2 = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1).count();
        printf("Runtime initialization took %llims\n", duration);

        if (config.IsDebug) {
            Isolate::Scope isolate_scope(isolate);
            HandleScope handle_scope(isolate);
            v8_inspector::JsV8InspectorClient* inspectorClient = new v8_inspector::JsV8InspectorClient(runtime_.get());
            inspectorClient->init();
            inspectorClient->registerModules();
            inspectorClient->connect([config ArgumentsCount], [config Arguments]);
        }
    }
    
    return self;
    
}

- (void)runMainApplication {
    runtime_->RunMainScript();

    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true);

    tns::Tasks::Drain();
}

- (bool)liveSync {
    if (runtime_ == nullptr) {
        return false;
    }

    Isolate* isolate = runtime_->GetIsolate();
    return tns::LiveSync(isolate);
}

@end

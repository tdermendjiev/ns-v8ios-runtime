#import <NativeScript/NativeScript.h>

extern char startOfMetadataSection __asm("section$start$__DATA$__TNSMetadata");
extern char startOfSwiftMetadataSection __asm("section$start$__DATA$__SwiftMetadata");

int main(int argc, char *argv[]) {
    @autoreleasepool {
        void* metadataPtr = &startOfMetadataSection;
        void* swiftMetadataPtr = &startOfSwiftMetadataSection;

        NSString* baseDir = [[NSBundle mainBundle] resourcePath];

        bool isDebug =
#ifdef DEBUG
            true;
#else
            false;
#endif

        Config* config = [[Config alloc] init];
        config.IsDebug = isDebug;
        config.LogToSystemConsole = YES;
        config.MetadataPtr = metadataPtr;
        config.SwiftMetadataPtr = swiftMetadataPtr;
        config.BaseDir = baseDir;
        config.ArgumentsCount = argc;
        config.Arguments = argv;

        [NativeScript start:config];

        return 0;
    }
}

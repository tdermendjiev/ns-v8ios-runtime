#ifndef MetadataBuilder_h
#define MetadataBuilder_h

#include "libffi.h"
#include "Common.h"
#include "Metadata.h"
#include "ClassBuilder.h"
#include "DataWrapper.h"

namespace tns {

class MetadataBuilder {
public:
    static void RegisterConstantsOnGlobalObject(v8::Isolate* isolate, v8::Local<v8::ObjectTemplate> global, bool isWorkerThread);
    static v8::Local<v8::FunctionTemplate> GetOrCreateConstructorFunctionTemplate(v8::Isolate* isolate, const BaseClassMeta* meta);
    static v8::Local<v8::Function> GetOrCreateStructCtorFunction(v8::Isolate* isolate, StructInfo structInfo);
    static void StructPropertyGetterCallback(v8::Local<v8::Name> property, const v8::PropertyCallbackInfo<v8::Value>& info);
    static void StructPropertySetterCallback(v8::Local<v8::Name> property, v8::Local<v8::Value> value, const v8::PropertyCallbackInfo<v8::Value>& info);
    static v8::Persistent<v8::Function>* CreateToStringFunction(v8::Isolate* isolate);
private:
    static void ClassConstructorCallback(const v8::FunctionCallbackInfo<v8::Value>& info);
    static void AllocCallback(const v8::FunctionCallbackInfo<v8::Value>& info);
    static void MethodCallback(const v8::FunctionCallbackInfo<v8::Value>& info);
    static void CFunctionCallback(const v8::FunctionCallbackInfo<v8::Value>& info);
    static void PropertyGetterCallback(const v8::FunctionCallbackInfo<v8::Value>& info);
    static void PropertySetterCallback(const v8::FunctionCallbackInfo<v8::Value>& info);
    static void PropertyNameGetterCallback(v8::Local<v8::Name> name, const v8::PropertyCallbackInfo<v8::Value> &info);
    static void PropertyNameSetterCallback(v8::Local<v8::Name> name, v8::Local<v8::Value> value, const v8::PropertyCallbackInfo<void> &info);
    static void StructConstructorCallback(const v8::FunctionCallbackInfo<v8::Value>& info);
    static void StructEqualsCallback(const v8::FunctionCallbackInfo<v8::Value>& info);
    static void ToStringFunctionCallback(const v8::FunctionCallbackInfo<v8::Value>& info);
    static std::pair<ffi_type*, void*> GetStructData(v8::Isolate* isolate, v8::Local<v8::Object> initializer, StructInfo structInfo);

    static v8::Local<v8::Value> InvokeMethod(v8::Isolate* isolate, const MethodMeta* meta, v8::Local<v8::Object> receiver, const std::vector<v8::Local<v8::Value>> args, std::string containingClass, bool isMethodCallback);
    static void RegisterAllocMethod(v8::Isolate* isolate, v8::Local<v8::Function> ctorFunc, const InterfaceMeta* interfaceMeta);
    static void RegisterInstanceMethods(v8::Isolate* isolate, v8::Local<v8::FunctionTemplate> ctorFuncTemplate, const BaseClassMeta* meta, std::vector<std::string>& names);
    static void RegisterInstanceProperties(v8::Isolate* isolate, v8::Local<v8::FunctionTemplate> ctorFuncTemplate, const BaseClassMeta* meta, std::string className, std::vector<std::string>& names);
    static void RegisterInstanceProtocols(v8::Isolate* isolate, v8::Local<v8::FunctionTemplate> ctorFuncTemplate, const BaseClassMeta* meta, std::string className, std::vector<std::string>& names);
    static void RegisterStaticMethods(v8::Isolate* isolate, v8::Local<v8::Function> ctorFunc, const BaseClassMeta* meta, std::vector<std::string>& names);
    static void RegisterStaticProperties(v8::Isolate* isolate, v8::Local<v8::Function> ctorFunc, const BaseClassMeta* meta, const std::string className, std::vector<std::string>& names);
    static void RegisterStaticProtocols(v8::Isolate* isolate, v8::Local<v8::Function> ctorFunc, const BaseClassMeta* meta, const std::string className, std::vector<std::string>& names);
    static void DefineFunctionLengthProperty(v8::Local<v8::Context> context, const TypeEncodingsList<ArrayCount>* encodings, v8::Local<v8::Function> func);

    struct GlobalHandlerContext {
        GlobalHandlerContext(bool isWorkerThread): isWorkerThread_(isWorkerThread) {
        }
        bool isWorkerThread_;
    };

    template<class T>
    struct CacheItem {
        CacheItem(const T* meta, const std::string className)
        : meta_(meta),
          className_(className) {
            static_assert(std::is_base_of<Meta, T>::value, "Derived not derived from Meta");
        }
        const T* meta_;
        const std::string className_;
    };

    struct TaskContext {
    public:
        TaskContext(v8::Isolate* isolate, const FunctionMeta* meta, std::vector<v8::Persistent<v8::Value>*> args): isolate_(isolate), meta_(meta), args_(args) {}
        v8::Isolate* isolate_;
        const FunctionMeta* meta_;
        std::vector<v8::Persistent<v8::Value>*> args_;
    };
};

}

#endif /* MetadataBuilder_h */
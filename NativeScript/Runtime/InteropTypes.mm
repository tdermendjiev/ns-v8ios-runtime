#include <Foundation/Foundation.h>
#include "SymbolLoader.h"
#include "Interop.h"
#include "ArgConverter.h"
#include "Helpers.h"
#include "FunctionReference.h"
#include "Reference.h"
#include "Pointer.h"

using namespace v8;

namespace tns {

void Interop::RegisterInteropTypes(Isolate* isolate) {
    Local<Context> context = isolate->GetCurrentContext();
    Local<Object> global = context->Global();

    Local<Object> interop = Object::New(isolate);
    Local<Object> types = Object::New(isolate);

    Reference::Register(isolate, interop);
    Pointer::Register(isolate, interop);
    FunctionReference::Register(isolate, interop);
    RegisterBufferFromDataFunction(isolate, interop);
    RegisterHandleOfFunction(isolate, interop);
    RegisterAllocFunction(isolate, interop);
    RegisterSizeOfFunction(isolate, interop);

    RegisterInteropType(isolate, types, "void", new PrimitiveDataWrapper(sizeof(ffi_type_void.size), BinaryTypeEncodingType::VoidEncoding));
    RegisterInteropType(isolate, types, "bool", new PrimitiveDataWrapper(sizeof(bool), BinaryTypeEncodingType::BoolEncoding));

    bool success = interop->Set(tns::ToV8String(isolate, "types"), types);
    assert(success);

    success = global->Set(tns::ToV8String(isolate, "interop"), interop);
    assert(success);
}

void Interop::RegisterInteropType(Isolate* isolate, Local<Object> types, std::string name, PrimitiveDataWrapper* wrapper) {
    Local<Context> context = isolate->GetCurrentContext();
    Local<Object> obj = ArgConverter::CreateEmptyObject(context);
    tns::SetValue(isolate, obj, wrapper);
    bool success = types->Set(tns::ToV8String(isolate, name), obj);
    assert(success);
}

void Interop::RegisterBufferFromDataFunction(v8::Isolate* isolate, v8::Local<v8::Object> interop) {
    Local<Context> context = isolate->GetCurrentContext();
    Local<v8::Function> func;
    bool success = v8::Function::New(context, [](const FunctionCallbackInfo<Value>& info) {
        assert(info.Length() == 1 && info[0]->IsObject());
        Local<Object> arg = info[0].As<Object>();
        assert(arg->InternalFieldCount() > 0 && arg->GetInternalField(0)->IsExternal());

        Local<External> ext = arg->GetInternalField(0).As<External>();
        ObjCDataWrapper* wrapper = static_cast<ObjCDataWrapper*>(ext->Value());

        id obj = wrapper->Data();
        assert([obj isKindOfClass:[NSData class]]);

        Isolate* isolate = info.GetIsolate();
        size_t length = [obj length];
        void* data = const_cast<void*>([obj bytes]);

        Local<ArrayBuffer> result = ArrayBuffer::New(isolate, data, length);
        info.GetReturnValue().Set(result);
    }).ToLocal(&func);
    assert(success);

    interop->Set(tns::ToV8String(isolate, "bufferFromData"), func);
}

void Interop::RegisterHandleOfFunction(Isolate* isolate, Local<Object> interop) {
    Local<Context> context = isolate->GetCurrentContext();
    Local<v8::Function> func;
    bool success = v8::Function::New(context, [](const FunctionCallbackInfo<Value>& info) {
        assert(info.Length() == 1);

        Isolate* isolate = info.GetIsolate();
        Local<Value> arg = info[0];

        void* handle = nullptr;
        bool hasHandle = false;

        if (!arg->IsNullOrUndefined()) {
            if (arg->IsArrayBuffer()) {
                Local<ArrayBuffer> buffer = arg.As<ArrayBuffer>();
                ArrayBuffer::Contents contents = buffer->GetContents();
                handle = contents.Data();
                hasHandle = true;
            } else if (arg->IsArrayBufferView()) {
                Local<ArrayBufferView> bufferView = arg.As<ArrayBufferView>();
                ArrayBuffer::Contents contents = bufferView->Buffer()->GetContents();
                handle = contents.Data();
                hasHandle = true;
            } else if (arg->IsObject()) {
                Local<Object> obj = arg.As<Object>();
                if (BaseDataWrapper* wrapper = tns::GetValue(isolate, obj)) {
                    switch (wrapper->Type()) {
                        case WrapperType::ObjCClass: {
                            ObjCClassWrapper* cw = static_cast<ObjCClassWrapper*>(wrapper);
                            @autoreleasepool {
                                CFTypeRef ref = CFBridgingRetain(cw->Klass());
                                handle = const_cast<void*>(ref);
                                CFRelease(ref);
                                hasHandle = true;
                            }
                            break;
                        }
                        case WrapperType::ObjCProtocol: {
                            ObjCProtocolWrapper* pw = static_cast<ObjCProtocolWrapper*>(wrapper);
                            CFTypeRef ref = CFBridgingRetain(pw->Proto());
                            handle = const_cast<void*>(ref);
                            CFRelease(ref);
                            hasHandle = true;
                            break;
                        }
                        case WrapperType::ObjCObject: {
                            ObjCDataWrapper* w = static_cast<ObjCDataWrapper*>(wrapper);
                            @autoreleasepool {
                                id target = w->Data();
                                CFTypeRef ref = CFBridgingRetain(target);
                                handle = const_cast<void*>(ref);
                                hasHandle = true;
                                CFRelease(ref);
                            }
                            break;
                        }
                        case WrapperType::Struct: {
                            StructWrapper* w = static_cast<StructWrapper*>(wrapper);
                            handle = w->Data();
                            hasHandle = true;
                            break;
                        }
                        case WrapperType::Reference: {
                            ReferenceWrapper* w = static_cast<ReferenceWrapper*>(wrapper);
                            if (w->Data() != nullptr) {
                                handle = w->Data();
                                hasHandle = true;
                            }
                            break;
                        }
                        case WrapperType::Pointer: {
                            PointerWrapper* w = static_cast<PointerWrapper*>(wrapper);
                            handle = w->Data();
                            hasHandle = true;
                            break;
                        }
                        case WrapperType::Function: {
                            FunctionWrapper* w = static_cast<FunctionWrapper*>(wrapper);
                            const FunctionMeta* meta = w->Meta();
                            handle = SymbolLoader::instance().loadFunctionSymbol(meta->topLevelModule(), meta->name());
                            hasHandle = true;
                            break;
                        }
                        case WrapperType::FunctionReference: {
                            FunctionReferenceWrapper* w = static_cast<FunctionReferenceWrapper*>(wrapper);
                            if (w->Data() != nullptr) {
                                handle = w->Data();
                                hasHandle = true;
                            }
                            break;
                        }
                        case WrapperType::Block: {
                            BlockWrapper* blockWrapper = static_cast<BlockWrapper*>(wrapper);
                            handle = blockWrapper->Block();
                            hasHandle = true;
                            break;
                        }

                        default:
                            break;
                    }
                }
            }
        } else if (arg->IsNull()) {
            hasHandle = true;
        }

        if (!hasHandle) {
            // TODO: throw a javascript exception for an unknown type
            assert(false);
        }

        if (handle == nullptr) {
            info.GetReturnValue().Set(Null(isolate));
            return;
        }

        Local<Value> pointerInstance = Pointer::NewInstance(isolate, handle);
        info.GetReturnValue().Set(pointerInstance);
    }).ToLocal(&func);
    assert(success);

    interop->Set(tns::ToV8String(isolate, "handleof"), func);
}

void Interop::RegisterAllocFunction(Isolate* isolate, Local<Object> interop) {
    Local<Context> context = isolate->GetCurrentContext();
    Local<v8::Function> func;
    bool success = v8::Function::New(context, [](const FunctionCallbackInfo<Value>& info) {
        assert(info.Length() == 1);
        assert(tns::IsNumber(info[0]));

        Isolate* isolate = info.GetIsolate();
        Local<Context> context = isolate->GetCurrentContext();
        Local<Number> arg = info[0].As<Number>();
        int32_t value;
        assert(arg->Int32Value(context).To(&value));

        size_t size = static_cast<size_t>(value);

        void* data = calloc(size, 1);

        Local<Value> pointerInstance = Pointer::NewInstance(isolate, data);
        PointerWrapper* wrapper = static_cast<PointerWrapper*>(pointerInstance.As<Object>()->GetInternalField(0).As<External>()->Value());
        wrapper->SetAdopted(true);
        info.GetReturnValue().Set(pointerInstance);
    }).ToLocal(&func);
    assert(success);

    interop->Set(tns::ToV8String(isolate, "alloc"), func);
}

void Interop::RegisterSizeOfFunction(Isolate* isolate, Local<Object> interop) {
    Local<Context> context = isolate->GetCurrentContext();
    Local<v8::Function> func;
    bool success = v8::Function::New(context, [](const FunctionCallbackInfo<Value>& info) {
        assert(info.Length() == 1);
        Local<Value> arg = info[0];
        Isolate* isolate = info.GetIsolate();
        size_t size = 0;

        if (!arg->IsNullOrUndefined()) {
            if (arg->IsObject()) {
                Local<Object> obj = arg.As<Object>();
                if (BaseDataWrapper* wrapper = tns::GetValue(isolate, obj)) {
                    switch (wrapper->Type()) {
                        case WrapperType::ObjCClass:
                        case WrapperType::ObjCProtocol:
                        case WrapperType::ObjCObject:
                        case WrapperType::PointerType:
                        case WrapperType::Pointer:
                        case WrapperType::Reference:
                        case WrapperType::ReferenceType:
                        case WrapperType::Block:
                        case WrapperType::FunctionReference:
                        case WrapperType::FunctionReferenceType:
                        case WrapperType::Function: {
                            size = sizeof(void*);
                            break;
                        }
                        case WrapperType::Struct: {
                            StructWrapper* sw = static_cast<StructWrapper*>(wrapper);
                            size = sw->FFIType()->size;
                            break;
                        }
                        case WrapperType::StructType: {
                            StructTypeWrapper* sw = static_cast<StructTypeWrapper*>(wrapper);
                            const StructMeta* structMeta = sw->Meta();
                            std::vector<StructField> fields;
                            ffi_type* ffiType = FFICall::GetStructFFIType(structMeta, fields);
                            size = ffiType->size;
                            break;
                        }
                        default:
                            break;
                    }
                }
            }
        }

        info.GetReturnValue().Set(Number::New(isolate, size));
    }).ToLocal(&func);
    assert(success);

    interop->Set(tns::ToV8String(isolate, "sizeof"), func);
}

}
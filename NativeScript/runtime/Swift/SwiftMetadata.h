//
//  SwiftMetadata.h
//  NativeScript
//
//  Created by Teodor Dermendzhiev on 2.02.21.
//  Copyright © 2021 Progress. All rights reserved.
//

#ifndef SwiftMetadata_h
#define SwiftMetadata_h
#include "Metadata.h"

namespace tns {

// Bit indices in flags section
enum SwiftMetaFlags {
    HasMangledName = 8
};

enum SwiftMetaType {
    SwiftUndefined = 0,
    SwiftStruct = 1,
    SwiftFunction = 2
};

enum SwiftBinaryTypeEncodingType : uint8_t {
    SwiftVoidEncoding,
    SwiftBoolEncoding,
    SwiftIntEncoding,
    SwiftInstanceTypeEncoding
};

#pragma pack(push, 1)

template <typename T>
struct SwiftPtrTo;
struct SwiftMeta;
struct SwiftInterfaceMeta;
struct SwiftProtocolMeta;
struct SwiftTypeEncoding;

template <typename T>
using ArrayOfSwiftPtrTo = Array<SwiftPtrTo<T>>;
using SwiftString = SwiftPtrTo<char>;

template <GlobalTableType TYPE>
struct SwiftGlobalTable {
    class iterator {
    private:
        const SwiftGlobalTable<TYPE>* _globalTable;
        int _topLevelIndex;
        int _bucketIndex;

        void findNext();

        const SwiftMeta* getCurrent();

    public:
        iterator(const SwiftGlobalTable<TYPE>* globalTable)
            : iterator(globalTable, 0, 0) {
            findNext();
        }

        iterator(const SwiftGlobalTable<TYPE>* globalTable, int32_t topLevelIndex, int32_t bucketIndex)
            : _globalTable(globalTable)
            , _topLevelIndex(topLevelIndex)
            , _bucketIndex(bucketIndex) {
            findNext();
        }

        bool operator==(const iterator& other) const;

        bool operator!=(const iterator& other) const;

        iterator& operator++();

        iterator operator++(int) {
            iterator tmp(_globalTable, _topLevelIndex, _bucketIndex);
            operator++();
            return tmp;
        }

        const SwiftMeta* operator*();
        
    };

    iterator begin() const {
        return iterator(this);
    }

    iterator end() const {
        return iterator(this, this->buckets.count, 0);
    }
    
    static bool compareName(const SwiftMeta& meta, const char* identifierString, size_t length);

    ArrayOfSwiftPtrTo<ArrayOfSwiftPtrTo<SwiftMeta>> buckets;

//    const InterfaceMeta* findInterfaceMeta(const char* identifierString) const;
//
//    const InterfaceMeta* findInterfaceMeta(const char* identifierString, size_t length, unsigned hash) const;
//
//    const ProtocolMeta* findProtocol(const char* identifierString) const;
//
//    const ProtocolMeta* findProtocol(const char* identifierString, size_t length, unsigned hash) const;

    const SwiftMeta* findMeta(const char* identifierString, bool onlyIfAvailable = true) const;

    const SwiftMeta* findMeta(const char* identifierString, size_t length, unsigned hash, bool onlyIfAvailable = true) const;

    int sizeInBytes() const {
        return buckets.sizeInBytes();
    }
};

struct SwiftMetaFile {
private:
    SwiftGlobalTable<GlobalTableType::ByJsName> _globalTableJs;
    
public:
    static SwiftMetaFile* instance();
    
    static SwiftMetaFile* setInstance(void* metadataPtr);
    
    const SwiftGlobalTable<GlobalTableType::ByJsName>* globalTableJs() const {
        return &this->_globalTableJs;
    }
    
    const SwiftGlobalTable<GlobalTableType::ByNativeName>* globalTableNativeProtocols() const {
        const SwiftGlobalTable<GlobalTableType::ByJsName>* gt = this->globalTableJs();
        return reinterpret_cast<const SwiftGlobalTable<GlobalTableType::ByNativeName>*>(offset(gt, gt->sizeInBytes()));
    }

    const SwiftGlobalTable<GlobalTableType::ByNativeName>* globalTableNativeInterfaces() const {
        const SwiftGlobalTable<GlobalTableType::ByNativeName>* gt = this->globalTableNativeProtocols();
        return reinterpret_cast<const SwiftGlobalTable<GlobalTableType::ByNativeName>*>(offset(gt, gt->sizeInBytes()));
    }
    
    const ModuleTable* topLevelModulesTable() const {
        const SwiftGlobalTable<GlobalTableType::ByNativeName>* gt = this->globalTableNativeInterfaces();
        return reinterpret_cast<const ModuleTable*>(offset(gt, gt->sizeInBytes()));
    }

    const void* heap() const {
        const ModuleTable* mt = this->topLevelModulesTable();
        const void* heap = offset(mt, mt->sizeInBytes());
        return heap;
    }
    
};

template <typename T>
struct SwiftPtrTo {
    int32_t offset;

    bool isNull() const {
        return offset == 0;
    }
    SwiftPtrTo<T> operator+(int value) const {
        return add(value);
    }
    const T* operator->() const {
        return valuePtr();
    }
    SwiftPtrTo<T> add(int value) const {
        return SwiftPtrTo<T>{ .offset = this->offset + value * sizeof(T) };
    }
    SwiftPtrTo<T> addBytes(int bytes) const {
        return SwiftPtrTo<T>{ .offset = this->offset + bytes };
    }
    template <typename V>
    SwiftPtrTo<V>& castTo() const {
        return reinterpret_cast<SwiftPtrTo<V>>(this);
    }
    const T* valuePtr() const {
        return isNull() ? nullptr : reinterpret_cast<const T*>(tns::offset(SwiftMetaFile::instance()->heap(), this->offset));
    }
    const T& value() const {
        return *valuePtr();
    }
    
};

enum SwiftNameIndex {
    SwiftJsName,
    SwiftName,
    MangledName,
    SwiftNameIndexCount,
};

struct SwiftJsNameAndNativeNames {
    SwiftString strings[SwiftNameIndexCount];
};

union SwiftMetaNames {
    SwiftString name;
    SwiftPtrTo<SwiftJsNameAndNativeNames> names;
};

template <typename T>
struct SwiftTypeEncodingsList {
    T count;

    const SwiftTypeEncoding* first() const {
        return reinterpret_cast<const SwiftTypeEncoding*>(this + 1);
    }
};

union SwiftTypeEncodingDetails {
    struct IdDetails {
        SwiftPtrTo<Array<SwiftString>> _protocols;
    } idDetails;
    struct PointerDetails {
        const SwiftTypeEncoding* getInnerType() const {
            return reinterpret_cast<const SwiftTypeEncoding*>(this);
        }
    } pointer;
    struct FunctionPointerDetails {
        SwiftTypeEncodingsList<uint8_t> signature;
    } functionPointer;
};

struct SwiftTypeEncoding {
    SwiftBinaryTypeEncodingType type;
    SwiftTypeEncodingDetails details;

    const SwiftTypeEncoding* next() const {
        const SwiftTypeEncoding* afterTypePtr = reinterpret_cast<const SwiftTypeEncoding*>(offset(this, sizeof(type)));

        switch (this->type) {
//        case SwiftBinaryTypeEncodingType::PointerEncoding: {
//            return this->details.pointer.getInnerType()->next();
//        }
//        case SwiftBinaryTypeEncodingType::FunctionPointerEncoding: {
//            const SwiftTypeEncoding* current = this->details.functionPointer.signature.first();
//            for (int i = 0; i < this->details.functionPointer.signature.count; i++) {
//                current = current->next();
//            }
//            return current;
//        }
        default: {
            return afterTypePtr;
        }
        }
    }
};


struct SwiftMeta {

    SwiftMetaNames _names;
    SwiftPtrTo<ModuleMeta> _topLevelModule;
    uint16_t _flags;
    
    
//    SwiftMeta(SwiftMetaNames names, SwiftPtrTo<ModuleMeta> m, uint16_t flags){
//        _names = names;
//        _topLevelModule = m;
//        _flags = flags;
//    }
public:
    SwiftMetaType type() const {
        SwiftMetaType type = (SwiftMetaType)(this->_flags & MetaTypeMask);
        return type;
    }
    
    bool hasName() const {
        return this->flag(MetaFlags::HasName);
    }

    bool hasMangledName() const {
        return this->flag(SwiftMetaFlags::HasMangledName);
    }

    const ModuleMeta* topLevelModule() const {
        return this->_topLevelModule.valuePtr();
    }
    
    bool flag(int index) const {
        return (this->_flags & (1 << index)) > 0;
    }
    
    const char* jsName() const {
        return this->getNameByIndex(SwiftJsName);
    }

    const char* name() const {
        return this->getNameByIndex(SwiftName);
    }
    
    const char* mangledName() const {
        return this->getNameByIndex(MangledName);
    }
    
private:
    const char* getNameByIndex(enum SwiftNameIndex index) const {
        int i = index;
        if (!this->hasName() && !this->hasMangledName()) {
            return this->_names.name.valuePtr();
        }

        if (!this->hasMangledName() && i >= DemangledName) {
            i--;
        }

        if (!this->hasName() && i >= Name) {
            i--;
        }

        return this->_names.names.value().strings[i].valuePtr();
////        int i = index;
//
//        return this->_names.name.swiftValuePtr();
////        return this->_names.names.value().strings[i].valuePtr();
    }
};

template <>
struct SwiftPtrTo<ArrayOfSwiftPtrTo<SwiftMeta>> {
    int32_t offset;

    bool isNull() const {
        return offset == 0;
    }
//    PtrTo<ArrayOfPtrTo<SwiftMeta>> operator+(int value) const {
//        return add(value);
//    }
    const ArrayOfSwiftPtrTo<SwiftMeta>* operator->() const {
        return valuePtr();
    }
//    PtrTo<ArrayOfPtrTo<SwiftMeta>> add(int value) const {
//        return PtrTo<SwiftMeta>{ .offset = static_cast<int32_t>(this->offset + value * sizeof(ArrayOfPtrTo<SwiftMeta>)) };
//    }
//    PtrTo<ArrayOfPtrTo<SwiftMeta>> addBytes(int bytes) const {
//        return PtrTo<ArrayOfPtrTo<SwiftMeta>>{ .offset = this->offset + bytes };
//    }
    template <typename V>
    SwiftPtrTo<V>& castTo() const {
        return reinterpret_cast<SwiftPtrTo<V>>(this);
    }
    const ArrayOfSwiftPtrTo<SwiftMeta>* valuePtr() const {
        return isNull() ? nullptr : reinterpret_cast<const ArrayOfSwiftPtrTo<SwiftMeta>*>(tns::offset(SwiftMetaFile::instance()->heap(), this->offset));
    }
    const ArrayOfSwiftPtrTo<SwiftMeta>& value() const {
        return *valuePtr();
    }
};

template <>
struct SwiftPtrTo<SwiftMeta> {
    int32_t offset;

    bool isNull() const {
        return offset == 0;
    }
    SwiftPtrTo<SwiftMeta> operator+(int value) const {
        return add(value);
    }
    const SwiftMeta* operator->() const {
        return valuePtr();
    }
    SwiftPtrTo<SwiftMeta> add(int value) const {
        return SwiftPtrTo<SwiftMeta>{ .offset = static_cast<int32_t>(this->offset + value * sizeof(SwiftMeta)) };
    }
    SwiftPtrTo<SwiftMeta> addBytes(int bytes) const {
        return SwiftPtrTo<SwiftMeta>{ .offset = this->offset + bytes };
    }
    template <typename V>
    SwiftPtrTo<V>& castTo() const {
        return reinterpret_cast<SwiftPtrTo<V>>(this);
    }
    const SwiftMeta* valuePtr() const {
        if (isNull()) {
            return nullptr;
        } else {
            auto offset = this->offset;
            
            auto meta = reinterpret_cast<const SwiftMeta*>(tns::offset(SwiftMetaFile::instance()->heap(), offset));
            return meta;
        }
    }
    const SwiftMeta& value() const {
        return *valuePtr();
    }
};

struct SwiftFunctionMeta : SwiftMeta {
private:
    SwiftPtrTo<SwiftTypeEncodingsList<ArrayCount>> _encoding;

public:

    const SwiftTypeEncodingsList<ArrayCount>* encodings() const {
     
        return _encoding.valuePtr();
    }

};

#pragma pack(pop)

}


#endif /* SwiftMetadata_h */

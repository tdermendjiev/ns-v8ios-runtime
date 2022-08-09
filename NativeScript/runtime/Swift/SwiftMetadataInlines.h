#ifndef SwiftMetadataInlines_h
#define SwiftMetadataInlines_h

#include <objc/runtime.h>
#include "StringHasher.h"
#include "SwiftMetadata.h"
#include "MetadataInlines.h"
#inlcude "Metadata.h"

namespace tns {
// GlobalTable

template <GlobalTableType TYPE>
const SwiftClassMeta* GlobalTable<TYPE>::findSwiftClassMeta(const char* identifierString) const {
    unsigned hash = WTF::StringHasher::computeHashAndMaskTop8Bits<LChar>(reinterpret_cast<const LChar*>(identifierString));
    return this->findSwiftClassMeta(identifierString, strlen(identifierString), hash);
}

template <GlobalTableType TYPE>
const SwiftClassMeta* GlobalTable<TYPE>::findSwiftClassMeta(const char* identifierString, size_t length, unsigned hash) const {
    const SwiftMeta* meta = this->findMeta(identifierString, length, hash, /*onlyIfAvailable*/ false);
    if (meta == nullptr) {
        return nullptr;
    }

    // Meta should be an interface, but it could also be a protocol in case of a
    // private interface having the same name as a public protocol
    assert(meta->type() == SwiftMetaType::SwiftClass || (meta->type() == SwiftMetaType::SwiftProtocol);

    if (meta->type() != SwiftMetaType::SwiftClass) {
        return nullptr;
    }

    const SwiftClassMeta* classMeta = static_cast<const SwiftClassMeta*>(meta);
    if (classMeta->isAvailable()) {
        return classMeta;
    } else {
        const char* baseName = classMeta->baseName();

        tns::LogMetadataUnavailable(
            std::string(identifierString, length).c_str(),
            getMajorVersion(classMeta->introducedIn()),
            getMinorVersion(classMeta->introducedIn()),
            baseName
        );

        return this->findSwiftClassMeta(baseName);
    }
}

}

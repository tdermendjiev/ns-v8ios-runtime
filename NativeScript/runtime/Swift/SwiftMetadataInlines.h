#ifndef SwiftMetadataInlines_h
#define SwiftMetadataInlines_h


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
//    assert(meta->type() == SwiftMetaType::SwiftClass || (meta->type() == SwiftMetaType::SwiftProtocol);

    if (meta->type() != SwiftMetaType::SwiftClass) {
        return nullptr;
    }

   // const SwiftClassMeta* classMeta = static_cast<const SwiftClassMeta*>(meta);
//    if (classMeta->isAvailable()) {
//        return classMeta;
//    } else {
//        const char* baseName = classMeta->baseName();
//
//        tns::LogMetadataUnavailable(
//            std::string(identifierString, length).c_str(),
//            getMajorVersion(classMeta->introducedIn()),
//            getMinorVersion(classMeta->introducedIn()),
//            baseName
//        );
//
//        return this->findSwiftClassMeta(baseName);
//    }
}

template <GlobalTableType TYPE>
const SwiftMeta* SwiftGlobalTable<TYPE>::findMeta(const char* identifierString, bool onlyIfAvailable) const {
    unsigned hash = WTF::StringHasher::computeHashAndMaskTop8Bits<LChar>(reinterpret_cast<const LChar*>(identifierString));
    return this->findMeta(identifierString, strlen(identifierString), hash, onlyIfAvailable);
}

template <GlobalTableType TYPE>
const SwiftMeta* SwiftGlobalTable<TYPE>::findMeta(const char* identifierString, size_t length, unsigned hash, bool onlyIfAvailable) const {
    int bucketIndex = hash % buckets.count;
    if (this->buckets[bucketIndex].isNull()) {
        return nullptr;
    }
//    const SwiftMeta* meta = buckets[bucketIndex].valuePtr();
//    if (this->compareName(*meta, identifierString, length)) {
//        return meta;
//    }
    const ArrayOfSwiftPtrTo<SwiftMeta>& bucketContent = buckets[bucketIndex].value();
    for (ArrayOfSwiftPtrTo<SwiftMeta>::iterator it = bucketContent.begin(); it != bucketContent.end(); it++) {
        const SwiftMeta* meta = (*it).valuePtr();
        if (this->compareName(*meta, identifierString, length)) {
            return meta;
        }
    }
    return nullptr;
}

template <>
inline bool SwiftGlobalTable<ByJsName>::compareName(const SwiftMeta& meta, const char* identifierString, size_t length) {
    return compareIdentifiers(meta.jsName(), identifierString, length) == 0;
}

template <GlobalTableType TYPE>
void SwiftGlobalTable<TYPE>::iterator::findNext() {
    if (this->_topLevelIndex == this->_globalTable->buckets.count) {
        return;
    }

    do {
        if (!this->_globalTable->buckets[_topLevelIndex].isNull()) {
            int bucketLength = this->_globalTable->buckets[_topLevelIndex].value().count;
            while (this->_bucketIndex < bucketLength) {
                if (this->getCurrent() != nullptr) {
                    return;
                }
                this->_bucketIndex++;
            }
        }
        this->_bucketIndex = 0;
        this->_topLevelIndex++;
    } while (this->_topLevelIndex < this->_globalTable->buckets.count);
}


} // namespace tns

#endif /* SwiftMetadataInlines_h */

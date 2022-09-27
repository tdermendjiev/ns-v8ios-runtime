//
//  BinarySerializer.swift
//  SwiftMetadataGenerator
//
//  Created by Teodor Dermendzhiev on 10.07.22.
//

import Foundation

//enum BinaryFlags: __uint16_t {
//    HasDemangledName = 1 << 8
//    HasName = 1 << 7
//}

enum BinaryFlags {
    case HasName;
    case MethodIsInitializer
    
    var val: __uint16_t {
        switch self {
        case .HasName:
             return 1 << 7
        
        case .MethodIsInitializer:
             return 1 << 1
        }
   }
    
}

class BinaryHashtable {
    private var elements: [[(String, MetaFileOffset)]]
    
    init(size: Int) {
        elements = [[(String, MetaFileOffset)]](repeating: [], count: size)
    }
    
    func hash(value: String) -> UInt32 {
        let hasher = StringHasher()
        hasher.addCharactersAssumingAligned(data: value)
        return hasher.hashWithTop8BitsMasked()
    }
    
    func add(jsName: String, offset: MetaFileOffset) {
        let h = hash(value: jsName)
        let index =  h % UInt32(self.elements.count)
        elements[Int(index)].append((jsName, offset))
    }
    
    func get(jsName: String) -> Int32 {
        let index = hash(value: jsName) % UInt32(self.elements.count)
        for tuple in elements[Int(index)] {
            if tuple.0 == jsName {
                return tuple.1
            }
        }
        return 0
    }
    
    func serialize(heapWriter: BinaryWriter) -> [MetaFileOffset] {
        var offsets = [MetaFileOffset]()
        for el in elements {
            if el.count > 0 {
                var elementOffsets = [MetaFileOffset]()
                for tuple in el {
                    elementOffsets.append(tuple.1)
                }
                offsets.append(heapWriter.pushBinaryArray(array: elementOffsets))
            } else {
                offsets.append(0)
            }
        }
        return offsets
    }
}

class MetaFile {
    var globalTableSymbolsJs: BinaryHashtable
    var globalTableSymbolsNativeProtocols: BinaryHashtable
    var globalTableSymbolsNativeInterfaces: BinaryHashtable
    
    var topLevelModules = [String:MetaFileOffset]()
    var heap: MemoryStream
    
    init(size: Int) {
        let tableSize = max(size, 100)
        self.globalTableSymbolsJs = BinaryHashtable(size: tableSize)
        self.globalTableSymbolsNativeProtocols = BinaryHashtable(size: size/10)
        self.globalTableSymbolsNativeInterfaces = BinaryHashtable(size: size/10)
        self.heap = MemoryStream()
        self.heap.pushByte(b: 0)
    }
    
    func getFromTopLevelModulesTable(moduleName: String) -> MetaFileOffset {
        return topLevelModules[moduleName] ?? 0
    }
    
    func registerInGlobalTables(meta: Meta, offset: MetaFileOffset) {
        globalTableSymbolsJs.add(jsName: meta.jsName, offset: offset)
        
        let nativeTable = meta.type == .Protocol ? self.globalTableSymbolsNativeProtocols : self.globalTableSymbolsNativeInterfaces
        
        nativeTable.add(jsName: meta.name, offset: offset)
    }
    
    func registerInTopLevelModulesTable(moduleName: String, offset: MetaFileOffset) {
        topLevelModules[moduleName] = offset
    }
    
    func save(path: String) {
        var stream = MemoryStream()
        save(stream: &stream)
        let data = Data(bytes: stream.heap)
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = URL(fileURLWithPath: path)
        
        do {
         try data.write(to: fileURL)
         print("File saved: \(fileURL.absoluteURL)")
        } catch {
         // Catch any errors
         print(error.localizedDescription)
        }
    }
    
    func save(stream: inout MemoryStream) {
        let globalTableStreamWriter = BinaryWriter(stream: stream)
        let heapWriter = self.heap_writer()
        
        let jsOffsets: [MetaFileOffset] = globalTableSymbolsJs.serialize(heapWriter: heapWriter)
        globalTableStreamWriter.pushBinaryArray(array: jsOffsets)
        
        let nativeProtocolOffsets = globalTableSymbolsNativeProtocols.serialize(heapWriter: heapWriter)
        globalTableStreamWriter.pushBinaryArray(array: nativeProtocolOffsets)
        
        let nativeInterfaceOffsets = globalTableSymbolsNativeInterfaces.serialize(heapWriter: heapWriter)
        globalTableStreamWriter.pushBinaryArray(array: (nativeInterfaceOffsets))
        
        var modulesOffsets = [MetaFileOffset]()
        for pair in topLevelModules {
            modulesOffsets.append(pair.1)
        }
        globalTableStreamWriter.pushBinaryArray(array: modulesOffsets)
        for byte in self.heap.heap {
            stream.pushByte(b: byte)
        }
        
    }
    
    func heap_writer() -> BinaryWriter {
        return BinaryWriter(stream: self.heap)
    }
    
}

class BinarySerializer: MetaVisitor {
    
    let file: MetaFile
    let heapWriter: BinaryWriter
    let typEncodingSerializer: BinaryTypeEncodingSerializer
    
    init(file: MetaFile) {
        self.file = file
        self.heapWriter = file.heap_writer()
        self.typEncodingSerializer = BinaryTypeEncodingSerializer(heapWriter: self.heapWriter)
    }
    
    func serializeContainer(container: [(String,[Meta])]) {
        for file in container {
            for meta in file.1 {
                meta.visit(visitor: self)
            }
        }
    }
    
    func serializeModule(moduleName: String, binaryModule: inout ModuleBinaryMeta) {
        var flags: UInt8 = 0
        binaryModule.flags |= flags
        binaryModule.name = heapWriter.pushString(str: moduleName)
        
        //TODO: serialize frameworks
    }
    
    func serializeMethod(meta: MethodMeta, binaryMetaStruct: inout MethodBinaryMeta) {
        self.serializeMember(meta: meta, binaryMetaStruct: &binaryMetaStruct)
        if meta.getFlags(flags: .MethodIsInitializer) {
            binaryMetaStruct.flags |= BinaryFlags.MethodIsInitializer.val
        }
        binaryMetaStruct.encoding = typEncodingSerializer.visit(types: meta.signature)
    }
    
    func serializeMember<T:BinaryMeta, M: Meta>(meta: M, binaryMetaStruct: inout T) {
        self.serializeBase(meta: meta, binaryMetaStruct: &binaryMetaStruct)
        binaryMetaStruct.flags =  binaryMetaStruct.flags & 0b1111111111111000; // this clears the type information written in the lower 3 bits
    }
    
    internal func visit(meta: inout FunctionMeta) {
        var binaryStruct = FunctionBinaryMeta(type: .Function)
        var base = meta as Meta
        serializeBase(meta: base, binaryMetaStruct: &binaryStruct)
        
        binaryStruct.encoding = typEncodingSerializer.visit(types: meta.signature)
        let offset = binaryStruct.save(writer: heapWriter)
        file.registerInGlobalTables(meta: meta, offset: offset)
    }
    
    func visit(meta: inout MethodMeta) {
        var binaryStruct = MethodBinaryMeta(type: .Method)
        var base = meta as Meta
        serializeBase(meta: base, binaryMetaStruct: &binaryStruct)
        
        binaryStruct.encoding = typEncodingSerializer.visit(types: meta.signature)
        let offset = binaryStruct.save(writer: heapWriter)
        file.registerInGlobalTables(meta: meta, offset: offset)
    }
    
    func visit(meta: inout ConstructorMeta) {
        var binaryStruct = MethodBinaryMeta(type: .Method)
        var base = meta as Meta
        serializeBase(meta: base, binaryMetaStruct: &binaryStruct)
        
        binaryStruct.encoding = typEncodingSerializer.visit(types: meta.signature)
        let offset = binaryStruct.save(writer: heapWriter)
        file.registerInGlobalTables(meta: meta, offset: offset)
    }
    
    func visit(meta: inout ClassMeta) {
        var binaryStruct = ClassBinaryMeta(type: .Class)
        
        
        serializeBase(meta: meta, binaryMetaStruct: &binaryStruct)
        
     
        var offsets = [MetaFileOffset]()
        for method in meta.instanceMethods {
            var binaryMeta = MethodBinaryMeta(type: .Method)
            self.serializeMethod(meta: method, binaryMetaStruct: &binaryMeta)
            let methodOffset = binaryMeta.save(writer: self.heapWriter)
            offsets.append(methodOffset)
        }
        binaryStruct.instanceMethods = heapWriter.pushBinaryArray(array: offsets)
       // offsets = [MetaFileOffset]()
        
        var initializersStartIndex: Int16 = -1
        for (index, method) in meta.instanceMethods.enumerated() {
            if (method.getFlags(flags: .MethodIsInitializer)) {
                initializersStartIndex = Int16(index)
                break
            }
        }
        
        binaryStruct.initializersStartIndex = initializersStartIndex
        
        
        let offset = binaryStruct.save(writer: heapWriter)
        file.registerInGlobalTables(meta: meta, offset: offset)
    }
    
    func serializeBase<T:BinaryMeta, M: Meta>(meta:M, binaryMetaStruct: inout T) {
        let hasName = meta.name != meta.jsName
        //TODO: hasDemangledName -> hasMangledName (do we ALWAYS have it true?)
        let hasMangledName = true
        if hasName || hasMangledName {
            var offsets = [0, 0, 0]
            var nOffsets = 0
            if (hasName) {
                offsets[nOffsets] = Int(heapWriter.pushString(str: meta.jsName))
                nOffsets += 1
            }
            
            offsets[nOffsets] = Int(heapWriter.pushString(str: meta.name, name: "name -> \(meta.name)"))
            nOffsets += 1
            if (hasMangledName) {
                offsets[nOffsets] = Int(heapWriter.pushString(str: meta.mangledName, name: "mangled name -> \(meta.name)"))
                nOffsets += 1
            }
            binaryMetaStruct.names = heapWriter.currentPosition()
            
            for i in 0...nOffsets-1 {
                let _ = heapWriter.pushPointer(offset: MetaFileOffset(offsets[i]))
            }
        } else {
            binaryMetaStruct.names = heapWriter.pushString(str: meta.jsName)
        }

        if hasName {
            binaryMetaStruct.flags |= (1 << 7)
        }
        
        if hasMangledName {
            binaryMetaStruct.flags |= (1 << 8)
        }
        
        let moduleName = meta.moduleName
        let moduleOffset = file.getFromTopLevelModulesTable(moduleName: moduleName)
        if moduleOffset != 0 {
            binaryMetaStruct.topLevelModule = moduleOffset
        } else {
            var moduleMeta = ModuleBinaryMeta()
            serializeModule(moduleName: moduleName, binaryModule: &moduleMeta)
            binaryMetaStruct.topLevelModule = moduleMeta.save(writer: heapWriter)
            file.registerInTopLevelModulesTable(moduleName: moduleName, offset: binaryMetaStruct.topLevelModule)
        }
    }
    
    
}

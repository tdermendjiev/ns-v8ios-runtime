//
//  BinaryMeta.swift
//  SwiftMetadataGenerator
//
//  Created by Teodor Dermendzhiev on 10.07.22.
//

import Foundation

protocol BinaryMetaProtocol {
    func save(writer: BinaryWriter) -> MetaFileOffset
}

enum MetaFlags {
    case None
    case MethodIsInitializer
    
    var val: __uint16_t {
        switch self {
        case .None:
             return 0
        
        case .MethodIsInitializer:
             return 1 << 8
        }
   }
    
}

class BinaryMeta: BinaryMetaProtocol {
    var names: MetaFileOffset = 0
    var topLevelModule: MetaFileOffset = 0
    var flags: __uint16_t = MetaFlags.None.val
    
    init(type: BinaryMetaType) {
        let val = UInt16(type.rawValue & 0x7)
        self.flags = val
    }
    
    func save(writer: BinaryWriter) -> MetaFileOffset {
        let offset = writer.pushPointer(offset: self.names, name: "names")
        writer.pushPointer(offset: topLevelModule, name: "top level module")
        writer.pushShort(value: Int16(flags), name: "flags")
        return offset
    }
}

class ModuleBinaryMeta {
    var flags: __uint8_t = 0
    var name: MetaFileOffset = 0
    var libraries: MetaFileOffset = 0
    
    func save(writer: BinaryWriter) -> MetaFileOffset {
        let offset = writer.pushByte(value: self.flags)
        let _ = writer.pushPointer(offset: self.name)
        let _ = writer.pushPointer(offset: self.libraries)
        return offset
    }
    
}

class FunctionBinaryMeta: BinaryMeta {
    
    var encoding: MetaFileOffset = 0
    
    override func save(writer: BinaryWriter) -> MetaFileOffset {
        let offset = super.save(writer: writer)
        let _ = writer.pushPointer(offset: self.encoding)
        return offset
    }
}

class MemberBinaryMeta: BinaryMeta {
    
}

class MethodBinaryMeta: MemberBinaryMeta {
    var encoding: MetaFileOffset = 0
    
    override func save(writer: BinaryWriter) -> MetaFileOffset {
        let offset = super.save(writer: writer)
        let _ = writer.pushPointer(offset: self.encoding, name: "encoding")
        return offset
    }
    
}

class BaseClassBinaryMeta: BinaryMeta {
    var instanceMethods: MetaFileOffset = 0
//    var staticMethods: MetaFileOffset = 0
//    var instanceProperties: MetaFileOffset = 0
//    var staticProperties: MetaFileOffset = 0
//    var protocols: MetaFileOffset = 0
    
    var initializersStartIndex: Int16 = -1
    
    override func save(writer: BinaryWriter) -> MetaFileOffset {
        let offset = super.save(writer: writer)
        writer.pushPointer(offset: self.instanceMethods, name: "instanceMethods")
//        writer.pushPointer(offset: self.staticMethods)
//        writer.pushPointer(offset: self.instanceProperties)
//        writer.pushPointer(offset: self.staticProperties)
//        writer.pushPointer(offset: self.protocols)
        writer.pushShort(value: self.initializersStartIndex)
        return offset
    }
}

class ClassBinaryMeta: BaseClassBinaryMeta {
    var baseName:MetaFileOffset = 0;
    
    override func save(writer: BinaryWriter) -> MetaFileOffset {
        let offset = super.save(writer: writer)
        writer.pushPointer(offset: self.baseName)
        return offset
    }
}

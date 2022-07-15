//
//  BinaryStructures.swift
//  SwiftMetadataGenerator
//
//  Created by Teodor Dermendzhiev on 10.07.22.
//

import Foundation

enum BinaryTypeEncodingType: UInt8 {
    
    case Void
    case Bool
    case Int
    case Float
    case String
};

class TypeEncoding {
    let type: BinaryTypeEncodingType
    
    init(type: BinaryTypeEncodingType) {
        self.type = type
    }
    
    func save(writer: BinaryWriter) -> MetaFileOffset {
        return writer.pushByte(value: self.type.rawValue)
    }
}

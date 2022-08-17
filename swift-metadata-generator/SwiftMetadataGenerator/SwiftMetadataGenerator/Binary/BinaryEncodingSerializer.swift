//
//  BinaryEncodingSerializer.swift
//  SwiftMetadataGenerator
//
//  Created by Teodor Dermendzhiev on 10.07.22.
//

import Foundation

class BinaryTypeEncodingSerializer: TypeVisitor<TypeEncoding> {
    
    let heapWriter: BinaryWriter
    
    init(heapWriter: BinaryWriter) {
        self.heapWriter = heapWriter
    }
    
    func visit(types: [Type]) -> MetaFileOffset {
        var binaryEncodings = [TypeEncoding]()
        for type in types {
            let binaryEncoding = type.visit(visitor: self)
            binaryEncodings.append(binaryEncoding)
        }
        
        let offset = heapWriter.pushArrayCount(count: MetaArrayCount(types.count))
        for encoding in binaryEncodings {
            let _ = encoding.save(writer: heapWriter)
        }
        return offset
    }
    
    override func visitInt() -> TypeEncoding {
        return TypeEncoding(type: .Int)
    }
    
    override func visitVoid() -> TypeEncoding {
        return TypeEncoding(type: .Void)
    }
    
    override func visitBool() -> TypeEncoding {
        return TypeEncoding(type: .Bool)
    }
    
    override func visitString() -> TypeEncoding {
        return TypeEncoding(type: .String)
    }
    
    override func visitFloat() -> TypeEncoding {
        return TypeEncoding(type: .Float)
    }
    
    override func visitPointer() -> TypeEncoding {
        return TypeEncoding(type: .Pointer)
    }
}

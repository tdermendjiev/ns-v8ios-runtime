//
//  BinaryWriter.swift
//  SwiftMetadataGenerator
//
//  Created by Teodor Dermendzhiev on 10.07.22.
//

import Foundation

typealias MetaFileOffset = Int32 //consider using Int32 if the memory layout is wrong (read more about Int and Int32)
typealias MetaArrayCount = Int32

extension String {
    var nullTerminated: Data? {
        if var data = self.data(using: String.Encoding.utf8) {
            data.append(0)
            return data
        }
        return nil
    }
}

class BinaryWriter: BinaryOperation {
    var uniqueStrings = [String:MetaFileOffset]()
    
    func currentPosition() -> MetaFileOffset {
        return self.stream.position
    }
    
    func pushByte(value: __uint8_t) -> MetaFileOffset {
        let offset = stream.position
        stream.pushByte(b: value)
        return offset
    }
    
    func pushNumber(number: Int, bytesCount: Int) -> Int32 {
        let offset = stream.position
        for i in 0...bytesCount-1 {
            let pad = 8 * i
            let current = __uint8_t((number & (255 << pad)) >> pad)
            stream.pushByte(b: current)
        }
        return offset
    }
    
    func pushString(str: String, shouldIntern: Bool = true, name: String? = nil) -> MetaFileOffset {
        if (shouldIntern && uniqueStrings[str] != nil) {
            return uniqueStrings[str]!
        }
        let offset = stream.position
        guard let nullTerminated = str.nullTerminated else { fatalError("Failed to terminate string")}
        let uintArray = [UInt8](nullTerminated)
        for c in uintArray {
            stream.pushByte(b: c)
        }
        
        if shouldIntern {
            uniqueStrings[str] = offset
        }
        
        if let name = name {
            print("--------")
            print("Pushed String: \(name)\n at: \(offset)\n bytesCount: \(MemoryLayout.size(ofValue: str))")
            print("--------")
        }
        
        return offset
    }
    
    func pushArrayCount(count: MetaArrayCount) -> MetaFileOffset {
        return pushNumber(number: Int(count), bytesCount: MemoryLayout.size(ofValue: count))
    }
    
    func pushPointer(offset: MetaFileOffset, name: String? = nil) -> MetaFileOffset {
        
        let offset = pushNumber(number: Int(offset), bytesCount: MemoryLayout.size(ofValue: offset))
        if let name = name {
            print("--------")
            print("Pushed Pointer: \(name)\n at: \(offset)\n bytesCount: \(MemoryLayout.size(ofValue: offset))")
            print("--------")
        }
        return offset
    }
    
    func pushShort(value: Int16, name: String? = nil) -> MetaFileOffset {
        let offset = pushNumber(number: Int(value), bytesCount: 2)
        if let name = name {
            print("--------")
            print("Pushed short: \(name)\n at: \(offset)\n bytesCount: 2")
            print("--------")
        }
        return offset
    }
    
    func pushBinaryArray(array: [MetaFileOffset]) -> MetaFileOffset {
        let offset = stream.position
        pushArrayCount(count: MetaArrayCount(array.count))
        
        for el in array {
            pushPointer(offset: el)
        }
        
        return offset
    }
    
}

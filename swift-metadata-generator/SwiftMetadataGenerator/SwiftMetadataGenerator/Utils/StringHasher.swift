//
//  StringHasher.swift
//  SwiftMetadataGenerator
//
//  Created by Teodor Dermendzhiev on 10.07.22.
//

import Foundation

let stringHashingStartValue = UInt32(0x9E3779B9)
let flagCount = UInt32(8)

class StringHasher {
    
    var m_hash: UInt32;
    var m_hasPendingCharacter: Bool;
    var m_pendingCharacter: UInt32;
    
    init() {
        m_hash = stringHashingStartValue
        m_hasPendingCharacter = false
        m_pendingCharacter = 0
    }
    
    func addCharactersAssumingAligned(a: UInt32, b: UInt32) {
        if (m_hasPendingCharacter) {
            fatalError("pending char")
        }
        m_hash += a
        m_hash = (m_hash << 16) ^ ((b << 11) ^ m_hash)
        m_hash += m_hash >> 11
    }

    func avalancheBits() -> UInt32 {
        var result = m_hash
                
        if m_hasPendingCharacter {
            result += m_pendingCharacter
            result ^= result << 11
            result += result >> 17
        }
        
        result ^= result << 3
        result += result >> 5
        result ^= result << 2
        result += result >> 15
        result ^= result << 10
        
        return result
    }

    func hashWithTop8BitsMasked() -> UInt32 {
        var result = avalancheBits()
        
        result &= (UInt32(1) << (UInt32(MemoryLayout.size(ofValue: result)) * 8 - flagCount)) - 1
        
        if (result == 0) {
            result = UInt32(0x80000000) >> flagCount
        }
        
        return result
    }
    
    func addCharacter(character: UInt32) {
        if m_hasPendingCharacter {
            m_hasPendingCharacter = false
            addCharactersAssumingAligned(a: m_pendingCharacter, b: character)
            return
        }
        
        m_pendingCharacter = character
        m_hasPendingCharacter = true
    }
    
    func addCharactersAssumingAligned(data: String) {
        if (m_hasPendingCharacter) {
            fatalError("pending char")
        }
        var length = data.count
        let remainder = length & 1;
        length >>= 1;
        
        let asUInt32Array = data.utf8.map{ UInt32($0) }
        var index = 0
        
        while (length > 0) {
            addCharactersAssumingAligned(a: asUInt32Array[index], b: asUInt32Array[index+1])
            length = length - 1
            index = index + 2
        }
        
        if remainder > 0 {
            addCharacter(character: UInt32(index))
        }
    }
    
}

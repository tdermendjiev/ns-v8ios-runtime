//
//  Stream.swift
//  SwiftMetadataGenerator
//
//  Created by Teodor Dermendzhiev on 10.07.22.
//

import Foundation

class Stream {
    var position: Int32 = 0
}

//TODO: do we need the position property?
class MemoryStream: Stream {
    var heap = [__uint8_t]()
    
    func size() -> Int {
        return heap.count
    }
    
    func readByte() -> __uint8_t {
        let result = self.heap[Int(self.position)]
        self.position += 1
        return result
    }
    
    func readByte(position: Int) -> __uint8_t {
        let result = self.heap[position]
        return result
    }
    
    func pushByte(b: __uint8_t) {
        heap.insert(b, at: Int(position))
        position += 1
    }
}

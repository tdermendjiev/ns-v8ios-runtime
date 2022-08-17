//
//  TypeVisitor.swift
//  SwiftMetadataGenerator
//
//  Created by Teodor Dermendzhiev on 10.07.22.
//

import Foundation

class TypeVisitor<T_RESULT> {
    func visitVoid() -> T_RESULT { fatalError("Should override") }
    func visitBool() -> T_RESULT { fatalError("Should override") }
    func visitInt() -> T_RESULT  { fatalError("Should override") }
    func visitString() -> T_RESULT { fatalError("Should override") }
    func visitFloat() -> T_RESULT  { fatalError("Should override") }
    func visitPointer() -> T_RESULT { fatalError("Should override") }
}
 

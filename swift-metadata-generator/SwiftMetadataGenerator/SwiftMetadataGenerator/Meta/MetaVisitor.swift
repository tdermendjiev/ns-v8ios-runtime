//
//  MetaVisitor.swift
//  SwiftMetadataGenerator
//
//  Created by Teodor Dermendzhiev on 10.07.22.
//

import Foundation

protocol MetaVisitor {
    func visit(meta: inout FunctionMeta)
    func visit(meta: inout MethodMeta)
    func visit(meta: inout ClassMeta)
}

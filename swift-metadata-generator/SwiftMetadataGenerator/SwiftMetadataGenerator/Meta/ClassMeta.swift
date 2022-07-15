//
//  ClassMeta.swift
//  SwiftMetadataGenerator
//
//  Created by Teodor Dermendzhiev on 10.07.22.
//

import Foundation
import SourceKittenFramework

class ClassMeta: Meta {
    
    
    var instanceMethods = [MethodMeta]()
    
    var staticMethods = [MethodMeta]()
    
    var instanceProperties = [PropertyMeta]()
    
    var staticProperties = [PropertyMeta]()
    
    var protocols = [ProtocolMeta]()
    
    override func visit(visitor: MetaVisitor) {
        var temp = self
        visitor.visit(meta: &temp)
    }
    
    required init(name: String, jsName: String, mangledName: String, moduleName: String) {
        super.init(type: .Class, name: name, jsName: jsName, mangledName: mangledName, moduleName: moduleName)
        
    }
    
    convenience init(dict: [String:SourceKitRepresentable], moduleName: String, path: String) {
        let name = Meta.nameFromDecl(d: dict["key.name"] as! String)
        let usr = Meta.usrForOffset(offset: ByteCount(dict["key.nameoffset"] as! Int64), path: path)
        let mangledName = usr.components(separatedBy: moduleName)[1]
        self.init(name: name, jsName: name, mangledName: mangledName, moduleName: moduleName)
        
        populateStaticMethods()
        populateInstanceMethods()
        populateStaticProperties()
        populateInstanceProperties()
        populateProtocols()
    }
    
    private func populateStaticMethods() {
        
    }
    
    private func populateInstanceMethods() {
        
    }
    
    private func populateStaticProperties() {
        
    }
    
    private func populateInstanceProperties() {
        
    }
    
    private func populateProtocols() {
        
    }
    
}

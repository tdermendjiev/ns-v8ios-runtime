//
//  ConstructorMeta.swift
//  SwiftMetadataGenerator
//
//  Created by Teodor Dermendzhiev on 28.07.22.
//

import Foundation
import SourceKittenFramework
import SwiftSyntax

class ConstructorMeta: MethodMeta {
    
    convenience init(decl: ClassDeclSyntax, moduleName: String, path: String) {
        let name = decl.identifier.description
        let signature = ConstructorMeta.defaultInitSignature()
        //TODO: check if there is a default constructor at all
        let offset = decl.identifier.tokenClassification.offset
        let mangledName = ConstructorMeta.mangleDefaultConstructorDecl(decl: decl, path: path, offset: offset)
        self.init(name: name, jsName: name, mangledName: mangledName, moduleName: moduleName, signature: signature)
    }
    
    static func defaultInitSignature() -> [Type] {
        //todo: implement
        return [Type(type: TypeType.TypeVoid)]
    }
    
    static func mangleDefaultConstructorDecl(decl: ClassDeclSyntax, path: String, offset: Int) -> String {
        let usr = Meta.usrForOffset(offset: ByteCount(offset), path: path)
        let url = URL(fileURLWithPath: path)
        let fileName = url.lastPathComponent.components(separatedBy: ".")[0]
        let mangledName = usr.components(separatedBy: fileName)[1]
        
        let moduleName = MODULE_NAME
        
        let symbolName = "_$s\(moduleName.count)\(moduleName)\(mangledName)ACycfC"
        print(symbolName)
        return symbolName
    }
    
}

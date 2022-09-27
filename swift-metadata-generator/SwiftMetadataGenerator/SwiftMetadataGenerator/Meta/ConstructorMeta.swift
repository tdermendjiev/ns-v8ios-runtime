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
    
    convenience init(classDecl: ClassDeclSyntax, decl: InitializerDeclSyntax, moduleName: String, path: String) {
        let signature = ConstructorMeta.signatureFromParameters(decl: decl.parameters)
        let mangledName = ConstructorMeta.mangleDecl(decl: decl, path: path, offset: decl.initKeyword.tokenClassification.offset)
        let name = classDecl.identifier.description
        self.init(name: name, jsName: name, mangledName: mangledName, moduleName: moduleName, signature: signature)
        self.setFlags(flags: MetaFlags.MethodIsInitializer.val, value: true)
    }
    
    static func signatureFromParameters(decl: ParameterClauseSyntax) -> [Type] {
        var signature = [Type]()
        signature.append(Type(type: TypeType.TypePointer))

        decl.parameterList.forEach { functionParameterSyntax in
          let paramType = asType(syntax: functionParameterSyntax.type)
          signature.append(paramType)
        }

        return signature
    }
    
    //not needed if we call default constructor without getting metadata
    static func defaultInitSignature() -> [Type] {
        //todo: implement
        return [Type(type: TypeType.TypePointer)]
    }
    
    //not needed if we call default constructor without getting metadata
    static func mangleDefaultConstructorDecl(decl: ClassDeclSyntax, path: String, offset: Int) -> String {
        let usr = Meta.usrForOffset(offset: ByteCount(offset), path: path)
        let url = URL(fileURLWithPath: path)
        let fileName = url.lastPathComponent.components(separatedBy: ".")[0]
        let mangledName = usr.components(separatedBy: fileName)[1]
        
        let moduleName = MODULE_NAME
        
        let symbolName = "$s\(moduleName.count)\(moduleName)\(mangledName)ACycfC"
        print(symbolName)
        return symbolName
    }
    
    static func mangleDecl(decl: InitializerDeclSyntax, path: String, offset: Int) -> String {
        let usr = Meta.usrForOffset(offset: ByteCount(offset), path: path)
        let url = URL(fileURLWithPath: path)
        let fileName = url.lastPathComponent.components(separatedBy: ".")[0]
        let mangledName = usr.components(separatedBy: fileName)[1]
        
        let moduleName = MODULE_NAME
        
        let symbolName = "$s\(moduleName.count)\(moduleName)\(mangledName)"
        print(symbolName)
        return symbolName
    }
    
}

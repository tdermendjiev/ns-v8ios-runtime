//
//  FunctionMeta.swift
//  SwiftMetadataGenerator
//
//  Created by Teodor Dermendzhiev on 10.07.22.
//

import Foundation
import SourceKittenFramework
import SwiftSyntax

class FunctionMeta: Meta {
    
    let signature: [Type]
    
    init(name: String, jsName: String, mangledName: String, moduleName: String, signature: [Type]) {
        self.signature = signature
        super.init(type: .Function, name: name, jsName: jsName, mangledName: mangledName, moduleName: moduleName)
        
    }
    
    convenience init(dict: [String:SourceKitRepresentable], moduleName: String, path: String) {
        let name = Meta.nameFromDecl(d: dict["key.name"] as! String)
        let signature = FunctionMeta.signatureFromDecl(d: dict)
        let usr = Meta.usrForOffset(offset: ByteCount(dict["key.nameoffset"] as! Int64), path: path)
        let mangledName = usr.components(separatedBy: moduleName)[1]
        self.init(name: name, jsName: name, mangledName: mangledName, moduleName: moduleName, signature: signature)
    }
    
    convenience init(decl: FunctionDeclSyntax, moduleName: String, path: String) {
        let name = decl.identifier.description
        let signature = FunctionMeta.signatureFromDecl(decl: decl.signature)
        let offset = decl.identifier.tokenClassification.offset
        let mangledName = FunctionMeta.mangleDecl(decl: decl, path: path, offset: offset)
        self.init(name: name, jsName: name, mangledName: mangledName, moduleName: moduleName, signature: signature)
    }
    
    
    override func visit(visitor: MetaVisitor) {
        var temp = self
        visitor.visit(meta: &temp)
    }
    
    static func mangleDecl(decl: FunctionDeclSyntax, path: String, offset: Int) -> String {
        let usr = Meta.usrForOffset(offset: ByteCount(offset), path: path)
        let url = URL(fileURLWithPath: path)
        let fileName = url.lastPathComponent.components(separatedBy: ".")[0]
        let mangledName = usr.components(separatedBy: fileName)[1]
        
        let moduleName = MODULE_NAME
        
        let symbolName = "_$s\(moduleName.count)\(moduleName)\(mangledName)"
        print(symbolName)
        return symbolName
    }
    
    static func signatureFromDecl(decl: FunctionSignatureSyntax) -> [Type] {
        //todo: implement
        return [Type(type: TypeType.TypeInt)]
    }

    static func signatureFromDecl(d: [String:SourceKitRepresentable]) -> [Type] {
        var result = [Type]()
        var returnType = TypeType.TypeVoid
        if let rType = d["key.typename"] as? String {
            switch rType {
            case "Int":
                returnType = TypeType.TypeInt
            case "Bool":
                returnType = TypeType.TypeBool
            case "Float":
                returnType = TypeType.TypeFloat
            case "String":
                returnType = TypeType.TypeString
            default:
                break
            }
        }
        result.append(Type(type: returnType))
        
        if let substruct = d["key.substructure"] as? [SourceKitRepresentable] {
            for item in substruct {
                if let d = item as? [String:SourceKitRepresentable] {
                    if let kind = d["key.kind"] as? String, kind == "source.lang.swift.decl.var.parameter" {
                        if let typename = d["key.typename"] as? String {
                            switch typename {
                            case "Int":
                                result.append(Type(type: .TypeInt))
                            case "Bool":
                                result.append(Type(type: .TypeBool))
                            case "Float":
                                result.append(Type(type: .TypeFloat))
                            case "String":
                                result.append(Type(type: .TypeString))
                            default:
                                break
                            }
                        }
                    }
                }
            }
        }
        
        return result
    }
}

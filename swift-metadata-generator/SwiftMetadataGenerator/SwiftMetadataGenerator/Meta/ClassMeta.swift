//
//  ClassMeta.swift
//  SwiftMetadataGenerator
//
//  Created by Teodor Dermendzhiev on 10.07.22.
//

import Foundation
import SourceKittenFramework
import SwiftSyntax

class ClassMeta: Meta {
    
    
    var instanceMethods = [MethodMeta]()
    
    var staticMethods = [MethodMeta]()
    
    var instanceProperties = [PropertyMeta]()
    
    var staticProperties = [PropertyMeta]()
    
    var protocols = [ProtocolMeta]()
    
    var constructors = [ConstructorMeta]()
    
    var  baseClass: ClassMeta?
    
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
        
//        populateStaticMethods()
//        populateInstanceMethods()
//        populateStaticProperties()
//        populateInstanceProperties()
//        populateProtocols()
    }
    
    convenience init(decl: ClassDeclSyntax, moduleName: String, path: String) {
        let name = decl.identifier.description.trimmingCharacters(in: .whitespaces)
        let offset = decl.identifier.tokenClassification.offset
        let usr = Meta.usrForOffset(offset: ByteCount(offset), path: path)
        let mangledName = usr
        self.init(name: name, jsName: name, mangledName: mangledName, moduleName: moduleName)
        
        //for debug
        for m in decl.members.members {
            print(m.decl.syntaxNodeType)
        }
        
        populateConstructors(decl: decl, moduleName: moduleName, path: path)
        populateStaticMethods()
        populateInstanceMethods(decl: decl, moduleName: moduleName, path: path)
        populateStaticProperties()
        populateInstanceProperties(decl: decl)
        populateProtocols()
    }
    
    private func populateConstructors(decl: ClassDeclSyntax, moduleName: String, path: String) {
        for m in decl.members.members {
            if let funcDecl = InitializerDeclSyntax(m.decl._syntaxNode) {
                let con = ConstructorMeta(classDecl: decl, decl: funcDecl, moduleName: moduleName, path: path)
                constructors.append(con)
            }
        }
       
        
    }
    
    private func populateStaticMethods() {
        
    }
    
    private func populateInstanceMethods(decl: ClassDeclSyntax, moduleName: String, path: String) {
        
        //should they be sorted?
        for m in decl.members.members {
            if let funcDecl = FunctionDeclSyntax(m.decl._syntaxNode) {
                //print(funcDecl.modifiers?.description)
                //TODO: check if it's instance
                if let mods = funcDecl.modifiers {
                    for mod in mods {
                        if !(mod.name.text == "static" || mod.name.text == "class" || mod.name.text == "private") {
                            let methodMeta = MethodMeta(decl: funcDecl, moduleName: moduleName, path: path)
                            instanceMethods.append(methodMeta)
                        }
                        
                    }
                }
                
            }
            
        }
    }
    
    private func populateStaticProperties() {
        
    }
    
    private func populateInstanceProperties(decl: ClassDeclSyntax) {
        for m in decl.members.members {
            if let varDecl = VariableDeclSyntax(m.decl._syntaxNode) {
                //print(varDecl.modifiers?.description)
            }
        }
    }
    
    private func populateProtocols() {
        
    }
    
}

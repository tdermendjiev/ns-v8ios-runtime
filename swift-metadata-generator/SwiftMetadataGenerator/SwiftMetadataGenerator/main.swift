//
//  main.swift
//  SwiftMetadataGenerator
//
//  Created by Teodor Dermendzhiev on 10.07.22.
//

import Foundation
import SourceKittenFramework
import SwiftSyntax
import SwiftSyntaxParser

let MODULE_NAME = "TestRunner"

class SwiftDeclarationVisitor: SyntaxRewriter {
    
    public var metas = [Meta]()
    public var path: String = ""
    
    init(path: String) {
        self.path = path
    }
    
    override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        let fMeta = FunctionMeta(decl: node, moduleName: "", path: self.path)
        metas.append(fMeta)
        symbols.append(fMeta.mangledName)
        return super.visit(node)
    }
    
    override func visit(_ node: ClassDeclSyntax) -> DeclSyntax {
        let cMeta = ClassMeta(decl: node, moduleName: "", path: path)
        metas.append(cMeta)
        symbols.append(cMeta.mangledName)
        return super.visit(node)
    }
    
}

var path: String?
var outputPath: String?

for (index, arg) in CommandLine.arguments.enumerated() {

    switch arg {
        case "-swift-files-path":
            path = CommandLine.arguments[index+1] + "/"
//            path = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.1.sdk/System/Library/Frameworks/SwiftUI.framework/Modules/SwiftUI.swiftmodule/"
        case "-output-bin":
            outputPath = CommandLine.arguments[index+1]
        default:
            break
        }
}

guard let path = path, let outputPath = outputPath else {
    fatalError("Please provide valid paths")
}

var container = [(String,[Meta])]()
var symbols = [String]()

let fileManager = FileManager.default
let enumerator = fileManager.enumerator(atPath: path)
while let element = enumerator?.nextObject() as? String {
    if element.hasSuffix("swift")  || element.hasSuffix("swiftinterface"){
        do {
            let file = path + element
            let url = URL(fileURLWithPath: file)
            let sourceFile = try SyntaxParser.parse(url)
            let visitor = SwiftDeclarationVisitor(path: file)
            _ = visitor.visit(sourceFile)
            
            container.append((path + element, visitor.metas))
        } catch(let err) {
            print(err)
        }
    }
}

let metaFile = MetaFile(size: 50)
let stream = MemoryStream()
let writer = BinaryWriter(stream: stream)
let binaryTypeEncodingSerializer = BinaryTypeEncodingSerializer(heapWriter: writer)

let serializer = BinarySerializer(file: metaFile)
serializer.serializeContainer(container: container)
metaFile.save(path: outputPath)




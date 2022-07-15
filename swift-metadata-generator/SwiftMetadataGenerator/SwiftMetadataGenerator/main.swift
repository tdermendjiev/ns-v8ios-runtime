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
            let file = File(path: path + element)!
            let result = try Structure(file: file)
            let dict = result.dictionary
            var metas = [Meta]()
            if let decls = dict["key.substructure"] as? [SourceKitRepresentable] {
                for d in decls {
                    visitDecl(s: d as! [String: SourceKitRepresentable], metas: &metas, moduleName: element.components(separatedBy: ".swift")[0], path: path + element)
                }
            }
            container.append((file.path!, metas))
        } catch(let err) {
            print(err)
        }
    }
}

func visitDecl(s: [String:SourceKitRepresentable], metas: inout [Meta], moduleName: String, path: String) {
    if let kind = s["key.kind"] as? String {
        if kind == "source.lang.swift.decl.function.free" {
            if let dict = s as? [String:SourceKitRepresentable] {
                let fMeta = FunctionMeta(dict: s, moduleName: moduleName, path: path)
                metas.append(fMeta)
                symbols.append(fMeta.mangledName)
            } else {
                print("meta failed")
            }
        } else if kind == "source.lang.swift.decl.class" {
            if let dict = s as? [String:SourceKitRepresentable] {
                let cMeta = ClassMeta(dict: s, moduleName: moduleName, path: path)
                metas.append(cMeta)
                symbols.append(cMeta.mangledName)
            } else {
                print("meta failed")
            }

        }
    }
    if let substructure = s["key.substructure"] as? [String: SourceKitRepresentable] {
        visitDecl(s: substructure, metas: &metas, moduleName: moduleName, path: path)
    }
}

let metaFile = MetaFile(size: 50)
let stream = MemoryStream()
let writer = BinaryWriter(stream: stream)
let binaryTypeEncodingSerializer = BinaryTypeEncodingSerializer(heapWriter: writer)

let serializer = BinarySerializer(file: metaFile)
serializer.serializeContainer(container: container)
metaFile.save(path: outputPath)




//
//  Meta.swift
//  SwiftMetadataGenerator
//
//  Created by Teodor Dermendzhiev on 10.07.22.
//

import Foundation
import SourceKittenFramework

enum TypeType {
    case TypeVoid
    case TypeBool
    case TypeInt
    case TypeFloat
    case TypeString
    case TypePointer
}

class Type {
    let type: TypeType
    
    init(type: TypeType) {
        self.type = type
    }
    
    func visit<T>(visitor: TypeVisitor<T>) -> T {
        switch self.type {
        case .TypeVoid:
            return visitor.visitVoid()
        case .TypeBool:
            return visitor.visitBool()
        case .TypeInt:
            return visitor.visitInt()
        case .TypeFloat:
            return visitor.visitFloat()
        case .TypeString:
            return visitor.visitString()
        case .TypePointer:
            return visitor.visitPointer()
        }
    }
}

enum MetaType: Int {
    case Undefined = 0
    case Struct
    case Function
    case Enum
    case Var
    case `Class`
    case `Protocol`
    case Method
}

enum BinaryMetaType: UInt8 {
    case Undefined = 0
    case Struct = 1
    case Function = 2
    case Enum = 3
    case Var = 4
    case `Protocol` = 5
    case Method = 6
    case `Class` = 7
}

class Meta {
    var type: MetaType
    var name: String
    var jsName: String
    var mangledName: String
    var moduleName: String
    
    init(type: MetaType, name: String, jsName: String, mangledName: String, moduleName: String) {
        self.name = name
        self.jsName = jsName
        self.mangledName = mangledName
        self.moduleName = moduleName
        self.type = type
    }
    
    func visit(visitor: MetaVisitor) {
        
    }
    
    static func usrForOffset(offset: ByteCount, path: String) -> String {
        let args = ["-sdk", "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX12.3.sdk","-j4",
                    path,
        ]
        let request = Request.cursorInfo(file: path, offset: offset, arguments: args)

        do {
            let result = try request.send()
            let dict = toNSDictionary(result) as! [String:Any]
            return dict["key.usr"] as! String
        } catch(let err) {
            print(err)
            return ""
        }
    }

    static func nameFromDecl(d: String) -> String{
        let delimiter = "("
        return d.components(separatedBy: delimiter)[0]
    }
}


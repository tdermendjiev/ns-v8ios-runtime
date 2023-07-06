//
//  MethodUtils.swift
//  v8ios
//
//  Created by Teodor Dermendzhiev on 3.07.23.
//  Copyright © 2023 Progress. All rights reserved.
//

import SourceryRuntime

public extension Method {
    
    var objcDeclaration: String {
            let methodNameComponents = self.name.components(separatedBy: " ")
            let nameComponents = self.name.components(separatedBy: "(")

            let baseMethodName = nameComponents[0]

            let parametersString: [String] = self.parameters.enumerated().map { index, param in
                if index == 0 {
                    return "(\(param.typeName.objcEquivalent)) \(param.name)"
                } else {
                    return "\(param.argumentLabel ?? param.name): (\(param.typeName.objcEquivalent))\(param.name)"
                }
            }

            let arguments = parametersString.joined(separator: " ")

            let returnType = self.returnTypeName.name != "Void" ? "\(self.returnTypeName.objcEquivalent)" : "void"
        
        return """
        //\(self.parameters)
        - (\(returnType))\(baseMethodName)\(self.parameters.count > 0 ? ":" : "")\(arguments);
        """

        }
    
    func cdeclName(forClass className: String) -> String {
        let nameComponents = self.name.components(separatedBy: "(")
        let methodName = nameComponents[0]
        if nameComponents.count > 1 {
            let params = nameComponents[1].dropLast()
            let paramCount = params.components(separatedBy: ",").count
            var paramString = ""
            for _ in 0..<paramCount {
                paramString.append(":")
            }
            return "\(className)_\(methodName)\(paramString)"
        } else {
            return "\(className)_\(methodName)"
        }
    }

    func proxyName(forClass className: String) -> String {
        let methodName = self.name.components(separatedBy: "(")[0]
        let params = self.parameters.map { param in
            let paramType = param.typeName.name == "Any" ? "UnsafeMutableRawPointer" : param.typeName.name
            return "\(param.name): \(paramType)"
        }
        return "\(className)_\(methodName)(inst: UnsafeRawPointer, \(params.joined(separator: ", ")))"
    }
    
    func objcHeaderRepresentation() -> String {
        let returnType = self.returnTypeName.name == "Void" ? "void" : "id"
        let methodNameParts = self.selectorName.split(separator: "(")
        
        var objcRepresentation = "-(\(returnType))"
        
        for (index, part) in methodNameParts.enumerated() {
            let argumentLabel = part.split(separator: " ").first!.trimmingCharacters(in: .whitespacesAndNewlines)
            let argumentType = "id"
            
            if index == 0 {
                objcRepresentation += "\(argumentLabel): (\(argumentType))param"
            } else {
                objcRepresentation += " \(argumentLabel): (\(argumentType))param\(index)"
            }
        }
        
        objcRepresentation += ";"
        
        return objcRepresentation
    }
}

public extension TypeName {
    var objcEquivalent: String {
        switch self.unwrappedTypeName {
        case "Int", "UInt", "Double", "Float":
            return "NSNumber *"
        case "String":
            return "NSString *"
        case "Bool":
            return "BOOL"
        case "Any":
            return "id"
        default:
            return self.unwrappedTypeName + " *"
        }
    }
}

//
//  SomeSwiftClass.swift
//  NativeScript
//
//  Created by Teodor Dermendzhiev on 4.08.22.
//  Copyright © 2022 Progress. All rights reserved.
//

import Foundation

//@_cdecl("someGlobalFunc")
//func someGlobalFunc() {
//    print("global called")
//}

@objc public class SwiftManager: NSObject {
    
    func createClass(name: String){
        let klass: AnyClass? = NSClassFromString(name)
        printMethodNamesForClass(cls: klass!)
        
    }
    
    func printMethodNamesForClass(cls: AnyClass) {
        var methodCount: UInt32 = 0
        let methodList = class_copyMethodList(cls, &methodCount)
        if methodList != nil && methodCount > 0 {
            enumerateCArray(array: methodList!, count: methodCount) { i, m in
                let name = methodName(m: m) ?? "unknown"
                print("#\(i): \(name)")
            }

            free(methodList)
        }
    }
    func enumerateCArray<T>(array: UnsafePointer<T>, count: UInt32, f: (UInt32, T) -> ()) {
        var ptr = array
        for i in 0..<count {
            f(i, ptr.pointee)
            ptr = ptr.successor()
        }
    }
    func methodName(m: Method) -> String? {
        let sel = method_getName(m)
        let nameCString = sel_getName(sel)
        return String(cString:  nameCString)
    }
    func printMethodNamesForClassNamed(classname: String) {
    // NSClassFromString() is declared to return AnyClass!, but should be AnyClass?
        let maybeClass: AnyClass? = NSClassFromString(classname)
        if let cls: AnyClass = maybeClass {
        printMethodNamesForClass(cls: cls)
        }
        else {
            print("\(classname): no such class")
        }
    }
}

class PrivateClass {
    
    public func m() {
        print("printed")
    }
}

@objc public class SomeSwiftClass: NSObject {
    
    var privC: PrivateClass?
    
    @objc public func someMethod() {
        
//        privC = PrivateClass()
//        privC?.m()
        let m = SwiftManager()
        m.createClass(name: "NativeScript.PrivateClass")
    }
    
}



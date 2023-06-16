//
//  AClass.swift
//  TestRunner
//
//  Created by Teodor Dermendzhiev on 11.05.23.
//  Copyright © 2023 Progress. All rights reserved.
//

import Foundation

class AClass {
    
    static let shared = AClass()
    
    var count: Int
    var name: String
    
    init() {
        self.count = 1
        self.name = "some name"
    }
    
    init(count: Int, name: String) {
        self.count = count
        self.name = name
    }
    
    func printCount() {
        print(count)
    }
    
    func execute(completion: (Int) -> Int) -> Int{
        return completion(5)
    }
    
}

//@_cdecl("aclass_create")
//public func AClass_create(count: Int) -> OpaquePointer {
//    let type = AClass(count: count)
//    let retained = Unmanaged.passRetained(type).toOpaque()
////    retained.deallocate()
////    print(retained)
//    return OpaquePointer(retained)
//}

@_cdecl("AClass_shared")
public func AClass_shared() -> UnsafeMutableRawPointer {
    let shared = AClass.shared
    let result = Unmanaged.passUnretained(shared).toOpaque()
    return result
}

@_cdecl("AClass_init")
func AClass_init() -> UnsafeMutableRawPointer {
    let instance = AClass()
    return Unmanaged.passRetained(instance).toOpaque()
}

@_cdecl("AClass_initWithCountName")
func AClass_initWithCount_name(_ count: Int32, _ name: UnsafePointer<Int8>) -> UnsafeMutableRawPointer {
    let nameStr = String(cString: name)
    let instance = AClass(count: Int(count), name: nameStr)
    return Unmanaged.passRetained(instance).toOpaque()
}

@_cdecl("AClass_printCount")
public func AClass_printCount(inst: UnsafeRawPointer) {
    let i = Unmanaged<AClass>.fromOpaque(inst).takeUnretainedValue()
    i.printCount()
}

@_cdecl("AClass_execute:")
func AClass_execute(_ instance: Unmanaged<AnyObject>, completion: @convention(c) (Int) -> Int) -> Int {
    let typedInstance = instance.takeUnretainedValue() as! AClass
    return typedInstance.execute(completion: completion)
}

@_cdecl("AClass_count")
func AClass_getCount(inst: UnsafeRawPointer) -> Int32 {
    let obj = Unmanaged<AClass>.fromOpaque(inst).takeUnretainedValue()
    return Int32(obj.count)
}

@_cdecl("AClass_setCount:")
func AClass_setCount(inst: UnsafeRawPointer, value: Int32) {
    let obj = Unmanaged<AClass>.fromOpaque(inst).takeUnretainedValue()
    obj.count = Int(value)
}

@_cdecl("AClass_name")
func AClass_getName(inst: UnsafeRawPointer) -> Unmanaged<NSString> {
    let obj = Unmanaged<AClass>.fromOpaque(inst).takeUnretainedValue()
    return Unmanaged.passRetained(obj.name as NSString)
}





//
//  SwiftClass.swift
//  TestRunner
//
//  Created by Teodor Dermendzhiev on 26.10.20.
//  Copyright © 2020 Progress. All rights reserved.
//

import Foundation

func aMethod2(paramFloat: Float) {
    print("The method has been called with param \(paramFloat)")
}

func aMethod2(paramInt: Int) {
    print("The method has been called with param \(paramInt)")
}

func method() -> String {
    return ""
}


class AClass {
    let int: Int
    let str: String
    init(intParam: Int, strParam: String) {
        int = intParam
        str = strParam
    }
    
    
//    func instanceMethod() {
//        print("Instance method has been called")
//    }
}

//class FunctionMeta {
//
//}
//
//@objc(SomeClass)
//class SomeClass: NSObject {
//
//}
//
//class MethodMeta: FunctionMeta {
//
//}

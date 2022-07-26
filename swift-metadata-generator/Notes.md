# 26.07.2022

## Constructors

### allocating and non-allocating constructors
- todo: check when non-allocating constructors are used

### mangled symbols
https://github.com/apple/swift/blob/main/docs/ABI/Mangling.rst

### Example:

```
class FunctionMeta {
    
}

class MethodMeta: FunctionMeta {
    
}
```

Compiles to:
```
00000001000165b0 t _$s10TestRunner10MethodMetaCACycfC
00000001000165e0 t _$s10TestRunner10MethodMetaCACycfc
000000010001bdec s _$s10TestRunner10MethodMetaCMF
00000001000166d0 t _$s10TestRunner10MethodMetaCMa
000000010002bb60 d _$s10TestRunner10MethodMetaCMf
000000010002bb38 d _$s10TestRunner10MethodMetaCMm
000000010001bd24 s _$s10TestRunner10MethodMetaCMn
000000010002bb70 d _$s10TestRunner10MethodMetaCN
0000000100016650 t _$s10TestRunner10MethodMetaCfD
0000000100016630 t _$s10TestRunner10MethodMetaCfd
0000000100016560 t _$s10TestRunner12FunctionMetaCACycfC
000000010001bd10 s _$s10TestRunner12FunctionMetaCACycfCTq
0000000100016590 t _$s10TestRunner12FunctionMetaCACycfc
000000010001bddc s _$s10TestRunner12FunctionMetaCMF
00000001000166b0 t _$s10TestRunner12FunctionMetaCMa
000000010002bad0 d _$s10TestRunner12FunctionMetaCMf
000000010002baa8 d _$s10TestRunner12FunctionMetaCMm
000000010001bcdc s _$s10TestRunner12FunctionMetaCMn
000000010002bae0 d _$s10TestRunner12FunctionMetaCN
0000000100016520 t _$s10TestRunner12FunctionMetaCfD
0000000100016500 t _$s10TestRunner12FunctionMetaCfd
```


`s10TestRunner10MethodMetaCACycfC` and `s10TestRunner12FunctionMetaCACycfC` are the default constructors. If the class has an initializer it wont have a default constructor - this can be checked via `decl.members.members` (`InitializerDeclSyntax`). So probably when we call a constructor from js first we need to check the params. Should be something like:
1. Check params
2. If no params - check for default constructor
3. If params - check for initializer with the same number of params
4. Call the symbol
5. Call swift_retain(?)

We may also keep this information in the metadata for faster checks:
* Add a defaultInitializer(?) -> check if decl has a parent class - check all parent classes for initializers -> if no such -> add a default initializer symbol



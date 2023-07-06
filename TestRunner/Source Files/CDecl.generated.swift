// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
@_cdecl("LCManager_shared")
public func LCManager_shared() -> UnsafeMutableRawPointer {
    let shared = LCManager.shared
    let result = Unmanaged.passUnretained(shared).toOpaque()
    return result
}
@_cdecl("LCManager_isVisible")
public func LCManager_getIsVisible(inst: UnsafeRawPointer) -> Bool {
    let obj = Unmanaged<LCManager>.fromOpaque(inst).takeUnretainedValue()
    return obj.isVisible
}
@_cdecl("LCManager_setIsVisible:")
public func LCManager_setIsVisible(inst: UnsafeMutableRawPointer, isVisible: Bool) {
    let obj = Unmanaged<LCManager>.fromOpaque(inst).takeUnretainedValue()
    obj.isVisible = isVisible
}
@_cdecl("LCManager_print:")
public func LCManager_print(inst: UnsafeRawPointer, items: UnsafeMutableRawPointer) {
    let obj = Unmanaged<LCManager>.fromOpaque(inst).takeUnretainedValue()
    obj.print(Unmanaged<AnyObject>.fromOpaque(items).takeUnretainedValue())
}

//
//  CString.swift
//  xdag-ios
//
//  Created by yangyin on 2018/5/8.
//  Copyright © 2018年 xdag.org. All rights reserved.
//

import Foundation

// Is this really the best way to extend the lifetime of C-style strings? The lifetime
// of those passed to the String.withCString closure are only guaranteed valid during
// that call. Tried cheating this by returning the same C string from the closure but it
// gets dealloc'd almost immediately after the closure returns. This isn't terrible when
// dealing with a small number of constant C strings since you can nest closures. But
// this breaks down when it's dynamic, e.g. creating the char** argv array for an exec
// call.
class CString {
    private let _len: Int
    let buffer: UnsafeMutablePointer<Int8>
    
    init(_ string: String) {
        (_len, buffer) = string.withCString {
            let len = Int(strlen($0) + 1)
            let dst = strcpy(UnsafeMutablePointer<Int8>.allocate(capacity: len), $0)
            return (len, dst!)
        }
    }
    
    deinit {
        buffer.deallocate();
    }
}

// An array of C-style strings (e.g. char**) for easier interop.
class CStringArray {
    // Have to keep the owning CString's alive so that the pointers
    // in our buffer aren't dealloc'd out from under us.
    private let _strings: [CString]
    let pointers: [UnsafeMutablePointer<Int8>]
    
    init(_ strings: [String]) {
        _strings = strings.map { CString($0) }
        pointers = _strings.map { $0.buffer }
    }
}


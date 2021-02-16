//
//  Log.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/25.
//

import Foundation

struct Log {
    // Dictionay
    static func d(_ dict: [String: Any]) {
        #if DEBUG
        print("==============================================================")
        let order = dict.sorted(by: { $0.0 < $1.0 })
        for (key, value) in order {
            print("<\(key)>")
            if let getString = value as? String {
                print(getString.prefix(4000)) //String형태일때 길면 4000자로 짤라주자
            } else {
                print(value)
            }
        }
        print("==============================================================")
        #endif
    }
    
    // info
    static func i(_ any: Any, filename: String = #file, funcName: String = #function) {
        #if DEBUG
        print("[ℹ️][\(sourceFileName(filePath: filename))] \(funcName) -> \(any)")
        #endif
    }

    // error
    static func e(_ any: Any, filename: String = #file, funcName: String = #function) {
        #if DEBUG
        print("[⁉️][\(sourceFileName(filePath: filename))] \(funcName) -> \(any)")
        #endif
    }
    
    // osh's Log
    static func osh(_ any: Any, filename: String = #file, funcName: String = #function) {
        #if DEBUG
        print("[🐵osh][\(sourceFileName(filePath: filename))] \(funcName) -> \(any)")
        #endif
    }
    
    private static func sourceFileName(filePath: String) -> String {
       let components = filePath.components(separatedBy: "/")
       return components.isEmpty ? "" : components.last!
    }
}

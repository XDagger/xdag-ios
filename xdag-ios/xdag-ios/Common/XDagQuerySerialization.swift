//
//  XDagQuerySerialization.swift
//  xdag-ios
//
//  Created by yangyin on 2018/3/17.
//  Copyright © 2018年 xdag.org. All rights reserved.
//

import Foundation

public class XDagQuerySerialization {
    
    public static func encode(address:String, paramsDictionary dictionary: [String: String], urlEncode: Bool = true) -> String {
        
        let queryContents: [String] = dictionary.map {
            
            var key = $0.key
            var value = $0.value
            
            if urlEncode {
                key = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                value = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
            }
            
            return key + "=" + value
        }
        
        return "xdag:\(address)?\(queryContents.joined(separator: "&"))"
    }
    
    public static func decode(uriScheme:String, urlEncode: Bool = true) -> (String?, [String: String]?) {
        
        if !validateUrlScheme(uriScheme: uriScheme) {
            return (nil, nil)
        }
        var schemeString = uriScheme
        var params = [String:String]()

        
         //remove `xdag:` prefix
         schemeString.removeSubrange(schemeString.startIndex...schemeString.index(schemeString.startIndex, offsetBy: 4))
        
        if !schemeString.contains("?") {
            return (schemeString, nil)
        }
        
        let ap = schemeString.components(separatedBy: "?")
        let address = ap[0]
        let rawParams = ap[1]
        let items = rawParams.components(separatedBy: "&")
        
        for item in items {
            var kv = item.components(separatedBy: "=")
            if kv.count == 2 {
                params[kv[0]]=kv[1]
            }
        }
        
        return (address, params)

    }
    
    public static func validateUrlScheme(uriScheme:String) -> Bool {
        if uriScheme.starts(with: "xdag:") == false {
            return false
        }
        return true
    }
    
}

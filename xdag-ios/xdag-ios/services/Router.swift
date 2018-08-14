//
//  Router.swift
//  xdag-ios
//
//  Created by solar on 2018/8/14.
//  Copyright © 2018年 xdag.io. All rights reserved.
//

import UIKit
import Alamofire

enum Router: URLRequestConvertible {
    /// Returns a URL request or throws if an `Error` was encountered.
    ///
    /// - throws: An `Error` if the underlying `URLRequest` is `nil`.
    ///
    /// - returns: A URL request.
    public func asURLRequest() throws -> URLRequest {
        return self.urlRequest
    }

    
    //Restfull api
    case getBlock(address:String)
    
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getBlock:
            return .get
        default:
            return .get
        }
        
    }
    
    
    var path: String {
        switch self {
        case .getBlock(let address):
            return ServiceApi.getBlock(address: address)
        }
    }
    
    
    var urlRequest: URLRequest {
        let url =  URL(string: path)!
        var mutableURLRequest = URLRequest(url: url)
        mutableURLRequest.httpMethod = method.rawValue
        
        mutableURLRequest.setValue("1.0", forHTTPHeaderField: "appVersion")
        mutableURLRequest.setValue("iOS", forHTTPHeaderField: "appType")
        mutableURLRequest.setValue("xdag-ios", forHTTPHeaderField: "appName")

        
        switch self {
            
        default:
            return mutableURLRequest
        }
        return mutableURLRequest
    }
}


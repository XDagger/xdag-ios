//
//  ServiceApi.swift
//  xdag-ios
//
//  Created by solar on 2018/8/14.
//  Copyright © 2018年 xdag.io. All rights reserved.
//

import Foundation

import UIKit

class ServiceApi: NSObject {
    
    static var host:String = "https://explorer.xdag.io"
    
    static var userAgent = ""
    
    class func getBlock(address:String) -> String {
        let url="\(host)/api/block/\(address)"
        return url
    }
}

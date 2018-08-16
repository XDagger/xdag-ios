//
//  Util.swift
//  xdag-ios
//
//  Created by yangyin on 2018/2/28.
//  Copyright © 2018年 xdag.org. All rights reserved.
//

import UIKit

class Util: NSObject {
    
    class func GetViewController<T>(controllerName:String)->T {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let toViewController = mainStoryboard.instantiateViewController(withIdentifier: controllerName) as! T
        return toViewController
        
    }
    
    class func saveAddress(address:String,balance:String) {
        UserDefaults.standard.set(address, forKey: "xdag-address")
        UserDefaults.standard.set(balance, forKey: "xdag-balance")
        UserDefaults.standard.synchronize()
    }
    
    class func getCurrentAddress() -> String {
        if let addr = UserDefaults.standard.string(forKey: "xdag-address") {
            return addr
        }
        return ""
    }
    
    class func getCurrentBalance() -> String {
        if let balance = UserDefaults.standard.string(forKey: "xdag-balance") {
            return balance
        }
        return "0.00"
    }
}

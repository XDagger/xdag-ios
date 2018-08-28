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
    
    //MARK: - 获取IP
    class public func GetIPAddresses() -> String? {
        var addresses = [String]()
        
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while (ptr != nil) {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        
                        let name = String(cString: ptr!.pointee.ifa_name)
                        if  name == "en0" {
                            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                            if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                                if let address = String(validatingUTF8:hostname) {
                                    addresses.append(address)
                                }
                            }
                        }
                       
                        
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return addresses.first
    }
}

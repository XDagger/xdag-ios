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
}

//
//  FirstViewController.swift
//  xdag-ios
//
//  Created by yangyin on 2018/2/25.
//  Copyright © 2018年 xdag.org. All rights reserved.
//

import UIKit
import SnapKit


func charArrayToString(_ array: UnsafePointer<Int8>, capacity: Int) -> String {
    return array.withMemoryRebound(to: UInt8.self, capacity: capacity) {
        String(cString: $0)
    }
}



class HomeViewController: UIViewController {

    let passwordCallback: @convention(c) (UnsafePointer<Int8>?, UnsafeMutablePointer<Int8>?, UInt32) -> Int32 = {
        (prompt, buf, size) -> Int32 in
        
        let pass = CString("123456xdag")
        print("input pass", pass);
        strncpy(buf, pass.buffer, Int(size));
        
        return 0
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var hv:TransactionViewController = Util.GetViewController(controllerName: "transactionView")
        self.addChildViewController(hv)
        self.view.addSubview(hv.view)
        hv.view.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.view).offset(200)
            maker.leading.equalTo(self.view).offset(0)
            maker.trailing.equalTo(self.view).offset(0)
            maker.bottom.equalTo(self.view).offset(-49)

        }
        
        let home = NSHomeDirectory() as NSString
        let docPath = home.appendingPathComponent("Documents")
        
        print(docPath)
        let cs = CString(docPath)
        
        let buffer = cs.buffer
        
        var arrs:[UnsafeMutablePointer<Int8>?] = [CString(docPath).buffer, CString("-m").buffer ,CString("0").buffer, CString("cn.xdag.vspool.com:13654").buffer]

        let p = arrs.withUnsafeMutableBufferPointer{
            ( buffer: inout UnsafeMutableBufferPointer<UnsafeMutablePointer<Int8>?>) -> UnsafeMutablePointer<UnsafeMutablePointer<Int8>?> in
            return buffer.baseAddress!
        }
       
//        xdag_set_password_callback  {
//          (prompt, buf, size) -> Int32 in
//
//            let pass = CString("123456xdag")
//            print("input pass", pass);
//            strncpy(buf, pass.buffer, Int(size));
//
//            return 0
//        }
        
//        xdag_set_password_callback(passwordCallback)
//

        
        xdag_wrapper_init(nil, {
            
            (sender:UnsafeRawPointer?, event:UnsafeMutablePointer<st_xdag_event>?) -> UnsafeMutablePointer<st_xdag_app_msg>? in
            
            if let v = event?.pointee.event_type.rawValue {
//                print (String(v, radix:16))
                let eType = XdagEvent(rawValue: Int32(v))!
                print("EventType", eType)
                switch eType {
                case .en_event_xdag_log_print:
                    
                    var buffer =  event!.pointee.app_log_msg;
                    let logMsg = withUnsafeBytes(of: &buffer) { (rawPtr) -> String in
                        let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
                        return String(cString: ptr)
                    }
                    
                    print(logMsg)
                    break
                case .en_event_set_pwd:fallthrough
                case .en_event_set_rdm:fallthrough
                case .en_event_retype_pwd:fallthrough
                case .en_event_type_pwd:
                    print(eType)
                    break
                case .en_event_open_dnetfile_error:
                    var errorMsg =  event!.pointee.error_msg;
                    let error = withUnsafeBytes(of: &errorMsg) { (rawPtr) -> String in
                        let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
                        return String(cString: ptr)
                    }
                    print("error", error)
                    break;
                case .en_event_update_state:
                    var bufferAddress =  event!.pointee.address;
                    let address = withUnsafeBytes(of: &bufferAddress) { (rawPtr) -> String in
                        let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
                        return String(cString: ptr)
                    }
                    
                    print("address", address)
                    var bufferBalance =  event!.pointee.balance;
                    let balance = withUnsafeBytes(of: &bufferBalance) { (rawPtr) -> String in
                        let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
                        return String(cString: ptr)
                    }
                    print("balance", balance)
                    break;
                default:
                    break
                }
                
            }
            var msg: UnsafeMutablePointer<st_xdag_app_msg>?
            msg?.pointee.xdag_pwd = CString("123456").buffer
            msg?.pointee.xdag_rdm = CString("123456").buffer
            msg?.pointee.xdag_retype_pwd = CString("123456").buffer
            return msg
            
        })
        
        let xdagPool = CString("xdagmine.com:13654").buffer;
        xdag_main(xdagPool)
//        var test = "xdag:sadfasdf/asdfsdf3=dsfasdf?k1=v1&k2=v2"
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
   func xdag_callback(sender:UnsafeRawPointer?, event:UnsafeMutablePointer<st_xdag_event>?) -> UnsafeMutablePointer<st_xdag_app_msg>? {
        return nil;
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


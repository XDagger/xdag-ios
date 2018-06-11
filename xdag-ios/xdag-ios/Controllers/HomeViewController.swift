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

    @IBOutlet weak var labelAddress: UIButton!
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
        let cs = CString(docPath+"/xdag")
        
        let pathBuffer = cs.buffer
        
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

        xdag_init_path(pathBuffer)
        xdag_wrapper_init(nil, {
            
            (sender:UnsafeRawPointer?, event:UnsafeMutablePointer<st_xdag_event>?) -> UnsafeMutablePointer<st_xdag_app_msg>? in
            
            var msg: UnsafeMutablePointer<st_xdag_app_msg>? = UnsafeMutablePointer.allocate(capacity: MemoryLayout<st_xdag_app_msg>.size)
            
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
                case .en_event_set_pwd:
                    let passBuffer = CString("123456");
                    msg?.pointee.xdag_pwd = UnsafeMutablePointer.allocate(capacity: MemoryLayout<Int8>.size);
                    strncpy(msg?.pointee.xdag_pwd, passBuffer.buffer,
                            MemoryLayout.size(ofValue: passBuffer));
                    break;
                case .en_event_set_rdm:
                    let passBuffer = CString("123456");

                     msg?.pointee.xdag_rdm = UnsafeMutablePointer.allocate(capacity: MemoryLayout<Int8>.size)
                     strncpy(msg?.pointee.xdag_rdm, passBuffer.buffer,
                             MemoryLayout.size(ofValue: passBuffer));
                    break;
                case .en_event_retype_pwd:
                    let passBuffer = CString("123456");

                     msg?.pointee.xdag_retype_pwd = UnsafeMutablePointer.allocate(capacity: MemoryLayout<Int8>.size)
                     strncpy(msg?.pointee.xdag_retype_pwd, passBuffer.buffer,
                             MemoryLayout.size(ofValue: passBuffer));
                    break;
                case .en_event_type_pwd:
                    let passBuffer = CString("123456");
                    msg?.pointee.xdag_pwd = UnsafeMutablePointer.allocate(capacity: MemoryLayout<Int8>.size);
                    strncpy(msg?.pointee.xdag_pwd, passBuffer.buffer,
                            MemoryLayout.size(ofValue: passBuffer));
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
                    
//                    self.labelAddress.titleLabel?.text  = address;
                    var bufferBalance =  event!.pointee.balance;
                    let balance = withUnsafeBytes(of: &bufferBalance) { (rawPtr) -> String in
                        let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
                        return String(cString: ptr)
                    }
                    print("balance", balance)
                    
                    let notificationName = Notification.Name(rawValue: "updateXdagState")
                    NotificationCenter.default.post(name: notificationName, object: nil,
                                                    userInfo: ["address":address, "balance" : balance])
                    
                    break;
                default:
                    break
                }
                
            }
            
            return msg
            
        })
        
        let xdagPool = CString("xdagmine.com:13654").buffer;
        xdag_main(xdagPool)
//        var test = "xdag:sadfasdf/asdfsdf3=dsfasdf?k1=v1&k2=v2"
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func registerNotify() {
        let notificationName = Notification.Name(rawValue: "updateXdagState")
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(updateXdagState(notification:)),
                                               name: notificationName, object: nil)
    }
    
    var address:String?
    
    @objc func updateXdagState(notification: Notification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let address = userInfo["address"] as! String
        let balance = userInfo["balance"] as! String
        print("updateXdagState: \(address):\(balance)")
        self.address = address;
//        self.labelAddress.titleLabel?.text = address;
        
//        DispatchQueue.global().async {
//            DispatchQueue.main.async {
//                 [unowned self] in
//                self.labelAddress.titleLabel?.text = self.address;
//            }
//        }
        
//        DispatchQueue.main.async {
//            
//          self.labelAddress.titleLabel?.text = self.address;
//        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        registerNotify();

    }
    override func viewDidDisappear(_ animated: Bool) {
         NotificationCenter.default.removeObserver(self)
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


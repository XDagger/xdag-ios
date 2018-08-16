//
//  FirstViewController.swift
//  xdag-ios
//
//  Created by solar on 2018/2/25.
//  Copyright © 2018年 xdag.io. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import SwiftyJSON


func charArrayToString(_ array: UnsafePointer<Int8>, capacity: Int) -> String {
    return array.withMemoryRebound(to: UInt8.self, capacity: capacity) {
        String(cString: $0)
    }
}



class HomeViewController: UIViewController {
    
    @IBOutlet weak var labelBalance: UILabel!
    
    @IBOutlet weak var labelAddress: UILabel!
    
    var hv:TransactionViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hv = Util.GetViewController(controllerName: "transactionView")
        self.addChildViewController(hv)
        self.view.addSubview(hv.view)
        hv.view.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.view).offset(200)
            maker.leading.equalTo(self.view).offset(0)
            maker.trailing.equalTo(self.view).offset(0)
            maker.bottom.equalTo(self.view).offset(-49)
            
        }
   
        
//        DispatchQueue.global(qos: .default).async {
//            [unowned self] in
//            self.initWallet()
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.presentPasswordVC()
    }
    
    func presentPasswordVC() {
        let pvc:PasswordViewController = Util.GetViewController(controllerName: "passwordViewController")
        pvc.modalPresentationStyle = .overCurrentContext
        self.present(pvc, animated: true, completion: nil)
    }
    
    
    var pool:CString? = nil
    
    func initWallet() {
        
        let home = NSHomeDirectory() as NSString
        let docPath = home.appendingPathComponent("Documents")
        
        print(docPath)
        let cs = CString(docPath+"/xdag")
        let pathBuffer = cs.buffer
        
        xdag_init_path(pathBuffer)
        
        
        var msg: UnsafeMutablePointer<st_xdag_app_msg>? =  UnsafeMutablePointer.allocate(capacity: MemoryLayout<st_xdag_app_msg>.size)
        //
        print("msg",msg)
        
        xdag_wrapper_init(msg, {
            
            (sender:UnsafeRawPointer?, event:UnsafeMutablePointer<st_xdag_event>?) -> UnsafeMutablePointer<st_xdag_app_msg>? in
            
            let msg = UnsafeMutablePointer<st_xdag_app_msg>.init(OpaquePointer(sender))
            //            var msg: UnsafeMutablePointer<st_xdag_app_msg>? =  UnsafeMutablePointer.allocate(capacity: MemoryLayout<st_xdag_app_msg>.size)
            
            if let v = event?.pointee.event_type.rawValue {
                //                print (String(v, radix:16))
                let eType = XdagEvent(rawValue: Int32(v))!
                print("EventType", eType)
                switch eType {
                case .en_event_xdag_log_print:
                    
                    var buffer =  event!.pointee.app_log_msg;
                    let logMsg = withUnsafeBytes(of: &buffer) { (rawPtr) -> String in
                        let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
                        let ret = String(cString: ptr)
                        //                        ptr.deallocate()
                        return ret;
                    }
                    
                    print(logMsg)
                    break
                case .en_event_set_pwd:
                    
                    var passBuffer:CString? = CString("123456");
                    
                    msg?.pointee.xdag_pwd = UnsafeMutablePointer.allocate(capacity: MemoryLayout<Int8>.size);
                    strncpy(msg?.pointee.xdag_pwd, passBuffer!.buffer,
                            MemoryLayout.size(ofValue: passBuffer));
                    passBuffer = nil
                    return msg
                    break;
                case .en_event_set_rdm:
                    
                    
                    var passBuffer:CString? = CString("123456");
                    
                    msg?.pointee.xdag_rdm = UnsafeMutablePointer.allocate(capacity: MemoryLayout<Int8>.size)
                    strncpy(msg?.pointee.xdag_rdm, passBuffer!.buffer,
                            MemoryLayout.size(ofValue: passBuffer));
                    passBuffer = nil
                    return msg
                    
                    break;
                case .en_event_retype_pwd:
                    
                    
                    var passBuffer:CString? = CString("123456");
                    
                    msg?.pointee.xdag_retype_pwd = UnsafeMutablePointer.allocate(capacity: MemoryLayout<Int8>.size)
                    strncpy(msg?.pointee.xdag_retype_pwd, passBuffer!.buffer,
                            MemoryLayout.size(ofValue: passBuffer));
                    passBuffer = nil
                    return msg
                    
                    break;
                case .en_event_type_pwd:
                    
                    
                    var passBuffer:CString? = CString("123456");
                    msg?.pointee.xdag_pwd = UnsafeMutablePointer.allocate(capacity: MemoryLayout<Int8>.size);
                    strncpy(msg?.pointee.xdag_pwd, passBuffer!.buffer,
                            MemoryLayout.size(ofValue: passBuffer));
                    passBuffer = nil
                    return msg
                    
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
                    
                    print("en_event_update_state:")
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
                    DispatchQueue.global(qos: .background).async {
                        let notificationName = Notification.Name(rawValue: "updateXdagState")
                        NotificationCenter.default.post(name: notificationName, object: nil,userInfo: ["address":address, "balance" : balance])
                    }
                    //
                    return nil
                    break;
                default:
                    break
                }
                
            }
            
            return nil
            
        })
        
        pool = CString("xdagmine.com:13654");
        xdag_main(pool!.buffer)
    }
    
    
    func registerNotify() {
        let notificationName = Notification.Name(rawValue: "updateXdagState")
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(updateXdagState(notification:)),
                                               name: notificationName, object: nil)
    }
    
    var address:String?
    var balance:String?
    
    @objc func updateXdagState(notification: Notification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let address = userInfo["address"] as! String
        let balance = userInfo["balance"] as! String
        print("updateXdagState: \(address):\(balance)")
        
        //        self.labelAddress.titleLabel?.text = address;
        if(self.address == address && self.balance == balance) {
            return
        }
        self.address = address;
        self.balance = balance
        
        DispatchQueue.global(qos: .background).async {
            
            DispatchQueue.main.async {
                [unowned self] in
                self.labelAddress.text = self.address!
                self.labelBalance.text = self.balance!
                if(self.address != "Not ready") {
                    self.loadTransactions(address: self.address!)
                    
                }
                
            }
        }
        
        //        DispatchQueue.main.async {
        //
        //          self.labelAddress.titleLabel?.text = self.address;
        //        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        registerNotify();
        let notificationName = Notification.Name(rawValue: "updateXdagState")
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadTransactions(address: String) {
        
        Alamofire.request(Router.getBlock(address: address)).responseJSON {
            res in
            
            if res.result.isFailure {
                let alertController = UIAlertController(title: "网络", message: "请检查网络设置", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
                let okAction = UIAlertAction(title: "好的", style: UIAlertActionStyle.default, handler: nil)
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            let json = res.result.value
//            print(json)
            let result = JSON(json!)
            
            if result["state"].stringValue == "Accepted" {
                
                let items = result["block_as_address"].array
                
                var index = 0
                
                var list:[XDAGTransaction] = []
                for it in items! {
                    if(index > 100) {
                        break
                    }
                    let txType = it["direction"].stringValue == "input" ? 1: 0
                    var tx = XDAGTransaction(txHash: it["address"].stringValue,txType:txType,txAmount:it["amount"].stringValue,txTime: it["time"].stringValue)
                    list.append(tx)
                    index = index + 1;
                }
                
                DispatchQueue.main.async {
                    self.hv.items = list;
                    self.hv.tableView.reloadData()
                }
            }
            
        }
        
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


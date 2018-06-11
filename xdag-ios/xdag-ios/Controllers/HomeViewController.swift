//
//  FirstViewController.swift
//  xdag-ios
//
//  Created by yangyin on 2018/2/25.
//  Copyright © 2018年 xdag.org. All rights reserved.
//

import UIKit
import SnapKit

enum xdagEvent: Int {
    /**
     * xdag event type start
     * */
   case en_event_type_pwd               = 0x1000;
   case en_event_set_pwd                = 0x1001;
   case en_event_retype_pwd             = 0x1002;
   case en_event_set_rdm                = 0x1003;
   case en_event_pwd_not_same           = 0x1004;
   case en_event_pwd_error              = 0x1005;
   case en_event_pwd_format_error       = 0x1006;
    
   case en_event_open_dnetfile_error    = 0x2000;
   case en_event_open_walletfile_error  = 0x2001;
   case en_event_load_storage_error     = 0x2002;
   case en_event_write_dnet_file_error  = 0x2003;
   case en_event_add_trust_host_error   = 0x2004;
    
  case  en_event_nothing_transfer       = 0x3000;
   case en_event_balance_too_small      = 0x3001;
   case en_event_invalid_recv_address   = 0x3002;
  case  en_event_xdag_transfered        = 0x3003;
    
   case en_event_connect_pool_timeout   = 0x4000;
   case en_event_make_block_error       = 0x4001;
    
   case en_event_xdag_log_print         = 0x5000;
  case  en_event_update_progress        = 0x5001;
  case  en_event_update_state           = 0x5002;
    
   case en_event_cannot_create_block    = 0x7000;
   case en_event_cannot_find_block      = 0x7001;
   case en_event_cannot_load_block      = 0x7002;
   case en_event_cannot_create_socket   = 0x7003;
  case  en_event_host_is_not_given      = 0x7004;
 case   en_event_cannot_reslove_host    = 0x7005;
  case  en_event_port_is_not_given      = 0x7006;
  case  en_event_cannot_connect_to_pool = 0x7007;
   case en_event_socket_isclosed        = 0x7008;
   case en_event_socket_hangup          = 0x7009;
   case en_event_socket_error           = 0x700a;
  case  en_event_read_socket_error      = 0x700b;
  case  en_event_write_socket_error     = 0x700c;
  case  en_event_unkown                 = 0xf000;
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
                print (String(v, radix:16))
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


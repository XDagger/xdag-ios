//
//  SendTransactionController.swift
//  xdag-ios
//
//  Created by yangyin on 2018/3/17.
//  Copyright © 2018年 xdag.org. All rights reserved.
//

import UIKit

class SendTransactionController: UIViewController {

    @IBOutlet weak var availabelBalance: UILabel!
    @IBOutlet weak var txtToAddress: UITextField!
    
    
    @IBOutlet weak var txtAmount: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.availabelBalance.text = Util.getCurrentBalance()
       
        // Do any additional setup after loading the view.
    }

    @IBAction func scanBtnClicked(_ sender: Any) {
        AppPermissions.authorizeCameraWith { (authorized) in
            if authorized {
                let scanViewController:ScanViewController = Util.GetViewController(controllerName: "scanViewController")
                scanViewController.scanSuccessDelegate = self
                self.navigationController?.pushViewController(scanViewController, animated: true)
            } else {
                let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    AppPermissions.jumpToSystemSetting()
                })
                let ac = UIAlertController(title:"Camera access", message: "Camera access was denied: open the settings app to change privacy settings", preferredStyle: UIAlertControllerStyle.alert)
                ac.addAction(action)
                self.present(ac, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func sendXdagClicked(_ sender: Any) {
    
        let sendTo = self.txtToAddress.text
        let txtAmount = self.txtAmount.text
        if let to = sendTo, let money = txtAmount  {
            let amount = Double(money)
            if amount! <= 0.0 {
                self.noticeOnlyText("Invalid Amount to Send")
                return;
            }
            
            if to.count < 10 {
                self.noticeOnlyText("Invalid Address to Send")
                return;
            }
            self.pleaseWait()
            let sendTo = CString(sendTo!)
            let toAmount = CString(txtAmount!)
            xdag_send_coin(toAmount.buffer, sendTo.buffer)
        }
    }
    
    func registerNotify() {
        let notificationName = Notification.Name(rawValue: "updateXdagState")
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(updateXdagXferState(notification:)),
                                               name: notificationName, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        registerNotify();
        self.availabelBalance.text = Util.getCurrentBalance()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)

    }
    
    func alertXferMsg(type:String, msg:String) {
        if type != "xdag_transfered" {
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            
            DispatchQueue.main.async {
                [unowned self] in
                self.clearAllNotice()
                if msg == "success" {
                    self.noticeSuccess("xfer success!")
                    self.txtAmount.text = ""
                    self.txtToAddress.text = ""
                } else {
                    self.noticeOnlyText(msg)
                }
                
            }
        }
    }
    
    
    @objc func updateXdagXferState(notification: Notification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        
        let type = userInfo["type"] as! String
        
        if type != "xdag_transfered" {
            return
        }
        
        let msg = userInfo["msg"] as! String

        self.alertXferMsg(type:type,msg:msg)
       
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SendTransactionController: ScanXDagQRCodeResultDelegate {
    func scanSuccess(_ address: String, withParams params: [String : String]?) {
        txtToAddress.text = address
        if params != nil  {
           txtAmount.text = params!["amount"]
        }
    }
    
    
}

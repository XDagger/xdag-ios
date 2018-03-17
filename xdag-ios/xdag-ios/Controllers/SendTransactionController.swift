//
//  SendTransactionController.swift
//  xdag-ios
//
//  Created by yangyin on 2018/3/17.
//  Copyright © 2018年 xdag.org. All rights reserved.
//

import UIKit

class SendTransactionController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func scanBtnClicked(_ sender: Any) {
        AppPermissions.authorizeCameraWith { (authorized) in
            if authorized {
                let scanViewController:ScanViewController = Util.GetViewController(controllerName: "scanViewController")
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

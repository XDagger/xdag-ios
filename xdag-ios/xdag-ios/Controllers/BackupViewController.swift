//
//  BackupViewController.swift
//  xdag-ios
//
//  Created by yangyin on 2018/8/26.
//  Copyright © 2018年 xdag.org. All rights reserved.
//

import UIKit
import Telegraph

class BackupViewController: UIViewController {

    var httpServer:Server!
    
    @IBOutlet weak var httpUrlLabel: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        let reachability = Reachability()!
        if (reachability.connection == .wifi) {
            initHttpServer()
        }
        // Do any additional setup after loading the view.
    }

    
    @IBAction func copyUrl(_ sender: Any) {
        UIPasteboard.general.string = httpUrlLabel.titleLabel?.text
        self.noticeSuccess("copy success!", autoClear: true,autoClearTime:1)
    }
    func initHttpServer() {
        httpServer = Server()
        let documentsDirectory = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)[0]
        httpServer.serveDirectory(documentsDirectory)
        try! httpServer.start(onPort: 8099)
        
        httpUrlLabel.setTitle("http://\(Util.GetIPAddresses()!):\(httpServer.port)/wallet.zip", for: UIControlState.normal)
    }
    
    @IBAction func closeView(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        if (httpServer != nil) {
            httpServer.stop()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
        
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
